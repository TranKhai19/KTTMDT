<%@ Page Title="" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="ToyShop.User.Contact" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <script>
        window.omload = function () {
            var seconds = 5;
            setTimeout(function () {
                document.getElementById("<%=lblMsg.ClientID %>").style.display = "none;"

            }, seconds * 1000);


        };
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">


    <!-- book section -->
    <section class="book_section layout_padding">
        <div class="container">
            <div class="heading_container">

                <div class="align-self-end">
                    <asp:Label runat="server" ID="lblMsg"></asp:Label>
                </div>
                <h2>Gửi yêu cầu của bạn</h2>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="form_container">
                       
                            <div>
                                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Tên của bạn"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvName" runat="server" ErrorMessage="Không được để trống" ControlToValidate="txtName"
                                    ForeColor="Red" Display="Dynamic" SetFocusOnError="true"></asp:RequiredFieldValidator>
                            </div>
                            <div>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Địa chỉ Email" TextMode="Email"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ErrorMessage="Không được để trống" ControlToValidate="txtEmail"
                                    ForeColor="Red" Display="Dynamic" SetFocusOnError="true"></asp:RequiredFieldValidator>
                            </div>
                            <div>
                                 <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" placeholder="Danh mục phản hồi"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ErrorMessage="Không được để trống" ControlToValidate="txtSubject"
                                    ForeColor="Red" Display="Dynamic" SetFocusOnError="true"></asp:RequiredFieldValidator>
                            </div>
                            <div>
                               <asp:TextBox ID="txtMessage" runat="server" CssClass="form-control" placeholder="Nhập vào phản hồi của bạn"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvMessage" runat="server" ErrorMessage="Không được để trống" ControlToValidate="txtMessage"
                                    ForeColor="Red" Display="Dynamic" SetFocusOnError="true"></asp:RequiredFieldValidator>
                            </div>
                            <div class="btn_box">
                                <asp:Button ID="btnSubmit" runat="server" Text="Gửi" CssClass="btn btn-warning rounded-pill pl-4 pr-4 text-white" 
                                    OnClick="btnSubmit_Click"/>
                            </div>
                     
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="map_container ">
                        <div id="googleMap"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <!-- end book section -->
</asp:Content>
