/*

Cleaning Data using SQL Queries

*/

select *
from PortfolioProject_NashvilleHousing..NashvilleHousing

-------------------------------------------------------------------------

-- Standardize Date Format

alter table PortfolioProject_NashvilleHousing..NashvilleHousing
add saledateconverted date;

update PortfolioProject_NashvilleHousing..NashvilleHousing
set saledateconverted = convert(date, saledate);


--------------------------------------------------------------------------

-- Populate Property Address data (fill NULL values using ParcelID as a reference)

/*
select propertyaddress
from PortfolioProject_NashvilleHousing..NashvilleHousing
where propertyaddress is null

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject_NashvilleHousing..NashvilleHousing a
join PortfolioProject_NashvilleHousing..NashvilleHousing b
	on (a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid)
where a.propertyaddress is null
*/

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject_NashvilleHousing..NashvilleHousing a
join PortfolioProject_NashvilleHousing..NashvilleHousing b
	on (a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid)
where a.propertyaddress is null


-----------------------------------------------------------------------------

-- Breaking out Address columns into individual columns (Address, City, State)

/*
select propertyaddress
from PortfolioProject_NashvilleHousing..NashvilleHousing

select
substring(propertyaddress, 1, charindex(',', propertyaddress)-1) as address,
substring(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress)) as address
from PortfolioProject_NashvilleHousing..NashvilleHousing
*/

alter table PortfolioProject_NashvilleHousing..NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update PortfolioProject_NashvilleHousing..NashvilleHousing
set PropertySplitAddress = substring(propertyaddress, 1, charindex(',', propertyaddress)-1);

alter table PortfolioProject_NashvilleHousing..NashvilleHousing
add PropertySplitCity Nvarchar(255);

update PortfolioProject_NashvilleHousing..NashvilleHousing
set PropertySplitCity = substring(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress));

/*
select OwnerAddress
from PortfolioProject_NashvilleHousing..NashvilleHousing

select
parsename(replace(owneraddress, ',', '.'), 3),
parsename(replace(owneraddress, ',', '.'), 2),
parsename(replace(owneraddress, ',', '.'), 1)
from PortfolioProject_NashvilleHousing..NashvilleHousing
*/


alter table PortfolioProject_NashvilleHousing..NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update PortfolioProject_NashvilleHousing..NashvilleHousing
set OwnerSplitAddress = parsename(replace(owneraddress, ',', '.'), 3);

alter table PortfolioProject_NashvilleHousing..NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update PortfolioProject_NashvilleHousing..NashvilleHousing
set OwnerSplitCity = parsename(replace(owneraddress, ',', '.'), 2);

alter table PortfolioProject_NashvilleHousing..NashvilleHousing
add OwnerSplitState Nvarchar(255);

update PortfolioProject_NashvilleHousing..NashvilleHousing
set OwnerSplitState = parsename(replace(owneraddress, ',', '.'), 1);

------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No is "Sold as Vacant" Field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject_NashvilleHousing..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end
from PortfolioProject_NashvilleHousing..NashvilleHousing


update PortfolioProject_NashvilleHousing..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end


------------------------------------------------------------------------------------------

-- Remove Duplicates

/*
with RowNumCTE as(
select *,
	row_number() over (
	partition by parcelid, 
				 propertyaddress, 
				 saleprice, saledate, 
				 legalreference 
				 order by 
				      uniqueid) as row_num
from PortfolioProject_NashvilleHousing..NashvilleHousing
)
select * 
from RowNumCTE
where row_num > 1
*/

with RowNumCTE as(
select *,
	row_number() over (
	partition by parcelid, 
				 propertyaddress, 
				 saleprice, saledate, 
				 legalreference 
				 order by 
				      uniqueid) as row_num
from PortfolioProject_NashvilleHousing..NashvilleHousing
)
delete 
from RowNumCTE
where row_num > 1


----------------------------------------------------------------------------------------------

-- Delete Unused Columns

/*
select *
from PortfolioProject_NashvilleHousing..NashvilleHousing
*/

alter table PortfolioProject_NashvilleHousing..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress 

alter table PortfolioProject_NashvilleHousing..NashvilleHousing
drop column saledate






