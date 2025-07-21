/*

Cleaning Data in SQL Queries

*/

SELECT DB_NAME() AS CurrentDatabase;
USE PortfolioProject



Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted  = CONVERT(Date, SaleDate)


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress,  b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))as City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing






SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState  NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing





--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


SELECT SoldAsVacant, CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'YES' THEN 'Yes'
	WHEN SoldAsVacant = 'N0' THEN 'No'
	ELSE SoldAsVacant
	END






--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
--WHERE row_num>1
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress

--DELETE
--FROM RowNumCTE
--WHERE row_num>1




SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate









--------------------------------------------------------------------------------------------------------------------------

-- 

