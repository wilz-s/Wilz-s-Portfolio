-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022




SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove unnecessary columns or rows


create table layoffs_staging
like layoffs; 

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;
-- creating a duplicate copy of 'layoffs' table for editing purpose


SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;
-- we create row numbers for the rows above to make sure they are unique. Any with no. > 1 isn't

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
-- check for duplicates using a CTE


SELECT *
FROM layoffs_staging
WHERE company = 'Casper';
-- checking the results to make sure they really are duplicates.


CREATE TABLE `layoffs_staging2` (
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
-- creating a new layoff_stagging database to copy the data to and delete the duplicates 



SELECT *
FROM layoffs_staging2;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
-- we insert the data into the table.

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;
-- now, we can delete the duplicates

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;
-- checking for duplicates. There should be none.

SELECT * 
FROM layoffs_staging2;
-- taking a look at the current table now with the changes done





-- 2. STANDARDIZING DATA(finding issues and fixing them)

SELECT company, (TRIM(company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);
-- fixing company column


SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
-- fixing industry column.


SELECT DISTINCT Country, TRIM(TRAILING '.'  FROM country)
FROM layoffs_staging2
ORDER BY 1 ;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.'  FROM country)
WHERE country LIKE 'United States%';
-- fixing country column


SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- fixing date column. Changing from text format to date format.

SELECT `date`
FROM layoffs_staging2;
-- checking the change

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;




-- 3. Null Values or blank values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- checking for nulls

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';
-- checking for nulls in industry column
-- notice that some of the blanks can be filled if we can identify other rows with similar values.

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';


SELECT t1.company, t2.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;
-- we fix the issue



SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT *
FROM layoffs_staging2;
-- taking a final look at the table.

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
-- we remove row_num column as it no longer serves a purpose.
-- cleaning is done.



