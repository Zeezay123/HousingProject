 /* 
  Cleaning Data in SQL
 */

 Select * 
 From PortfolioProject..NashvilleHousing
  
 -- Standardize Date Format
 Select SaleDateConverted, CONVERT(Date,SaleDate)
 From PortfolioProject..NashvilleHousing

 /*Update PortfolioProject..NashvilleHousing
 set SaleDate = CONVERT(Date,SaleDate)
*/

 ALTER TABLE PortfolioProject..NashvilleHousing
 Add SaleDateConverted Date;

 Update PortfolioProject..NashvilleHousing
 set SaleDateConverted = CONVERT(Date,SaleDate)


 --Populate Property Address Data

  Select *
 From PortfolioProject..NashvilleHousing
 --Where PropertyAddress is null
 Order by ParcelID

Select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress) 
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is Null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

-- Breaking out Address Into Individual Columns (Address, City, State)
 Select PropertyAddress
 From PortfolioProject..NashvilleHousing
 --Where PropertyAddress is null
 --Order by ParcelID

 Select 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
 From PortfolioProject..NashvilleHousing

  ALTER TABLE PortfolioProject..NashvilleHousing
 Add PropertySplitAddress nvarchar(255);

 Update PortfolioProject..NashvilleHousing
 set PropertySplitAddress  =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

  ALTER TABLE PortfolioProject..NashvilleHousing
 Add PropertySplitCity nvarchar(255);

 Update PortfolioProject..NashvilleHousing
 set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 


 Select 
 PARSENAME(REPLACE(OwnerAddress,',', '.') , 3), 
 PARSENAME(REPLACE(OwnerAddress,',', '.') , 2), 
 PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)
 From PortfolioProject..NashvilleHousing
where OwnerAddress is not null

ALTER TABLE PortfolioProject..NashvilleHousing
 Add OwnerSplitAddress nvarchar(255);

 Update PortfolioProject..NashvilleHousing
 set OwnerSplitAddress  =  PARSENAME(REPLACE(OwnerAddress,',', '.') , 3)

  ALTER TABLE PortfolioProject..NashvilleHousing
 Add OwnerSplitCity nvarchar(255);

 Update PortfolioProject..NashvilleHousing
 set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') , 2)

  ALTER TABLE PortfolioProject..NashvilleHousing
 Add OwnerSplitState nvarchar(255);

 Update PortfolioProject..NashvilleHousing
 set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)


 -- Change Y and N to Yes and No in "Sold as Vacant"

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
  CASE When SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END


-- Remove Duplicate 
With RowNumCTE AS (
Select *, 
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 Order BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-- Delete Unused Colums


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate