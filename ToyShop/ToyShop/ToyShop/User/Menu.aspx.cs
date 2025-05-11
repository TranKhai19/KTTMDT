using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ToyShop.User
{
    public partial class Menu : System.Web.UI.Page
    {
        SqlConnection con;
        SqlCommand cmd;
        SqlDataAdapter sda;
        DataTable dt;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                getCategories();
                getProducts();
            }
        }

        private void getCategories()
        {
            try
            {
                con = new SqlConnection(Connection.GetConnectionString());
                cmd = new SqlCommand("Category_Crud", con);
                cmd.Parameters.AddWithValue("@Action", "ACTIVECAT");
                cmd.CommandType = CommandType.StoredProcedure;
                sda = new SqlDataAdapter(cmd);
                dt = new DataTable();
                sda.Fill(dt);
                rCategory.DataSource = dt;
                rCategory.DataBind();
            }
            catch (Exception ex)
            {
                lblMsg.Visible = true;
                lblMsg.Text = "Lỗi khi tải danh mục: " + ex.Message;
                lblMsg.CssClass = "alert alert-danger";
            }
        }

        private void getProducts()
        {
            try
            {
                con = new SqlConnection(Connection.GetConnectionString());
                cmd = new SqlCommand("Product_Crud", con);
                cmd.Parameters.AddWithValue("@Action", "ACTIVEPROD");
                cmd.CommandType = CommandType.StoredProcedure;
                sda = new SqlDataAdapter(cmd);
                dt = new DataTable();
                sda.Fill(dt);
                rProducts.DataSource = dt;
                rProducts.DataBind();
            }
            catch (Exception ex)
            {
                lblMsg.Visible = true;
                lblMsg.Text = "Lỗi khi tải sản phẩm: " + ex.Message;
                lblMsg.CssClass = "alert alert-danger";
            }
        }

        protected void rProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (Session["userId"] != null)
            {
                try
                {
                    int productId = Convert.ToInt32(e.CommandArgument);
                    int userId = Convert.ToInt32(Session["userId"]);
                    int quantityInCart = isItemExistInCart(productId);

                    using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                    {
                        using (SqlCommand cmd = new SqlCommand("Cart_Crud", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@Action", "INSERT"); // Luôn dùng INSERT vì stored procedure xử lý logic tồn tại
                            cmd.Parameters.AddWithValue("@ProductId", productId);
                            cmd.Parameters.AddWithValue("@Quantity", 1); // Tăng 1 đơn vị mỗi lần bấm
                            cmd.Parameters.AddWithValue("@UserId", userId);

                            con.Open();
                            cmd.ExecuteNonQuery();
                            con.Close();
                        }
                    }

                    lblMsg.Visible = true;
                    lblMsg.Text = "Sản phẩm đã được thêm vào giỏ hàng!";
                    lblMsg.CssClass = "alert alert-success";

                    // Làm mới trang sau 1 giây
                    Response.AddHeader("REFRESH", "1;URL=Cart.aspx");
                }
                catch (Exception ex)
                {
                    lblMsg.Visible = true;
                    lblMsg.Text = "Lỗi khi thêm sản phẩm vào giỏ hàng: " + ex.Message;
                    lblMsg.CssClass = "alert alert-danger";
                }
            }
            else
            {
                // Chuyển hướng sang trang đăng nhập nếu chưa đăng nhập
                Response.Redirect("Login.aspx");
            }
        }

        private int isItemExistInCart(int productId)
        {
            int quantity = 0;
            try
            {
                using (SqlConnection con = new SqlConnection(Connection.GetConnectionString()))
                {
                    using (SqlCommand cmd = new SqlCommand("Cart_Crud", con))
                    {
                        cmd.Parameters.AddWithValue("@Action", "GETBYID");
                        cmd.Parameters.AddWithValue("@ProductId", productId);
                        cmd.Parameters.AddWithValue("@UserId", Session["userId"]);
                        cmd.CommandType = CommandType.StoredProcedure;
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            if (dt.Rows.Count > 0)
                            {
                                quantity = Convert.ToInt32(dt.Rows[0]["Quantity"]);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblMsg.Visible = true;
                lblMsg.Text = "Lỗi khi kiểm tra giỏ hàng: " + ex.Message;
                lblMsg.CssClass = "alert alert-danger";
            }
            return quantity;
        }
    }
}
