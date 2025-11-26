-- Exploratory data analysis

-- Checking the total number of inspections
select count(*) from inspection_results
where inspection_status = 'inspected'; -- The total number of inspections is 285,179 

-- Number of restaurants
select count(distinct camis) 
from inspection_results;

-- Total number of violations
select count(violation_code) as no_of_violations
from inspection_results
where inspection_status = 'inspected';

select `year`, count(violation_code) as no_of_violations
from inspection_results
where inspection_status = 'inspected'
group by `year`
order by no_of_violations desc;

select monthname(inspection_date_new) as `month`, count(violation_code) as no_of_violations
from inspection_results
where inspection_status = 'inspected'
group by `month`
order by no_of_violations desc;

-- Checking the number of critical violations
select count(violation_code) as critical_violations
from inspection_results
where critical_flag = 'Critical'; -- 153133 critical violations

select violation_code, violation_description, count(*) as total_critical_violations
from inspection_results
where critical_flag = 'Critical'
group by violation_code, violation_description
order by total_critical_violations desc;

-- Checking the number of inspections per year
select `year`, count(*) as no_of_inspections
from inspection_results 
where inspection_status = 'inspected'
group by `year`
order by no_of_inspections desc; -- 2024 had the higest number of inspections, followed by 2023 then 2025. 2015 had the lowest

-- Checking the number of inspections per borough
select boro, count(*) as no_of_inspections
from inspection_results 
where inspection_status = 'inspected'
group by boro
order by no_of_inspections desc; -- Manhattan has the highest number of inspections at 15,185, followed by Brooklyn at 73,937

-- Checking the number of inspections per borough over the years
select boro, `year`, count(*) as no_of_inspections
from inspection_results 
where inspection_status = 'inspected'
group by boro, `year`
order by `year` desc;

-- Boroughs with the worst scores
select boro, round(avg(cast(score as signed)), 2) as avg_score
from inspection_results
where score is not null
group by boro
order by avg_score desc; -- Queens has the worst average score, followed by Brooklyn

-- Neighborhoods with the worst scores
select zipcode, round(avg(cast(score as signed)), 2) as avg_score
from inspection_results
where score is not null
group by zipcode
order by avg_score desc limit 10; -- The 11109 zipcode has the worst average score, followed by 11001

-- Restaurants with the worst scores
select camis, dba, round(avg(cast(score as signed)), 2) as avg_score
from inspection_results
where score is not null
group by camis, dba
order by avg_score desc limit 10; 

-- Boroughs with the highest number of violations
select boro, count(violation_code) as total_violations
from inspection_results
where violation_code is not null
group by boro
order by total_violations desc; -- Manhattan has the most violations at 104,199, followed by Brooklyn

-- Neighbourhoods with the highest number of violations
select zipcode, count(violation_code) as total_violations
from inspection_results
where violation_code is not null
group by zipcode
order by total_violations desc limit 10;

-- Restaurants with the highest number of violations
select camis, dba, count(violation_code) as total_violations
from inspection_results
where violation_code is not null
group by camis, dba
order by total_violations desc limit 10;

-- Inspections with a grade but not a score
select grade, count(*)
from inspection_results 
where score is null
group by grade; -- most null scores are in rows with a null (uninspected) row or N (pending). There are 2 A grades and 2 C grades with null scores

-- Checking for missing zipcodes by borough
select boro, count(*) as missing_zipcodes
from inspection_results
where zipcode is null
group by boro;

-- Distribution of grades
select grade, count(*) as count
from inspection_results
where grade is not null
group by grade
order by grade;

-- Checking for restaurants with extremely high scores (severe violations)
select camis, dba, score, count(*) as count
from inspection_results
where score >= 100
group by camis, dba, score
order by cast(score as signed) desc;

-- Looking at seasonal changes in the average scores
select monthname(inspection_date_new) as `month`, round(avg(cast(score as signed)), 2) as avg_score
from inspection_results
where inspection_status =  'inspected'
group by `month`
order by avg_score desc; 

-- Looking at inspection types and scores + violations
select distinct inspection_type, count(*) as no_of_inspections
from inspection_results
where inspection_status = 'inspected'
group by inspection_type;

select inspection_type, round(avg(cast(score as signed)), 2) as avg_score
from inspection_results
where inspection_status = 'inspected' and score is not null
group by inspection_type
order by avg_score desc;

select inspection_type, count(violation_code) as total_violations
from inspection_results
where inspection_status = 'inspected'
group by inspection_type
order by total_violations desc; -- Cycle Inspection / Initial Inspection has the highest number of violations

select * from inspection_results;

select boro, count(*)
from inspection_results
where critical_flag = 'Critical'
group by boro;