

/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



Select top 2 percent *
from [Portfolio Project]..CovidDeaths


--select Dataum those we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project].dbo.CovidDeaths
order by 1,2

--Total Cases Vs Total Deaths and percentage of deaths in Ethiopia


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where  location like '%opi%'
order by 1,2

-- Total Cases vs Population 
-- Shows what percentage of population got Covid
 
 
 select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
 from [Portfolio Project].dbo.CovidDeaths
 where  location like '%opi%'
order by 1,2

--Looking at Countries with Highest Infection Rate Compared to Population


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%opi%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population


Select Location,MAX(cast (Total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%opi'
 where continent is not null
group by location
order by TotalDeathCount desc
 
 --Contintents with the highest death count per population

 
 Select continent,MAX(cast (Total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%opi'
 where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers 


select date,sum(new_cases) as Total_New_Cases,sum(cast(new_deaths as int)) as Total_New_Deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 PercentageOfDeathsOfNewCases
from [Portfolio Project].dbo.CovidDeaths
--where  location like '%opi%'
where continent is not null
group by date 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--USING CTE 


With cte_PopVsVac (Continent,Location,Date,Population,RollingPeopleVaccinated)
	as 
	(
Select dea.continent, dea.location, dea.date, dea.population, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)


select Distinct  Continent,Location, ((Max(RollingPeopleVaccinated) over ( partition by Location order by location))/Population)*100
from cte_PopVsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
INTO #PercentPopulationVaccinated  --- temporary table
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select *
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

