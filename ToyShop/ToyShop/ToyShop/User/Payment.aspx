﻿<%@ Page Title="" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" CodeBehind="Payment.aspx.cs" Inherits="ToyShop.User.Payment" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
 <style>
        .rounded {
            border-radius: 1rem
        }

        .nav-pills .nav-link {
            color: #555
        }

            .nav-pills .nav-link.active {
                color: white
            }

        .bold {
            font-weight: bold
        }

        .card {
            padding: 40px 50px;
            border-radius: 20px;
            border: none;
            box-shadow: 1px 5px 10px 1px rgba(0, 0, 0, 0.2)
        }
    </style>
    <script>
        /*For disappearing alert message*/
        window.onload = function () {
            var seconds = 5;
            setTimeout(function () {
                document.getElementById("<%=lblMsg.ClientID %>").style.display = "none";
            }, seconds * 1000);
        };
        /*For tooltip*/
        $(function () {
            $('[data-toggle="tooltip"]').tooltip()
        })
    </script>

    <%--Function for preventing back button--%>
    <script type="text/javascript">
        function DisableBackButton() {
            window.history.forward()
        }
        DisableBackButton();
        window.onload = DisableBackButton;
        window.onpageshow = function (evt) { if (evt.persisted) DisableBackButton() }
        window.onunload = function () { void (0) }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

 

        <div class="container py-5">
            <div class="align-self-end">
                <asp:Label ID="lblMsg" runat="server" Visible="false"></asp:Label>
            </div>
            <!-- For demo purpose -->
            <div class="row mb-4">
                <div class="col-lg-8 mx-auto text-center">
                    <h1 class="display-6">Thông tin đặt hàng</h1>
                </div>
            </div>
            <!-- End -->
            <div class="row pb-5">
                <div class="col-lg-6 mx-auto">
                    <div class="card ">
                        <div class="card-header">
                            <div class="bg-white shadow-sm pt-4 pl-2 pr-2 pb-2">
                                <!-- Payment type tabs -->
                                <ul role="tablist" class="nav bg-light nav-pills rounded nav-fill mb-3">
                                    <li class="nav-item"><a data-toggle="pill" href="#credit-card" class="nav-link active "><i class="fa fa-credit-card mr-2"></i>Thẻ ghi nợ </a></li>
                                    <li class="nav-item"><a data-toggle="pill" href="#paypal" class="nav-link "><i class="fa fa-money mr-2"></i>Thanh toán khi nhận hàng </a></li>
                                    <%--<li class="nav-item"><a data-toggle="pill" href="#net-banking" class="nav-link "><i class="fa fa-mobile mr-2"></i>Net Banking </a></li>--%>
                                </ul>
                                <!-- End -->
                            </div>
                            <!-- Credit card form content -->
                            <div class="tab-content">
                                <!-- credit card info-->
                                <div id="credit-card" class="tab-pane fade show active pt-3">
                                    <div role="form">
                                        <div class="form-group">
                                            <label for="txtName">
                                                <h6>Chủ thẻ</h6>
                                            </label>
                                            <asp:RequiredFieldValidator ID="rfvName" runat="server" ErrorMessage="Bắt buộc"
                                                ControlToValidate="txtName" ForeColor="Red" Display="Dynamic" SetFocusOnError="true"
                                                ValidationGroup="card">*</asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server"
                                                ErrorMessage="Tên nên là kí tự không có số" ForeColor="Red" Display="Dynamic" SetFocusOnError="true"
                                                ValidationExpression="^[a-zA-Z\s]+$" ControlToValidate="txtName" ValidationGroup="card">*
                                            </asp:RegularExpressionValidator>
                                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Tên chủ thẻ"></asp:TextBox>
                                        </div>
                                        <div class="form-group">
                                            <label for="txtCardNo">
                                                <h6>Số thẻ</h6>
                                            </label>
                                            <asp:RequiredFieldValidator ID="rfvCardNo" runat="server" ErrorMessage="Bắt buộc"
                                                ControlToValidate="txtCardNo" ForeColor="Red" Display="Dynamic" SetFocusOnError="true"
                                                ValidationGroup="card">*</asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="RegularExpressionValidator2" runat="server"
                                                ErrorMessage="Số thẻ có 16 số" ForeColor="Red" Display="Dynamic" SetFocusOnError="true"
                                                ValidationExpression="[0-9]{16}" ControlToValidate="txtCardNo" ValidationGroup="card">*
                                            </asp:RegularExpressionValidator>
                                            <div class="input-group">
                                                <asp:TextBox ID="txtCardNo" runat="server" CssClass="form-control" placeholder="Nhập Số thẻ hợp lệ"
                                                    TextMode="Number"></asp:TextBox>
                                                <div class="input-group-append">
                                                    <span class="input-group-text text-muted">
                                                        <i class="fa fa-cc-visa mx-1"></i>
                                                        <i class="fa fa-cc-mastercard mx-1"></i>
                                                        <i class="fa fa-cc-amex mx-1"></i>
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-sm-8">
                                                <div class="form-group">
                                                    <label>
                                                        <span class="hidden-xs">
                                                            <h6>Thời gian hết hạn</h6>
                                                        </span>
                                                    </label>
                                                    <asp:RequiredFieldValidator ID="rfvExpMonth" runat="server" ErrorMessage="Bắt buộc"
                                                        ControlToValidate="txtExpMonth" ForeColor="Red" Display="Dynamic" SetFocusOnError="true"
                                                        ValidationGroup="card">*</asp:RequiredFieldValidator>
                                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator3" runat="server" Display="Dynamic"
                                                        ErrorMessage="Tháng hết hạn thẻ là 2 kí tự" ForeColor="Red" SetFocusOnError="true"
                                                        ValidationExpression="[0-9]{2}" ControlToValidate="txtExpMonth" ValidationGroup="card">*
                                                    </asp:RegularExpressionValidator>
                                                    <asp:RequiredFieldValidator ID="rfvExpYear" runat="server" ErrorMessage="Năm hết hạn bắt buộc ghi"
                                                        ControlToValidate="txtExpYear" ForeColor="Red" Display="Dynamic" SetFocusOnError="true"
                                                        ValidationGroup="card">*</asp:RequiredFieldValidator>
                                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator4" runat="server" Display="Dynamic"
                                                        ErrorMessage="Năm hết hạn thẻ là 4 kí tự" ForeColor="Red" SetFocusOnError="true"
                                                        ValidationExpression="[0-9]{4}" ControlToValidate="txtExpYear" ValidationGroup="card">*
                                                    </asp:RegularExpressionValidator>
                                                    <div class="input-group">
                                                        <asp:TextBox ID="txtExpMonth" runat="server" CssClass="form-control" placeholder="MM"
                                                            TextMode="Number"></asp:TextBox>
                                                        <asp:TextBox ID="txtExpYear" runat="server" CssClass="form-control" placeholder="YYYY"
                                                            TextMode="Number"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group mb-4">
                                                    <label data-toggle="tooltip" title="Three digit CV code on the back of your card">
                                                        <h6>Mã CVV <i class="fa fa-question-circle d-inline"></i></h6>
                                                    </label>
                                                    <asp:RequiredFieldValidator ID="rfvCvv" runat="server" ErrorMessage="CVV no. is required"
                                                        ControlToValidate="txtCvv" ForeColor="Red" Display="Dynamic" SetFocusOnError="true"
                                                        ValidationGroup="card">*</asp:RequiredFieldValidator>
                                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator5" runat="server" Display="Dynamic"
                                                        ErrorMessage="CVV no. must be of 3 digits" ForeColor="Red" SetFocusOnError="true"
                                                        ValidationExpression="[0-9]{3}" ControlToValidate="txtCvv" ValidationGroup="card">*
                                                    </asp:RegularExpressionValidator>
                                                    <asp:TextBox ID="txtCvv" runat="server" CssClass="form-control" placeholder="CVV No."
                                                        TextMode="Number"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="txtAddress">
                                                <h6>Địa chỉ nhận hàng</h6>
                                            </label>
                                            <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ErrorMessage="Address is required" ForeColor="Red"
                                                ControlToValidate="txtAddress" Display="Dynamic" SetFocusOnError="true" ValidationGroup="card">*
                                            </asp:RequiredFieldValidator>
                                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" placeholder="Địa chỉ"
                                                TextMode="MultiLine" ValidationGroup="card"></asp:TextBox>
                                        </div>
                                        <div class="card-footer">
                                            <asp:LinkButton ID="lbCardSubmit" runat="server" CssClass="subscribe btn btn-info btn-block shadow-sm"
                                                ValidationGroup="card" OnClick="lbCardSubmit_Click">Xác nhận thanh toán</asp:LinkButton>
                                        </div>
                                    </div>
                                </div>
                                <!-- End -->
                                <!-- Cash On Delivery info -->
                                <div id="paypal" class="tab-pane fade pt-3">
                                    <div class="form-group">
                                        <label for="txtCODAddress">
                                            <h6>Địa chỉ nhận hàng</h6>
                                        </label>
                                        <asp:TextBox ID="txtCODAddress" runat="server" CssClass="form-control" placeholder="Địa chỉ nhận hàng"
                                            TextMode="MultiLine"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="rfvCODAddress" runat="server" ErrorMessage="Bắt buộc" ForeColor="Red"
                                            ControlToValidate="txtCODAddress" Display="Dynamic" SetFocusOnError="true" ValidationGroup="cod"
                                            Font-Names="Segoe Script"></asp:RequiredFieldValidator>
                                    </div>
                                    <p>
                                        <asp:LinkButton ID="lbCodSubmit" runat="server" CssClass="btn btn-info" ValidationGroup="cod" OnClick="lbCodSubmit_Click">
                                            <i class="fa fa-cart-arrow-down mr-2"></i>Xác nhận đặt đơn</asp:LinkButton>
                                    </p>
                                    <p class="text-muted">
                                        Lưu ý: Khi nhận được đơn hàng, bạn cần thanh toán đầy đủ.
            Sau khi hoàn tất quá trình thanh toán, bạn có thể kiểm tra trạng thái đơn hàng đã cập nhật của mình.
                                    </p>
                                </div>
                                <!-- End -->
                            </div>
                            <!-- End -->
                        </div>
                        <div class="card-footer">
                            <b class="badge badge-success badge-pill shadow-sm">Tổng hoá đơn: <% Response.Write(Session["grandTotalPrice"]); %> đ</b>
                            <div class="pt-1">
                                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" ValidationGroup="card"
                                    HeaderText="Fix the following errors" Font-Names="Segoe Script" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>
