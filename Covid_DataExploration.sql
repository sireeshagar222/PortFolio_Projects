Select *
from Testdb..CovidDeaths

Select * from Testdb..CovidDeaths
Where continent is not null
Order by 4,5

--getting data we will be working on
Select location,date,total_cases, new_cases,total_deaths,population 
from Testdb.dbo.CovidDeaths
Where continent is not null
Order by 1,2

--Total cases vs total deaths  (Death Percentage)
Select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from Testdb.dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Percentage Population Infected
Select location,date,total_cases, population, (total_cases/population)*100 PercentageInfected
from Testdb.dbo.CovidDeaths
Where continent is not null 
--and location like '%India%'
Order by 1,2

--Countries with Higest infection rate with Population and Maximum percentage infection in a country

Select location,max(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 PercentageInfected
from Testdb.dbo.CovidDeaths
Where continent is not null 
--and location like '%India%'
Group by location,population 
Order by PercentageInfected desc 

--Countries with MaxDeathCount per population, Percentage Death 

Select location,Max(cast(total_deaths as int)) as MaxDeathCount, population, (MAx(total_deaths)/population)*100 as PercentageDeath
from Testdb.dbo.CovidDeaths
Where continent is not null 
--and location like '%India%'
Group by location,population 
Order by MaxDeathCount desc 

-----------breaking by continent

Select location, Max(cast(total_deaths as bigint)) as MaxDeathCount 
from Testdb..CovidDeaths
Where continent is null
group by location
Order by MaxDeathCount desc 


Select continent, Max(cast(total_deaths as bigint)) as MaxDeathCount 
from Testdb..CovidDeaths
Where continent is not null
group by continent
Order by MaxDeathCount desc 

---- Total cases, total deaths, Death percentage globally

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
       SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Testdb..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

Select * from Testdb..CovidVaccinations;

------------- Cummulative Population vaccinated per location


Select dea.location,dea.date,dea.population,vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPopulationVaccinated
from Testdb..CovidDeaths dea
join Testdb..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
order by 1,2

--CTE to calculate percentage of rolling population vaccinated.

With PercentageRollingPoplnVaccinated(location,date,population,new_vaccinations,RollingVaccinated)
as(
Select dea.location,dea.date,dea.population,vac.new_vaccinations,
  sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPopulationVaccinated
from Testdb..CovidDeaths dea
join Testdb..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null
--order by 1,2
)
Select *, (RollingVaccinated)/population *100 as PercentageVaccinated
from PercentageRollingPoplnVaccinated

--with temp table for above query

Drop table if exists #PercentRollingPoplnVaccinated
Create table #PercentRollingPoplnVaccinated(
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingVaccinated numeric,
)
Insert into #PercentRollingPoplnVaccinated 
Select dea.location,dea.date,dea.population,vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinated
from Testdb..CovidDeaths dea
join Testdb..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 1,2

Select *,(RollingVaccinated/population)*100 as PercentageVaccinated
from #PercentRollingPoplnVaccinated
Order by location,date

--Creating View for same

Drop view if exists PopVaccinated 
Create View PopVaccinated as
Select dea.location,dea.date,dea.population,vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinated
from Testdb..CovidDeaths dea
join Testdb..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null

Select * , (RollingVaccinated/population)*100 as PercentageVaccinated
from PopVaccinated







