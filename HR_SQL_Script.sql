SELECT id, first_name, last_name, birthdate, gender, race, department, jobtitle, location, hire_date, termdate, location_city, location_state
FROM Projects.HR

USE PROJECTS

select birthdate from hr

-- Standardize dates in the birthdate and hiredate column

UPDATE HR 
SET birthdate = CASE 
	WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
	WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
	ELSE NULL
END

SELECT hire_date FROM hr


ALTER TABLE PROJECTS.HR MODIFY COLUMN BIRTHDATE DATE;

UPDATE HR 
SET hire_date = CASE 
	WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date , '%m/%d/%Y'), '%Y-%m-%d')
	WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date , '%m-%d-%Y'), '%Y-%m-%d')
	ELSE NULL
END

ALTER TABLE PROJECTS.HR MODIFY COLUMN hire_date DATE NULL;

-- Standardize termdate column

update hr
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')) 
where termdate is not null and termdate != ''

update hr
set termdate = null
where termdate = '';

select birthdate, termdate from hr
where termdate != null;

alter table projects.HR
modify column termdate date null;

alter table projects.HR
modify column hire_date date null;

describe hr

-- Add age column
ALTER TABLE HR
ADD COLUMN Age INT

UPDATE HR 
SET AGE = timestampdiff(YEAR, birthdate, CURDATE())

SELECT AGE, BIRTHDATE FROM HR

-- Cleaning ages and birthyears
SELECT MIN(AGE), MAX(AGE) FROM HR

SELECT COUNT(AGE) FROM HR 
WHERE AGE < 18


-- ANALYSIS
-- What is the gender breakdown of the employees in the company? 
SELECT GENDER, COUNT(GENDER), (COUNT(GENDER)/ (SELECT COUNT(GENDER) FROM HR WHERE AGE >=18 AND TERMDATE IS NULL )*100) AS PROPORTION
FROM HR
WHERE AGE>=18 AND TERMDATE IS NULL
GROUP BY GENDER

-- What is the race/ethnicity breakdown of the employees? 
SELECT race, COUNT(*) FROM projects.HR
where age > 18 and termdate is null
GROUP BY race
order by count(*) desc

-- What is the age distribution of employees in the company
SELECT 
	CASE 
		WHEN AGE >= 18 AND AGE <25 THEN '18-24'
		WHEN AGE >= 25 AND AGE <35 THEN '25-34'
		WHEN AGE >= 35 AND AGE <45 THEN '35-44'
		WHEN AGE >= 45 AND AGE <54 THEN '45-54'
		WHEN AGE >= 55 AND AGE <64 THEN '55-64'
		ELSE '65+'
	END AS age_group, 
	gender,
	count(*)
FROM HR
WHERE AGE >= 18 AND TERMDATE IS NULL
GROUP BY AGE_GROUP, gender
ORDER BY AGE_GROUP

-- How many employees WFH vs at the office
select location, count(*) from hr
where age >=18 and termdate is NULL 
GROUP BY LOCATION


-- What is the average length of employment for employees who have been terminated
SELECT  avg(DATEDIFF(termdate, hire_date))/365 as avg_years FROM HR
where termdate is not null and termdate < year(CURDATE()) and age >= 18
	

-- How does gender distribution vary across departments and job title
SELECT DEPARTMENT, GENDER, COUNT(*) FROM HR
WHERE AGE >=18 AND TERMDATE IS NULL
GROUP BY DEPARTMENT, GENDER
ORDER BY DEPARTMENT

-- What is the distribution of job titles across the company? 
SELECT JOBTITLE, COUNT(*) FROM HR
WHERE AGE >=18 AND TERMDATE IS NULL 
GROUP BY JOBTITLE
ORDER BY JOBTITLE DESC 

-- Which department has the highest turnover date
SELECT department, total_count, terminated_count, terminated_count/total_count as termination_rate
FROM (
	SELECT DEPARTMENT,
		COUNT(*) AS total_count, 
		SUM(CASE WHEN TERMDATE IS NOT NULL AND TERMDATE <= CURDATE() THEN 1 ELSE 0 END) AS terminated_count
		FROM HR
	WHERE AGE >= 18 
	GROUP BY DEPARTMENT
) as subquery
GROUP BY DEPARTMENT
ORDER BY termination_rate desc

-- What is the distribution of employees across locations by city and state

select location_state, count(*)
from hr
where age >=18 and termdate is NULL 
group by location_state
order by count(*) desc

-- How has the company's employee count changed over time based on hire and term dates
select yearofoperation, hires, fired, hires-fired as net_change, round((hires-fired)/hires*100, 2) as net_change_percent
from (
select year(hire_date) as yearofoperation, 
count(year(hire_date)) as hires, 
SUM(CASE WHEN termdate is not null and termdate <= curdate() then 1 else 0 end) as fired
from hr
where age >= 18 
group by yearofoperation 
order by yearofoperation
) as subquery

-- What is the tenure distribution for each department?
SELECT department, round(avg(averagetenure), 0)
from(
 SELECT department, DATEDIFF(termdate, hire_date)/365 as averagetenure
 from hr
 where termdate is  null or termdate <=curdate() and age >= 18
) as subquery
GROUP BY department
ORDER BY avg(averagetenure) desc



select count(year(termdate)) from hr

