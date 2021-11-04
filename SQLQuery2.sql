-- 

select *
from Nashville.dbo.[Nashville Housing]

-- Standardize Date Format  -- removendo o horário do formato de data

select SaleDateConverted, CONVERT(Date, SaleDate)
from Nashville.dbo.[Nashville Housing]

Update [Nashville Housing]
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [Nashville Housing]
Add SaleDateConverted Date;

Update [Nashville Housing]
SET SaleDateConverted = CONVERT(Date, SaleDate)



----------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

select *
from Nashville.dbo.[Nashville Housing]
--where PropertyAddress is null
 order by ParcelID
 

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Nashville.dbo.[Nashville Housing] a
JOIN Nashville.dbo.[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- criando nova coluna com isnull (se a is null, populate with b)
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville.dbo.[Nashville Housing] a
JOIN Nashville.dbo.[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- usando a nova coluna no endereço da tabela "a"
update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville.dbo.[Nashville Housing] a
JOIN Nashville.dbo.[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-------------------------------------------------------------------------------------------------------
-- Breaking out address into individual columns (Address, City, State)

select PropertyAddress
from Nashville.dbo.[Nashville Housing]
--where PropertyAddress is null
--order by ParcelID
 
-- seleciona o texto (posição 1) até a vírgula
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
from Nashville.dbo.[Nashville Housing]

-- separa depois da vírgula a cidade no texto (posição depois da vírgula)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from Nashville.dbo.[Nashville Housing]


ALTER TABLE [Nashville Housing]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Nashville Housing]
Add PropertySplitCity Nvarchar(255);

Update [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- ao final teremos duas colunas com endereço separado da cidade
select *
from Nashville.dbo.[Nashville Housing]


-- agora com owner address
select OwnerAddress
from Nashville.dbo.[Nashville Housing]

-- PARSENAME só funciona com ponto, não com vírgula
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from Nashville.dbo.[Nashville Housing]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from Nashville.dbo.[Nashville Housing]

ALTER TABLE [Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing]
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from Nashville.dbo.[Nashville Housing]


--------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant), Count(SoldAsVacant)
from Nashville.dbo.[Nashville Housing]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from Nashville.dbo.[Nashville Housing]

Update [Nashville Housing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


select distinct(SoldAsVacant), Count(SoldAsVacant)
from Nashville.dbo.[Nashville Housing]
Group by SoldAsVacant
Order by 2

---------------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID
				   ) row_num

from Nashville.dbo.[Nashville Housing]
--order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress



WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID
				   ) row_num

from Nashville.dbo.[Nashville Housing]
--order by ParcelID
)
DELETE
From RowNumCTE
where row_num > 1
--Order by PropertyAddress

------------------------------------------------------------------------------------------------------------------

--Delete Unused Colmns

select *
from Nashville.dbo.[Nashville Housing]

ALTER TABLE Nashville.dbo.[Nashville Housing]
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE Nashville.dbo.[Nashville Housing]
DROP COLUMN SaleDate