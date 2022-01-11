-------------------------DATA EXTRACTION-----------------------------

--GETTING DATA BY COUNTRY

----Total Cases vs. Deaths over Time
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM SQLProject..CovidDeaths
WHERE location LIKE '%Pakistan%'
AND continent is NOT NULL
ORDER BY 1,2;

----Total Cases vs. Population over Time
SELECT location, date, total_cases, population,(total_cases/population)*100 AS	contraction_percentage 
FROM SQLProject..CovidDeaths
WHERE location LIKE '%Pakistan%'
AND continent IS NOT NULL
ORDER BY 1,2;

----Infection Rate (i.e. Maximum Total Cases) Across Countries 
SELECT location, population, MAX(total_cases) AS max_infection, MAX(total_cases/population)*100 AS infection_percentage
FROM SQLProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 desc;

----Maximum Deaths per Country
SELECT location, MAX(cast(total_deaths AS INT)) AS max_deaths
FROM SQLProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER by 2 desc;

----Death as a Percentage of Population 
SELECT location, population, MAX(total_deaths) AS max_deaths, MAX(total_deaths/population)*100 AS death_percentage
FROM SQLProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 desc; 

----Total Population vs. Vaccinations 
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(BIGINT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS aggregate_vaccinations
FROM SQLProject..CovidDeaths CD
JOIN SQLProject..CovidVaccinations CV 
	ON CD.location = CV.location 
	AND CD.date = CV.date 
WHERE CD.continent IS NOT NULL 
ORDER BY 2,3;


--GETTING DATA BY CONTINENT

----Maximum Deaths per Continent
SELECT continent, MAX(cast(total_deaths AS INT)) AS max_deaths
FROM SQLProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY 2 desc;

--GETTING GLOBAL DATA 

----Total Cases vs. Total Deaths 
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, (SUM(cast(new_deaths AS INT)) /SUM(new_cases))*100 AS death_percentage
FROM SQLProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date 
ORDER BY 1,2;


-------------------------CREATING COMMON TABLE EXPRESSIONS-----------------------------


With PopulationVsVaccinations (continent, location, date, population, new_vaccinations, aggregate_vaccinations)
AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(BIGINT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS aggregate_vaccinations
FROM SQLProject..CovidDeaths CD
JOIN SQLProject..CovidVaccinations CV 
	ON CD.location = CV.location 
	AND CD.date = CV.date 
WHERE CD.continent IS NOT NULL 
)
SELECT *, (aggregate_vaccinations/population) AS aggregate_vaccinations_percentage FROM PopulationVsVaccinations;



-------------------------CREATING TABLES-----------------------------


DROP TABLE IF EXISTS VaccinatedPopulationPercentage
CREATE TABLE VaccinatedPopulationPercentage
(
continent NVARCHAR(255), 
location NVARCHAR(255), 
date DATETIME, 
population NUMERIC, 
new_vaccinations NUMERIC, 
aggregate_vaccinations NUMERIC, 
)

INSERT INTO VaccinatedPopulationPercentage
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(BIGINT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS aggregate_vaccinations
FROM SQLProject..CovidDeaths CD
JOIN SQLProject..CovidVaccinations CV 
	ON CD.location = CV.location 
	AND CD.date = CV.date 
WHERE CD.continent IS NOT NULL 

SELECT *, (aggregate_vaccinations/population) AS aggregate_vaccinations_percentage FROM VaccinatedPopulationPercentage;

--CREATING TEMP TABLES just add a # before Table--




-------------------------CREATING VIEWS-----------------------------

CREATE VIEW VaccinatedPopulationPercentageView
AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(BIGINT, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS aggregate_vaccinations
FROM SQLProject..CovidDeaths CD
JOIN SQLProject..CovidVaccinations CV 
	ON CD.location = CV.location 
	AND CD.date = CV.date 
WHERE CD.continent IS NOT NULL;
)
	



