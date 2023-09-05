USE KN302_Agafonov
GO

IF OBJECT_ID('KN302_Agafonov.dbo.InsertBook', 'P') IS NOT NULL
  DROP PROCEDURE dbo.InsertBook
GO

IF OBJECT_ID('KN302_Agafonov.dbo.GetSalesInfo', 'P') IS NOT NULL
  DROP PROCEDURE dbo.GetSalesInfo
GO

---Добавляем NOT NULL---

ALTER TABLE dbo.author$ ALTER COLUMN [Код автора] INT NOT NULL

ALTER TABLE dbo.book$ ALTER COLUMN [Код автора] INT NOT NULL

ALTER TABLE dbo.book$ ALTER COLUMN [Код книги] INT NOT NULL

ALTER TABLE dbo.book$ ALTER COLUMN [Код издательства] INT NOT NULL

ALTER TABLE dbo.publishing_house$ ALTER COLUMN [Код издательства] INT NOT NULL

ALTER TABLE dbo.purchases$ ALTER COLUMN [Код покупки] INT NOT NULL

ALTER TABLE dbo.purchases$ ALTER COLUMN [Код закупаемой книги] INT NOT NULL

ALTER TABLE dbo.purchases$ ALTER COLUMN [Код поставщика] INT NOT NULL

ALTER TABLE dbo.deliveries$ ALTER COLUMN [Код поставщика] INT NOT NULL

/*Удаление повторяющихся строк*/
--author--
SELECT DISTINCT *
INTO duplicate_authors
FROM dbo.author$
GROUP BY [Код автора], [Фамилия, имя, отчество автора], [Дата рождения]
HAVING COUNT([Код автора]) > 1

DELETE dbo.author$
WHERE [Код автора]
IN (SELECT [Код автора]
FROM duplicate_authors)

INSERT dbo.author$
SELECT *
FROM duplicate_authors

DROP TABLE duplicate_authors

--book--
SELECT DISTINCT *
INTO duplicate_book
FROM dbo.book$
GROUP BY [Код книги], [Название книги], [Количество страниц], [Код автора], [Код издательства]
HAVING COUNT([Код книги]) > 1

DELETE dbo.book$
WHERE [Код книги]
IN (SELECT [Код книги]
FROM duplicate_book)

INSERT dbo.book$
SELECT *
FROM duplicate_book

DROP TABLE duplicate_book
---publishinhg house---
SELECT DISTINCT *
INTO duplicate_publishing_house
FROM dbo.publishing_house$
GROUP BY [Код издательства], Издательство, Город
HAVING COUNT([Код издательства]) > 1

DELETE dbo.publishing_house$
WHERE [Код издательства]
IN (SELECT [Код издательства]
FROM duplicate_publishing_house)

INSERT dbo.publishing_house$
SELECT *
FROM duplicate_publishing_house

DROP TABLE duplicate_publishing_house
---purchases---
SELECT DISTINCT *
INTO duplicate_purchases
FROM dbo.purchases$
GROUP BY [Код покупки], [Дата заказа книги], [Тип закупки (опт/ розница)], [Стоимость единицы товара], [Количество экземпляров], [Код поставщика], [Код закупаемой книги]
HAVING COUNT([Код покупки]) > 1

DELETE dbo.purchases$
WHERE [Код покупки]
IN (SELECT [Код покупки]
FROM duplicate_purchases)

INSERT dbo.purchases$
SELECT *
FROM duplicate_purchases

