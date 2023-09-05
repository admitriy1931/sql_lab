USE KN302_Agafonov
GO

IF OBJECT_ID('GetStudentsCountWhoGotMoreThanXPoints') IS NOT NULL
    DROP FUNCTION GetStudentsCountWhoGotMoreThanXPoints
GO

IF OBJECT_ID('GetAveragePointsBySubjectWhenGotMoreThanXInOther') IS NOT NULL
    DROP FUNCTION GetAveragePointsBySubjectWhenGotMoreThanXInOther
GO

IF OBJECT_ID('GetStudentNameByScoreRegionAndSubject') IS NOT NULL
    DROP FUNCTION GetStudentNameByScoreRegionAndSubject
GO

IF OBJECT_ID('GetParticipantsListThatGotMoreThanXPointsInTwoЛист2$') IS NOT NULL
    DROP PROCEDURE GetParticipantsListThatGotMoreThanXPointsInTwoЛист2$
GO

IF OBJECT_ID('ScoreSum') IS NOT NULL
	DROP VIEW ScoreSum

IF OBJECT_ID('GetStudentList') IS NOT NULL
    DROP PROCEDURE GetStudentList
GO

IF OBJECT_ID('GetNameByID') IS NOT NULL
    DROP FUNCTION GetNameByID
GO

IF OBJECT_ID('Transform') IS NOT NULL
    DROP FUNCTION Transform
GO

IF OBJECT_ID('CombineMinAndMax2') IS NOT NULL
    DROP FUNCTION CombineMinAndMax2
GO

IF OBJECT_ID('GetCombinations') IS NOT NULL
    DROP FUNCTION GetCombinations
GO

--a

	
GO
CREATE FUNCTION GetStudentsCountWhoGotMoreThanXPoints(@x INT, @firstSubject NVARCHAR(250), @secondSubject NVARCHAR(250), @thirdSubject NVARCHAR(250))
RETURNS INT
AS BEGIN
	DECLARE @count INT;
	
	WITH Fixed AS (
		SELECT s.Дисциплина, [Номер участника], Баллы
		FROM Лист3$ as f
		LEFT JOIN Лист2$ as s ON f.Дисциплина = s.Номер
		WHERE s.Дисциплина IN (@firstSubject, @secondSubject, @thirdSubject)
	)
	SELECT @count = COUNT(*) FROM (
		SELECT [Номер участника]
		FROM Fixed
		GROUP BY [Номер участника]
		HAVING SUM(Баллы) > @x
	) AS _


    RETURN @count
END

GO

--Тесты для а

PRINT(dbo.GetStudentsCountWhoGotMoreThanXPoints(0, 'Русский язык', 'Математика', 'Информатика'))

PRINT(dbo.GetStudentsCountWhoGotMoreThanXPoints(400, 'Русский язык', 'Математика', 'Информатика'))

PRINT(dbo.GetStudentsCountWhoGotMoreThanXPoints(200, '', '', ''))



--b	

GO
CREATE FUNCTION GetAveragePointsBySubjectWhenGotMoreThanXInOther(@targetSubject NVARCHAR(250), @secondSubject NVARCHAR(250), @secondSubjectScore INT)
RETURNS FLOAT
AS BEGIN
	DECLARE @avg FLOAT;
	
	WITH Numbers AS (
		SELECT [Номер участника]
		FROM Лист3$ as f
		LEFT JOIN Лист2$ as s ON f.Дисциплина = s.Номер
		WHERE s.Дисциплина = @secondSubject AND Баллы > @secondSubjectScore
	), TEMP AS (
		SELECT Баллы
		FROM Лист3$ as f
		LEFT JOIN Лист2$ as s ON f.Дисциплина = s.Номер
		WHERE s.Дисциплина = @targetSubject AND [Номер участника] IN (SELECT * FROM Numbers)
	)
	SELECT @avg = AVG(Баллы) FROM TEMP


    RETURN @avg
END

GO

--Тесты для b


PRINT(dbo.GetAveragePointsBySubjectWhenGotMoreThanXInOther('Русский язык', 'Русский язык', 0))

PRINT(dbo.GetAveragePointsBySubjectWhenGotMoreThanXInOther('Русский язык', 'Русский язык', 99))


--c

GO

CREATE PROCEDURE GetStudentList
	@score INT
AS
BEGIN
	DECLARE @FullName NVARCHAR(255), @ID INT, @Subjects NVARCHAR(2500), @Line NVARCHAR(255)
	DECLARE helper cursor local for
		SELECT Фамилия + ' ' + Имя + ' ' + Отчество, Лист3$.[Номер участника], STRING_AGG(Лист2$.Дисциплина, ', ') AS [Дисциплины, по которым более  баллов]
		FROM Лист3$
		JOIN Лист2$ ON Лист3$.Дисциплина = Лист2$.Номер
		JOIN Лист1$ ON Лист3$.[Номер участника] = Лист1$.Номер
		WHERE Баллы >90
		GROUP BY Лист3$.[Номер участника]
		HAVING COUNT(*) >= 2


	OPEN helper
		FETCH NEXT FROM helper INTO @FullName, @ID, @Subjects
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @Line = @FullName + ' ' + @Subjects
				PRINT @Line
				FETCH NEXT FROM helper INTO @FullName, @ID, @Subjects
			END
	CLOSE helper
	DEALLOCATE helper
END
GO


--Тесты для c

EXEC dbo.GetStudentList 90


--d
GO

CREATE VIEW ScoreSum AS (
	SELECT marks.[Номер участника], SUM(marks.Баллы) AS [Сумма баллов]
	FROM Лист3$ marks
	GROUP BY marks.[Номер участника]
)
GO

