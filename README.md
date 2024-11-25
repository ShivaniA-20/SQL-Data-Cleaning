# SQL Data Cleaning Project: World Layoffs


## Project Overview
This project focuses on data cleaning, a crucial step in ensuring data quality and usability for analysis. Using a dummy dataset related to layoffs across various companies, I performed a systematic cleaning process to transform raw data into a clean and standardized format, while preserving the original data for reference.

## Dataset
The database created is **world_layoffs**, containing the following columns:

* company
* location
* industry
* total_laid_off
* percentage_laid_off
* date
* stage
* country
* funds_raised_millions

## Cleaning Steps
The following steps were undertaken to clean the dataset:

### 1. Preserve Raw Data 
* To ensure the original data remains intact, a staging table was created:

*CREATE TABLE world_layoffs.layoffs_staging  
LIKE world_layoffs.layoffs;*


* Records were copied into this staging table for cleaning:

  *INSERT INTO layoffs_staging  
   SELECT * FROM layoffs;*

### 2. Remove Duplicates

Duplicates were identified and removed using a **PARTITION BY** clause and a new column __row_num__  

 * Created a new table with the __row_num__ column:
   
    *select* *,  
    *row_number() over(partition by company, location,industry, total_laid_off, percentage_laid_off,'date', stage, country, funds_raised_millions) as row_num*  
    *from layoffs_staging;*


   <img width="352" alt="image" src="https://github.com/user-attachments/assets/82e545f5-9fbd-4b31-80c1-9742d69172dd">


* Filtered and removed rows where __row_num > 1__:

  *DELETE FROM layoffs_staging2 WHERE row_num > 1;*

### 3. Standardize Data

 Data was standardized to ensure consistency:

- Trimmed column values and normalized names (e.g., correcting spelling inconsistencies).
- Changed the data type of the date column from __TEXT__ to __DATE__

   *ALTER TABLE layoffs_staging2  
    ALTER COLUMN date TYPE DATE USING TO_DATE(date, 'YYYY-MM-DD');*

### 4. Handle Null or Blank Values  

Null or blank values in key columns (industry, total_laid_off, percentage_laid_off) were addressed:

* Populated missing values in the __industry__ column where possible.
* Left total_laid_off and percentage_laid_off unchanged due to insufficient data.


### 5. Remove Unnecessary Columns and Rows

Rows where both total_laid_off and percentage_laid_off were null were deleted  
   
   *DELETE FROM layoffs_staging2  
    WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;*  


## Key SQL Concepts Used
* **CTEs (Common Table Expressions)**
* **PARTITION BY** for grouping duplicate records.
* **ata Type Conversion** for columns like date.
* **Data Normalization** through trimming and standardizing.
* Preserving raw data integrity through **staging tables**.


## Outcome  
The cleaned dataset is now free from duplicates, standardized, and rid of unnecessary or incomplete rows. It is ready for further analysis, ensuring accurate and reliable insights.

