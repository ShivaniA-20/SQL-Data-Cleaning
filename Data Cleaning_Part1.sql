-- SQL Project - Data Cleaning

select * from layoffs;

CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

-- To check what data is present in staging table
select * from layoffs_staging;

-- insert dats as table is empty
insert layoffs_staging
select * from layoffs;


-- Data cleaning:
-- 1. Remove duplicates
-- 2. Standardize the data (spellings)
-- 3. Check Null or blank values
-- 4. Remove any columns and rows that are not necessary




-- 1. Remove duplicates

-- We need a unique row id to identify duplicates
-- PARTITION BY clause is used to partition rows of table into groups

select*, 
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',
stage,country,funds_raised_millions) as row_num
from layoffs_staging;


-- use a cte/subquery to filter row number is greater than 1

with duplicate_cte as
(
select*, 
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,
stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
select * from duplicate_cte
where row_num>1;


-- Now delete the duplicate records
-- Below method does not work

with duplicate_cte as
(
select*, 
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',
stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
delete from duplicate_cte
where row_num>1;


-- Create a new column and add those row numbers in.

create table `layoffs_staging2` (
`company` text,
`location` text,
`industry` text,
`total_laid_off` int default null,
`percentage_laid_off` text,
`date` text,
`stage` text,
`country` text,
`funds_raised_millions` int default null,
`row_num` int) 
engine=InnoDB default charset=utf8mb4 collate=utf8mb4_0900_ai_ci;


-- check if any records are present
select * from layoffs_staging2;


-- insert data and now along with new column row_num
insert into layoffs_staging2
select*, 
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',
stage,country,funds_raised_millions) as row_num
from layoffs_staging;

-- filter out the duplicate rows
select * from layoffs_staging2
where row_num>1;

-- delete the duplicates
delete from layoffs_staging2
where row_num>1;




-- 2. Standardize the data (spellings)

-- TRIM company
select company,trim(company)
from layoffs_staging2;

update layoffs_staging2
set company=trim(company);


-- Update Industry
select distinct industry from layoffs_staging2
where industry like "crypto%";

update layoffs_staging2
set industry='Crypto'
where industry like "crypto%";

update layoffs_staging2
set country='United States'
where country like "United States%";

select distinct country from layoffs_staging2
order by 1;


-- Change Data type of Date column

select `date`,
str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set date=str_to_date(`date`,'%m/%d/%Y');

select * from layoffs_staging2;

alter table layoffs_staging2
modify column `date` DATE;




-- 3. Check Null or blank values

select * from layoffs_staging2
where total_laid_off is null;


-- check Industry
select * from layoffs_staging2
where industry is null
or industry='';


-- taking an example company
select * from layoffs_staging2
where company = 'Carvana';


-- set all blank values to NULL
update layoffs_staging2
set industry=null
where industry='';

-- check
select * from layoffs_staging2
where industry is null
or industry='';


-- populate data
select t1.industry, t2.industry from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company=t2.company
and t1.location=t2.location
where (t1.industry is null or t1.industry='')
and t2.industry is not null;


-- Update the rows
update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null
and t2.industry is not null;


-- Bally's Interactive not updated as there are no 2 rows for this
select * from layoffs_staging2
where company like "Bally's%";



-- 4. Remove any columns and rows that are not necessary

select * from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;





-- drop column
alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2