SELECT marks.[Сумма баллов], COUNT(marks.[Номер участника]) AS [Количество студентов]
FROM dbo.ScoreSum as marks
GROUP BY marks.[Сумма баллов]
ORDER BY marks.[Сумма баллов] DESC
GO

Select * FROM dbo.Лист3$
--e

GO

CREATE FUNCTION GetStudentNameByScoreRegionAndSubject(@subject NVARCHAR(250), @score INT, @region NVARCHAR(250))
RETURNS NVARCHAR(250)
AS BEGIN
	DECLARE @name NVARCHAR(250);
	
	SELECT TOP 1 @name = (Фамилия + ' ' +  Имя + ' ' + Отчество)
	FROM Лист3$
	INNER JOIN Лист2$ ON Лист3$.Дисциплина = Лист2$.Номер
	INNER JOIN Лист1$ ON Лист3$.[Номер участника] = Лист1$.Номер
	INNER JOIN Лист4$ ON Лист1$.Номер = Лист4$.[Номер участника] AND Лист4$.Дисциплина = Лист3$.Дисциплина
	WHERE округ = @region AND Баллы = @score AND Лист2$.Дисциплина = @subject


    RETURN @name
END

GO

WITH TEMP AS (
	SELECT DISTINCT Фамилия, Имя, Отчество, Лист2$.Дисциплина, Баллы, округ
	FROM Лист3$
	INNER JOIN Лист2$ ON Лист3$.Дисциплина = Лист2$.Номер
	INNER JOIN Лист1$ ON Лист3$.[Номер участника] = Лист1$.Номер
	INNER JOIN Лист4$ ON Лист1$.Номер = Лист4$.[Номер участника] AND Лист4$.Дисциплина = Лист3$.Дисциплина
)
SELECT Округ, Дисциплина, AVG(Баллы) AS [Средний балл], MIN(Баллы) AS [Минимальный балл], MAX(Баллы) AS [Максимальный балл],
	dbo.GetStudentNameByScoreRegionAndSubject(Дисциплина, MAX(Баллы), Округ) AS [Участник, получивший максимальный балл]
FROM TEMP
GROUP BY Округ, Дисциплина
ORDER BY Округ

GO



--f

CREATE FUNCTION GetCombinations()
RETURNS @res TABLE(First_ INT, Second_ INT, Third_ INT) 
AS 
BEGIN
	DECLARE @UsedDisciplines TABLE(discipline INT)

	INSERT INTO @UsedDisciplines
	SELECT marks.Дисциплина FROM Лист3$ marks GROUP BY marks.Дисциплина

	DECLARE @f int = 1
	DECLARE @count int = 0
	SELECT @count = COUNT(disciplines.Номер) FROM Лист2$ disciplines
	WHILE @f <= @count - 2 BEGIN
		IF (EXISTS(SELECT * FROM @UsedDisciplines ud WHERE ud.discipline = @f)) BEGIN
			DECLARE @s int = @f + 1
			WHILE @s <= @count - 1 BEGIN
				IF (EXISTS(SELECT * FROM @UsedDisciplines ud WHERE ud.discipline = @s)) BEGIN
					DECLARE @t int = @s + 1
					WHILE @t <= @count BEGIN
						IF (EXISTS(SELECT * FROM @UsedDisciplines ud WHERE ud.discipline = @t))
							INSERT @res VALUES (@f, @s, @t)
						SET @t = @t + 1
					END
				END
				SET @s = @s + 1
			END
		END
		SET @f = @f + 1
	END
RETURN
END

GO

CREATE FUNCTION GetNameByID(@first INT, @second INT, @third INT)
RETURNS varchar(500) AS BEGIN
	DECLARE @result varchar(500) = ''

	SELECT @result = @result + disciplines.Дисциплина + ' '
	FROM Лист2$ disciplines
	WHERE disciplines.Номер = @first OR disciplines.Номер = @second OR disciplines.Номер = @third

	RETURN @result
END

GO

CREATE FUNCTION Transform(@first INT, @second INT, @third INT)
RETURNS @res TABLE(dId int) 
	AS BEGIN
		INSERT @res VALUES(@first)
		INSERT @res VALUES(@second)
		INSERT @res VALUES(@third)
	RETURN
END	

GO

CREATE FUNCTION CombineMinAndMax2()
RETURNS @res TABLE(marks varchar(500), minScore int, maxScore int) AS BEGIN
	DECLARE @first INT = 0
	DECLARE @second INT = 0
	DECLARE @third INT = 0
	DECLARE db_cursor CURSOR FOR
	SELECT
		cmb.First_, cmb.Second_, cmb.Third_
	FROM
		dbo.GetCombinations() cmb

	OPEN db_cursor
	FETCH NEXT FROM db_cursor INTO
		@first, @second, @third

	WHILE @@FETCH_STATUS = 0 BEGIN
		INSERT INTO @res(marks, minScore, maxScore)
		SELECT dbo.GetNameByID(@first, @second, @third), SUM(marks.Баллы), SUM(marks.Баллы)
		FROM Лист3$ marks
		RIGHT JOIN dbo.Transform(@first, @second, @third) tr ON tr.dId = marks.Дисциплина
		GROUP BY marks.[Номер участника]

		FETCH NEXT FROM db_cursor INTO
		@first, @second, @third
	END

	CLOSE db_cursor
	DEALLOCATE db_cursor
RETURN
END
GO

SELECT TEMP.marks AS [Дисциплины], MIN(temp.minScore) AS [Минимальная сумма баллов], MAX(temp.maxScore) AS [Максимальная сумма баллов]
FROM dbo.CombineMinAndMax2() TEMP
GROUP BY TEMP.marks
GO