using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ToyShop.User
{
    public partial class Cart : System.Web.UI.Page
    {
        SqlConnection con;
        SqlCommand cmd;
        SqlDataAdapter sda;
        DataTable dt;
        decimal grandTotal = 0;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) {

                if (Session["userId"] == null)
                {
                    Response.Redirect("Login.aspx");
                }
                else {
                    getCartItems();

                }
            }
        }
        void getCartItems() {

            con = new SqlConnection(Connection.GetConnectionString());
            cmd = new SqlCommand("Cart_Crud", con);
            cmd.Parameters.AddWithValue("@Action", "SELECT");
            cmd.Parameters.AddWithValue("@UserId", Session["userId"]);
            cmd.CommandType = CommandType.StoredProcedure;
            sda = new SqlDataAdapter(cmd);
            dt = new DataTable();
            sda.Fill(dt);
            rCartItem.DataSource = dt;
            if (dt.Rows.Count == 0)
            {
                rCartItem.FooterTemplate = null;
                rCartItem.FooterTemplate = new CustomTemplate(ListItemType.Footer);

            }
            rCartItem.DataBind();

        }

        protected void rCartItem_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            Utils utils = new Utils();
            if (e.CommandName == "remove")
            {
                con = new SqlConnection(Connection.GetConnectionString());
                cmd = new SqlCommand("Cart_Crud", con);
                cmd.Parameters.AddWithValue("@Action", "DELETE");
                cmd.Parameters.AddWithValue("@ProductId", e.CommandArgument);
                cmd.Parameters.AddWithValue("@UserId", Session["userId"]);
                cmd.CommandType = CommandType.StoredProcedure;
                try
                {
                    con.Open();
                    cmd.ExecuteNonQuery();
                    getCartItems();
                    //Cart Count
                    Session["cartCount"] = utils.cartCount(Convert.ToInt32(Session["userId"]));

                }
                catch (Exception ex)
                {
                    Response.Write("<script>alert('Error - " + ex.Message + " ');</script>");

                }
                finally
                {

                    con.Close();
                }


            }

            if (e.CommandName == "updateCart")
            {
                bool isCartUpdated = false;
                for (int item = 0; item < rCartItem.Items.Count; item++)
                {
                    if (rCartItem.Items[item].ItemType == ListItemType.Item || rCartItem.Items[item].ItemType == ListItemType.AlternatingItem)
                    {
                        TextBox quantity = rCartItem.Items[item].FindControl("txtQuantity") as TextBox;
                        HiddenField _productId = rCartItem.Items[item].FindControl("hdnProductId") as HiddenField;
                        int quantityFromCart = Convert.ToInt32(quantity.Text);
                        int ProductId = Convert.ToInt32(_productId.Value);

                        // Cập nhật số lượng vào cơ sở dữ liệu
                        if (quantityFromCart > 0)
                        {
                            isCartUpdated = utils.updateCartQuantity(quantityFromCart, ProductId, Convert.ToInt32(Session["userId"]));
                        }
                    }
                }

                // Cập nhật lại giỏ hàng sau khi cập nhật
                getCartItems();
            }

            if (e.CommandName == "checkout")
            {
                bool isTrue = false;
                string pName = string.Empty;
                //First Will Check Item Quantity
                for (int item = 0; item < rCartItem.Items.Count; item++)
                {
                    if (rCartItem.Items[item].ItemType == ListItemType.Item || rCartItem.Items[item].ItemType == ListItemType.AlternatingItem)
                    {
                        HiddenField _productId = rCartItem.Items[item].FindControl("hdnProductId") as HiddenField;
                        HiddenField _cartQuantity = rCartItem.Items[item].FindControl("hdnQuantity") as HiddenField;
                        HiddenField _productQuantity = rCartItem.Items[item].FindControl("hdnPrdQuantity") as HiddenField;
                        Label productName = rCartItem.Items[item].FindControl("lblName") as Label;
                        int productId = Convert.ToInt32(_productId.Value);
                        int cartQuantity = Convert.ToInt32(_cartQuantity.Value);
                        int productQuantity = Convert.ToInt32(_productQuantity.Value);

                        if (productQuantity >= cartQuantity)
                        {
                            isTrue = true;
                        }
                        else
                        {
                            isTrue = false;
                            pName = productName.Text.ToString();
                            break;
                        }
                    }
                }

                if (isTrue)
                {

                    Response.Redirect("Payment.aspx");

                }
                else {
                    lblMsg.Visible = true;
                    lblMsg.Text = "Item <b>'" + pName + "' </b>Out of Stock:(";
                    lblMsg.CssClass = "alert alert-warning";


                }
            }
        } 
    

        protected void rCartItem_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Label totalPrice = e.Item.FindControl("lblTotalPrice") as Label;
                Label productPrice = e.Item.FindControl("lblPrice") as Label;
                TextBox quantity = e.Item.FindControl("txtQuantity") as TextBox;
                //if (decimal.TryParse(productPrice.Text.Replace("₹", "").Trim(), out decimal price) &&
                //int.TryParse(quantity.Text.Trim(), out int qty))
                //            {
                //                decimal total = price * qty;
                //                totalPrice.Text = total.ToString("N0"); // Format number with thousands separator
                //                grandTotal += total;
                //            }

                // Cập nhật Session để hiển thị Grand Total ở Footer

                //decimal calTotalPrice = Convert.ToDecimal(productPrice.Text) * Convert.ToDecimal(quantity.Text);
                //totalPrice.Text = calTotalPrice.ToString();
                //grandTotal += calTotalPrice;

                if (decimal.TryParse(productPrice.Text.Replace("đ", "").Trim(), out decimal price) &&
                int.TryParse(quantity.Text.Trim(), out int qty))
                {
                    decimal total = price * qty;
                    totalPrice.Text = total.ToString("N0");
                    grandTotal += total;
                }
            }
            //Session["grandTotalPrice"] = grandTotal;
            Session["grandTotalPrice"] = grandTotal.ToString("N0");
        }

        //Custom Tempalte Class to add controls to the repeater's header , item and footer sections.

        private sealed class CustomTemplate : ITemplate
        {
            private ListItemType ListItemType { get; set; }

            public CustomTemplate(ListItemType type) {

                ListItemType = type;
            }

            public void InstantiateIn(Control container)
            {
                if (ListItemType == ListItemType.Footer) {

                    var footer = new LiteralControl("<tr><td colspan='5'><b>Giỏ hàng đang trống.</b><a href='Menu.aspx' class='badge badge-info ml-2'>Tiếp tục mua sắm</a></td></tr></tbody></table>");
                    container.Controls.Add(footer);
                }
            }
        
        
        }


    }
}