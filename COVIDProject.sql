select*
from PortfolioProject..['death-covid-data$']
where continent is not null
order by 3,4

--select*
--from PortfolioProject..['vacs-covid-data$']
--order by 3,4

--select data

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['death-covid-data$']
order by 1,2

--looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract COVID in your country

select Location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
from PortfolioProject..['death-covid-data$']
where location like '%states%'
order by 1,2

--Total Cases vs Population
--percentage of COVID contraction
select Location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulation
from PortfolioProject..['death-covid-data$']
--where location like '%states%'
order by 1,2

--Countries with highest infection rate vs population
select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentofPopulationInfected
from PortfolioProject..['death-covid-data$']
--where location like '%states%'
group by location, population
order by PercentofPopulationInfected desc

--Countries with highest death count per population
select Location, Max(cast(total_deaths as int)) as totaldeathCount
from PortfolioProject..['death-covid-data$']
--where location like '%states%'
where continent is not null
group by location
order by totaldeathCount desc


--continent with highest death 
select continent, Max(cast(total_deaths as int)) as totaldeathCount
from PortfolioProject..['death-covid-data$']
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathCount desc

--global

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as globaldeath
from PortfolioProject..['death-covid-data$']
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
,(rollingpeoplevaccinated/population)*100
from PortfolioProject..['death-covid-data$'] dea	
join PortfolioProject..['vacs-covid-data$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..['death-covid-data$'] dea	
join PortfolioProject..['vacs-covid-data$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

--temp table

Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..['death-covid-data$'] dea	
join PortfolioProject..['vacs-covid-data$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view for viz
create view percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..['death-covid-data$'] dea	
join PortfolioProject..['vacs-covid-data$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

create view casesvsdeaths as
select Location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
from PortfolioProject..['death-covid-data$']
where location like '%states%'
--order by 1,2

create view highestdeathperpop as
select Location, Max(cast(total_deaths as int)) as totaldeathCount
from PortfolioProject..['death-covid-data$']
--where location like '%states%'
where continent is not null
group by location
--order by totaldeathCount desc

create view infectvsvac as
select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentofPopulationInfected
from PortfolioProject..['death-covid-data$']
--where location like '%states%'
group by location, population
--order by PercentofPopulationInfected desc