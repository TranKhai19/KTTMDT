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


ALTER PROCEDURE Save_Payment
    @OrderId INT,
    @Name NVARCHAR(100) = NULL,
    @CardNo NVARCHAR(16) = NULL,
    @ExpiryDate NVARCHAR(10) = NULL,
    @CvvNo NVARCHAR(4) = NULL,
    @Address NVARCHAR(500) = NULL,
    @PaymentMethod VARCHAR(10),
    @Amount DECIMAL(18, 2),
    @PaymentStatus VARCHAR(20) = 'PENDING',
    @InsertedId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra phương thức thanh toán
    IF @PaymentMethod = 'CARD'
    BEGIN
        -- Kiểm tra nếu thiếu thông tin thẻ
        IF @CvvNo IS NULL OR @CardNo IS NULL OR @ExpiryDate IS NULL
        BEGIN
            RAISERROR ('Thông tin thẻ không hợp lệ cho thanh toán qua thẻ.', 16, 1);
            RETURN;
        END

        -- Logic cho thanh toán qua thẻ
        INSERT INTO Payments (OrderId, Name, CardNo, ExpiryDate, Address, PaymentMethod, Amount, PaymentStatus, CreatedDate)
        VALUES (@OrderId, @Name, @CardNo, @ExpiryDate, @Address, @PaymentMethod, @Amount, @PaymentStatus, GETDATE());
    END
    ELSE IF @PaymentMethod = 'COD'
    BEGIN
        -- Logic cho COD
        INSERT INTO Payments (OrderId, Name, Address, PaymentMethod, Amount, PaymentStatus, CreatedDate)
        VALUES (@OrderId, @Name, @Address, @PaymentMethod, @Amount, 'PENDING', GETDATE());
    END
    ELSE
    BEGIN
        RAISERROR ('Phương thức thanh toán không hợp lệ.', 16, 1);
        RETURN;
    END

    -- Lấy ID của bản ghi vừa thêm
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


-- Xóa bảng Payment cũ nếu không cần dữ liệu
DROP TABLE IF EXISTS Payment;

-- Tạo bảng Payments mới
CREATE TABLE Payments (
    PaymentId INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    OrderId INT NOT NULL, -- Tham chiếu đến OrderDetailsId từ bảng Orders
    Name NVARCHAR(100) NULL,
    CardNo NVARCHAR(16) NULL,
    ExpiryDate NVARCHAR(10) NULL,
    Address NVARCHAR(500) NULL,
    PaymentMethod NVARCHAR(10) NULL, -- 'CARD' hoặc 'COD'
    Amount DECIMAL(18, 2) NOT NULL,
    PaymentStatus NVARCHAR(20) NULL,
    CreatedDate DATETIME NOT NULL
);

DROP PROCEDURE IF EXISTS Payment_Crud;

CREATE TRIGGER TRG_Product_Delete
ON Products
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Carts
    WHERE ProductId IN (SELECT ProductId FROM deleted);
END;

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
        -- Kiểm tra xem sản phẩm có tồn tại không
        IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductId = @ProductId)
        BEGIN
            RAISERROR ('Sản phẩm không tồn tại.', 16, 1);
            RETURN;
        END
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
        SELECT Quantity
        FROM Carts
        WHERE ProductId = @ProductId AND UserId = @UserId;
    END
END

SELECT * FROM Products;

DELETE FROM Carts
WHERE ProductId NOT IN (SELECT ProductId FROM Products);

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
        IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductId = @ProductId)
        BEGIN
            RAISERROR ('Sản phẩm không tồn tại.', 16, 1);
            RETURN;
        END
        IF EXISTS (SELECT 1 FROM Carts WHERE ProductId = @ProductId AND UserId = @UserId)
        BEGIN
            UPDATE Carts
            SET Quantity = Quantity + @Quantity
            WHERE ProductId = @ProductId AND UserId = @UserId;
        END
        ELSE
        BEGIN
            INSERT INTO Carts (ProductId, Quantity, UserId)
            VALUES (@ProductId, @Quantity, @UserId);
        END
    END         
    ELSE IF @Action = 'UPDATE'
    BEGIN
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
        SELECT Quantity
        FROM Carts
        WHERE ProductId = @ProductId AND UserId = @UserId;
    END
