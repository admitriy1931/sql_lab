**LAB2**

Пусть даны 
•	таблица, содержащая типы
измерений (например, влажность, давление и температура воздуха)
•	таблица, содержащая названия гидрометеорологических
станций 
•	таблица, содержащая информацию об измерениях определенных типов, производимых в определенные моменты времени (дата и время) на определенных станциях.

Создать базу данных с указанными таблицами (в таблицах сразу определять первичный ключ, если надо).
Заполнить данными таблицы (в таблице, содержащей информацию об измерениях, должно быть не менее 10 записей)
Пример заполнения таблицы, содержащей типы измерений:
1 Влажность
2 Давление
3 Температура воздуха
4 Температура воды
5 Скорость ветра
6 Излучение солнца

Используя команду ALTER TABLE:

Связать таблицу, содержащую информацию об измерениях, с таблицей типов измерений и с таблицей названий станций.

Добавить в таблицу названий станций новый столбец «адрес», который будет заполняться по умолчанию «Россия, г.».
Добавить в таблицу названий станций новую станцию.

Создать таблицу с наименованиями  единиц измерений (должно быть полное наименование, обозначение). Добавить в нее данные. Пример заполнения таблицы с наименованиями  единиц измерений:
1 Градусы °
2 Метр в секунду м/с
3 Миллиметр ртутного столба мм рт. ст.
4 Паскаль Па
и т.д.

Добавить в таблицу типов измерений новый столбец, связанный с таблицей  наименований единиц измерений. Новый столбец соответственно заполнить с помощью команды UPDATE.


Используя команду SELECT:

1. Выдать упорядоченный список дат, в которые проводились измерения (без повторений).

2. Выдать максимальное и минимальное значение различных измерений.

3. Напишите запрос с подзапросом для получения данных, которые измеряются в градусах. Объяснение. SQL подзапрос — это запрос, вложенный в другой запрос. 
Пример
Рассмотрим таблицу CUSTOMERS, содержащую следующие записи:
 
Теперь давайте выполним следующий подзапрос с инструкцией SELECT.
SELECT * 
  FROM CUSTOMERS 
  WHERE ID IN (SELECT ID 
        FROM CUSTOMERS 
        WHERE SALARY > 4500) ;
В результате мы получим следующее.
 
 
4. Напишите команду SELECT, использующую связанные подзапросы и выполняющую вывод дат (а также код измерения, значение), в которые были минимальное значение измерений.

Пример.
Можно использовать подзапросы, связывающие таблицу со своей собственной копией. Например, надо найти идентификаторы, фамилии и стипендии студентов, получающих стипендию выше средней на курсе, на котором они учатся.
SELECT DISTINCT STUDENT_ID, SURNAME, STIPEND
FROM STUDENT E1
WHERE STIPEND >
(SELECT AVG(STIPEND)
FROM STUDENT E2
WHERE E1.KURS = E2.KURS);

Тот же результат можно получит с помощью следующего запроса:
SELECT DISTINCT STUDENT_ID, SURNAME, STIPEND
FROM STUDENT E1,
(SELECT KURS, AVG(STIPEND) AS AVG_STIPEND
FROM STUDENT E2
GROUP BY E2.KURS) E3
WHERE E1.STIPEND > AVG_STIPEND AND E1.KURS=E3.KURS;

Добавить в таблицу типов измерений запись «Объем осадков».
5. С помощью JOIN выдать информацию тип измерения,  единица измерения. Рассмотреть тот же запрос с помощью WHERE.
Например:
1	SELECT name, addres FROM table1 LEFT JOIN table2 ON table1.user_id=table2.user_id;
2	SELECT table1.name, table1.addres, table2.index FROM table1, table2 WHERE table1.user_id = table2.user_id;


6. Выдать средние значения разных типов измерений ( c единицами измерений) на определенную дату по каждой станции. Заголовки полей итоговых таблиц должны быть на русском языке, даты в виде dd.month.yy(yyyy). 
Пример:	
Дата	Станция	ТипИзмерения	СреднееЗначение	ЕдиницыИзмерения
22.сентября.2021	Метеогорка	Давление	749.5	миллиметр ртутного столба
20.октября.2021	Станция 1	Давление	750	миллиметр ртутного столба
20.октября.2021	Метеогорка	Температура воздуха	5.5	Градус
25.октября.2021	Станция 1	Влажность	48	Процент


Контрольное задание  
Приведён фрагмент базы фрагмент базы данных «Города и страны», описывающей различные страны, города и языки. База данных состоит из трех таблиц. Таблица «Страны» (код, название, континент, регион, площадь, год получения независимости, население, ОПЖ – ожидаемая продолжительность жизни, ВНД – валовый национальный доход, предыдущее значение ВНД, форма правления, идентификатор столицы). Таблица «Города» (идентификатор, название, код страны, район, население). Таблица «Языки» (код языка, код страны, название, является ли официальным, процент использования в стране). По некоторым значениям данных нет, в этом случае в таблице внесено значение NULL. На рисунке приведена схема базы данных.
 
Создайте таблицы и сделайте импорт данных.

