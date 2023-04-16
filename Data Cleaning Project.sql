/*

Cleaning Data in SQL Queries

*/

---------------------------------------------------------------------------------------------------------------

-- Change the Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

---------------------------------------------------------------------------------------------------------------

-- Populate Propery Address Data

Select *
From [Portfolio Project].dbo.NashvilleHousing
Where PropertyAddress is Null

Select *
From [Portfolio Project].dbo.NashvilleHousing
Order By ParcelID

---------------------------------------------------------------------------------------------------------------

--ParcelID is a unique ID per address
--Some address fields are blank for the same ParcelID
--Find where PropertyAddress Is Null and update it based on ParcelID
--JOIN NashvilleHousing on ParcelID 
--Make sure UniqueID is not matching so there are no duplicates

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Update Table a, check if a.PropertyAddress Is Null and update with b.PropertyAddress

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------

--Separating Address into individual columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project].dbo.NashvilleHousing

--Use SUBSTRNG to retrun a specific string in PropertyAddress
--Use CHARINDEX specify a position within the string -1 to remove the comma from Address
--Use SUBSTRIG to create a Substring of City
--CHARINDEX is used to find the position after the comma
--LEN is used as the ending position

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
From [Portfolio Project].dbo.NashvilleHousing

--Alter table by adding two new columns for Address and City
--Update based on the SUBSTRINGS defined earlier

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

--Lets do the same for OwnerAddress but a different way

SELECT OwnerAddress
From [Portfolio Project].dbo.NashvilleHousing
Where OwnerAddress is not Null

--Use PARSENAME to parse the OwnerAddress
--Replace the commas with periods (since PARSENAME only looks for periods)

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
From [Portfolio Project].dbo.NashvilleHousing

--Now lets create new columns for the OwnerAddress

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

---------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in SoldAsVacant column

SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Use CASE to go through the condition 

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [Portfolio Project].dbo.NashvilleHousing

--Use UPDATE to update the SoldAsVacant column

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

---------------------------------------------------------------------------------------------------------------

--Remove duplicate fields
--Use a CTE with ROW_NUMBERS to find all duplicate rows

WITH RowNumCTE AS (
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM [Portfolio Project].dbo.NashvilleHousing
)

--Delete the duplicate rows with the CTE 

DELETE
FROM RowNumCTE
Where row_num > 1

---------------------------------------------------------------------------------------------------------------

--Delete Unused Columns
--Use alter table to drop unused columns

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate