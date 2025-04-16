 -- STEP 1: creating temp table with reformatted values. Some values were imported as text value to allow for variations of value types. 
 -- NULL values are cleaned out in the first step due to interfering with query results of aggregate functions. 
 -- Columns with numeric or decimal values without NULL values are reformatted as decimal in the first step. 
 
 CREATE TEMP TABLE esg_1 AS
 SELECT symbol, 
		name, 
		sector, 
		industry, 
		full_time_employees AS employees,
		total_esg_risk_score::decimal AS total_score, 
		environment_risk_score::decimal AS environment_score, 
		governance_risk_score::decimal AS governance_score, 
		social_risk_score::decimal AS social_score, 
		controversy_level, 
		controversy_score, 
		esg_risk_percentile AS risk_percentile, 
		esg_risk_level AS risk_level
FROM sp500_esg_riskratings
WHERE total_esg_risk_score IS NOT NULL;


-- STEP 2: further reformatting of data, standardizing values with percentiles, and standardizing NULL values. 
-- For the "employees" column, large numbers would often be represented with a ',' (for example, '10,000'). 
	-- The ',' are replaced with blank space, and the column is reformatted to numeric value. 
-- The column 'controversy_level' also has long value names which have been shortened. ('moderate controversy level' to 'moderate)
-- The column 'controversy _score' contains NULL values and 'N/A' values.
	-- The N/A values were converted to NULL using the CASE WHEN function. 
	-- The column is reformatted to numeric. 
-- The column 'risk_percentile' has values such as '3rd percentile' or '26th percentile'.
	-- The word 'percentile has been removed, and the values shortened to just the number, then reformatted to numeric.
-- The whole TEMP TABLE was then turned into a regular table using the SELECT INTO function. 

SELECT symbol,
name,
sector, 
industry,
REPLACE(employees, ',', '')::numeric AS employees,
total_score,
environment_score,
governance_score,
social_score, 
REPLACE(controversy_level, 'Controversy Level', '') AS controversy_level, 
CASE WHEN controversy_score = 'N/A' THEN NULL
	ELSE controversy_score END::numeric AS controversy_score,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE (risk_percentile, 'percentile',''),'nd',''),'rd',''),'th',''),'st','')::numeric AS risk_percentile,
risk_level
INTO esg_score
FROM esg_1
 

