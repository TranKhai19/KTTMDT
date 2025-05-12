using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net.Mail;
using System.IO;
using System.Net;

namespace ToyShop.User
{
    public partial class Payment : System.Web.UI.Page
    {
        SqlConnection con;
        SqlCommand cmd;
        SqlDataReader dr, dr1;
        DataTable dt;
        SqlTransaction transaction = null;
        string _name = string.Empty; string _cardNo = string.Empty; string _expiryDate = string.Empty; string _cvv = string.Empty;
        string _address = string.Empty; string _paymentMode = string.Empty;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["userId"] == null)
                {
                    Response.Redirect("Login.aspx");
                }
            }
        }

        protected void lbCardSubmit_Click(object sender, EventArgs e)
        {
            _name = txtName.Text.Trim();
            _cardNo = txtCardNo.Text.Trim();
            _cardNo = string.Format("************{0}", txtCardNo.Text.Trim().Substring(12, 4));
            _expiryDate = txtExpMonth.Text.Trim() + "/" + txtExpYear.Text.Trim();
            _cvv = txtCvv.Text.Trim();
            _address = txtAddress.Text.Trim();
            _paymentMode = "card";

            if (Session["userId"] != null)
            {
                OrderPayment(_name, _cardNo, _expiryDate, _cvv, _address, _paymentMode);
            }
            else
            {
                Response.Redirect("Login.aspx");
            }
        }

        protected void lbCodSubmit_Click(object sender, EventArgs e)
        {
            _address = txtCODAddress.Text.Trim();
            _paymentMode = "cod";

            if (Session["userId"] != null)
            {
                OrderPayment(_name, _cardNo, _expiryDate, _cvv, _address, _paymentMode);
            }
            else
            {
                Response.Redirect("Login.aspx");
            }
        }

        bool CheckStock(out string errorMessage)
        {
            errorMessage = string.Empty;
            try
            {
                using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("Cart_Crud", con))
                    {
                        cmd.Parameters.AddWithValue("@Action", "SELECT");
                        cmd.Parameters.AddWithValue("@UserId", Session["userId"]);
                        cmd.CommandType = CommandType.StoredProcedure;
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            List<(int ProductId, int Quantity, string ProductName)> cartItems = new List<(int, int, string)>();
                            while (dr.Read())
                            {
                                cartItems.Add(((int)dr["ProductId"], (int)dr["Quantity"], dr["Name"].ToString()));
                            }
                            dr.Close();

                            foreach (var item in cartItems)
                            {
                                try
                                {
                                    using (SqlCommand cmd2 = new SqlCommand("Product_Crud", con))
                                    {
                                        cmd2.Parameters.AddWithValue("@Action", "GETBYID");
                                        cmd2.Parameters.AddWithValue("@ProductId", item.ProductId);
                                        cmd2.CommandType = CommandType.StoredProcedure;
                                        using (SqlDataReader dr1 = cmd2.ExecuteReader())
                                        {
                                            if (!dr1.Read())
                                            {
                                                errorMessage = $"Sản phẩm '{item.ProductName}' (ID: {item.ProductId}) không tồn tại hoặc không hoạt động.";
                                                return false;
                                            }
                                            int availableQuantity = (int)dr1["Quantity"];
                                            if (availableQuantity < item.Quantity)
                                            {
                                                errorMessage = $"Sản phẩm '{item.ProductName}' (ID: {item.ProductId}) không đủ tồn kho. Còn lại: {availableQuantity}, yêu cầu: {item.Quantity}.";
                                                return false;
                                            }
                                        }
                                    }
                                }
                                catch (SqlException ex) when (ex.Number == 50000) // RAISERROR từ SQL Server
                                {
                                    errorMessage = $"Sản phẩm '{item.ProductName}' (ID: {item.ProductId}) {ex.Message}";
                                    return false;
                                }
                            }
                        }
                    }
                    return true;
                }
            }
            catch (Exception ex)
            {
                errorMessage = "Lỗi khi kiểm tra tồn kho: " + ex.Message;
                string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                Directory.CreateDirectory(Path.GetDirectoryName(logPath));
                File.AppendAllText(logPath, DateTime.Now + ": CheckStock - " + ex.Message + "\n");
                return false;
            }
        }

        void OrderPayment(string name, string cardNo, string expiryDate, string cvv, string address, string paymentMode)
        {
            int paymentId;
            dt = new DataTable();
            dt.Columns.AddRange(new DataColumn[7] {
        new DataColumn("OrderNo", typeof(string)),
        new DataColumn("ProductId", typeof(int)),
        new DataColumn("Quantity", typeof(int)),
        new DataColumn("UserId", typeof(int)),
        new DataColumn("Status", typeof(string)),
        new DataColumn("PaymentId", typeof(int)),
        new DataColumn("OrderDate", typeof(DateTime)),


    });

            string errorMessage;
            if (!CheckStock(out errorMessage))
            {
                lblMsg.Visible = true;
                lblMsg.Text = errorMessage;
                lblMsg.CssClass = "alert alert-danger";
                return;
            }

            con = new SqlConnection(Connection.GetConnectionString());
            try
            {
                con.Open();
                transaction = con.BeginTransaction();

                // Lấy OrderId
                int orderId;
                try
                {
                    orderId = GetOrderId();
                }
                catch (Exception ex)
                {
                    lblMsg.Visible = true;
                    lblMsg.Text = "Lỗi khi lấy OrderId: " + ex.Message;
                    lblMsg.CssClass = "alert alert-danger";
                    return;
                }

                // Lấy Amount
                decimal amount;
                try
                {
                    amount = Convert.ToDecimal(Session["grandTotalPrice"] ?? 0);
                    if (amount <= 0)
                    {
                        throw new Exception("Số tiền thanh toán không hợp lệ.");
                    }
                }
                catch (Exception ex)
                {
                    lblMsg.Visible = true;
                    lblMsg.Text = "Lỗi khi lấy số tiền: " + ex.Message;
                    lblMsg.CssClass = "alert alert-danger";
                    return;
                }

                // Xác thực dữ liệu đầu vào
                if (paymentMode == "card")
                {
                    if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(cardNo) || string.IsNullOrEmpty(expiryDate) || string.IsNullOrEmpty(cvv))
                    {
                        lblMsg.Visible = true;
                        lblMsg.Text = "Vui lòng nhập đầy đủ thông tin thẻ.";
                        lblMsg.CssClass = "alert alert-danger";
                        return;
                    }
                    if (!System.Text.RegularExpressions.Regex.IsMatch(cvv, @"^\d{3,4}$"))
                    {
                        lblMsg.Visible = true;
                        lblMsg.Text = "Mã CVV không hợp lệ. Vui lòng nhập 3 hoặc 4 chữ số.";
                        lblMsg.CssClass = "alert alert-danger";
                        return;
                    }
                }
                else if (paymentMode != "cod")
                {
                    lblMsg.Visible = true;
                    lblMsg.Text = "Phương thức thanh toán không hợp lệ.";
                    lblMsg.CssClass = "alert alert-danger";
                    return;
                }

                // Lưu thông tin thanh toán
                using (SqlCommand cmd = new SqlCommand("Save_Payment", con, transaction))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@OrderId", orderId);
                    cmd.Parameters.AddWithValue("@Name", string.IsNullOrEmpty(name) ? (object)DBNull.Value : name);
                    cmd.Parameters.AddWithValue("@CardNo", string.IsNullOrEmpty(cardNo) ? (object)DBNull.Value : cardNo);
                    cmd.Parameters.AddWithValue("@ExpiryDate", string.IsNullOrEmpty(expiryDate) ? (object)DBNull.Value : expiryDate);
                    cmd.Parameters.AddWithValue("@CvvNo", paymentMode == "cod" ? (object)DBNull.Value : cvv);
                    cmd.Parameters.AddWithValue("@Address", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address);
                    cmd.Parameters.AddWithValue("@PaymentMethod", paymentMode);
                    cmd.Parameters.AddWithValue("@Amount", amount);
                    cmd.Parameters.AddWithValue("@PaymentStatus", "PENDING");
                    cmd.Parameters.Add("@InsertedId", SqlDbType.Int).Direction = ParameterDirection.Output;

                    string logParams = $"OrderPayment: OrderId={orderId}, Name={name}, CardNo={cardNo}, ExpiryDate={expiryDate}, CvvNo={(paymentMode == "cod" ? "NULL" : cvv)}, Address={address}, PaymentMethod={paymentMode}, Amount={amount}";
                    File.AppendAllText(Path.Combine(Server.MapPath("~/Logs"), "params.log"), DateTime.Now + ": " + logParams + "\n");

                    cmd.ExecuteNonQuery();
                    paymentId = Convert.ToInt32(cmd.Parameters["@InsertedId"].Value);
                }

                // Lấy dữ liệu giỏ hàng
                List<(int ProductId, int Quantity, string ProductName)> cartItems = new List<(int, int, string)>();
                using (SqlCommand cmd = new SqlCommand("Cart_Crud", con, transaction))
                {
                    cmd.Parameters.AddWithValue("@Action", "SELECT");
                    cmd.Parameters.AddWithValue("@UserId", Session["userId"]);
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            cartItems.Add(((int)dr["ProductId"], (int)dr["Quantity"], dr["Name"].ToString()));
                        }
                    }
                }

                // Xử lý cập nhật số lượng và xóa giỏ hàng
                foreach (var item in cartItems)
                {
                    try
                    {
                        UpdateQuantity(item.ProductId, item.Quantity, transaction, con);
                        DeleteCartItem(item.ProductId, transaction, con);
                        dt.Rows.Add(Utils.GetUniqueId(), item.ProductId, item.Quantity, Convert.ToInt32(Session["userId"]), "Pending", paymentId, DateTime.Now);
                    }
                    catch (Exception ex)
                    {
                        transaction?.Rollback();
                        lblMsg.Visible = true;
                        lblMsg.Text = $"Lỗi khi xử lý sản phẩm '{item.ProductName}' (ID: {item.ProductId}): {ex.Message}";
                        lblMsg.CssClass = "alert alert-danger";
                        string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                        Directory.CreateDirectory(Path.GetDirectoryName(logPath));
                        File.AppendAllText(logPath, DateTime.Now + ": OrderPayment (Cart Processing) - " + ex.Message + "\n" + ex.StackTrace + "\n");
                        return;
                    }
                }

                // Lưu chi tiết đơn hàng
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        using (SqlCommand cmd = new SqlCommand("Invoices", con, transaction))
                        {
                            cmd.Parameters.AddWithValue("@Action", "INSERT");
                            cmd.Parameters.AddWithValue("@OrderNo", row["OrderNo"]);
                            cmd.Parameters.AddWithValue("@ProductId", row["ProductId"]);
                            cmd.Parameters.AddWithValue("@Quantity", row["Quantity"]);
                            cmd.Parameters.AddWithValue("@UserId", row["UserId"]);
                            cmd.Parameters.AddWithValue("@Status", row["Status"]);
                            cmd.Parameters.AddWithValue("@PaymentId", row["PaymentId"]);
                            cmd.Parameters.AddWithValue("@OrderDate", row["OrderDate"]);
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.ExecuteNonQuery();
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand("INSERT INTO OrderNotifications (OrderDetailsId, PaymentId, UserId, NotificationType, CreatedDate) " +
                                                         "SELECT MAX(OrderDetailsId), @PaymentId, @UserId, 'NewOrder', GETDATE() FROM Orders", con, transaction))
                    {
                        cmd.Parameters.AddWithValue("@PaymentId", paymentId);
                        cmd.Parameters.AddWithValue("@UserId", Convert.ToInt32(Session["userId"]));
                        cmd.ExecuteNonQuery();
                    }
                }

                transaction.Commit();
                lblMsg.Visible = true;
                lblMsg.Text = "Đơn hàng của bạn đã được đặt thành công!!!";
                lblMsg.CssClass = "alert alert-success";
                Response.AddHeader("REFRESH", "1;URL=Invoice.aspx?id=" + paymentId);
            }
            catch (Exception ex)
            {
                try
                {
                    transaction?.Rollback();
                    string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                    Directory.CreateDirectory(Path.GetDirectoryName(logPath));
                    File.AppendAllText(logPath, DateTime.Now + ": OrderPayment - " + ex.Message + "\n" + ex.StackTrace + "\n");
                }
                catch (Exception rollbackEx)
                {
                    string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                    Directory.CreateDirectory(Path.GetDirectoryName(logPath));
                    File.AppendAllText(logPath, DateTime.Now + ": Rollback failed - " + rollbackEx.Message + "\n");
                }
                lblMsg.Visible = true;
                lblMsg.Text = "Lỗi khi xử lý đơn hàng: " + ex.Message;
                lblMsg.CssClass = "alert alert-danger";
            }
            finally
            {
                con.Close();
            }
        }

        private int GetOrderId()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO Orders (UserId, OrderDate) OUTPUT INSERTED.OrderDetailsId VALUES (@UserId, GETDATE())", con))
                    {
                        if (Session["userId"] == null)
                        {
                            throw new Exception("UserId không tồn tại.");
                        }
                        cmd.Parameters.AddWithValue("@UserId", Convert.ToInt32(Session["userId"]));
                        int orderId = (int)cmd.ExecuteScalar();
                        return orderId;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Không thể tạo OrderId: " + ex.Message);
            }
        }

        void UpdateQuantity(int _productId, int _quantity, SqlTransaction sqlTransaction, SqlConnection sqlConnection)
        {
            try
            {
                int dbQuantity;
                using (SqlCommand cmd = new SqlCommand("SELECT Quantity FROM Products WITH (UPDLOCK) WHERE ProductId = @ProductId AND IsActive = 1", sqlConnection, sqlTransaction))
                {
                    cmd.Parameters.AddWithValue("@ProductId", _productId);
                    using (SqlDataReader dr1 = cmd.ExecuteReader())
                    {
                        if (dr1.Read())
                        {
                            dbQuantity = (int)dr1["Quantity"];
                        }
                        else
                        {
                            // Kiểm tra xem sản phẩm có tồn tại nhưng không hoạt động không
                            dr1.Close();
                            using (SqlCommand checkCmd = new SqlCommand("SELECT 1 FROM Products WHERE ProductId = @ProductId", sqlConnection, sqlTransaction))
                            {
                                checkCmd.Parameters.AddWithValue("@ProductId", _productId);
                                var exists = checkCmd.ExecuteScalar();
                                if (exists != null)
                                {
                                    throw new Exception($"Sản phẩm {_productId} không hoạt động.");
                                }
                                else
                                {
                                    throw new Exception($"Không tìm thấy sản phẩm {_productId}.");
                                }
                            }
                        }
                    }
                }

                if (dbQuantity >= _quantity)
                {
                    using (SqlCommand cmd = new SqlCommand("UPDATE Products SET Quantity = Quantity - @Quantity WHERE ProductId = @ProductId", sqlConnection, sqlTransaction))
                    {
                        cmd.Parameters.AddWithValue("@Quantity", _quantity);
                        cmd.Parameters.AddWithValue("@ProductId", _productId);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    throw new Exception($"Sản phẩm {_productId} không đủ tồn kho. Còn lại: {dbQuantity}, yêu cầu: {_quantity}.");
                }
            }
            catch (Exception ex)
            {
                string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                Directory.CreateDirectory(Path.GetDirectoryName(logPath));
                File.AppendAllText(logPath, DateTime.Now + ": UpdateQuantity - " + ex.Message + "\n");
                throw;
            }
        }

        void DeleteCartItem(int _productId, SqlTransaction sqlTransaction, SqlConnection sqlConnection)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand("Cart_Crud", sqlConnection, sqlTransaction))
                {
                    cmd.Parameters.AddWithValue("@Action", "DELETE");
                    cmd.Parameters.AddWithValue("@ProductId", _productId);
                    cmd.Parameters.AddWithValue("@UserId", Convert.ToInt32(Session["userId"]));
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                Directory.CreateDirectory(Path.GetDirectoryName(logPath));
                File.AppendAllText(logPath, DateTime.Now + ": DeleteCartItem - " + ex.Message + "\n");
                throw;
            }
        }           
    }
}