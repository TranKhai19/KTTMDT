﻿<%@ Page Title="" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" CodeBehind="Cart.aspx.cs" Inherits="ToyShop.User.Cart" %>
<%@ Import Namespace="ToyShop" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <section class="book_section layout_padding">
        <div class="container">
            <div class="heading_container">
                <div class="align-self-end">
                    <asp:Label ID="lblMsg" runat="server" Visible="false"></asp:Label>
                </div>
                <h2>Giỏ hàng của bạn
                </h2>
            </div>
        </div>

        <div class="container">
            <asp:Repeater ID="rCartItem" runat="server" OnItemCommand="rCartItem_ItemCommand" OnItemDataBound="rCartItem_ItemDataBound">
                <HeaderTemplate>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Tên</th>
                                <th>Ảnh</th>
                                <th>Giá</th>
                                <th>Số lượng</th>
                                <th>Tổng tiền</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                  <tr>
                      <td>
                          <asp:Label ID="lblName" runat="server" Text='<%# Eval("Name") %>'></asp:Label>
                      </td>
                      <td>
                          <img width="60" src="<%# Utils.GetImageUrl(Eval("ImageUrl")) %>" alt="" />
                      </td>
                      <td><asp:Label ID="lblPrice" runat="server" Text='<%# Eval("Price", "{0:N0}") + " đ" %>'></asp:Label>
                          <asp:HiddenField ID="hdnProductId" runat="server" Value='<%# Eval("ProductId") %>' />
                          <asp:HiddenField ID="hdnQuantity" runat="server" Value='<%# Eval("Quantity") %>' />
                          <asp:HiddenField ID="hdnPrdQuantity" runat="server" Value='<%# Eval("PrdQty") %>' />
                      </td>
                      <td>
                          <div class="product__details__option">
                              <div class="quantity">
                                  <div class="pro-qty">
                                      <asp:TextBox ID="txtQuantity" runat="server" TextMode="Number" Text='<%# Eval("Quantity") %>'>
                                      </asp:TextBox>
                                      <asp:RegularExpressionValidator ID="revQuantity" runat="server" ErrorMessage="*" ForeColor="Red" Font-Size="Small"
                                          ValidationExpression="[1-9]*" ControlToValidate="txtQuantity" Display="Dynamic" 
                                          SetFocusOnError="true" EnableClientScript="true"></asp:RegularExpressionValidator>
                                  </div>
                              </div>
                          </div>
                      </td>
                      <td><asp:Label ID="lblTotalPrice" runat="server"></asp:Label>đ</td>
                      <td>
                          <asp:LinkButton ID="lbDelete" runat="server" Text="Xoá" CommandName="remove" CommandArgument='<%# Eval("ProductId") %>'
                              onClientClick="return confirm('Bạn có chắc muốn xoá mặt hàng này không?');">
                              <i class="fa fa-close"></i></asp:LinkButton>
                      </td>
                  </tr>
                </ItemTemplate>
                 <FooterTemplate>
                     <tr>
                     <td colspan="3"></td>
                     <td class="pl-lg-5">
                         <b>Grand Total:-</b>
                     </td>
                         <td><% Response.Write(Session["grandTotalPrice"]); %>đ</td>
                         <td></td>
                         </tr>
                     <tr>
                         <td colspan="2" class="continue__btn">
                             <a href="Menu.aspx" class="btn btn-info"> <i class="fa fa-arrow-circle-left mr-2"></i>Tiếp tục mua sắm</a>
                         </td>
                         <td>
                             <asp:LinkButton ID="lbUpdateCart" runat="server" CommandName="updateCart" CssClass="btn btn-warning">
                            <i class="fa fa-refresh mr-2"></i> 
                                Cập nhật giỏ hàng
                             </asp:LinkButton>
                         </td>
                         <td>
                              <asp:LinkButton ID="lbCheckout" runat="server" CommandName="checkout" CssClass="btn btn-success">
                             Checkout<i class="fa fa-arrow-circle-right ml-2"></i>    
                             </asp:LinkButton>
                         </td>
                     </tr>
                        </tbody>
                    </table>
                   </FooterTemplate>
            </asp:Repeater>

        </div>

    </section>

</asp:Content>
