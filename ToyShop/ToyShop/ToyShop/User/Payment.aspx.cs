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

        bool CheckStock()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                {
                    con.Open();
                    cmd = new SqlCommand("Cart_Crud", con);
                    cmd.Parameters.AddWithValue("@Action", "SELECT");
                    cmd.Parameters.AddWithValue("@UserId", Session["userId"]);
                    cmd.CommandType = CommandType.StoredProcedure;
                    dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        int productId = (int)dr["ProductId"];
                        int quantity = (int)dr["Quantity"];
                        dr.Close();
                        cmd = new SqlCommand("Product_Crud", con);
                        cmd.Parameters.AddWithValue("@Action", "GETBYID");
                        cmd.Parameters.AddWithValue("@ProductId", productId);
                        cmd.CommandType = CommandType.StoredProcedure;
                        dr1 = cmd.ExecuteReader();
                        if (dr1.Read() && (int)dr1["Quantity"] < quantity)
                        {
                            dr1.Close();
                            con.Close();
                            return false;
                        }
                        dr1.Close();
                        break; // Thoát vòng lặp sau khi kiểm tra xong sản phẩm đầu tiên
                    }
                    con.Close();
                    return true;
                }
            }
            catch (Exception ex)
            {
                string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                Directory.CreateDirectory(Path.GetDirectoryName(logPath)); // Tạo thư mục Logs nếu chưa tồn tại
                File.AppendAllText(logPath, DateTime.Now + ": CheckStock - " + ex.Message + "\n");
                return false;
            }
        }

        void OrderPayment(string name, string cardNo, string expiryDate, string cvv, string address, string paymentMode)
        {
            int paymentId; int productId; int quantity;
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

            if (!CheckStock())
            {
                lblMsg.Visible = true;
                lblMsg.Text = "Một số sản phẩm không đủ tồn kho.";
                lblMsg.CssClass = "alert alert-danger";
                return;
            }

            con = new SqlConnection(Connection.GetConnectionString());
            con.Open();
            transaction = con.BeginTransaction();
            cmd = new SqlCommand("Save_Payment", con, transaction);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Name", string.IsNullOrEmpty(name) ? DBNull.Value : name);
            cmd.Parameters.AddWithValue("@CardNo", string.IsNullOrEmpty(cardNo) ? DBNull.Value : cardNo);
            cmd.Parameters.AddWithValue("@ExpiryDate", string.IsNullOrEmpty(expiryDate) ? DBNull.Value : expiryDate);
            cmd.Parameters.AddWithValue("@CvvNo", paymentMode == "cod" ? DBNull.Value : (int.TryParse(cvv, out int cvvNo) ? cvvNo : DBNull.Value));
            cmd.Parameters.AddWithValue("@Address", string.IsNullOrEmpty(address) ? DBNull.Value : address);
            cmd.Parameters.AddWithValue("@PaymentMode", paymentMode);
            cmd.Parameters.Add("@InsertedId", SqlDbType.Int);
            cmd.Parameters["@InsertedId"].Direction = ParameterDirection.Output;
            try
            {
                cmd.ExecuteNonQuery();
                paymentId = Convert.ToInt32(cmd.Parameters["@InsertedId"].Value);

                #region Getting Cart Item's
                cmd = new SqlCommand("Cart_Crud", con, transaction);
                cmd.Parameters.AddWithValue("@Action", "SELECT");
                cmd.Parameters.AddWithValue("@UserId", Session["userId"]);
                cmd.CommandType = CommandType.StoredProcedure;
                dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    productId = (int)dr["ProductId"];
                    quantity = (int)dr["Quantity"];
                    UpdateQuantity(productId, quantity, transaction, con);
                    DeleteCartItem(productId, transaction, con);
                    dt.Rows.Add(Utils.GetUniqueId(), productId, quantity, (int)Session["userId"], "Pending",
                        paymentId, Convert.ToDateTime(DateTime.Now));
                }
                dr.Close();
                #endregion Getting Cart Item's

                #region Order Details
                if (dt.Rows.Count > 0)
                {
                    string logPath = Path.Combine(Server.MapPath("~/Logs"), "order.log");
                    Directory.CreateDirectory(Path.GetDirectoryName(logPath)); // Tạo thư mục Logs nếu chưa tồn tại
                    File.AppendAllText(logPath,
                        DateTime.Now + ": " + string.Join(",", dt.Rows.Cast<DataRow>().Select(r => r["OrderNo"])) + "\n");

                    foreach (DataRow row in dt.Rows)
                    {
                        cmd = new SqlCommand("Invoices", con, transaction);
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

                    cmd = new SqlCommand("INSERT INTO OrderNotifications (OrderDetailsId, PaymentId, UserId, NotificationType, CreatedDate) " +
                                         "SELECT MAX(OrderDetailsId), @PaymentId, @UserId, 'NewOrder', GETDATE() FROM Orders", con, transaction);
                    cmd.Parameters.AddWithValue("@PaymentId", paymentId);
                    cmd.Parameters.AddWithValue("@UserId", Session["userId"]);
                    cmd.ExecuteNonQuery();
                }
                #endregion Order Details

                transaction.Commit();
                lblMsg.Visible = true;
                lblMsg.Text = "Your Item Ordered Successfully!!!";
                lblMsg.CssClass = "alert alert-success";

                //// Gửi email thông báo cho Admin
                //try
                //{
                //    var smtpClient = new SmtpClient("smtp.gmail.com")
                //    {
                //        Port = 587,
                //        Credentials = new NetworkCredential("your-email@gmail.com", "your-app-password"),
                //        EnableSsl = true,
                //    };
                //    smtpClient.Send("your-email@gmail.com", "admin@example.com",
                //        "New Order Placed",
                //        $"A new order (PaymentId: {paymentId}) has been placed by UserId: {Session["userId"]}");
                //}
                //catch (Exception emailEx)
                //{
                //    string logPath = Path.Combine(Server.MapPath("~/Logs"), "email.log");
                //    Directory.CreateDirectory(Path.GetDirectoryName(logPath)); // Tạo thư mục Logs nếu chưa tồn tại
                //    File.AppendAllText(logPath, DateTime.Now + ": Email failed - " + emailEx.Message + "\n");
                //}

                //Response.AddHeader("REFRESH", "1;URL=Invoice.aspx?id=" + paymentId);
            }
            catch (Exception ex)
            {
                try
                {
                    transaction.Rollback();
                    string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                    Directory.CreateDirectory(Path.GetDirectoryName(logPath)); // Tạo thư mục Logs nếu chưa tồn tại
                    File.AppendAllText(logPath,
                        DateTime.Now + ": OrderPayment - " + ex.Message + "\n" + ex.StackTrace + "\n");
                }
                catch (Exception rollbackEx)
                {
                    string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                    Directory.CreateDirectory(Path.GetDirectoryName(logPath)); // Tạo thư mục Logs nếu chưa tồn tại
                    File.AppendAllText(logPath,
                        DateTime.Now + ": Rollback failed - " + rollbackEx.Message + "\n");
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

        void UpdateQuantity(int _productId, int _quantity, SqlTransaction sqlTransaction, SqlConnection sqlConnection)
        {
            try
            {
                cmd = new SqlCommand("Product_Crud", sqlConnection, sqlTransaction);
                cmd.Parameters.AddWithValue("@Action", "GETBYID");
                cmd.Parameters.AddWithValue("@ProductId", _productId);
                cmd.CommandType = CommandType.StoredProcedure;
                dr1 = cmd.ExecuteReader();
                if (dr1.Read())
                {
                    int dbQuantity = (int)dr1["Quantity"];
                    dr1.Close();
                    if (dbQuantity >= _quantity)
                    {
                        cmd = new SqlCommand("Product_Crud", sqlConnection, sqlTransaction);
                        cmd.Parameters.AddWithValue("@Action", "QTYUPDATE");
                        cmd.Parameters.AddWithValue("@Quantity", dbQuantity - _quantity);
                        cmd.Parameters.AddWithValue("@ProductId", _productId);
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.ExecuteNonQuery();
                    }
                    else
                    {
                        throw new Exception($"Sản phẩm {_productId} không đủ tồn kho.");
                    }
                }
                else
                {
                    dr1.Close();
                    throw new Exception($"Không tìm thấy sản phẩm {_productId}.");
                }
            }
            catch (Exception ex)
            {
                string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                Directory.CreateDirectory(Path.GetDirectoryName(logPath)); // Tạo thư mục Logs nếu chưa tồn tại
                File.AppendAllText(logPath, DateTime.Now + ": UpdateQuantity - " + ex.Message + "\n");
                throw;
            }
        }

        void DeleteCartItem(int _productId, SqlTransaction sqlTransaction, SqlConnection sqlConnection)
        {
            cmd = new SqlCommand("Cart_Crud", sqlConnection, sqlTransaction);
            cmd.Parameters.AddWithValue("@Action", "DELETE");
            cmd.Parameters.AddWithValue("@ProductId", _productId);
            cmd.Parameters.AddWithValue("@UserId", Session["userId"]);
            cmd.CommandType = CommandType.StoredProcedure;
            try
            {
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                string logPath = Path.Combine(Server.MapPath("~/Logs"), "error.log");
                Directory.CreateDirectory(Path.GetDirectoryName(logPath)); // Tạo thư mục Logs nếu chưa tồn tại
                File.AppendAllText(logPath, DateTime.Now + ": DeleteCartItem - " + ex.Message + "\n");
                throw;
            }
        }
    }
}