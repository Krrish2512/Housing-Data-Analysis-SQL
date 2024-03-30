-- Using the databse

USE [Housing Database];

SELECT * FROM Housing_Data;

-------------------------------------------------------------------------------------------------------------------------------------

-- Populating Property Address Data

SELECT PropertyAddress FROM Housing_Data;

SELECT * FROM Housing_Data
WHERE PropertyAddress IS NULL;

-- Using Same Parcel Id for populating Property Address Data

SELECT * FROM Housing_Data
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing_Data a
JOIN Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing_Data a
JOIN Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-------------------------------------------------------------------------------------------------------------------------------------

-- Breaking Property Address into individual columns (Address, City, State)

SELECT PropertyAddress FROM Housing_Data;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address, -- -1 to remove the comma from the output
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM Housing_Data;

ALTER TABLE Housing_DATA
Add PropertySplitAddress Nvarchar(255);

ALTER TABLE Housing_DATA
Add PropertySplitCity Nvarchar(255);

UPDATE Housing_Data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

-------------------------------------------------------------------------------------------------------------------------------------

-- Breaking Owner Address into individual columns (Address, City, State)

SELECT OwnerAddress FROM Housing_Data;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM Housing_Data;

ALTER TABLE Housing_DATA
Add OwnerSplitAddress Nvarchar(255),
OwnerSplitCity Nvarchar(255),
OwnerSplitState Nvarchar(255);

UPDATE Housing_Data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);

-------------------------------------------------------------------------------------------------------------------------------------

-- Modify SoldAsVacant Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing_Data
GROUP BY SoldAsVacant
ORDER BY 2;

-------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num
FROM Housing_Data
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

SELECT *
FROM Housing_Data;


ALTER TABLE Housing_Data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;