Таблица «Страны»- 3-402.csv
Таблица «Города»- 3-40.csv
Таблица «Языки»- 3-401.csv


Фрагмент программы.

CREATE TABLE [dbo].[S_goroda](
	[Cod] [int] PRIMARY KEY,
	[Name] [nvarchar](50) NULL,
	[Cod_s] [nvarchar](5) NULL,
	[Rayon] [nvarchar](50) NULL,
	[Nasel] [int] NULL
) ON [PRIMARY]

GO
BULK INSERT S_goroda FROM 'D:\3-40.csv'
   WITH (
      FIELDTERMINATOR = ';',
      ROWTERMINATOR = '\n'
);
GO
CREATE TABLE [dbo].[S_lang](
	[Cod] [int] PRIMARY KEY,
	[Name] [nvarchar](50) NULL,
	[Cod_s] [nvarchar](5) NULL,
	[Oficial] [nvarchar](1) NULL,
	[procent] [Decimal] (4,1) NULL
) ON [PRIMARY]

GO
BULK INSERT S_lang FROM 'D:\3-401.csv'
   WITH (
      FIELDTERMINATOR = ';',
      ROWTERMINATOR = '\n'
);
GO
CREATE TABLE [dbo].[S_stran](
	[Cod] [nvarchar](5) PRIMARY KEY,
	[Name] [nvarchar](50) NULL,
	[Continent] [nvarchar](50) NULL,
	[Region] [nvarchar](50) NULL,
	[S] [Decimal] (9,1) NULL,
	[Year] [int] NULL,
	[Nasel] [int] NULL,
	[OPG] [Decimal] (4,1) NULL,
	[VND] [Decimal] (8,1) NULL,
	[VNDpred] [Decimal] (8,1)  NULL,
	[Form] [nvarchar](100) NULL,
	[Cod_st] [int] NULL

) ON [PRIMARY]

GO
BULK INSERT S_stran FROM 'D:\3-402.csv'
   WITH (
      FIELDTERMINATOR = ';',
      ROWTERMINATOR = '\n'
);
GO

Выберите по последней цифре номера вашего студенческого билета вариант задания. 
N 	Задание. 
0 	Используя информацию из приведённой базы данных, определите количество городов, расположенных в странах с населением более 100 000 000.

Определите среднее население городов, расположенных в странах, население столицы которых превышает 1 000 000 человек, а одним из официальных языков является английский (English).
1 	Используя информацию из приведённой базы данных, определите среднее значение населения стран у которых в столице проживает более 100000 человек, но не более 500000.

Определите страну с максимальной площадью среди стран Азии у которых один из официальных языков используют более 70% населения. В ответе запишите название страны.
2 	Используя информацию из приведённой базы данных, определите среднюю площадь стран Южной Америки, в которых население столицы не превышает 150 000. 

Определите, на сколько суммарно изменился ВНД стран у которых население столицы превышает 1 000 000 человек. Для тех стран, у которых нет значения ВНД, принять его равным 0. В ответе укажите модуль полученного значения.
3 	Используя информацию из приведённой базы данных, определите страну с максимальной площадью среди стран Азии у которых один из официальных языков используют более 70% населения. В ответе запишите название страны.

Определите среднее население стран Европы, в которых наиболее популярный официальный язык используют менее 60% населения.
.
4 	Используя информацию из приведённой базы данных, определите среднюю ожидаемую продолжительность жизни тех стран, в которых ВНД увеличился, а население столицы не превышает 500 000 человек. Те страны, у которых нет значения ВНД, не учитывать при подсчете.

Определите количество городов с населением не менее 100 000 человек, которые являются столицами стран в которых распространены несколько языков с процентом более 10 каждый.
5 	Используя информацию из приведённой базы данных, определите количество городов, расположенных в странах с населением более 100 000 000.

Определите наиболее часто встречающуюся форму правления среди стран где хотя бы два официальных языка.
6 	Используя информацию из приведённой базы данных, определите среднее значение населения стран у которых в столице проживает более 100000 человек, но не более 500000

Определите среднее население стран Европы, в которых наиболее популярный официальный язык используют менее 60% населения.

7 	Используя информацию из приведённой базы данных, определите среднюю площадь стран Южной Америки, в которых население столицы не превышает 150 000. 

Определите количество городов с населением не менее 100 000 человек, которые являются столицами стран в которых распространены несколько языков с процентом более 10 каждый.
8 	Используя информацию из приведённой базы данных, определите страну с максимальной площадью среди стран Азии у которых один из официальных языков используют более 70% населения. В ответе запишите название страны.

Определите, на сколько суммарно изменился ВНД стран у которых население столицы превышает 1 000 000 человек. Для тех стран, у которых нет значения ВНД, принять его равным 0. В ответе укажите модуль полученного значения.
9 	Используя информацию из приведённой базы данных, определите среднюю ожидаемую продолжительность жизни тех стран, в которых ВНД увеличился, а население столицы не превышает 500 000 человек. Те страны, у которых нет значения ВНД, не учитывать при подсчете.

Определите среднее население стран Европы, в которых наиболее популярный официальный язык используют менее 60% населения.

**LAB3**