DROP TABLE duplicate_purchases
--deliveries--
SELECT DISTINCT *
INTO duplicate_deliveries
FROM dbo.deliveries$
GROUP BY [Код поставщика], [Фамилия, и#, о# ответственного лица], [Название компании-поставщика], [Юридический адрес], [Телефон контактный], ИНН
HAVING COUNT([Код поставщика]) > 1

DELETE dbo.deliveries$
WHERE [Код поставщика]
IN (SELECT [Код поставщика]
FROM duplicate_deliveries)

INSERT dbo.deliveries$
SELECT *
FROM duplicate_deliveries

DROP TABLE duplicate_deliveries

---Добавляем primary key---
/*
ALTER TABLE dbo.author$
ADD CONSTRAINT PK_author_id PRIMARY KEY ([Код автора])

ALTER TABLE dbo.book$
ADD CONSTRAINT PK_book_id PRIMARY KEY ([Код книги])

ALTER TABLE dbo.publishing_house$
ADD CONSTRAINT PK_publishing_house_id PRIMARY KEY ([Код издательства])

ALTER TABLE dbo.purchases$
ADD CONSTRAINT PK_purchases_id PRIMARY KEY ([Код покупки])

ALTER TABLE dbo.deliveries$
ADD CONSTRAINT PK_deliveries_id PRIMARY KEY ([Код поставщика])
*/

---добавляем foreign key---
/*
ALTER TABLE dbo.book$
ADD CONSTRAINT FK_author_id FOREIGN KEY ([Код автора])
REFERENCES dbo.author$ ([Код автора])

ALTER TABLE dbo.purchases$
ADD CONSTRAINT FK_book_id FOREIGN KEY ([Код закупаемой книги])
REFERENCES dbo.book$ ([Код книги])

ALTER TABLE dbo.book$
ADD CONSTRAINT FK_publishing_house_id FOREIGN KEY ([Код издательства])
REFERENCES dbo.publishing_house$ ([Код издательства])

ALTER TABLE dbo.purchases$
ADD CONSTRAINT FK_deliveries_delivery_id FOREIGN KEY ([Код поставщика])
REFERENCES dbo.deliveries$ ([Код поставщика])
*/

-------------

SELECT TOP 5 * FROM dbo.author$
GO

SELECT TOP 5 * FROM dbo.book$
GO

SELECT TOP 5 * FROM dbo.publishing_house$
GO

SELECT TOP 5 * FROM dbo.purchases$
GO

SELECT TOP 5 * FROM dbo.deliveries$
GO


/*task1*/
SELECT * FROM dbo.book$
ORDER BY [Код книги]
GO

/* или? */
SELECT [Код книги], [Название книги], [Количество страниц] FROM dbo.book$
ORDER BY [Код книги]
GO

/* task2*/
SELECT [Название книги], [Количество страниц], [Фамилия, имя, отчество автора] FROM dbo.book$
LEFT JOIN dbo.author$ ON dbo.book$.[Код автора]=dbo.author$.[Код автора]
GO

/*task 3*/
SELECT [Фамилия, имя, отчество автора] FROM dbo.author$
WHERE [Фамилия, имя, отчество автора] LIKE 'Иванов%'
GO

/*task 4*/
SELECT [Название книги], [Количество страниц] FROM dbo.book$
WHERE [Количество страниц] between 200 and 300
GO

/*task 5*/
SELECT [Фамилия, имя, отчество автора] FROM dbo.author$
WHERE [Фамилия, имя, отчество автора] LIKE 'К%'
GO

/*task 6*/
SELECT [Издательство] FROM dbo.book$
LEFT JOIN dbo.publishing_house$ ON dbo.book$.[Код издательства]=dbo.publishing_house$.[Код издательства]
WHERE [Название книги] LIKE 'Труды%' and [Город]='Новосибирск'
GO

/*task 7*/
SELECT [Стоимость единицы товара] * [Количество экземпляров] as [Суммарная стоимость], [Название книги] FROM dbo.purchases$
LEFT JOIN dbo.book$ ON dbo.purchases$.[Код закупаемой книги]=dbo.book$.[Код книги]
GO

/*task 8*/
SELECT AVG(ROUND([Стоимость единицы товара], 0)) as [Средняя стоимость], AVG([Количество экземпляров]) as [Среднее кол-во экземпляров] FROM dbo.purchases$
LEFT JOIN dbo.book$ ON dbo.purchases$.[Код закупаемой книги]=dbo.book$.[Код книги]
LEFT JOIN dbo.author$ ON dbo.book$.[Код автора]=dbo.author$.[Код автора]
WHERE dbo.author$.[Фамилия, имя, отчество автора] LIKE'%Акунин%'
GO

/* task 9*/
SELECT SUM(ROUND([Стоимость единицы товара], 0)) as Sum_cost FROM dbo.purchases$
LEFT JOIN dbo.deliveries$ ON dbo.purchases$.[Код поставщика]=dbo.deliveries$.[Код поставщика]
WHERE dbo.deliveries$.[Название компании-поставщика] = 'ОАО Луч'
GO

/* task 10*/
SELECT [Фамилия, имя, отчество автора]  FROM dbo.author$
LEFT JOIN dbo.book$ ON dbo.author$.[Код автора]=dbo.book$.[Код автора]
LEFT JOIN dbo.publishing_house$ ON dbo.book$.[Код издательства]=dbo.publishing_house$.[Код издательства]
WHERE dbo.publishing_house$.[Издательство] IN ('Мир', 'Питер Софт', 'Наука')
GO

/*task 11*/
SELECT [Название книги] FROM dbo.book$
WHERE [Количество страниц] > (SELECT AVG([Количество страниц]) FROM dbo.book$)
GO

/*task 12*/
SELECT [Название книги] FROM dbo.book$
LEFT JOIN dbo.purchases$ ON dbo.book$.[Код книги]=dbo.purchases$.[Код закупаемой книги]
LEFT JOIN dbo.deliveries$ ON dbo.purchases$.[Код поставщика]=dbo.deliveries$.[Код поставщика]
WHERE dbo.deliveries$.[Название компании-поставщика] = 'ЗАО Квантор' 
GO

/*task 13*/
CREATE PROCEDURE InsertBook
@pagesCount int, @authorCode int, @publishingCode int
AS
	DECLARE @maxId int = (SELECT MAX([Код книги]) FROM dbo.book$)
	INSERT dbo.book$ VALUES
		(@maxID + 1, 'Наука. Техника. Инновации', @pagesCount, @authorCode, @publishingCode)
GO

EXECUTE dbo.InsertBook 50, 11, 10
GO

SELECT * FROM dbo.book$
GO

/* task 14*/
DROP TRIGGER PurchasesTrigger
GO
CREATE TRIGGER PurchasesTrigger
	ON dbo.purchases$
	FOR INSERT, UPDATE
AS
	DECLARE @deliveriesWithNullCount int
	SET @deliveriesWithNullCount = (SELECT COUNT(*) FROM inserted
		LEFT JOIN dbo.deliveries$ ON inserted.[Код поставщика]=dbo.deliveries$.[Код поставщика]
		WHERE [Юридический адрес] is NULL or [Телефон контактный] is NULL)
	IF @deliveriesWithNullCount != 0
		ROLLBACK transaction;
GO


/*добавим поставщика с NULL в качестве юридического адреса*/
/*
INSERT dbo.deliveries$ VALUES
	(16, 'dilivery16', 'ОАО Луч', NULL, '234354', 129837456)
GO
SELECT * FROM dbo.deliveries$
GO
*/

/*добавим заказ для этого поставщика*/
INSERT dbo.purchases$ VALUES
	(70, '21.02.2023', 0, 50, 1, 16, 5)
GO
SELECT * FROM dbo.purchases$
GO

/*изменим поставщика существующей книги на этого поставщика*/
UPDATE dbo.purchases$ 
SET dbo.purchases$.[Код поставщика] = 16
WHERE [Код покупки]=1
GO

/*task 15*/
CREATE PROCEDURE GetSalesInfo
@inn int
AS
	SELECT [Дата заказа книги], [Название книги], [Издательство], [Стоимость единицы товара]*[Количество экземпляров] AS [Общая стоимость] FROM dbo.book$ 
		LEFT JOIN dbo.purchases$ ON dbo.book$.[Код книги]=dbo.purchases$.[Код закупаемой книги]
		LEFT JOIN dbo.deliveries$ ON dbo.purchases$.[Код поставщика]=dbo.deliveries$.[Код поставщика]
		LEFT JOIN dbo.publishing_house$ ON dbo.book$.[Код издательства]=dbo.publishing_house$.[Код издательства]
			WHERE [ИНН]=@inn
			ORDER BY [Дата заказа книги]
GO

EXEC GetSalesInfo 19354851
GO