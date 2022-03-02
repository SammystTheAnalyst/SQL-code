select *
From  MyPortfolioProject..Adolescent_Birthrate_in_Countries
order by 3,4

--select *
--From  MyPortfolioProject..CountriesAndWBI

select WHO_region_string, Country_string, Adolescent_birth_rate_per_1000_women_aged_15_19_years_string
From  MyPortfolioProject..Adolescent_Birthrate_in_Countries

-- To find the total adolescent birthrate per continent

select WHO_region_string, SUM(Adolescent_birth_rate_per_1000_women_aged_15_19_years_string) as Total_Per_Region
From  MyPortfolioProject..Adolescent_Birthrate_in_Countries
Group by WHO_region_string
order by 2 desc

-- To find the total adolescent birthrate per country in Africa

Create View TotalPerCountryinAfrica as
select WHO_region_string, Country_string, SUM(Adolescent_birth_rate_per_1000_women_aged_15_19_years_string) as Total_Per_Country
From  MyPortfolioProject..Adolescent_Birthrate_in_Countries
where WHO_region_string like '%Africa%'
Group by WHO_region_string, Country_string
order by 3 asc

-- To find the frequency of countries per continent

Create View CountCountryPerRegion as 
select WHO_region_string, COUNT(Country_string) as Count_of_Countries
From MyPortfolioProject..Adolescent_Birthrate_in_Countries
Group by WHO_region_string
--order by 2 desc

-- to find the total Adolescent birthrate of each country per number of country occurence

select WHO_region_string, Country_string, SUM(Adolescent_birth_rate_per_1000_women_aged_15_19_years_string) as Total_Per_Country, SUM(Adolescent_birth_rate_per_1000_women_aged_15_19_years_string)/COUNT(Country_string) as Ratio_Per_Country
From  MyPortfolioProject..Adolescent_Birthrate_in_Countries
Group by WHO_region_string, Country_string
--order by 2 desc

-- Looking closely at Nigeria in each year

Create View AdolescentBirthrateDataInNigeria as
select Year_string, Country_string, Adolescent_birth_rate_per_1000_women_aged_15_19_years_string
From  MyPortfolioProject..Adolescent_Birthrate_in_Countries
where Country_string like '%Nigeria%'
Order by Year_string

-- Joining with the data on World Bank Indicator

select *
From MyPortfolioProject..Adolescent_Birthrate_in_Countries ABC
Join MyPortfolioProject..CountriesAndWBI2 WBI
On ABC.Country_string = WBI.Country_string
order by 3,4


-- Let's take a look at the total adolescent_birthrate_per_1000_women_aged_15_19_years_string per World_Bank_income_group

Create View TotalAdolescentBirthratePerWBI as
select World_Bank_income_group, SUM(Adolescent_birth_rate_per_1000_women_aged_15_19_years_numeric) OVER (Partition by World_Bank_income_group) as Total_Per_WBI
FROM MyPortfolioProject..CountriesAndWBI2


-- Let's also take a look at the count of WBI, maybe it may be partly responsible for the total figures obtained per World_Bank_Indicator

Create View TotalCountWBI as
select World_Bank_income_group, COUNT(World_Bank_income_group) as Count_of_WBI
From MyPortfolioProject..CountriesAndWBI2
Group by World_Bank_income_group



-- Rolling numbers per year
With AvgPerYear(Year_string, Country_string, Adolescent_birth_rate_per_1000_women_aged_15_19_years_numeric, RollingNumbers_PerCountry)
as
(
select ABC.Year_string, ABC.Country_string, WBI.Adolescent_birth_rate_per_1000_women_aged_15_19_years_numeric
, SUM(Adolescent_birth_rate_per_1000_women_aged_15_19_years_numeric) OVER (PARTITION BY ABC.Country_string Order by ABC.Country_string, ABC.Year_string) as RollingNumbers_PerCountry
From MyPortfolioProject..Adolescent_Birthrate_in_Countries ABC
Join MyPortfolioProject..CountriesAndWBI2 WBI
On ABC.Country_string = WBI.Country_string
)
select *
From AvgPerYear


-- Creating views

Create View RollingNumbersPerCountriesPerYear as
select ABC.Year_string, ABC.Country_string, WBI.Adolescent_birth_rate_per_1000_women_aged_15_19_years_numeric
, SUM(Adolescent_birth_rate_per_1000_women_aged_15_19_years_numeric) OVER (PARTITION BY ABC.Country_string Order by ABC.Country_string, ABC.Year_string) as RollingNumbers_PerCountry
From MyPortfolioProject..Adolescent_Birthrate_in_Countries ABC
Join MyPortfolioProject..CountriesAndWBI2 WBI
On ABC.Country_string = WBI.Country_string


select *
from RollingNumbersPerCountriesPerYear
