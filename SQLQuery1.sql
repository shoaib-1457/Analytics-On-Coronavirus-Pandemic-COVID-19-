
SELECT *
FROM Portfolioproject..['Cowid Deaths$']
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM Portfolioproject..['Cowid Vaccinations$']
--ORDER BY 3,4

-- Select Data that we were going to be using For Country India
-- This Selected Data is showing Dying Rate in India
SELECT location,date,total_cases,total_deaths,
    CASE
        WHEN TRY_CAST(total_deaths AS float) = 0 THEN NULL
        ELSE (TRY_CAST(total_deaths AS float) / TRY_CAST(total_cases AS float)) *100 END AS DeathPercentage
FROM Portfolioproject..['Cowid Deaths$']
WHERE location like '%India%'
ORDER BY 1, 2;

-- Looking at total Cases VS Population

SELECT location,date,total_cases,population,(total_cases/population) * 100 as PercentPopulationInfected
FROM Portfolioproject..['Cowid Deaths$']
WHERE location like '%India%'
ORDER BY 1, 2;

-- Looking at the max percent of people in each country
SELECT location, MAX(population) as population,MAX(total_cases) as HighestInfectionCount,MAX((CAST(total_cases AS float) / population) * 100) as PercentPopulationInfected
FROM Portfolioproject..['Cowid Deaths$']
GROUP BY location,population
ORDER BY PercentPopulationInfected desc

-- Looking at the Highest Death Country
SELECT location, Max(cast(total_deaths as int)) AS MaxDeathCount
FROM Portfolioproject..['Cowid Deaths$']
WHERE continent is not null
GROUP BY location,population
ORDER BY MaxDeathCount desc

-- Looking at the Highest Death Continent
-- Showing continent with highest death count per population
SELECT continent, Max(cast(total_deaths as int)) AS MaxDeathCount
FROM Portfolioproject..['Cowid Deaths$']
WHERE continent is not null
GROUP BY continent
ORDER BY MaxDeathCount desc

--Global Numbers
SELECT SUM(ISNULL(new_cases, 0)) as TotalCases,SUM(ISNULL(CAST(new_deaths AS int), 0)) as TotalDeaths,
      SUM(ISNULL(CAST(new_deaths AS int), 0)) / NULLIF(SUM(ISNULL(new_cases, 0)), 0) * 100 as DeathPercentage
FROM Portfolioproject..['Cowid Deaths$']
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Looking Total Population v/s Vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) As RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)
FROM Portfolioproject..['Cowid Deaths$'] dea
JOIN Portfolioproject..['Cowid Vaccinations$'] vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE
With PopvsVac (Continent, Location ,Date , Population , New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) As RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)
FROM Portfolioproject..['Cowid Deaths$'] dea
JOIN Portfolioproject..['Cowid Vaccinations$'] vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/population)
From PopvsVac


-- TEMP TABLE
/*
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255)
Date datetime,
Population numeric
New_Vaccinations numeric
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) As RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)
FROM Portfolioproject..['Cowid Deaths$'] dea
JOIN Portfolioproject..['Cowid Vaccinations$'] vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT * , (RollingPeopleVaccinated/population)
From #PercentPopulationVaccinated
*/

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) As RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)
FROM Portfolioproject..['Cowid Deaths$'] dea
JOIN Portfolioproject..['Cowid Vaccinations$'] vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View For Visualizations
-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) As RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)
FROM Portfolioproject..['Cowid Deaths$'] dea
JOIN Portfolioproject..['Cowid Vaccinations$'] vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated