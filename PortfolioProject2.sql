--DATA CLEANING USING SQL QUERIES

select *
from PortfolioProject..NashvilleHousing

--Standard Date Format
select ConvertedSaleDate
from PortfolioProject..NashvilleHousing
 

 Alter table PortfolioProject..NashvilleHousing
 Add ConvertedSaleDate date

 Update PortfolioProject..NashvilleHousing
 Set ConvertedSaleDate = convert(date,SaleDate)

 --Populating Property Address
 select *
from PortfolioProject..NashvilleHousing
order by ParcelID

Select NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress
From PortfolioProject..NashvilleHousing NH1
Join PortfolioProject..NashvilleHousing NH2
On NH1.ParcelID = NH2.ParcelID
AND NH1.[UniqueID ] <> NH2.[UniqueID ]
where NH1.PropertyAddress is null

Update NH1
Set PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
From PortfolioProject..NashvilleHousing NH1
Join PortfolioProject..NashvilleHousing NH2
On NH1.ParcelID = NH2.ParcelID
AND NH1.[UniqueID ] <> NH2.[UniqueID ]
where NH1.PropertyAddress is null

--Splitting address into different columns using SUBSTRING

Select *
From PortfolioProject..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as TownAddress
From PortfolioProject..NashvilleHousing

 Alter table PortfolioProject..NashvilleHousing
 Add StreetAddress nvarchar(255);

 Update PortfolioProject..NashvilleHousing
 Set StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter table PortfolioProject..NashvilleHousing
 Add TownAddress nvarchar(255)

 Update PortfolioProject..NashvilleHousing
 Set TownAddress=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select StreetAddress, TownAddress
from PortfolioProject..NashvilleHousing

--Splitting Address using PARSENAME
Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select PARSENAME(Replace(OwnerAddress, ',','.'),3), PARSENAME(Replace(OwnerAddress, ',','.'),2),PARSENAME(Replace(OwnerAddress, ',','.'),1)
From PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
 Add OwnerStreetAddress nvarchar(255);
  Update PortfolioProject..NashvilleHousing
 Set OwnerStreetAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3)

 Alter table PortfolioProject..NashvilleHousing
 Add OwnerCity nvarchar(255);
  Update PortfolioProject..NashvilleHousing
 Set OwnerCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

 Alter table PortfolioProject..NashvilleHousing
 Add OwnerCityCode nvarchar(255);
  Update PortfolioProject..NashvilleHousing
 Set OwnerCityCode = PARSENAME(Replace(OwnerAddress, ',','.'),1)

 Select OwnerStreetAddress, OwnerCity, OwnerCityCode
From PortfolioProject..NashvilleHousing

--Keeping "Sold as Vacant" column consistent by replacing 'Y' and 'N' with 'Yes' and 'No'
Select DIstinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
group by SoldAsVacant

Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
else SoldAsVacant END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
else SoldAsVacant END
From PortfolioProject..NashvilleHousing

--Removing Duplicates
With rownum AS(
Select *,
row_number() Over(Partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order by UniqueID) rownumber 
From PortfolioProject..NashvilleHousing
)
Select *
--DELETE 
From rownum 
where rownumber > 1




