select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


--total cases vs total deaths
select location, date, total_cases, total_deaths, Round((total_deaths*100/total_cases),4) as DeathPercent
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


--total cases vs population
select location, date, total_cases, population, Round((total_cases*100/population),6) as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


--countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, 
Round(MAX(total_cases/population)*100,6) as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--countries with highest death count per population
select location, population, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by HighestDeathCount desc


--continent with highest death count
select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by HighestDeathCount desc


--deaths by date
select --date, 
SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))*100/SUM(new_cases) as DeathPercent
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1


--total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using with
With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
) select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
from PopVsVac


--temp table
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
from #PercentPopulationVaccinated
order by 2

--create view for later visualisations
Drop View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select * from PercentPopulationVaccinated