-- Exploratory Data Analysis

-- Exploring for trends and patterns. Not looking for anything in particular



SELECT *
FROM layoffs_staging2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
-- checking the max total_laid_off & percentage_laid_off

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- checking the total layoff, highest to lowest
-- noticing that it's the usual big companies with the most layoffs.


SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- checking the start to end date of the layoffs. 2020-2023


SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
-- checking the industries
-- mostly consumer, retail and transportaion


SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- checking countries. The US was #1 by far then India & netherlands.


SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;


SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- checking year


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
-- checking stage. Most from post-IPO(amazon, google types of companies) & acquired companies




SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY  `MONTH`
ORDER BY 1 ASC;
-- want to see the progressive increase in layoff month by month.


WITH Rolling_Total AS
(
 SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY  `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
-- using a cte to make a rolling total.


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;
-- checking the companies with the most layoffs by the year.


WITH Company_Year (Company, Years, Total_Laid_Off) AS
(
 SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY Years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE Years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;
-- ranking the companies based on the most layoffs.  
