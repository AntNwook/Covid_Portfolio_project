-- Covid 19 Data Exploration
-- Skills demonstrated: Joins, CTE's, Temp tables, Windows fuctions, creating views, converting data types 



-- checking to make sure that my data was fully and properly imported 
select * 
from coviddeaths;

select count(*) 
from coviddeaths;


select * 
from covidvaccinations;

select Count(*) 
from covidvaccinations;

-- Selecting Data that will be used 

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null;

-- Looking at Total Cases vs Total Deaths 
-- Likelihood of Dying if you contract covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Deathpercentage
from coviddeaths
where location = 'United States'
and continent is not null;

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Deathpercentage
from coviddeaths
where location = 'Nigeria'
and continent is not null;

-- Looking at total cases v population
-- Shows what percentage of population is infected

select location, date, total_cases, population, (total_cases/population) * 100 as InfectionPercentage
from coviddeaths
where location = 'United States'
and continent is not null;

-- Looking at countries with highest infection rate compared to population 

select location, population, max(total_cases)as HighestInfectionCount,Max((total_cases/population)) * 100 as InfectionPercentage
from coviddeaths
-- where location = 'United States'
group by population, location
Order by InfectionPercentage DESC;

-- Showing countries with the highest death count compared to population

select location, max(cast(total_deaths as unsigned)) as TotalDeathCount
from coviddeaths
where continent is not null
group by location
Order by TotalDeathCount DESC;


-- Lets break things down by continent/continents with highest death count 

select continent, max(cast(total_deaths as unsigned)) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
Order by TotalDeathCount DESC;

-- Global numbers 

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) * 100 as GlobalDeathPercentage
from coviddeaths
where continent is not null
group by date;

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) * 100 as GlobalDeathPercentage
from coviddeaths
where continent is not null;
-- group by date;

select *
from covidvaccinations;

-- Looking at population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2, 3;

-- Use CTE

with PopvVac (Continent, location, date, population, new_vaccinations, RollingCountOfVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RolingCountOfVaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2, 3
)
select *, (RollingCountOfVaccinated/Population) * 100
from PopvVac;

-- Temp table
drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations char,
RollingCountOfVaccinated numeric
);
-- ask about this code and data type later!
insert into PercentPopulationVaccinated
select dea.continent, dea.location, cast(dea.date as Date), dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RolingCountOfVaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2, 3;

Select *, (rollingcountofvaccinated/population) * 100
from PercentpopulationVaccinated;

-- Creating view to store data for visualization

create view Populationvaccinated as
select dea.continent, dea.location, cast(dea.date as Date), dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RolingCountOfVaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null;


 







		

