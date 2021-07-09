
--SELECT *
--FROM PortfolioProject..CovidDeaths$
--order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4

--Getting data we need
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Let us look into the total cases vs total deaths
--Data shows likelihood of death if one contracts the virus in your country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeath
from PortfolioProject..CovidDeaths$
where location = 'Australia'
order by 1,2

--Let us look into the Total Population vs Total cases
--Shows likelihood(in %) of contracting the virus in your country
Select location, date, total_cases,population, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
where location = 'Australia'
order by 1,2

--Countries with highest infection rates compared to population
Select location, MAX(total_cases),population, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location = 'Australia'
Group by location, population
order by PercentagePopulationInfected DESC

--Countries with Highest Death Count 
Select location, MAX(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location = 'Australia'
where continent != 'NULL'
Group by location
order by TotalDeathCount DESC

--Continents with Highest Death Count 
Select continent, MAX(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location = 'Australia'
where continent is not NULL
Group by continent
order by TotalDeathCount DESC

--Looking at numbers on a global scale by day
Select date, SUM(new_cases) as totalcases,SUM(cast(new_deaths as INT)) as totaldeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as PercentageOfDeath
from PortfolioProject..CovidDeaths$
--where location = 'Australia'
where continent is not Null
group by date
order by 1,2
--Looking at numbers on a global scale on the whole
Select SUM(new_cases) as totalcases,SUM(cast(new_deaths as INT)) as totaldeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as PercentageOfDeath
from PortfolioProject..CovidDeaths$
--where location = 'Australia'
where continent is not Null
--group by date
order by 1,2

--Total Population vs Vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(convert(int,v.new_vaccinations)) OVER (Partition by d.location order by d.date) as RollingCountVaccinated
FROM PortfolioProject..CovidDeaths$ d
Join PortfolioProject..CovidVaccinations$ v
On d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

--Using Temp Table to calculate Percentage of people Vaccinated compared to population
Drop Table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(continent nvarchar(255),location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,RollingCountVaccinated numeric)
Insert into #PercentagePopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(convert(int,v.new_vaccinations)) OVER (Partition by d.location order by d.date) as RollingCountVaccinated
FROM PortfolioProject..CovidDeaths$ d
Join PortfolioProject..CovidVaccinations$ v
On d.location = v.location and d.date = v.date
where d.continent is not null

Select *, (RollingCountVaccinated/population)*100 as PercentagePopulationVaccinated
From #PercentagePopulationVaccinated order by 2,3

--USING CTE to calculate Percentage of people Vaccinated compared to population

WITH PvsV (continent, location,date,population,new_vaccinations,RollingCountVaccinated)
as(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(convert(int,v.new_vaccinations)) OVER (Partition by d.location order by d.date) as RollingCountVaccinated
FROM PortfolioProject..CovidDeaths$ d
Join PortfolioProject..CovidVaccinations$ v
On d.location = v.location and d.date = v.date
where d.continent is not null
)
Select *, (RollingCountVaccinated/population)*100 as PercentagePopulationVaccinated
From PvsV order by 2,3

--Creating views
Create view HighestDeathCount as
Select continent, MAX(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location = 'Australia'
where continent is not NULL
Group by continent
