USE KN302_Agafonov
GO
IF OBJECT_ID('KN302_Agafonov.dbo.StationNames', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.StationNames
GO
IF OBJECT_ID('KN302_Agafonov.dbo.MeasurementTypes', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.MeasurementTypes
GO
IF OBJECT_ID('KN302_Agafonov.dbo.Measurements', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.Measurements
GO
IF OBJECT_ID('KN302_Agafonov.dbo.Units', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.Units

GO 
CREATE TABLE StationNames
   (StationID int PRIMARY KEY NOT NULL, 
    StationName text NOT NULL) 
GO
CREATE TABLE MeasurementTypes 
   (MeasurementTypeID int PRIMARY KEY NOT NULL, 
	TypeName text NOT NULL) 
GO
CREATE TABLE Measurements
   (MeasurementID INT PRIMARY KEY NOT NULL,
   MeasurementDate Date NOT NULL,
   MeasurementTime Time NOT NULL,
   MeasurementValue float NOT NULL) 

INSERT MeasurementTypes (MeasurementTypeID, TypeName)
    VALUES
	(1, 'Влажность'), 
	(2, 'Давление'),
	(3, 'Температура воздуха'),
	(4, 'Температура воды'),
	(5, 'Скорость ветра'),
	(6, 'Излучение солнца') 

INSERT StationNames(StationID, StationName)
    VALUES
	(1, 'Москва'),
	(2, 'Санкт-Петербург'),
	(3, 'Новосибирск'),
	(4, 'Екатеринбург'),
	(5, 'Казань'),
	(6, 'Нижний Новгород'),
	(7, 'Челябинск'),
	(8, 'Красноярск'),
	(9, 'Самара'),
	(10, 'Уфа')
INSERT Measurements(MeasurementID, MeasurementDate, MeasurementTime, MeasurementValue)
    VALUES
	(1, '2022-07-11', '02:03:59', 1.0),
	(2, '2022-05-05', '03:15:49', 0.7),
	(3, '2022-11-06', '04:53:05', 55),
	(4, '2022-07-08', '15:33:55', 55),
	(5, '2022-05-09', '16:03:34', 31),
	(6, '2022-01-17', '07:09:43', 12),
	(7, '2022-03-03', '08:03:51', 0.4),
	(8, '2022-07-23', '09:05:15', 1),
	(9, '2022-06-12', '10:13:26', 23),
	(10, '2022-09-26', '15:33:39', 44)

GO
ALTER TABLE Measurements 
    ADD MeasurementTypeID INT,
    FOREIGN KEY (MeasurementTypeID) REFERENCES MeasurementTypes(MeasurementTypeID)
GO
ALTER TABLE StationNames
	ADD StationAddress text NOT NULL DEFAULT 'Россия, г.'
GO
INSERT StationNames(StationID, StationName)
    VALUES
	(11, 'Васюки')



GO
CREATE TABLE Units
   (UnitID int PRIMARY KEY NOT NULL,
	FullName varchar(50) NOT NULL, 
	Designation text NOT NULL) 
GO 
INSERT Units(UnitID, FullName, Designation)
    VALUES
    (1, 'Проценты', '%'),
    (2, 'Миллиметр ртутного столба', 'мм рт. ст.'),
    (3, 'Цельсии', '°'),
    (4, 'Метр в секунду', 'м/с')

GO
ALTER TABLE MeasurementTypes
	ADD UnitOfMeasurement int NULL

GO
ALTER TABLE Measurements
    ADD UnitID INT,
    FOREIGN KEY (UnitID) REFERENCES Units(UnitID);


GO
DECLARE @i INT = 0
 
WHILE @i <= 10
BEGIN
    SET @i = @i + 1
 
    UPDATE Measurements
    SET MeasurementTypeID = @i + 1
    WHERE MeasurementID = @i;

END
SELECT* FROM MeasurementTypes
SELECT* FROM Measurements

GO

DECLARE @j INT = 0
 
WHILE @j <= 10
BEGIN
    SET @j = @j + 1
    UPDATE Measurements
    SET UnitID = @j + 2
    WHERE MeasurementID = @j;
END

GO
DECLARE @k INT = 0

WHILE @k <= 6
BEGIN
     SET @k = @k + 1
     UPDATE MeasurementTypes 
     SET UnitOfMeasurement = @k + 3
	 WHERE MeasurementTypeID = @k;
END


SELECT* FROM MeasurementTypes
SELECT* FROM Measurements


--TASK1
GO
SELECT DISTINCT MeasurementDate 
FROM Measurements 
ORDER BY MeasurementDate ASC

--TASK2
GO
SELECT MeasurementTypeID, MAX(MeasurementValue) as MaxMeasurementValue, MIN(MeasurementValue) as MInMeasurementValue 
FROM Measurements
GROUP BY MeasurementTypeID
--TASK3
GO
SELECT * FROM Measurements 
  WHERE MeasurementTypeID IN (SELECT MeasurementTypeID FROM MeasurementTypes
  WHERE UnitOfMeasurement IN (SELECT UnitID FROM Units WHERE FullName = 'Цельсии'))
--TASK4
GO
SELECT DISTINCT MeasurementTypeId, MeasurementDate, MeasurementValue FROM Measurements AS FirstM
WHERE MeasurementValue IN (SELECT MIN(MeasurementValue) FROM Measurements AS SecondM
WHERE FirstM.MeasurementTypeID = SecondM.MeasurementTypeID);

SELECT * FROM Units
SELECT * FROM MeasurementTypes

--Task5
SELECT TypeName, FullName 
FROM MeasurementTypes LEFT JOIN Units ON MeasurementTypes.UnitOfMeasurement=Units.UnitID;

GO
SELECT MeasurementTypes.TypeName, Units.FullName
FROM MeasurementTypes, Units
WHERE MeasurementTypes.UnitOfMeasurement=Units.UnitID 

--Task6
SELECT FORMAT(Дата, 'dd/MMMM/yyyy', 'ru-RU' ) AS Дата, MeasurementTypes.TypeName AS Тип_Измерения, Среднее_Значение, Units.FullName AS Единицы_Измерения FROM
    (SELECT MeasurementDate AS Дата, MeasurementTypeID AS Тип_Измерения,
        AVG(MeasurementValue) AS Среднее_Значение
        FROM Measurements, Units
    GROUP BY MeasurementDate, MeasurementTypeID) K
    LEFT JOIN MeasurementTypes ON MeasurementTypes.MeasurementTypeID=K.Тип_Измерения
    LEFT JOIN Units ON K.Тип_Измерения=Units.UnitID
GO

