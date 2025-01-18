
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND continent <> ''
ORDER BY 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- selecting our data to use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND continent <> ''
ORDER BY 1,2

-- total cases vs total deaths
-- shows death percentage from covid by country
SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
AND continent <> ''
ORDER BY 1,2

-- total cases vs population
-- shows what percentage of population got covid
SELECT Location, date, Population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, Population), 0)) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND continent <> ''
ORDER BY 1,2

-- countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, Population), 0))) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND continent <> ''
GROUP BY Location, Population 
ORDER BY PercentPopulationInfected DESC


--by continent

-- showing continents with highest death count

SELECT continent, MAX(CONVERT(float, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- global numbers

SELECT SUM(CONVERT(float, new_cases)) as total_cases, SUM(CONVERT(float, new_deaths)) as total_deaths, 
SUM(CONVERT(float, new_deaths))/SUM(NULLIF(CONVERT(float, new_cases), 0))*100 as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND continent <> ''
--GROUP BY date
ORDER BY 1,2


-- looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND dea.continent <> ''
ORDER BY 2,3


--use cte
WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND dea.continent <> ''
)
SELECT *, (RollingPeopleVaccinated/(NULLIF(CONVERT(float, population), 0)))*100
FROM PopvsVac


-- temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(50),
Location varchar(50),
Date varchar(50),
Population varchar(50),
New_Vaccinations varchar(50),
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
SELECT *, (RollingPeopleVaccinated/(NULLIF(CONVERT(float, population), 0)))*100
FROM #PercentPopulationVaccinated


-- create view to store data for visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND dea.continent <> ''