-- Total cases vs total deaths: Shows the likelihood of a person dying when infected with the COVID-19 virus.
SELECT 
    location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    (total_deaths / total_cases) * 100 AS percentage_death
FROM [portfolio project].[dbo].[CovidDeaths$]
ORDER BY location, date;

-- Percentage of people who got COVID-19.
SELECT 
    location, 
    date, 
    (total_cases / population) * 100 AS percentage_infected
FROM [portfolio project].[dbo].[CovidDeaths$]
ORDER BY date;

-- Compares percentage of population infected in each country.
SELECT 
    location, 
    population, 
    MAX(total_cases) AS highest_infection_count, 
    MAX((total_cases / population) * 100) AS percentage_infected
FROM [portfolio project].[dbo].[CovidDeaths$]
GROUP BY location, population
ORDER BY percentage_infected DESC;

-- Compares the death percentage of each country.
SELECT 
    location, 
    population, 
    MAX(CAST(total_deaths AS INT)) AS total_deaths, 
    MAX((total_deaths / population) * 100) AS percentage_deaths
FROM [portfolio project].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_deaths DESC;

-- Compares the number of deaths of each continent.
SELECT 
    location, 
    MAX(CAST(total_deaths AS INT)) AS total_deaths
FROM [portfolio project].[dbo].[CovidDeaths$]
WHERE continent IS NULL
  AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_deaths DESC;

-- Total cases, total deaths, total death percentage.
SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS total_death_percentage
FROM [portfolio project].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL;

-- Time stamps with global data.
SELECT 
    location, 
    population, 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS death_percentage
FROM [portfolio project].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY location;

-- Vaccination data with rolling population.
WITH rollpopvac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumulative_total_vaccinations
    FROM [portfolio project].[dbo].[CovidDeaths$] AS dea
    JOIN [portfolio project].[dbo].[CovidVaccinations$] AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT 
    continent, 
    location, 
    date, 
    population, 
    new_vaccinations, 
    cum_vaccinations, 
    (cum_vaccinations / population) * 100 AS percentage_vaccinated
FROM rollpopvac;
