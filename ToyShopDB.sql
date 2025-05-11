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

CREATE PROCEDURE User_Crud
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


CREATE OR ALTER PROCEDURE Cart_Crud
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
            P.ImageUrl AS ImageUrl,
            P.Price,
            P.Quantity AS PrdQty,
            C.Quantity,
            C.UserId
        FROM Carts C
        INNER JOIN Products P ON C.ProductId = P.ProductId
        WHERE C.UserId = @UserId;
    END
    ELSE IF @Action = 'INSERT'
    BEGIN
        -- Kiểm tra xem sản phẩm đã tồn tại trong giỏ hàng hay chưa
        IF EXISTS (SELECT 1 FROM Carts WHERE ProductId = @ProductId AND UserId = @UserId)
        BEGIN
            -- Nếu tồn tại, cập nhật số lượng
            UPDATE Carts
            SET Quantity = Quantity + @Quantity
            WHERE ProductId = @ProductId AND UserId = @UserId;
        END
        ELSE
        BEGIN
            -- Nếu chưa tồn tại, thêm mới
            INSERT INTO Carts (ProductId, Quantity, UserId)
            VALUES (@ProductId, @Quantity, @UserId);
        END
    END         
    ELSE IF @Action = 'UPDATE'
    BEGIN
        -- Cập nhật số lượng dựa trên ProductId và UserId
        UPDATE Carts
        SET Quantity = @Quantity
        WHERE ProductId = @ProductId AND UserId = @UserId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Carts WHERE ProductId = @ProductId AND UserId = @UserId;
    END
    ELSE IF @Action = 'GETBYID'
    BEGIN
        -- Lấy thông tin sản phẩm trong giỏ hàng
        SELECT Quantity
        FROM Carts
        WHERE ProductId = @ProductId AND UserId = @UserId;
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



CREATE PROCEDURE Category_Crud
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


CREATE PROCEDURE Product_Crud
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


CREATE PROCEDURE Dashboared
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


CREATE PROCEDURE ContactSp
    @Action       NVARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE', 'SELECT', 'SELECT_ALL'
    @ContactId    INT = NULL,
    @Name         VARCHAR(50) = NULL,
    @Email        VARCHAR(50) = NULL,
    @Subject      VARCHAR(200) = NULL,
    @Message      VARCHAR(MAX) = NULL,
    @CreatedDate  DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Contact ([Name], [Email], [Subject], [Message], [CreatedDate])
        VALUES (@Name, @Email, @Subject, @Message, @CreatedDate);
    END

    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Contact
        SET 
            [Name] = @Name,
            [Email] = @Email,
            [Subject] = @Subject,
            [Message] = @Message,
            [CreatedDate] = @CreatedDate
        WHERE ContactId = @ContactId;
    END

    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Contact
        WHERE ContactId = @ContactId;
    END

    ELSE IF @Action = 'SELECT'
    BEGIN
        SELECT * FROM Contact
        WHERE ContactId = @ContactId;
    END

    ELSE IF @Action = 'SELECT_ALL'
    BEGIN
        SELECT * FROM Contact;
    END
END

CREATE OR ALTER PROCEDURE Invoices
    @Action         NVARCHAR(20),
    @OrderDetailsId INT = NULL,
    @OrderNo        VARCHAR(MAX) = NULL,
    @ProductId      INT = NULL,
    @Quantity       INT = NULL,
    @UserId         INT = NULL,
    @Status         VARCHAR(50) = NULL,
    @PaymentId      INT = NULL,
    @OrderDate      DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Orders ([OrderNo], [ProductId], [Quantity], [UserId], [Status], [PaymentId], [OrderDate])
        VALUES (@OrderNo, @ProductId, @Quantity, @UserId, @Status, @PaymentId, @OrderDate);
    END

    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Orders
        SET 
            [OrderNo] = @OrderNo,
            [ProductId] = @ProductId,
            [Quantity] = @Quantity,
            [UserId] = @UserId,
            [Status] = @Status,
            [PaymentId] = @PaymentId,
            [OrderDate] = @OrderDate
        WHERE [OrderDetailsId] = @OrderDetailsId;
    END

    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Orders
        WHERE [OrderDetailsId] = @OrderDetailsId;
    END

    ELSE IF @Action = 'SELECT'
    BEGIN
        SELECT * FROM Orders
        WHERE [OrderDetailsId] = @OrderDetailsId;
    END

    ELSE IF @Action = 'SELECT_ALL'
    BEGIN
        SELECT * FROM Orders;
    END

    ELSE IF @Action = 'GETSTATUS'
    BEGIN
        SELECT 
            O.OrderDetailsId,
            O.OrderNo,
            O.ProductId,
            P.Name AS ProductName,
            O.Quantity,
            O.UserId,
            O.Status,
            O.PaymentId,
            O.OrderDate
        FROM Orders O
        INNER JOIN Products P ON O.ProductId = P.ProductId
        ORDER BY O.OrderDate DESC;
    END

    ELSE IF @Action = 'STATUSBYID'
    BEGIN
        SELECT 
            O.OrderDetailsId,
            O.Status
        FROM Orders O
        WHERE O.OrderDetailsId = @OrderDetailsId;
    END

    ELSE IF @Action = 'UPDTSTATUS'
    BEGIN
        UPDATE Orders
        SET Status = @Status
        WHERE OrderDetailsId = @OrderDetailsId;
    END
END

CREATE TABLE OrderNotifications (
    NotificationId INT IDENTITY(1,1) PRIMARY KEY,
    OrderDetailsId INT,
    PaymentId INT,
    UserId INT,
    NotificationType NVARCHAR(50),
    CreatedDate DATETIME
);


CREATE PROCEDURE Save_Payment
    @Name VARCHAR(50),
    @CardNo VARCHAR(50),
    @ExpiryDate VARCHAR(50),
    @CvvNo INT,
    @Address VARCHAR(MAX),
    @PaymentMode VARCHAR(50),
    @InsertedId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Payment (Name, CardNo, ExpiryDate, CvvNo, Address, PaymentMode)
    VALUES (@Name, @CardNo, @ExpiryDate, @CvvNo, @Address, @PaymentMode);

    SET @InsertedId = SCOPE_IDENTITY();
END

DECLARE @InsertedId INT;
EXEC Save_Payment 
    @Name = 'Test User',
    @CardNo = '****1234',
    @ExpiryDate = '12/2025',
    @CvvNo = 123,
    @Address = '123 Test Street',
    @PaymentMode = 'card',
    @InsertedId = @InsertedId OUTPUT;
SELECT @InsertedId AS InsertedId;
SELECT * FROM Payment WHERE PaymentId = @InsertedId;

DECLARE @InsertedId INT;
EXEC Save_Payment 
    @Name = 'Test User',
    @CardNo = NULL,
    @ExpiryDate = NULL,
    @CvvNo = NULL,
    @Address = '123 Test Street',
    @PaymentMode = 'cod',
    @InsertedId = @InsertedId OUTPUT;
SELECT @InsertedId AS InsertedId;
SELECT * FROM Payment WHERE PaymentId = @InsertedId;