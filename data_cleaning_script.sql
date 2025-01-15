
--Converting date to standard form
select convert(date,SaleDate)
from [portfolio project].[dbo].[Sheet1$]

select * from [portfolio project].[dbo].[Sheet1$]


-- populate the property Address
update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [portfolio project].[dbo].[Sheet1$] a
join [portfolio project].[dbo].[Sheet1$] b
	on a.ParcelID =b.ParcelID
	and a.UniqueID <> b.UniqueID

where a.PropertyAddress is null

--convert preperty address to street number , street name and city name

ALTER TABLE [portfolio project].[dbo].[Sheet1$]
DROP COLUMN st_name, st_no, city_name;

ALTER TABLE [portfolio project].[dbo].[Sheet1$]
ADD st_no NVARCHAR(50),
    st_name NVARCHAR(255),
    city_name NVARCHAR(255);

UPDATE [portfolio project].[dbo].[Sheet1$]
SET st_no = LEFT(PropertyAddress, CHARINDEX(' ', PropertyAddress) - 1)
WHERE CHARINDEX(' ', PropertyAddress) > 0;

UPDATE [portfolio project].[dbo].[Sheet1$]
SET st_name = CASE 
    WHEN CHARINDEX(' ', PropertyAddress) > 0 
         AND CHARINDEX(',', PropertyAddress) > CHARINDEX(' ', PropertyAddress) 
         AND CHARINDEX(',', PropertyAddress) - CHARINDEX(' ', PropertyAddress) - 1 > 0 THEN
        SUBSTRING(
            PropertyAddress, 
            CHARINDEX(' ', PropertyAddress) + 1, 
            CHARINDEX(',', PropertyAddress) - CHARINDEX(' ', PropertyAddress) - 1
        )
    ELSE NULL
END;

UPDATE [portfolio project].[dbo].[Sheet1$]
SET city_name = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1);

--convert soldasvacant Y to Yes and N to No
UPDATE [portfolio project].[dbo].[Sheet1$]
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes' 
    WHEN SoldAsVacant = 'N' THEN 'No' 
    ELSE SoldAsVacant 
END;

-- Remove duplicates
with remdup as(
select *,ROW_NUMBER()OVER(
	partition by ParcelID,LandUse,SaleDate,SalePrice,PropertyAddress,LegalReference order by UniqueID) as row_num
from [portfolio project].[dbo].[Sheet1$])

select * from remdup where row_num>1