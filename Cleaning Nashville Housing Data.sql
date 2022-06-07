/* Cleaning Data */

SELECT *
FROM projects.dbo.NashvilleHousing;

-- Standardize Date Format
SELECT saledate, CONVERT (date, SaleDate)
FROM projects.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT (date, SaleDate);


--Populate Property Address Data
SELECT *
FROM projects.dbo.NashvilleHousing
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM projects.dbo.NashvilleHousing a
JOIN projects.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM projects.dbo.NashvilleHousing a
JOIN projects.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Separate Address into Individual Columns (Address, City, State)
SELECT Propertyaddress
FROM projects.dbo.NashvilleHousing;

SELECT 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as Address
,SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(PropertyAddress)) as Address
FROM projects.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(PropertyAddress))



--Separate Owner Address into Individual Columns (Address, City, State) Using PARSENAME

SELECT
PARSENAME(REPLACE(owneraddress, ',', '.') , 3)
,PARSENAME(REPLACE(owneraddress, ',', '.') , 2)
,PARSENAME(REPLACE(owneraddress, ',', '.') , 1)
FROM projects.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.') , 1)


--CHange Y and N to Yes and No in "Sold as Vacant" Column

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM projects.dbo.NashvilleHousing
GROUP BY soldasvacant
ORDER BY 2

SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	 WHEN soldasvacant = 'N' THEN 'No'
	 ELSE soldasvacant END
FROM projects.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
						WHEN soldasvacant = 'N' THEN 'No'
						ELSE soldasvacant END


--Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 legalreference
				 ORDER BY
					uniqueid
					) row_num

FROM projects.dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 legalreference
				 ORDER BY
					uniqueid
					) row_num

FROM projects.dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress




--DELETE Unused Columns

SELECT *
FROM projects.dbo.NashvilleHousing

ALTER TABLE projects.dbo.NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress