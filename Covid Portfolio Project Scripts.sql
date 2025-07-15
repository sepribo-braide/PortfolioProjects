select *
from PortfolioProject..CovidDeaths
--Where continent is not null
Order by 3,4

--select *
--from PortfolioProject..CovidDeaths$
--Order by 3,4

-- Select the data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (cast(total_deaths as decimal))/(cast(total_cases as decimal))*100 as  DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
Order by 1,2

-- Looking at the total cases vs population
-- shows what population of population got covid
select Location, date, total_cases, population, (total_cases/population)*100 as  PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Order by 1,2


-- Looking countries with highest infection rates compared to population
select Location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, population
Order by PercentPopulationInfected DESC


-- Showing the countries with the highest death counts per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount DESC



--LETS break it down by continents



--Showing the continents with the highest deathcount
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount DESC




-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
Order by 1,2

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
Order by 1,2



-- looking at total population vs vaccination

Select
	dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as CummulativeVaccination,
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccination)
as
(
Select
	dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as CummulativeVaccination
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (CumulativeVaccination/Population)*100
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVaccination numeric
);

Insert into #PercentPopulationVaccinated
Select
	dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as CumulativeVaccination
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *, (CumulativeVaccination/Population)*100
From #PercentPopulationVaccinated




-- creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 

Select
	dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as CumulativeVaccination
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated