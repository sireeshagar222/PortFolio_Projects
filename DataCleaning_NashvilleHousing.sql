/* Cleaning data in SQL*/

Select * from Testdb..NashvilleHousing

-- Changing date format
Select SaleDate , cast(SaleDate as date)
from Testdb.dbo.NashvilleHousing

Update Testdb.dbo.NashvilleHousing
set SaleDate=CAST(SaleDate as date) 

--Above query didn't work for me

Alter table Testdb.dbo.NashvilleHousing
Add SaleDateConverted date

Update Testdb.dbo.NashvilleHousing
set SaleDateConverted =CAST(SaleDate as date) 

Select SaleDate, SaleDateConverted
from Testdb.dbo.NashvilleHousing



---Populate Property address data

Select ParcelID,PropertyAddress
from Testdb..NashvilleHousing
--where PropertyAddress is null

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from Testdb..NashvilleHousing a
join Testdb..NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Testdb..NashvilleHousing a
join Testdb..NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

---Breaking Property address , OwnerAddress into Address,city,state
--1.Property Address 
---i.using substring and charlength
Select PropertyAddress,
Substring(PropertyAddress,1,charindex(',', PropertyAddress)-1) as Address,
Substring(PropertyAddress,charindex(',', PropertyAddress)+1,len(PropertyAddress)) as City
from Testdb..NashvilleHousing

---ii.using parsename and replace
Select PropertyAddress,
PARSENAME(replace(PropertyAddress,',','.'),2) as Address,
PARSENAME(replace(PropertyAddress,',','.'),1) as City
from Testdb..NashvilleHousing

Alter table Testdb..NashvilleHousing
add PropertyAddress_address nvarchar(255),PropertyAddress_city nvarchar(100)

Update Testdb..NashvilleHousing
set PropertyAddress_address = Substring(PropertyAddress,1,charindex(',', PropertyAddress)-1),
PropertyAddress_city = Substring(PropertyAddress,charindex(',', PropertyAddress)+1,len(PropertyAddress))

Select PropertyAddress, PropertyAddress_address,PropertyAddress_city
from Testdb..NashvilleHousing

--2.OwnerAddress

Select OwnerAddress
from Testdb..NashvilleHousing

--i.using substring and charlength
/*Select OwnerAddress,
Substring(OwnerAddress,1,charindex(',', OwnerAddress)-1) as Address,
Substring(OwnerAddress,charindex(',', OwnerAddress)+1,len(OwnerAddress)) as City
--Substring(OwnerAddress,charindex(',', OwnerAddress)+1,len(PropertyAddress)) as State
from Testdb..NashvilleHousing
*/

--select OwnerAddress
--, REPLACE(SUBSTRING(OwnerAddress, 1, LEN(OwnerAddress) - CHARINDEX(' ', REVERSE(OwnerAddress), CHARINDEX(' ', REVERSE(OwnerAddress)) + 1)), ',', '') as address
--, SUBSTRING(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(' ', REVERSE(OwnerAddress), CHARINDEX(' ', REVERSE(OwnerAddress)) + 1) + 2, 9) as city
--, SUBSTRING(OwnerAddress, LEN(OwnerAddress) + 2 - CHARINDEX(' ', REVERSE(OwnerAddress)), CHARINDEX(' ', REVERSE(OwnerAddress))) as state
--from Testdb..NashvilleHousing


--Using parsename and replace
Select OwnerAddress,
PARSENAME(replace(OwnerAddress,',','.'),3) as Address,
PARSENAME(replace(OwnerAddress,',','.'),2) as City,
PARSENAME(replace(OwnerAddress,',','.'),1) as State
from Testdb..NashvilleHousing
where OwnerAddress is not null

Alter table Testdb..NashvilleHousing
add OwnerAddress_address nvarchar(255), 
	OwnerAddress_City nvarchar(100),
	OwnerAddress_State nvarchar(50)


Update Testdb..NashvilleHousing
Set OwnerAddress_address = PARSENAME(replace(OwnerAddress,',','.'),3),
	OwnerAddress_City = PARSENAME(replace(OwnerAddress,',','.'),2),
	OwnerAddress_State = PARSENAME(replace(OwnerAddress,',','.'),1)

Select OwnerAddress, OwnerAddress_address,OwnerAddress_City,OwnerAddress_State
from Testdb..NashvilleHousing
where OwnerAddress is not null

--Changing Y and N to Yes and No in sold as vacant field

Select distinct(SoldAsVacant)
from Testdb..NashvilleHousing

Select distinct(SoldAsVacant),count(SoldAsVacant)
from Testdb..NashvilleHousing
group by SoldAsVacant 
order by 2 desc

Select SoldAsVacant,
Case 
	when SoldAsVacant= 'Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	else SoldAsVacant
end 
from Testdb..NashvilleHousing
where SoldAsVacant in('Y','N')

Update Testdb..NashvilleHousing
set SoldAsVacant= 
Case 
	when SoldAsVacant= 'Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	else SoldAsVacant
end

--Removing duplicates

Select ROW_NUMBER() over (
partition by ParcelID,PropertyAddress,SaleDateConverted,SalePrice,LegalReference order by UniqueID ) as Row_num
from Testdb..NashvilleHousing
--where row_num >1

--to see duplicate rows
With RowNumCTE as(
Select * , 
	ROW_NUMBER() over (
	partition by ParcelID,PropertyAddress,SaleDateConverted,SalePrice,LegalReference order by UniqueID ) as Row_num
	from Testdb..NashvilleHousing )
Select * from RowNumCTE where Row_num >1

--to delete duplicates
With RowNumCTE as(
Select * , 
	ROW_NUMBER() over (
	partition by ParcelID,PropertyAddress,SaleDateConverted,SalePrice,LegalReference order by UniqueID ) as Row_num
	from Testdb..NashvilleHousing )
--Select * from RowNumCTE where Row_num >1
Delete from RowNumCTE where Row_num >1

Select * from Testdb..NashvilleHousing

--delete unused columns

Alter table Testdb..NashvilleHousing
Drop column OwnerAddress,TaxDistrict
--,SaleDate