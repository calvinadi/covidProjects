-- Checking and Cleaning Data

SELECT * 
FROM portfolioproject.dbo.covid_death
WHERE continent IS NOT NULL
ORDER BY location,date

SELECT * 
FROM portfolioproject.dbo.covid_vaccinations
WHERE continent IS NOT NULL
ORDER BY location,date

SELECT * FROM portfolioproject.dbo.covid_death
WHERE population IS NULL 

SELECT * FROM portfolioproject.dbo.covid_death
WHERE date IS NULL 

DELETE FROM portfolioproject.dbo.covid_death
WHERE population IS NULL 

SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM portfolioproject.dbo.covid_death
WHERE continent IS NOT NULL
ORDER BY location, date

--	Looking at Total Cases vs Total Deaths
--	Shows probability of dying if contract with covid in indo
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	cast(total_deaths AS DECIMAL)/cast(total_cases AS DECIMAL) * 100 AS death_percentage
FROM portfolioproject.dbo.covid_death
WHERE location LIKE 'indo%'
ORDER BY location, date


--	Looking at Total Cases vs Population
--	Shows percentage of population got Covid
SELECT 
	location,
	date,
	population,
	total_cases,
	cast(total_deaths AS DECIMAL)/population * 100 AS pop_percentage_infected
FROM portfolioproject.dbo.covid_death
WHERE location like 'indo%'
ORDER BY location, date

--	Looking at Countries with Highest Infection Rate compared to Population
SELECT 
	location,
	population,
	max(cast(total_cases AS INT)) AS highest_total_infection,
	max(cast(total_cases AS INT))/population * 100 AS pop_percentage_infected
FROM portfolioproject.dbo.covid_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY pop_percentage_infected DESC

--	Showing Countries with Highest Death Count per Population

SELECT 
	location,
	max(cast(total_deaths AS INT)) AS total_death_count
FROM portfolioproject.dbo.covid_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

--	Showing Continents with the Highest Death Count

SELECT 
	location,
	max(cast(total_deaths AS INT)) AS total_death_count
FROM portfolioproject.dbo.covid_death
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY total_death_count DESC

--	GLOBAL NUMBERS

SELECT 
	date,
	sum(new_cases) AS total_cases,
	sum(new_deaths) AS total_deaths,
	ISNULL(sum(new_deaths) / NULLIF(sum(new_cases), 0), 0) * 100 AS death_percentage
FROM portfolioproject.dbo.covid_death
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY date

SELECT 
	sum(new_cases) AS total_cases,
	sum(new_deaths) AS total_deaths,
	sum(new_deaths) / sum(new_cases) * 100 AS death_percentage
FROM portfolioproject.dbo.covid_death
WHERE continent IS NOT NULL 

--	Looking at Total Population vs Vaccinations

WITH cte_popvsvac AS(
	SELECT 
		cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		sum(cast(new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS ppl_vaccinated
	FROM covid_death cd
	JOIN covid_vaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL)
SELECT 
	*,
	(ppl_vaccinated/population)*100 AS percentage
FROM cte_popvsvac


--	Create view for Later Visualization

CREATE VIEW Percent_Population_Vaccinated AS 
	WITH cte_popvsvac AS(
		SELECT 
			cd.continent,
			cd.location,
			cd.date,
			cd.population,
			cv.new_vaccinations,
			sum(cast(new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS ppl_vaccinated
		FROM covid_death cd
		JOIN covid_vaccinations cv
		ON cd.location = cv.location AND cd.date = cv.date
		WHERE cd.continent IS NOT NULL)
	SELECT 
		*,
		(ppl_vaccinated/population)*100 AS percentage
	FROM cte_popvsvac