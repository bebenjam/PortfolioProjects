--Create New Table With Scraped Data Combined

SELECT * INTO Wauwa_Sold_2021_2023
FROM (
  SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (1)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (2)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (3)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (4)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (5)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (6)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (7)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (8)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (9)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (10)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (11)$']
UNION
SELECT *
FROM Wauwatosa_Housing_Market.dbo.['wauwatosa_recently_sold (12)$']
) AS Wauwa_Combined_Data

SELECT * 
FROM Wauwatosa_Housing_Market.dbo.Wauwa_Sold_2021_2023

--Remove Duplicates

WITH DuplicateCTE AS (
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY Address
	ORDER BY Address) AS row_num
FROM Wauwatosa_Housing_Market.dbo.Wauwa_Sold_2021_2023)

SELECT * 
FROM DuplicateCTE
WHERE row_num > 1

--DELETE 
--FROM DuplicateCTE
--WHERE row_num > 1

SELECT *
FROM Wauwatosa_Housing_Market.dbo.Wauwa_Sold_2021_2023

--Defines locations used for SUBSTRING FUNCTION for 'State' Field

SELECT Address,
	LEN(Address),
	CHARINDEX(' ', REVERSE(Address)),
	CHARINDEX(',', REVERSE(Address)) +2
FROM Wauwatosa_Housing_Market.dbo.Wauwa_Sold_2021_2023

--Break out Address into Street, City, StateAndZIP Columns 

