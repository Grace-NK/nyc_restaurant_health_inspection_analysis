-- creating a new table with just the necessary columns
create table inspection_results_analysis as
select camis, 
		  dba, 
          boro, 
          zipcode, 
          cuisine_description, 
          inspection_status,
          inspection_date_new as inspection_date,
          inspection_type,
          violation_code, 
          violation_description,
          `action`,
          score,
          grade,
          critical_flag
          
from inspection_results;


select count(*) from inspection_results_analysis;
select * from inspection_results_analysis limit 20;


-- 1. WHICH VIOLATIONS ARE MOST COMMON, AND WHERE DO THEY OCCUR MOST FREQUENTLY?
-- Most common violations
select violation_code, violation_description, count(*) as total_violations
from inspection_results_analysis
where violation_code is not null
group by violation_code, violation_description
order by total_violations desc limit 10; -- Top 5 most common violations: 10F, 08A, 06D, 02G, 10B

-- Where they occur most frequently
select boro, violation_code, count(*) as total_violations
from inspection_results_analysis
where violation_code is not null and boro != 'not specified'
group by boro, violation_code
order by total_violations desc limit 20; -- Manhattan leads in all top violations (10F, 08A, 06D, 02G, 10B), Brooklyn is second for 10F, followed by Queens


-- 2. WHICH CUISINES AND NEIGHBORHOODS HAVE THE LOWEST FOOD SAFETY PERFORMANCE?
-- worst cuisine performance
select cuisine_description, count(*) as total_inspections,
round(avg(cast(score as signed)), 2) as avg_score,
sum(case when grade = 'C' then 1 else 0 end) as grade_C_count -- grade C is the worst grade 
from inspection_results_analysis
where score is not null and inspection_status = 'inspected' 
group by cuisine_description
order by avg_score desc; -- African cuisine has a higher average score which means lower food safety performance. Asian cuisine is second and also has the highest number of C grades

-- worst neighborhood performance
select zipcode, boro, count(*) as total_inspections,
round(avg(cast(score as signed)), 2) as avg_score,
sum(case when grade = 'C' then 1 else 0 end) as grade_C_count  
from inspection_results_analysis
where score is not null and inspection_status = 'inspected' and zipcode is not null
group by zipcode, boro
order by avg_score desc limit 10;

-- 3. HOW DO RESTAURANT GRADES AND VIOLATIONS VARY ACROSS BOROUGHS AND OVER TIME?

-- restaurant grades across boroughs
select boro, grade, count(*) as total
from inspection_results_analysis
where grade is not null and inspection_status = 'inspected'
group by boro, grade
order by boro, total desc;

-- restaurant grades over years
select year(inspection_date) as `year`, grade, count(*) as count
from inspection_results_analysis 
where grade is not null and inspection_status = 'inspected'
group by `year`, grade
order by `year`, grade;

-- violations across boroughs
select boro, count(violation_code) as total_violations
from inspection_results_analysis
where violation_code is not null and inspection_status = 'inspected'
group by boro
order by total_violations desc;

-- violations over the years
select year(inspection_date) as `year`, count(violation_code) as total_violations
from inspection_results_analysis
where violation_code is not null and inspection_status = 'inspected'
group by `year`
order by `year`;

-- 4. WHERE SHOULD THE CITY FOCUS INSPECTIONS, POLICIES, OR EDUCATION TO IMPROVE FOOD SAFETY?
-- High risk areas (those with the most worst scores and violations)
select zipcode, boro, round(avg(cast(score as signed)), 2) as avg_score, count(violation_code) as total_violations
from inspection_results_analysis
where score is not null and inspection_status = 'inspected'
group by zipcode, boro
order by avg_score desc, total_violations desc limit 10;

-- Most problematic violations for education
select violation_code, violation_description, critical_flag, count(*) as frequency, count(distinct camis) as affected_restaurants
from inspection_results_analysis
where violation_code is not null
group by violation_code, violation_description, critical_flag
order by frequency desc limit 10;

