/* Link to the Dataset

'https://www.kaggle.com/datasets/bvanntruong/housing-sql-project'

*/

--------------------------------------------------------------------------------------------------------------------------

/*

Creating the Database

*/

DROP DATABASE IF EXISTS nashville_housing;
CREATE DATABASE nashville_housing;
USE nashville_housing;

--------------------------------------------------------------------------------------------------------------------------
/*

Creating the Table 

*/

CREATE TABLE nashville_data (
	UniqueID INT NOT NULL,
	ParcelID TEXT,
	LandUse TEXT,
	PropertyAddress TEXT,
	SaleDate DATETIME,
	SalePrice INT ,
	LegalReference TEXT, 
	SoldAsVacant TEXT ,
	OwnerName TEXT ,
	OwnerAddress TEXT, 
	Acreage DOUBLE ,
	TaxDistrict TEXT, 
	LandValue INT ,
	BuildingValue INT, 
	TotalValue INT ,
	YearBuilt YEAR ,
	Bedrooms INT ,
	FullBath INT ,
	HalfBath INT
);

--------------------------------------------------------------------------------------------------------------------------
/*

Loading the Dataset 

*/
LOAD DATA INFILE '/path/to/your/file.csv'
INTO TABLE nashville_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES; 

--------------------------------------------------------------------------------------------------------------------------

/*

Cleaning Data in SQL Queries

*/

SELECT * FROM nashville_housing.nashville_data;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT 
	SaleDate,
	STR_TO_DATE(SaleDate,'%M %d, %Y') AS Sale_Date 
FROM
	nashville_data;

UPDATE nashville_data
SET SaleDate = STR_TO_DATE(SaleDate,'%M %d, %Y');


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT 
		*
FROM
	nashville_data
WHERE COALESCE(PropertyAddress, '') = '';

UPDATE nashville_data
SET PropertyAddress = NULLIF(PropertyAddress, '');

SELECT
	*
FROM
	nashville_data
WHERE PropertyAddress IS NULL;

SELECT 
	a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    coalesce(a.PropertyAddress,b.PropertyAddress) AS New_PropertyAddress
FROM nashville_data a
JOIN nashville_data b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_data a
JOIN nashville_data b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = coalesce(a.PropertyAddress,b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Property Address --

SELECT
  SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
  SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
  FROM
	nashville_data;

ALTER TABLE nashville_data
ADD COLUMN Property_Address VARCHAR(255);

ALTER TABLE nashville_data
ADD COLUMN Property_City VARCHAR(255);

UPDATE nashville_data
SET Property_Address =  SUBSTRING_INDEX(PropertyAddress, ',', 1);

UPDATE nashville_data
SET Property_City = SUBSTRING_INDEX(PropertyAddress, ',', -1);

-- Owner Adress --

SELECT
  SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2),",",1) AS City,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -1),",",-1) AS State
  FROM
	nashville_data;

ALTER TABLE nashville_data
ADD COLUMN Owner_Address VARCHAR(255);

ALTER TABLE nashville_data
ADD COLUMN OwnerCity VARCHAR(255);

ALTER TABLE nashville_data
ADD COLUMN OwnerState VARCHAR(255);

UPDATE nashville_data
SET OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2),",",1);

UPDATE nashville_data
SET Owner_Address =  SUBSTRING_INDEX(OwnerAddress, ',', 1);

UPDATE nashville_data
SET OwnerState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -1),",",-1);

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT
	DISTINCT(SoldAsVacant) AS Answer,
    COUNT(SoldAsVacant) AS Counts
FROM
	nashville_data
GROUP BY SoldAsVacant
ORDER BY 2 ;

SELECT
	SoldAsVacant,
    CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
	END AS Updated_SoldAsVacant
FROM 
	nashville_data;
    
UPDATE nashville_data
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
	END;
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH Row_NumCTE AS (
SELECT
	*,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
		ORDER BY UniqueID ) Row_num
FROM
	nashville_data)
/*
 SELECT
	*
FROM 
	Row_NumCTE
WHERE
	Row_num > 1;
*/

DELETE nashville_data
FROM nashville_data
JOIN Row_NumCTE
ON nashville_data.UniqueID = Row_NumCTE.UniqueID
WHERE Row_NumCTE.Row_num > 1;

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE nashville_data
DROP COLUMN PropertyAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN OwnerAddress;

---------------------------------------------------------------------------------------------------------