SELECT Address, 
	SUBSTRING (Address, 1, CHARINDEX(',',Address) -1) AS StreetAddress,
	PARSENAME(REPLACE(Address, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(Address, ',', '.'), 1) AS State_and_Zip
FROM Wauwatosa_Housing_Market.dbo.Wauwa_Sold_2021_2023

ALTER TABLE Wauwa_Sold_2021_2023
ADD StreetAddress varchar(255)

ALTER TABLE Wauwa_Sold_2021_2023
ADD City varchar(255)

ALTER TABLE Wauwa_Sold_2021_2023
ADD StateAndZip varchar(255)

UPDATE Wauwa_Sold_2021_2023
SET StreetAddress = SUBSTRING (Address, 1, CHARINDEX(',',Address) -1)

UPDATE Wauwa_Sold_2021_2023
SET City = PARSENAME(REPLACE(Address, ',', '.'), 2)

UPDATE Wauwa_Sold_2021_2023
SET StateAndZip = PARSENAME(REPLACE(Address, ',', '.'), 1)

-- Extract State and Zip from StateAndZip

SELECT StateAndZip,
	PARSENAME(REPLACE(StateAndZip, ' ', '.'), 2) AS State,
	PARSENAME(REPLACE(StateAndZip, ' ', '.'), 1) AS ZIP_Code
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

ALTER TABLE Wauwa_Sold_2021_2023
ADD State varchar(255)

ALTER TABLE Wauwa_Sold_2021_2023
ADD ZIP_Code INT

UPDATE Wauwa_Sold_2021_2023
SET State = PARSENAME(REPLACE(StateAndZip, ' ', '.'), 2)

UPDATE Wauwa_Sold_2021_2023
SET ZIP_Code = PARSENAME(REPLACE(StateAndZip, ' ', '.'), 1)


--Clean "price" Column
--To get rid of string 'null' in "price" and create new column with "price" as Integer "Price_Sold":

UPDATE Wauwa_Sold_2021_2023
SET price = ': $100,000'
WHERE price = 'null'

SELECT CAST(REPLACE(REPLACE(price, ': $', ''), ',', '') AS INT) AS cleaned_value
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

ALTER TABLE Wauwa_Sold_2021_2023
ADD Price_Sold INT

UPDATE Wauwa_Sold_2021_2023
SET Price_Sold = CAST(REPLACE(REPLACE(price, ': $', ''), ',', '') AS INT)

UPDATE Wauwa_Sold_2021_2023
SET Price_Sold = NULL
WHERE Price_Sold = 100000

-- Replacing String for bedrooms and bathrooms

SELECT bedrooms, bathrooms
FROM  Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

SELECT DISTINCT bedrooms
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

SELECT DISTINCT bathrooms
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

SELECT SUBSTRING(bedrooms, 1, 1), SUBSTRING(bathrooms, 1, 1)
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

ALTER TABLE Wauwa_Sold_2021_2023
ADD BedroomsFormatted INT

ALTER TABLE Wauwa_Sold_2021_2023
ADD BathroomsFormatted INT

UPDATE Wauwa_Sold_2021_2023
SET BedroomsFormatted = TRY_CAST(SUBSTRING(bedrooms, 1, 1) AS INT)

UPDATE Wauwa_Sold_2021_2023
SET BathroomsFormatted = TRY_CAST(SUBSTRING(bathrooms, 1, 1) AS INT)

SELECT bedrooms, bathrooms, BedroomsFormatted, BathroomsFormatted
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

--Remove "sqft" from "Squarefeet" Column

SELECT Squarefeet, SUBSTRING(Squarefeet, 1, PATINDEX('% sqft', Squarefeet)-1)
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023
WHERE Squarefeet LIKE '%sqft'

ALTER TABLE Wauwa_Sold_2021_2023
ADD Sqft INT

UPDATE Wauwa_Sold_2021_2023
SET Sqft =  TRY_CAST(REPLACE(REPLACE(Squarefeet, ',', ''), ' sqft', '') AS INT)

--Extract and create Date_Sold Column

SELECT datesold
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

SELECT TRIM(SUBSTRING(datesold, CHARINDEX('on', datesold) +3, 8))
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

ALTER TABLE Wauwa_Sold_2021_2023
ADD Date_Sold DATE

UPDATE Wauwa_Sold_2021_2023
SET Date_Sold = TRY_CAST((TRIM(SUBSTRING(datesold, CHARINDEX('on', datesold) +3, 8))) AS DATE)

SELECT Date_Sold, datesold
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

--Extract Zestimate

SELECT REPLACE(
PARSENAME(REPLACE((PARSENAME(REPLACE(datesold, 'on', '.'), 1) ), '$', '.'), 1), ',', '')
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

ALTER TABLE Wauwa_Sold_2021_2023
ADD Zestimate INT

UPDATE Wauwa_Sold_2021_2023
SET Zestimate = TRY_CAST(REPLACE(
PARSENAME(REPLACE((PARSENAME(REPLACE(datesold, 'on', '.'), 1) ), '$', '.'), 1), ',', '')AS INT)

SELECT Zestimate
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

--Separate Street Number from Street Direction and Name (will make querying for street data drill down easier)

SELECT SUBSTRING(StreetAddress, 1, CHARINDEX(' ', StreetAddress))
, SUBSTRING(StreetAddress, CHARINDEX(' ', StreetAddress), LEN(StreetAddress))
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

ALTER TABLE Wauwa_Sold_2021_2023
ADD AddressNumber varchar(255)

ALTER TABLE Wauwa_Sold_2021_2023
ADD StreetName varchar(255)

UPDATE Wauwa_Sold_2021_2023
SET AddressNumber = SUBSTRING(StreetAddress, 1, CHARINDEX(' ', StreetAddress))

UPDATE Wauwa_Sold_2021_2023
SET StreetName = SUBSTRING(StreetAddress, CHARINDEX(' ', StreetAddress), LEN(StreetAddress))

--Get rid of StreetName that has a period (only one record)

SELECT REPLACE(StreetName, '.', '') AS NoPeriods
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

SELECT StreetName
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023
WHERE StreetName LIKE '%.%'

UPDATE Wauwa_Sold_2021_2023
SET StreetName = REPLACE(StreetName, '.', '') 

--Show Data Types in my table

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Wauwa_Sold_2021_2023'

--Create View of Cleaned and Formatted Data For Querying

CREATE VIEW Wauwatosa_Recent_Home_Sales AS
SELECT [web-scraper-order], AddressNumber, StreetName, City, State, ZIP_Code, 
BedroomsFormatted, BathroomsFormatted, Sqft, Date_Sold, Price_Sold, Zestimate
FROM Wauwatosa_Housing_Market..Wauwa_Sold_2021_2023

SELECT *
FROM Wauwatosa_Recent_Home_Sales