END

SELECT * FROM Products;

INSERT INTO Products (Name, Description, Price, Quantity, ImageUrl, CategoryId, IsActive, CreatedDate)
VALUES ('Sản phẩm mẫu 1', 'Mô tả sản phẩm mẫu 1', 100000, 50, 'sample1.jpg', 1, 1, GETDATE()),
       ('Sản phẩm mẫu 2', 'Mô tả sản phẩm mẫu 2', 200000, 30, 'sample2.jpg', 1, 1, GETDATE());

SELECT * FROM Products;
SELECT C.*, P.Name, P.Quantity AS AvailableQuantity
FROM Carts C
INNER JOIN Products P ON C.ProductId = P.ProductId
WHERE C.UserId = 1;

CREATE OR ALTER PROCEDURE Product_Crud
    @Action VARCHAR(20),
    @ProductId INT = NULL,
    @Name VARCHAR(100) = NULL,
    @Description VARCHAR(MAX) = NULL,
    @Price DECIMAL(10, 2) = NULL,
    @Quantity INT = NULL,
    @ImageUrl VARCHAR(MAX) = NULL,
    @CategoryId INT = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'SELECT'
    BEGIN
        SELECT ProductId, Name, Description, Price, Quantity, ImageUrl, CategoryId, IsActive, CreatedDate
        FROM Products
        WHERE IsActive = 1;
    END
    IF @Action = 'GETBYID'
    BEGIN
        IF EXISTS (SELECT 1 FROM Products WHERE ProductId = @ProductId AND IsActive = 1)
        BEGIN
            SELECT ProductId, Name, Description, Price, Quantity, ImageUrl, CategoryId, IsActive, CreatedDate
            FROM Products
            WHERE ProductId = @ProductId AND IsActive = 1;
        END
        ELSE
        BEGIN
            IF EXISTS (SELECT 1 FROM Products WHERE ProductId = @ProductId)
            BEGIN
                -- Sản phẩm tồn tại nhưng không hoạt động
                RAISERROR ('Sản phẩm không hoạt động.', 16, 1);
                RETURN;
            END
            ELSE
            BEGIN
                -- Sản phẩm không tồn tại
                RAISERROR ('Sản phẩm không tồn tại.', 16, 1);
                RETURN;
            END
        END
    END
    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Products(Name, Description, Price, Quantity, ImageUrl, CategoryId, IsActive, CreatedDate)
        VALUES (@Name, @Description, @Price, @Quantity, @ImageUrl, @CategoryId, @IsActive, GETDATE());
    END
    IF @Action = 'UPDATE'
    BEGIN
        UPDATE Products
        SET Name = @Name, Description = @Description, Price = @Price, Quantity = @Quantity,
            ImageUrl = @ImageUrl, CategoryId = @CategoryId, IsActive = @IsActive
        WHERE ProductId = @ProductId;
    END
    IF @Action = 'QTYUPDATE'
    BEGIN
        UPDATE Products
        SET Quantity = @Quantity
        WHERE ProductId = @ProductId;
    END
    IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Products WHERE ProductId = @ProductId;
    END
END


ALTER TABLE Orders
ADD TotalPrice DECIMAL(18, 2) NULL;

CREATE OR ALTER PROCEDURE Invoices
    @Action VARCHAR(20),
    @OrderNo VARCHAR(50) = NULL,
    @ProductId INT = NULL,
    @Quantity INT = NULL,
    @UserId INT = NULL,
    @Status VARCHAR(20) = NULL,
    @PaymentId INT = NULL,
    @OrderDate DATETIME = NULL,
    @TotalPrice DECIMAL(18, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Orders (OrderNo, ProductId, Quantity, UserId, Status, PaymentId, OrderDate, TotalPrice)
        VALUES (@OrderNo, @ProductId, @Quantity, @UserId, @Status, @PaymentId, @OrderDate, @TotalPrice);
    END
END

