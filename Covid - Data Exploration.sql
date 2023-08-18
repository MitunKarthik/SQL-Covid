SELECT * 
FROM [Covid deaths]
ORDER BY 3,4

--SELECT * 
--FROM [Covid Vaccinations]
--ORDER BY 3,4

--Total Cases VS Total Deaths
SELECT Location,date,total_cases,total_deaths,population
FROM [Covid deaths]
ORDER By 1,2

--Death Percentage during Covid
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercenrage
FROM [Covid deaths]
where location like '%india%'
ORDER By 1,2
--Death Percentage in INDIA
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercenrage
FROM [Covid deaths]
where location like '%india%'
ORDER By 1,2

--Total Cases VS Population
--Percentage of Population affected by Covid
SELECT Location,date,total_cases,population, (total_cases/population)*100 AS CasesPercentage
FROM [Covid deaths]
ORDER By 1,2
--Percentage of Population affected by Covid In INDIA
SELECT Location,date,total_cases,population, (total_cases/population)*100 AS CasesPercentage
FROM [Covid deaths]
WHERE location like '%India%'
ORDER By 1,2

--Remove Unnecessary Rows
SELECT DISTINCT(Location)
FROM [Covid deaths]

DELETE
FROM [Covid deaths]
WHERE Location in ('World' ,'High income', 'Upper middle income','Lower middle Income','Asia','Europe','European union','North America','South America','Africa')

--Countries with Highest Infection Rate compared to Population
SELECT Location, population ,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) AS PercentPopulationInfected
FROM [Covid deaths]
GROUP BY Location,population
ORDER BY PercentPopulationInfected desc

--Total Death Count per Location
SELECT Location, MAX(total_deaths) AS DeathCount
FROM [Covid deaths]
GROUP BY Location 
ORDER BY DeathCount desc

--Countries with Highest Death Rate compared to Population
SELECT Location, population ,MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population)) AS PercentPopulationDead
FROM [Covid deaths]
GROUP By Location,population
ORDER BY HighestDeathCount desc

--Death Count by Continent
SELECT continent, MAX(total_deaths) AS DeathCount
FROM [Covid deaths]
WHERE continent is not null
GROUP BY Continent 
ORDER BY DeathCount desc

--GLOBAL NUMBERS
--Replace 0 with NULL (to avoid error during calculations)
UPDATE [Covid deaths] SET new_cases=NULL 
WHERE new_cases=0 
UPDATE [Covid deaths] SET new_deaths=NULL 
WHERE new_deaths=0

SELECT date,SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercent
FROM [Covid deaths]
GROUP BY date
order by date

--Total Cases VS Total Deaths (In the World)
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercent
FROM [Covid deaths]

--JOINING both tables

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date)
FROM [Covid Vaccinations] vac
JOIN [Covid deaths] dea ON vac.location = dea.location and vac.date = dea.date
where dea.continent is not null
Order By 2,3

-- Rolling Vaccination Total
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER ( PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinationTotal
FROM [Covid Vaccinations] vac
JOIN [Covid deaths] dea ON vac.location = dea.location and vac.date = dea.date
where dea.continent is not null

--Try CTE

WITH PopVsVac AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER ( PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinationTotal
FROM [Covid Vaccinations] vac
JOIN [Covid deaths] dea ON vac.location = dea.location and vac.date = dea.date
where dea.continent is not null
)

SELECT*,(RollingVaccinationTotal/population)*100 AS PercentVaccinated
FROM PopVsVac

--Create Temp Tables

--DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationTotal numeric
)
INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER ( PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinationTotal
FROM [Covid Vaccinations] vac
JOIN [Covid deaths] dea ON vac.location = dea.location and vac.date = dea.date
where dea.continent is not null

SELECT *
FROM #PercentPeopleVaccinated
Order by 2,3

--Creating Views for later visualization

Create View PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER ( PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinationTotal
FROM [Covid Vaccinations] vac
JOIN [Covid deaths] dea ON vac.location = dea.location and vac.date = dea.date
where dea.continent is not null












