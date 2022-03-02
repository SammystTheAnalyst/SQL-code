Select *
From CovidDataProject..CovidDeath
Where continent is not null

--Queries  for visualization in Tableau labelled 1-4

-- 1
--Global numbers
Select (SUM(new_cases)) as GlobalCases, (SUM(cast(new_deaths as int))) as GlobalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as GlobalDeathPercent
From CovidDataProject..CovidDeath
Where continent is not null
--Group by date


-- 2
--Highest Death Count by Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDataProject..CovidDeath
where continent is NULL
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
Order by TotalDeathCount desc


-- 3
--Countries with Highest Infection percentage compared to their population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as  PercentPopulationInfected
From CovidDataProject..CovidDeath
where continent is not NULL
Group by location, population
Order by PercentPopulationInfected desc


-- 4
--Total Cases vs Population
--Shows what percentage of the population has got covid
Select Location, Date, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as  PercentPopulationInfected
From CovidDataProject..CovidDeath
Group by location, Date, population
Order by PercentPopulationInfected desc



--Total Cases vs Total Deaths
--Shows what percentage of cases reulted in death.
Select Location, Date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as  DeathPercentage
From CovidDataProject..CovidDeath
--where location like '%Nigeria%'
Order by 1,2



--Countries with Highest Death percentage compared to their population
Select Location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as  PercentDeathPopulation
From CovidDataProject..CovidDeath
where continent is not NULL
Group by location, population
Order by PercentDeathPopulation desc



--Highest Death Count by Country
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDataProject..CovidDeath
where continent is not NULL
Group by location
Order by TotalDeathCount desc


--Joining both data on CovidDeath and CovidVaccination together
Select *
From CovidDataProject..CovidDeath dea
Join CovidDataProject..CovidVaccinations vac
on dea.Location=vac.Location
and dea.date=vac.date


--Total Population vs Total Vaccinations
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDataProject..CovidDeath dea
Join CovidDataProject..CovidVaccinations vac
on dea.Location=vac.Location
and dea.date=vac.date
where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopvsVac


--Creating Views
Create view PercentPoulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDataProject..CovidDeath dea
Join CovidDataProject..CovidVaccinations vac
on dea.Location=vac.Location
and dea.date=vac.date
where dea.continent is not null
