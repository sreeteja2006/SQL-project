create table if not exists layoffs_stage
like layoffs;

insert layoffs_stage
select *
from layoffs;

CREATE TABLE `layoffs_stage2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_stage2
select *,row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_stage;

delete 
from layoffs_stage2
where row_num>1;

update layoffs_stage2
set company = trim(company);

update layoffs_stage2
set industry ='Crypto'
where industry like 'Crypto%';

update layoffs_stage2
set country = TRIM(trailing '.' FROM country)
where country = 'United States.';

update layoffs_stage2
set date = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_stage2
modify column `date` DATE;

update layoffs_stage2
set industry = NULL
where industry ='';

update layoffs_stage2 t1
join layoffs_stage2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is NULL or t1.industry ='')
and t2.industry is not NULL
;

delete
from layoffs_stage2
where total_laid_off is NULL
and percentage_laid_off is NULL
;

ALTER TABLE layoffs_stage2
DROP column row_num;

-- EDA --

select company,sum(total_laid_off)
from layoffs_stage2
group by company
order by 2 desc;





	
