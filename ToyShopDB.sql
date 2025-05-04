CREATE DATABASE ToyShopDB
USE ToyShopDB

CREATE TABLE [Users](
	[UserId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Username] [varchar](50) NULL UNIQUE,
	[Mobile] [varchar](10) NULL,
	[Email] [varchar](50) NULL UNIQUE,
	[Address] [varchar](max) NULL,
	[PostCode] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[ImageUrl] [varchar](max) NULL,
	[CreatedDate] [datetime] NULL
)
CREATE TABLE [Contact](
	[ContactId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[Subject] [varchar](200) NULL,
	[Message] [varchar](max) NULL,
	[CreatedDate] [datetime] NULL
)
CREATE TABLE [Categories](
	[CategoryId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[ImageUrl] [varchar](max) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime] NULL
)
CREATE TABLE [Products](
	[ProductId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Description] [varchar](max) NULL,
	[Price] [decimal](18, 2) NULL,
	[Quantity] [int] NULL,
	[ImageUrl] [varchar](max) NULL,
	[CategoryId] [int] NULL, --FK
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime] NULL
)
CREATE TABLE [Carts](
	[CartId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[ProductId] [int] NULL, --FK
	[Quantity] [int] NULL,
	[UserId] [int] NULL --FK
)

CREATE TABLE [Orders](
	[OrderDetailsId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[OrderNo] [varchar](max) NULL,
	[ProductId] [int] NULL, --FK
	[Quantity] [int] NULL,
	[UserId] [int] NULL, --FK
	[Status] [varchar](50) NULL,
	[PaymentId] [int] NULL, --FK
	[OrderDate] [datetime] NULL
)

CREATE TABLE [Payment](
	[PaymentId] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[CardNo] [varchar](50) NULL,
	[ExpiryDate] [varchar](50) NULL,
	[CvvNo] [int] NULL,
	[Address] [varchar](max) NULL,
	[PaymentMode] [varchar](50) NULL
)

ALTER PROCEDURE User_Crud
    @Action NVARCHAR(20),
    @UserId INT = NULL,
    @Name NVARCHAR(100) = NULL,
    @Username NVARCHAR(100) = NULL,
    @Mobile NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Address NVARCHAR(255) = NULL,
    @PostCode NVARCHAR(20) = NULL,
    @Password NVARCHAR(100) = NULL,
    @ImageUrl NVARCHAR(255) = NULL,
    @CreatedDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'SELECT'
    BEGIN
        SELECT * FROM Users;
    END
    ELSE IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Users (Name, Username, Mobile, Email, Address, PostCode, Password, ImageUrl, CreatedDate)
        VALUES (@Name, @Username, @Mobile, @Email, @Address, @PostCode, @Password, @ImageUrl, @CreatedDate);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Users
        SET Name = @Name,
            Username = @Username,
            Mobile = @Mobile,
            Email = @Email,
            Address = @Address,
            PostCode = @PostCode,
            Password = @Password,
            ImageUrl = @ImageUrl,
            CreatedDate = @CreatedDate
        WHERE UserId = @UserId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Users WHERE UserId = @UserId;
    END
    ELSE IF @Action = 'SELECT4LOGIN'
    BEGIN
        SELECT * FROM Users
        WHERE (Username = @Username OR Email = @Email)
          AND Password = @Password;
    END
END


ALTER PROCEDURE Cart_Crud
    @Action NVARCHAR(10),
    @CartId INT = NULL,
    @ProductId INT = NULL,
    @Quantity INT = NULL,
    @UserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'SELECT'
    BEGIN
        SELECT 
            C.CartId,
            C.ProductId,
            P.Name AS Name,
            P.ImageUrl as ImageUrl,
            P.Price,
            P.Quantity as PrdQty,
            C.Quantity,
            C.UserId
        FROM Carts C
        INNER JOIN Products P ON C.ProductId = P.ProductId
        WHERE C.UserId = @UserId;
    END
    ELSE IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Carts (ProductId, Quantity, UserId)
        VALUES (@ProductId, @Quantity, @UserId);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Carts
        SET ProductId = @ProductId,
            Quantity = @Quantity,
            UserId = @UserId
        WHERE CartId = @CartId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Carts WHERE ProductId = @ProductId AND UserId = @UserId;
    END
END


CREATE PROCEDURE Contact_Crud
    @Action NVARCHAR(10),
    @ContactId INT = NULL,
    @Name NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Subject NVARCHAR(255) = NULL,
    @Message NVARCHAR(MAX) = NULL,
    @CreatedDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'SELECT'
    BEGIN
        SELECT * FROM Contact;
    END
    ELSE IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Contact (Name, Email, Subject, Message, CreatedDate)
        VALUES (@Name, @Email, @Subject, @Message, @CreatedDate);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Contact
        SET Name = @Name,
            Email = @Email,
            Subject = @Subject,
            Message = @Message,
            CreatedDate = @CreatedDate
        WHERE ContactId = @ContactId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Contact WHERE ContactId = @ContactId;
    END
END

CREATE PROCEDURE Order_Crud
    @Action NVARCHAR(10),
    @OrderDetailsId INT = NULL,
    @OrderNo NVARCHAR(50) = NULL,
    @ProductId INT = NULL,
    @Quantity INT = NULL,
    @UserId INT = NULL,
    @Status NVARCHAR(50) = NULL,
    @PaymentId INT = NULL,
    @OrderDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'SELECT'
    BEGIN
        SELECT * FROM Orders;
    END
    ELSE IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Orders (OrderNo, ProductId, Quantity, UserId, Status, PaymentId, OrderDate)
        VALUES (@OrderNo, @ProductId, @Quantity, @UserId, @Status, @PaymentId, @OrderDate);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Orders
        SET OrderNo = @OrderNo,
            ProductId = @ProductId,
            Quantity = @Quantity,
            UserId = @UserId,
            Status = @Status,
            PaymentId = @PaymentId,
            OrderDate = @OrderDate
        WHERE OrderDetailsId = @OrderDetailsId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Orders WHERE OrderDetailsId = @OrderDetailsId;
    END
END

CREATE PROCEDURE Payment_Crud
    @Action NVARCHAR(10),
    @PaymentId INT = NULL,
    @Name NVARCHAR(100) = NULL,
    @CardNo NVARCHAR(50) = NULL,
    @ExpiryDate NVARCHAR(20) = NULL,
    @CvvNo NVARCHAR(10) = NULL,
    @Address NVARCHAR(255) = NULL,
    @PaymentMode NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'SELECT'
    BEGIN
        SELECT * FROM Payment;
    END
    ELSE IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Payment (Name, CardNo, ExpiryDate, CvvNo, Address, PaymentMode)
        VALUES (@Name, @CardNo, @ExpiryDate, @CvvNo, @Address, @PaymentMode);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Payment
        SET Name = @Name,
            CardNo = @CardNo,
            ExpiryDate = @ExpiryDate,
            CvvNo = @CvvNo,
            Address = @Address,
            PaymentMode = @PaymentMode
        WHERE PaymentId = @PaymentId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Payment WHERE PaymentId = @PaymentId;
    END
END



ALTER PROCEDURE Category_Crud
    @Action NVARCHAR(20),
    @CategoryId INT = NULL,
    @Name VARCHAR(50) = NULL,
    @ImageUrl VARCHAR(MAX) = NULL,
    @IsActive BIT = NULL,
    @CreatedDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'SELECT'
    BEGIN
        SELECT * FROM Categories;
    END
    ELSE IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Categories (Name, ImageUrl, IsActive, CreatedDate)
        VALUES (@Name, @ImageUrl, @IsActive, @CreatedDate);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Categories
        SET Name = @Name,
            ImageUrl = @ImageUrl,
            IsActive = @IsActive,
            CreatedDate = @CreatedDate
        WHERE CategoryId = @CategoryId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Categories WHERE CategoryId = @CategoryId;
    END
    ELSE IF @Action = 'ACTIVECATE'
    BEGIN
        SELECT * FROM Categories WHERE IsActive = 1;
    END
END


Alter PROCEDURE Product_Crud
    @Action NVARCHAR(20),
    @ProductId INT = NULL,
    @Name VARCHAR(50) = NULL,
    @Description VARCHAR(MAX) = NULL,
    @Price DECIMAL(18, 2) = NULL,
    @Quantity INT = NULL,
    @ImageUrl VARCHAR(MAX) = NULL,
    @CategoryId INT = NULL,
    @IsActive BIT = NULL,
    @CreatedDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'SELECT'
    BEGIN
        SELECT * FROM Products;
    END
    ELSE IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Products (Name, Description, Price, Quantity, ImageUrl, CategoryId, IsActive, CreatedDate)
        VALUES (@Name, @Description, @Price, @Quantity, @ImageUrl, @CategoryId, @IsActive, @CreatedDate);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Products
        SET Name = @Name,
            Description = @Description,
            Price = @Price,
            Quantity = @Quantity,
            ImageUrl = @ImageUrl,
            CategoryId = @CategoryId,
            IsActive = @IsActive,
            CreatedDate = @CreatedDate
        WHERE ProductId = @ProductId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Products WHERE ProductId = @ProductId;
    END
    ELSE IF @Action = 'ACTIVEPROD'
    BEGIN
        SELECT * FROM Products WHERE IsActive = 1;
    END
END



select *
from Users


Use ToyShopDB
select * from Users

SELECT * FROM Users WHERE Username = 'tdk';

SELECT * FROM Products
SELECT * FROM Categories


ALTER PROCEDURE Dashboared
    @Action NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'Categories'
        SELECT COUNT(*) FROM Categories;
    ELSE IF @Action = 'Products'
        SELECT COUNT(*) FROM Products;
    ELSE IF @Action = 'Orders'
        SELECT COUNT(*) FROM Orders;
    ELSE
        SELECT 0;  -- Trường hợp không khớp
END

EXEC Dashboared @Action = 'Categories'

SELECT COUNT(*) FROM Products;
SELECT * FROM Products;

INSERT INTO Products (Name, Description, Price, Quantity, ImageUrl, CategoryId, IsActive, CreatedDate)
VALUES ('Test sản phẩm', 'Mô tả test', 100000, 10, 'test.jpg', 1, 1, GETDATE());

EXEC Product_Crud @Action = 'ACTIVEPROD'



