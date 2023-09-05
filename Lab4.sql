USE KN302_Agafonov
GO
IF OBJECT_ID('KN302_Agafonov.dbo.Regions', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.Regions
GO
IF OBJECT_ID('KN302_Agafonov.dbo.CarsInOut', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.CarsInOut
GO
IF OBJECT_ID('KN302_Agafonov.dbo.InOut', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.InOut
GO
IF OBJECT_ID('KN302_Agafonov.dbo.CarsInOut', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.CarsInOut
GO
IF OBJECT_ID('KN302_Agafonov.dbo.RegionNames', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.RegionNames
GO
IF OBJECT_ID('KN302_Agafonov.dbo.Checkpoints', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.Checkpoints
GO
IF OBJECT_ID('KN302_Agafonov.dbo.Cars', 'U') IS NOT NULL
  DROP TABLE KN302_Agafonov.dbo.Cars
GO
IF OBJECT_ID('GetRegionIdByNumber') IS NOT NULL
  DROP FUNCTION GetRegionIdByNumber
GO
IF OBJECT_ID('lastInOut') IS NOT NULL
  DROP FUNCTION lastInOut
GO
IF OBJECT_ID('Transit') IS NOT NULL
  DROP FUNCTION Transit
GO
IF OBJECT_ID('Nonresident') IS NOT NULL
  DROP FUNCTION Nonresident
GO
IF OBJECT_ID('Local') IS NOT NULL
  DROP FUNCTION Local
GO
IF OBJECT_ID('Other') IS NOT NULL
  DROP FUNCTION Other
GO
IF OBJECT_ID('lastInOutTime') IS NOT NULL
  DROP FUNCTION lastInOutTime
GO
IF OBJECT_ID('lastInOutCheckpoint') IS NOT NULL
  DROP FUNCTION lastInOutCheckpoint
GO
IF OBJECT_ID('allCarsInOrOut') IS NOT NULL
  DROP FUNCTION allCarsInOrOut
GO

CREATE TABLE RegionNames(
	RegionId int PRIMARY KEY NOT NULL,
	RegionName varchar(40) NOT NULL
)
GO

INSERT RegionNames(RegionId, RegionName)
	VALUES 
	(1, 'Свердловская область'),
	(2, 'Москва'),
	(3, 'Свердловская область')
GO

CREATE TABLE Regions(
	RegionNumber int PRIMARY KEY NOT NULL CONSTRAINT RegionNumber_chk CHECK (
		CAST(RegionNumber AS varchar(3)) LIKE '[0-9][1-9]' OR
		CAST(RegionNumber AS varchar(3)) LIKE '[127][0-9][1-9]'
	),
	RegionId int NOT NULL CONSTRAINT RegionId_fk REFERENCES RegionNames(RegionId)
)
GO

INSERT Regions(RegionNumber, RegionId)
	VALUES 
	(66, 1),
	(196, 1),
	(77, 2),
	(78, 3)
GO

CREATE TABLE InOut(
	InOutId int PRIMARY KEY NOT NULL,
	InOutName varchar(5) NOT NULL
)
GO

INSERT InOut(InOutId, InOutName)
	VALUES 
	(0, 'Въезд'),
	(1, 'Выезд')
GO

CREATE TABLE Cars(
	CarsId int PRIMARY KEY NOT NULL,
	CarsNumber varchar(10) NOT NULL CONSTRAINT CarsNumber_chk CHECK (
		CarsNumber LIKE '[АВЕКМНОРСТУХ][0-9][0-9][0-9][АВЕКМНОРСТУХ][АВЕКМНОРСТУХ][0-9][0-9]' OR
		CarsNumber LIKE '[АВЕКМНОРСТУХ][0-9][0-9][0-9][АВЕКМНОРСТУХ][АВЕКМНОРСТУХ][127][0-9][1-9]'
	)
)
GO

INSERT Cars(CarsId, CarsNumber)
	VALUES 
	(1, 'Р234ЕЕ196'),
	(2, 'Р212ОЕ66'),
	(3, 'К263СС77'),
	(4, 'Е235НН77'),
	(5, 'Р254РР59'),
	(6, 'Н656ОО66'),
	(7, 'Н756ОО77')
GO

CREATE TABLE Checkpoints(
	CheckpointsId int PRIMARY KEY NOT NULL,
	CheckpointsName varchar(30) NOT NULL
)
GO

INSERT Checkpoints(CheckpointsId, CheckpointsName)
	VALUES 
	(1, 'Checkpoint1'),
	(2, 'Checkpoint2'),
	(3, 'Checkpoint3'),
	(4, 'Checkpoint4')
GO

CREATE TABLE CarsInOut(
	CarInOutId int PRIMARY KEY NOT NULL,
	CarId int NOT NULL CONSTRAINT CarId_fk REFERENCES Cars(CarsId),
	CheckpointId int NOT NULL CONSTRAINT CheckpointId_fk REFERENCES Checkpoints(CheckpointsId),
	InOutId int NOT NULL CONSTRAINT InOutId_fk REFERENCES InOut(InOutId),
	InOutTime time  NOT NULL
)
GO

INSERT CarsInOut(CarInOutId, CarId, CheckpointId, InOutId, InOutTime)
	VALUES 
	(1, 1, 1, 0, '9:45:30'),
	(2, 2, 1, 0, '10:22:44'),
	(3, 3, 2, 1, '8:44:10'),
	(4, 2, 1, 1, '16:55:16')
GO

-- Проверяем, что автомобиль с таким же ID до этого не проезжал по той же стороне
CREATE TRIGGER trigger_CarsInOut
	ON CarsInOut AFTER INSERT
	AS IF EXISTS (
		SELECT * FROM inserted AS i
		WHERE i.InOutId = (
			SELECT TOP 1 exInOut.InOutId FROM CarsInOut exInOut
			WHERE i.CarId = exInOut.CarId AND
				  i.InOutTime > exInOut.InOutTime
			ORDER BY exInOut.InOutTime DESC
		)
	)
BEGIN
	PRINT 'Ошибка вставки данных'
	ROLLBACK TRANSACTION
END
GO
INSERT CarsInOut(CarInOutId, CarId, CheckpointId, InOutId, InOutTime)
	VALUES 
	(5, 1, 3, 1, '13:45:30'),
	(6, 4, 3, 0, '9:45:30'),
	(7, 4, 2, 1, '11:45:30'),
	(8, 5, 2, 0, '11:45:30'),
	(9, 5, 2, 1, '17:45:30'),
	(10, 1, 2, 0, '17:45:30')
GO

INSERT CarsInOut(CarInOutId, CarId, CheckpointId, InOutId, InOutTime)
	VALUES 
	(11, 6, 3, 0, '9:35:30'),
	(12, 6, 3, 1, '10:35:30'),
	(13, 6, 3, 0, '11:35:30'),
	(14, 6, 3, 1, '12:35:30'),
	(15, 6, 3, 0, '14:35:30'),
	(16, 7, 4, 0, '19:35:30')
GO

--Проверка триггера. Автомобиль с CarId = 4 уже выезжал с третьего поста минутой ранее


INSERT CarsInOut(CarInOutId, CarId, CheckpointId, InOutId, InOutTime)
	VALUES 
	(23, 4, 3, 0, '9:46:30'),
	(42, 7, 4, 0, '19:35:30')
	GO


--1
CREATE FUNCTION GetRegionIdByNumber(@number varchar(10))
RETURNS int AS BEGIN
	DECLARE @res_raw varchar(3) = '';
	DECLARE @res int = 0;
	SET @res_raw = (
		CASE LEN(@number)
			WHEN 9 THEN RIGHT(@number, 3)
			WHEN 8 THEN RIGHT(@number, 2)
		END
	)
	RETURN CAST(@res_raw AS int)
END;
GO

PRINT dbo.GetRegionIdByNumber('Р212ОЕ66')
--66

GO
CREATE FUNCTION lastInOut(@carId int, @InOutId int)
RETURNS TABLE AS RETURN(
	SELECT TOP 1 * FROM CarsInOut cInOut
	WHERE cInOut.CarId = @carId AND cInOut.InOutId = @InOutId
	ORDER BY cInOut.InOutTime DESC
)
GO

SELECT * FROM dbo.lastInOut(3, 1)
GO

SELECT * FROM dbo.lastInOut(3, 0)
GO

--Транзитные
CREATE FUNCTION Transit(@baseRegion varchar(100))
RETURNS TABLE AS RETURN(
	SELECT DISTINCT
		cInOut.CarId,
		cars.CarsNumber,
		rg.RegionNumber,
		rgN.RegionName
	FROM 
		CarsInOut cInOut 
		JOIN Cars cars ON cars.CarsId = cInOut.CarId
		JOIN Regions rg ON rg.RegionNumber = dbo.GetRegionIdByNumber(cars.CarsNumber)
		JOIN RegionNames rgN ON rgN.RegionId = rg.RegionId
	WHERE EXISTS(
		SELECT * FROM 
			lastInOut(cInOut.CarId, 0) lastI, 
			lastInOut(cInOut.CarId, 1) lastO
		WHERE lastO.InOutTime > lastI.InOutTime AND
			lastO.CheckpointId != lastI.CheckpointId
	) AND rgN.RegionName != @baseRegion
)
GO

--Иногородние
CREATE FUNCTION Nonresident(@baseRegion varchar(100))
RETURNS TABLE AS RETURN(
	SELECT DISTINCT
		cInOut.CarId,
		cars.CarsNumber,
		rg.RegionNumber,
		rgN.RegionName
	FROM 
		CarsInOut cInOut 
		JOIN Cars cars ON cars.CarsId = cInOut.CarId
		JOIN Regions rg ON rg.RegionNumber = dbo.GetRegionIdByNumber(cars.CarsNumber)
		JOIN RegionNames rgN ON rgN.RegionId = rg.RegionId
	WHERE EXISTS(
		SELECT * FROM 
			lastInOut(cInOut.CarId, 0) lastI, 
			lastInOut(cInOut.CarId, 1) lastO
		WHERE lastO.InOutTime > lastI.InOutTime AND
			lastO.CheckpointId = lastI.CheckpointId
	) AND rgN.RegionName != @baseRegion
)
GO

--Местные
CREATE FUNCTION Local(@baseRegion varchar(100))
RETURNS TABLE AS RETURN(
	SELECT DISTINCT
		cInOut.CarId,
		cars.CarsNumber,
		rg.RegionNumber,
		rgN.RegionName
	FROM 
		CarsInOut cInOut 
		JOIN Cars cars ON cars.CarsId = cInOut.CarId
		JOIN Regions rg ON rg.RegionNumber = dbo.GetRegionIdByNumber(cars.CarsNumber)
		JOIN RegionNames rgN ON rgN.RegionId = rg.RegionId
	WHERE EXISTS(
		SELECT * FROM 
			lastInOut(cInOut.CarId, 0) lastI, 
			lastInOut(cInOut.CarId, 1) lastO
		WHERE lastO.InOutTime < lastI.InOutTime
	) AND rgN.RegionName = @baseRegion
)
GO

--Остальные
CREATE FUNCTION Other(@baseRegion varchar(100))
RETURNS TABLE AS RETURN(
	SELECT DISTINCT
		cInOut.CarId,
		cars.CarsNumber,
		rg.RegionNumber,
		rgN.RegionName
	FROM 
		CarsInOut cInOut
		JOIN Cars cars ON cars.CarsId = cInOut.CarId
		JOIN Regions rg ON rg.RegionNumber = dbo.GetRegionIdByNumber(cars.CarsNumber)
		JOIN RegionNames rgN ON rgN.RegionId = rg.RegionId,
		dbo.Transit(@baseRegion) transit,
		dbo.Nonresident(@baseRegion) nonresident,
		dbo.Local(@baseRegion) local
	WHERE cInOut.CarId NOT IN (transit.CarId) AND
		cInOut.CarId NOT IN (nonresident.CarId) AND
		cInOut.CarId NOT IN (local.CarId)
)
GO

SELECT * FROM dbo.Transit('Свердловская область')
GO
SELECT * FROM dbo.Nonresident('Свердловская область')
GO
SELECT * FROM dbo.Local('Свердловская область')
GO
SELECT * FROM dbo.Other('Свердловская область')
GO
SELECT COUNT(other.CarId) as CountOfOtherCars FROM dbo.Other('Свердловская область') other;

GO

WITH cars AS (
	SELECT DISTINCT CarsInOut.CarId
	FROM CarsInOut
)
SELECT COUNT(1) AS CarsCount
FROM cars

GO

--Получает последнее время въезда/выезда заданной машины
CREATE FUNCTION lastInOutTime(@carId int, @InOutId int)
RETURNS time AS BEGIN 
	DECLARE @res time
	SELECT @res = MAX(temp.InOutTime) FROM (
		SELECT
			TOP 1 cInOut.InOutTime 
		FROM CarsInOut cInOut
		WHERE cInOut.CarId = @carId AND cInOut.InOutId = @InOutId
		ORDER BY cInOut.InOutTime DESC
	) temp
	RETURN @res
END
GO

--Получает последний пост въезда/выезда заданной машины
CREATE FUNCTION lastInOutCheckpoint(@carId int, @InOutId int)
RETURNS varchar(30) AS BEGIN 
	DECLARE @res varchar(30)
	SELECT @res = MAX(temp.CheckpointsName) FROM (
		SELECT
			TOP 1 cp.CheckpointsName 
		FROM CarsInOut cInOut
			JOIN Checkpoints cp ON cp.CheckpointsId = cInOut.CheckpointId
		WHERE cInOut.CarId = @carId AND cInOut.InOutId = @InOutId
		ORDER BY cInOut.InOutTime DESC
	) temp
	RETURN @res
END
GO

--Показывает в одной таблице время въезда/выезда, а также пост для каждой машины
SELECT DISTINCT
	cInOutRes.CarsNumber,
	cInOutRes.RegionName,
	dbo.lastInOutTime(cInOutRes.CarsId, 0) AS EnterTime,
	dbo.lastInOutCheckpoint(cInOutRes.CarsId, 0) AS EnterCheckpoint,
	dbo.lastInOutTime(cInOutRes.CarsId, 1) AS ExitTime,
	dbo.lastInOutCheckpoint(cInOutRes.CarsId, 1) AS ExitCheckpoint
FROM (
	SELECT
		cars.CarsId,
		cars.CarsNumber,
		rgN.RegionName
	FROM
		CarsInOut cInOut 
		JOIN Cars cars ON cars.CarsId = cInOut.CarId
		JOIN Regions rg ON rg.RegionNumber = dbo.GetRegionIdByNumber(cars.CarsNumber)
		JOIN RegionNames rgN ON rgN.RegionId = rg.RegionId
) cInOutRes
ORDER BY cInOutRes.RegionName
GO


--Получает все въехавшие/выехавшие автомобили
CREATE FUNCTION allCarsInOrOut(@InOutId int)
	RETURNS TABLE AS RETURN(
		SELECT * FROM CarsInOut cInOut
		WHERE cInOut.InOutId = @InOutId
	)
GO

SELECT * FROM Regions

SELECT * FROM CarsInOut
GO
SELECT
	cI.CarId,
	cars.CarsNumber,
	rgN.RegionName,
	cI.InOutTime AS InCity,
	cI.CheckpointId,
	cp.CheckpointsName,
	cO.InOutTime AS OutCity,
	cO.CheckpointId,
	cp2.CheckpointsName
FROM
	dbo.allCarsInOrOut(0) cI
	LEFT JOIN dbo.allCarsInOrOut(1) cO
		ON cI.CarId = cO.CarId and
		cO.InOutTime > cI.InOutTime and
		not EXISTS(
			SELECT * FROM dbo.allCarsInOrOut(0) cI2
			WHERE
				cI2.CarId = cI.CarId and
				cI2.InOutTime > cI.InOutTime and
				cI2.InOutTime < cO.InOutTime
		)
	LEFT JOIN Cars cars ON cars.CarsId = cI.CarId
	LEFT JOIN Regions rg ON rg.RegionNumber = dbo.GetRegionIdByNumber(cars.CarsNumber)
	LEFT JOIN RegionNames rgN ON rgN.RegionId = rg.RegionId
	LEFT JOIN Checkpoints cp ON cp.CheckpointsId = cI.CheckpointId
	LEFT JOIN Checkpoints cp2 ON cp2.CheckpointsId = cO.CheckpointId
UNION
SELECT
	cO.CarId,
	cars.CarsNumber,
	rgN.RegionName,
	cI.InOutTime AS InCity,
	cI.CheckpointId,
	cp.CheckpointsName,
	cO.InOutTime AS OutCity,
	cO.CheckpointId,
	cp2.CheckpointsName
FROM
	dbo.allCarsInOrOut(1) cO
	LEFT JOIN dbo.allCarsInOrOut(0) cI
		ON cO.CarId = cI.CarId and
		cI.InOutTime < cO.InOutTime and
		not EXISTS(
			SELECT * FROM dbo.allCarsInOrOut(1) cO2
			WHERE
				cO2.CarId = cO.CarId and
				cO2.InOutTime < cO.InOutTime and
				cO2.InOutTime > cI.InOutTime
		)
	LEFT JOIN Cars cars ON cars.CarsId = cO.CarId
	LEFT JOIN Regions rg ON rg.RegionNumber = dbo.GetRegionIdByNumber(cars.CarsNumber)
	LEFT JOIN RegionNames rgN ON rgN.RegionId = rg.RegionId
	LEFT JOIN Checkpoints cp ON cp.CheckpointsId = cI.CheckpointId
	LEFT JOIN Checkpoints cp2 ON cp2.CheckpointsId = cO.CheckpointId
GO