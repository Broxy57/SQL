SELECT *
FROM healthcare_dataset;

USE [Health]
GO

/****** Object:  Table [dbo].[healthcare_dataset]    Script Date: 24/09/2024 20:43:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[staging_healthcare_dataset](
	[Name] [nvarchar](255) NULL,
	[Age] [float] NULL,
	[Gender] [nvarchar](255) NULL,
	[Blood Type] [nvarchar](255) NULL,
	[Medical Condition] [nvarchar](255) NULL,
	[Date of Admission] [datetime] NULL,
	[Doctor] [nvarchar](255) NULL,
	[Hospital] [nvarchar](255) NULL,
	[Insurance Provider] [nvarchar](255) NULL,
	[Billing Amount] [float] NULL,
	[Room Number] [float] NULL,
	[Admission Type] [nvarchar](255) NULL,
	[Discharge Date] [datetime] NULL,
	[Medication] [nvarchar](255) NULL,
	[Test Results] [nvarchar](255) NULL
) ON [PRIMARY]
GO;

SELECT *
FROM staging_healthcare_dataset;

INSERT INTO staging_healthcare_dataset
SELECT *
FROM healthcare_dataset;

--Updating the names to the right format(uppercase first letter and lowercase remaining letters)

SELECT
    CONCAT(
        UPPER(LEFT(Name, 1)),
        LOWER(SUBSTRING(Name, 2, CHARINDEX(' ', Name + ' ') - 1)),
        ' ',
        UPPER(SUBSTRING(Name, CHARINDEX(' ', Name) + 1, 1)),
        LOWER(SUBSTRING(Name, CHARINDEX(' ', Name) + 2, LEN(Name)))
    ) AS formatted_name
FROM staging_healthcare_dataset;

UPDATE staging_healthcare_dataset
SET Name = CONCAT(
        UPPER(LEFT(Name, 1)),
        LOWER(SUBSTRING(Name, 2, CHARINDEX(' ', Name + ' ') - 1)),
        ' ',
        UPPER(SUBSTRING(Name, CHARINDEX(' ', Name) + 1, 1)),
        LOWER(SUBSTRING(Name, CHARINDEX(' ', Name) + 2, LEN(Name)))
    );


--Removing extra space between the "Name" column
UPDATE staging_healthcare_dataset
SET Name = REPLACE(Name, '  ', ' ')
WHERE Name LIKE '%  %';

SELECT *
FROM staging_healthcare_dataset
WHERE Name LIKE 'Abigail Young';

SELECT Name, TRIM(Name)
FROM staging_healthcare_dataset;

UPDATE staging_healthcare_dataset
SET Name = TRIM(Name);


--Removing duplicates
SELECT *, ROW_NUMBER () OVER (PARTITION BY Name, Age, Gender, [Blood Type], [Date of Admission], Doctor, Hospital, [Insurance Provider] 
ORDER BY Name) AS Row_num
FROM staging_healthcare_dataset;

SELECT *
FROM 
(SELECT *, ROW_NUMBER () OVER (PARTITION BY Name, Age, Gender, [Blood Type], [Date of Admission], Doctor, Hospital, [Insurance Provider] 
ORDER BY Name) AS Row_num
FROM staging_healthcare_dataset) AS Row_n
WHERE Row_num > 1;

SELECT *
FROM staging_healthcare_dataset
WHERE [Name]='Adam Thomas';


WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Name, Age, Gender, [Blood Type], [Date of Admission], Doctor, Hospital, [Insurance Provider] 
                              ORDER BY Name) AS Row_num
    FROM staging_healthcare_dataset
)
DELETE FROM CTE
WHERE Row_num > 1;

SELECT *
FROM staging_healthcare_dataset;

--Count of patients based on gender and medical condition
SELECT [Medical Condition], Gender, COUNT(Gender) Count_Gender
FROM staging_healthcare_dataset
GROUP BY [Medical Condition], Gender
ORDER BY Gender;

WITH GenderCount AS
(
SELECT [Medical Condition], Gender, COUNT(Gender) Count_Gender
FROM staging_healthcare_dataset
GROUP BY [Medical Condition], Gender
)
SELECT [Medical Condition], Gender, Count_Gender,
	SUM(Count_Gender) OVER(PARTITION BY Gender ORDER BY [Medical Condition]) AS Rolling_Total
FROM GenderCount;

--Count of patients based on Blood Type
SELECT [Blood Type], COUNT([Blood Type])
FROM staging_healthcare_dataset
GROUP BY [Blood Type];

--Insurance Provider
SELECT [Insurance Provider], COUNT([Insurance Provider])
FROM staging_healthcare_dataset
GROUP BY [Insurance Provider];

--Medical Condition
SELECT [Medical Condition], [Blood Type], COUNT([Medical Condition]) AS Count_condition
FROM staging_healthcare_dataset
GROUP BY [Medical Condition], [Blood Type]
ORDER BY [Blood Type], Count_condition DESC;

--Average age of patients
SELECT [Medical Condition], AVG(Age) Avg_age
FROM staging_healthcare_dataset
GROUP BY [Medical Condition]
ORDER BY Avg_age DESC;

--Finding the number of days between admission and discharge
SELECT [Name], [Medical Condition], [Date of Admission], [Discharge Date], DATEDIFF(day, [Date of Admission], [Discharge Date]) AS DaysAdmitted
FROM staging_healthcare_dataset;

--Finding the average number of DaysAdmitted for different medical conditions
WITH CTE_Days AS
(
SELECT [Name], [Medical Condition], [Date of Admission], [Discharge Date], DATEDIFF(day, [Date of Admission], [Discharge Date]) AS DaysAdmitted
FROM staging_healthcare_dataset
)
SELECT [Medical Condition], AVG(DaysAdmitted)
FROM CTE_Days
GROUP BY [Medical Condition];

--Maximum and Minimum Billing Amount
SELECT MAX([Billing Amount]) Max_Amount, MIN([Billing Amount]) Min_Amount
FROM staging_healthcare_dataset;

--Average billing amount for different medical conditions
SELECT [Medical Condition], AVG([Billing Amount]) Avg_Amount
FROM staging_healthcare_dataset
GROUP BY [Medical Condition]
ORDER BY Avg_Amount DESC;

SELECT *
FROM staging_healthcare_dataset
WHERE [Medical Condition]= 'Hypertension';
















