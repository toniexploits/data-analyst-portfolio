/*
Data Cleaning Queries
*/

select * 
from PortfolioProject.dbo.NashvilleHousing

--------------------------------
-- Change date

select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted Date

select top 1000 SaleDate, SaleDateConverted from PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------
-- Populate the nulls in property address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(b.PropertyAddress, a.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null


Update b
SET PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null


-----------------------------------------------------------------
-- Breaking Address into individual columns (address, city, state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select top 1000 * 
from PortfolioProject.dbo.NashvilleHousing


select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
from PortfolioProject.dbo.NashvilleHousing


Alter Table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--------------------------------------------------
--Change Y and N to Yes and No in SoldAsVacant

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant


UPDATE PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
						when SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						END




-------------------------------------------
-- Remove Duplicates

With RowNumCTE AS (
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID ) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress




---------------------------------------------
--Delete Unused Columns

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate, OwnerAddress, PropertyAddress, TaxDistrict

select * 
from PortfolioProject.dbo.NashvilleHousing