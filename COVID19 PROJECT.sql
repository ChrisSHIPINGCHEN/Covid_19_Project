SELECT *
FROM covid19..CovidDeaths 
where continent is not null
ORDER BY 3,4

-- Looking at Total Cases VS Total Deaths
-- Shows likelyhood of dying if you contract the covid in Canada
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathsPercentage
FROM covid19..CovidDeaths 
WHERE Location like '%Canada%'
ORDER BY 1,2

-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population) *100 as PercentPopulation
FROM covid19..CovidDeaths 
where continent is not null
ORDER BY 1,2

-- Looking at Contries with Highest Inection Rate compared to Population 

SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)) *100 as PercentPopulationInfected
FROM covid19..CovidDeaths 
where continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(Total_deaths) as TotalDeathCount
FROM covid19..CovidDeaths 
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Showing contintents with the highest death count per population
SELECT continent, MAX(Total_deaths) as TotalDeathCount
FROM covid19..CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Gloabl Numbers
SELECT SUM(total_cases) as Total_Cases, SUM(total_deaths) as Total_Deaths, SUM(total_deaths)/SUM(total_cases) * 100 as DeathPercentage
FROM covid19..CovidDeaths 
WHERE continent is not null
ORDER BY 1,2

-- JOIN two table together

SELECT * 
FROM covid19..CovidDeaths  dea
JOIN covid19..CovidVaccinations  vac
  ON dea.Location = vac.Location
  and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPoepleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM covid19..CovidDeaths  dea
JOIN covid19..CovidVaccinations  vac
  ON dea.Location = vac.Location
  and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 
FROM PopvsVac


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM covid19..CovidDeaths  dea
JOIN covid19..CovidVaccinations  vac
  ON dea.Location = vac.Location
  and dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated/Population) * 100 
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visulizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM covid19..CovidDeaths  dea
JOIN covid19..CovidVaccinations  vac
  ON dea.Location = vac.Location
  and dea.date = vac.date
WHERE dea.continent is not null
