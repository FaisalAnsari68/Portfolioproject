/*
--Cleaning Data in SQL Queries
*/

Select * from housing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select converted_saledate from housing

alter table housing add converted_saledate date;

update housing set converted_saledate = CONVERT(date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * from housing  
where propertyAddress is null
order by ParcelID

select a.parcelID , a.propertyAddress , b.parcelID , b.propertyAddress ,isnull(a.propertyAddress,b.propertyAddress)
	from housing as a join housing as b on a.ParcelID = b.ParcelID 
	and a.[UniqueID ]<>b.[UniqueID ] 
	where a.PropertyAddress is null

	update a
	set propertyAddress = isnull(a.propertyAddress,b.propertyAddress)
	from housing as a join housing as b on a.ParcelID = b.ParcelID 
	and a.[UniqueID ]<>b.[UniqueID ] 
	where a.PropertyAddress is null	
	--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress from housing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(propertyAddress, 1 , CHARINDEX(',' , propertyAddress) -1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',' , propertyAddress) + 1 , len(propertyAddress)) as Address
from housing

alter table housing add splitAddress Nvarchar(255);

update housing set splitAddress = SUBSTRING(propertyAddress, 1 , CHARINDEX(',' , propertyAddress) -1)

alter table housing add splitCity Nvarchar(255);

update housing set splitCity  = SUBSTRING(propertyAddress, CHARINDEX(',' , propertyAddress) + 1 , len(propertyAddress))

select ownerAddress from housing


select 
PARSENAME(replace(ownerAddress , ',' ,'.' ), 3) as ownersplitAddress,
PARSENAME(replace(ownerAddress , ',' ,'.' ), 2) as ownersplitcity,
PARSENAME(replace(ownerAddress , ',' ,'.' ), 1)as ownersplitstate

from housing where OwnerAddress is not  null

alter table housing add ownersplitAddress Nvarchar(255);

update housing set ownersplitAddress = PARSENAME(replace(ownerAddress , ',' ,'.' ), 3)

alter table housing add ownersplitcity Nvarchar(255);

update housing set ownersplitcity  = PARSENAME(replace(ownerAddress , ',' ,'.' ), 2)

alter table housing add ownersplitstate Nvarchar(255);

update housing set ownersplitstate  = PARSENAME(replace(ownerAddress , ',' ,'.' ), 1)

select * from housing
where OwnerAddress 

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct SoldAsVacant, count(soldAsvacant) from housing group by SoldAsVacant order  by 2

select SoldAsVacant,
 case when SoldAsVacant = 'Y' then 'Yes'

  when SoldAsVacant = 'N' then 'No'
 Else SoldAsVacant 
 End 
 from housing 

 update housing set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'

  when SoldAsVacant = 'N' then 'No'
 Else SoldAsVacant 
 End 

 -----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RownumCTE As (
select * , ROW_NUMBER() over ( partition by parcelID,
													 propertyAddress,
													 salePrice,
													 SaleDate,
													 legalReference	
													 order by uniqueID) row_num
		from housing
		)
	select *from RownumCTE
	where row_num > 1
--	order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * from housing

alter table housing drop column propertyAddress,OwnerAddress,TaxDistrict, saleDate



