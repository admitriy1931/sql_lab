USE KN302_Agafonov
GO
IF OBJECT_ID('KN302_Agafonov.dbo.Products', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.Products
GO
IF OBJECT_ID('KN302_Agafonov.dbo.Cities', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.Cities
GO
IF OBJECT_ID('KN302_Agafonov.dbo.Prices', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.Prices
GO
IF OBJECT_ID('KN302_Agafonov.dbo.ProductsInBag', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.ProductsInBag
GO
IF OBJECT_ID('MinMaxProductPrices') IS NOT NULL
    DROP FUNCTION MinMaxProductPrices
GO
IF OBJECT_ID('CalculateBagPrice') IS NOT NULL
    DROP FUNCTION CalculateBagPrice
GO
IF OBJECT_ID('WhetherEnoughMoneyForProducts') IS NOT NULL
    DROP FUNCTION WhetherEnoughMoneyForProducts

GO
CREATE TABLE Products
   (ID INT PRIMARY KEY NOT NULL, 
	Name varchar(50) NOT NULL,
	Unit varchar(50) NOT NULL) 
GO 
CREATE TABLE Cities
   (ID INT PRIMARY KEY NOT NULL, 
    Name varchar(50) NOT NULL) 
GO 
CREATE TABLE Prices
   (CityID INT NOT NULL,
   ProductID INT NOT NULL,
   Price FLOAT NOT NULL) 
GO
CREATE TABLE ProductsInBag
   (ID INT PRIMARY KEY NOT NULL,
   Quantity FLOAT NOT NULL) 

INSERT Products VALUES
(1, 'Шоколад', 'штука'),
(2, 'Молоко', 'литр'),
(3, 'Картофель', 'кг'),
(4, 'Сыр', 'кг'),
(5, 'Мясо', 'кг'),
(6, 'Подсолнечное масло', 'литр')
GO

INSERT Cities VALUES
(1, 'Москва'),
(2, 'Санкт-Петербург'),
(3, 'Екатеринбург')
GO

INSERT Prices VALUES
(1, 1, 5),
(1, 2, 6),
(1, 3, 7),
(1, 4, 8),
(1, 5, 9),
(1, 6, 10),
(2, 1, 7),
(2, 2, 8),
(2, 3, 9),
(2, 4, 10),
(2, 5, 11),
(2, 6, 12),
(3, 1, 9),
(3, 2, 10),
(3, 3, 11),
(3, 4, 12),
(3, 5, 13),
(3, 6, 14)
GO

INSERT ProductsInBag VALUES
(1, 2),
(2, 3),
(3, 2),
(4, 5),
(5, 6)
GO

--FUNC 1
CREATE FUNCTION CalculateBagPrice(@city VARCHAR(250))
RETURNS FLOAT
AS BEGIN
    DECLARE @sum FLOAT;
	WITH city AS 
	(
		SELECT *
		FROM Cities
		WHERE Cities.Name = @city
	),
	result AS (
	SELECT Products.Name, Prices.Price, ProductsInBag.Quantity
	FROM city
	INNER JOIN Prices on city.ID = Prices.CityID
	INNER JOIN ProductsInBag on Prices.ProductID = ProductsInBag.ID
	INNER JOIN Products on ProductsInBag.ID = Products.ID
	)
	SELECT @sum = SUM(result.Price * result.Quantity)
	FROM result

    RETURN @sum
END

GO

--FUNC 2
CREATE FUNCTION MinMaxProductPrices (@productName VARCHAR(50))
RETURNS @result_table TABLE
(
	Название_Города varchar(50) NOT NULL,
	Цена FLOAT NOT NULL,
	Разница_с_Максимумом FLOAT NOT NULL,
	Разница_с_Минимумом FLOAT NOT NULL
)
AS 
BEGIN
	DECLARE @max FLOAT
	DECLARE @min FLOAT

	SELECT @max = MAX(Prices.Price)
	FROM Prices, Products
	WHERE Products.Name = @productName AND Prices.ProductID = Products.ID

	SELECT @min = MIN(Prices.Price)
	FROM Prices, Products
	WHERE Products.Name = @productName AND Prices.ProductID = Products.ID

	DECLARE @productID INT

	SELECT @productID = ID
	FROM Products
	WHERE Products.Name = @productName

	INSERT INTO @result_table
	SELECT Cities.Name as НазваниеГорода, Prices.Price as Цена, @max - Prices.Price as Разница_с_Максимумом, Prices.Price - @min as Разница_с_Минимумом
	FROM Cities
	INNER JOIN Prices ON Prices.CityID = Cities.ID AND Prices.ProductID = @productID
    RETURN;
END

GO

--FUNC 3
CREATE FUNCTION WhetherEnoughMoneyForProducts(@amount FLOAT)
RETURNS @result_table TABLE
(
	Название_Города varchar(50) NOT NULL,
	Достаточно_Денег varchar(50) NOT NULL,
	Разница FLOAT NOT NULL
)
AS
BEGIN
	INSERT INTO @result_table
	SELECT Cities.Name, "IsEnough" =
	CASE
		WHEN @amount - dbo.CalculateBagPrice(Cities.Name) >= 0 THEN 'Да'
		ELSE 'Нет'
	END,
	@amount - dbo.CalculateBagPrice(Cities.Name)
FROM Cities

	return;
END

GO

SELECT dbo.CalculateBagPrice('Екатеринбург') as Общая_Стоимость

SELECT *
FROM dbo.MinMaxProductPrices('Молоко')

SELECT *
FROM dbo.WhetherEnoughMoneyForProducts(100)

DECLARE
	@columns NVARCHAR(MAX) = '',
	@sql NVARCHAR(MAX) = '';
SELECT @columns += QUOTENAME(Name) + ','
FROM Cities

SET @columns = LEFT(@columns, LEN(@columns) - 1);

DECLARE
@pivo NVARCHAR(MAX) = 
'SELECT * FROM (
	SELECT
		Cities.Name as CityName,
		Products.Name as ProductName,
		Price
	FROM
		Prices
		INNER JOIN Cities ON Cities.ID=Prices.CityID
		INNER JOIN Products on Products.ID = Prices.ProductID
) AS t
PIVOT(
	AVG(Price)
	FOR CityName IN
	(' + @columns + ')
) as PivoTable'

EXECUTE(@pivo)
GO