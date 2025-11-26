-- DATA CLEANING
select * from inspection_results
limit 20;

select count(*) from inspection_results;



-- 1. CREATING A NEW INSPECTION DATE COLUMN WITH DATE TYPE FOR PROPER TIME-SERIES ANALYSIS
alter table inspection_results
add column inspection_date_new DATE; 

update inspection_results
set inspection_date_new = str_to_date(inspection_date_raw, '%m/%d/%Y');



-- 2. CHECKING FOR NULL/MISSING VALUES IN KEY COLUMNS
select count(*) from inspection_results
where boro = '0'; -- 15 rows where boro is not specified

select count(*) from inspection_results
where zipcode = ''; -- 2908 rows with missing values

select count(*) from inspection_results
where cuisine_description = ''; -- 3699 rows with missing values

select count(*) from inspection_results
where inspection_date_new = '1900-01-01'; -- 3699 restaurants haven't been inspected (this date is a placeholder date for restaurants that haven't been inspected)

select count(*) from inspection_results 
where inspection_date_new is null and cuisine_description is null; -- it appears that all restaurants with missing cuisine description haven't been inspected

select count(*) from inspection_results
where `action` = ''; -- 3699 rows with missing values (these are the restaurants that haven't been inspected)

select count(*) from inspection_results
where violation_code = ''; -- 5851 rows with missing values

select count(*) from inspection_results
where score = ''; -- 15926 rows with missing values

select count(*) from inspection_results
where grade = ''; -- 148044 rows with missing values



-- 3. REPLACING THE MISSING VALUES WITH 'NULL' FOR EASIER ANALYSIS
update inspection_results
set zipcode = null where zipcode = '';

update inspection_results
set cuisine_description = null where cuisine_description = '';

update inspection_results
set inspection_date_new = null where inspection_date_new = '1900-01-01';

update inspection_results
set `action` = null where `action` = '';

update inspection_results
set violation_code = null where violation_code = '';

update inspection_results
set score = null where score = '';

update inspection_results
set grade = null where grade = '';

select * from inspection_results
limit 20;


-- 4. CREATING A NEW COLUMN TO IDENTIFY WHICH RESTAURANTS HAVE ACTUALLY BEEN INSPECTED
alter table inspection_results
add column inspection_status text;

update inspection_results
set inspection_status = case when inspection_date_new is not null then "inspected" else "not inspected" end;

select inspection_status from inspection_results;


-- 5. HANDLING NULL VALUES IN KEY COLUMNS FOR INSPECTED RESTAURANTS
update inspection_results
set boro = "not specified" where boro = '0';

update inspection_results
set cuisine_description = "not specified" where cuisine_description is null;

update inspection_results
set grade = 'N' where grade is null and inspection_status = 'inspected'; -- N = Not yet graded according to the data dictionary


-- 6. STANDARDIZING CUISINES
select distinct cuisine_description from inspection_results;

update inspection_results
set cuisine_description = case
    when cuisine_description in (
        'African',
        'Ethiopian',
        'Moroccan',
        'Egyptian'
    ) then 'African'
    
    when cuisine_description in (
        'Chinese',
        'Chinese/Japanese',
        'Chinese/Cuban',
        'Japanese',
        'Korean',
        'Thai',
        'Vietnamese',
        'Filipino',
        'Asian/Asian Fusion',
        'Southeast Asian',
        'Indonesian',
        'Bangladeshi',
        'Pakistani',
        'Indian',
        'Hawaiian'
    ) then 'Asian'
    
    when cuisine_description in (
        'Italian',
        'Pizza', 
        'French',
        'New French',
        'Greek',
        'Mediterranean',
        'Spanish',
        'Tapas',
        'Portuguese',
        'Basque',
        'German',
        'Polish',
        'Eastern European',
        'Russian',
        'Czech',
        'English',
        'Irish',
        'Scandinavian',
        'Continental',
        'Haute Cuisine'
    ) then 'European'
    
    when cuisine_description in (
        'Middle Eastern',
        'Turkish',
        'Armenian',
        'Afghan',
        'Iranian',
        'Lebanese'
    ) then 'Middle Eastern'
    
    when cuisine_description in (
        'Mexican',
        'Tex-Mex',
        'Latin American',
        'Caribbean',
        'Cuban',
        'Puerto Rican',
        'Peruvian',
        'Brazilian',
        'Chilean',
        'Soul Food', 
        'Creole',
        'Creole/Cajun',
        'Cajun',
        'Chimichurri'
    ) then 'Latin/Caribbean'
    
    when cuisine_description in (
        'American',
        'New American',
        'Southwestern',
        'Californian',
        'Southern',
        'Hamburgers',
        'Hotdogs',
        'Hotdogs/Pretzels',
        'Chicken',
        'Sandwiches',
        'Sandwiches/Salads/Mixed Buffet',
        'Salads',
        'Soups',
        'Soups/Salads/Sandwiches',
        'Steakhouse',
        'Barbecue',
        'Seafood',
        'Jewish/Kosher',
        'Bakery Products/Desserts',
        'Donuts',
        'Bagels/Pretzels',
        'Pancakes/Waffles',
        'Frozen Desserts',
        'Coffee/Tea',
        'Juice, Smoothies, Fruit Salads',
        'Bottled Beverages',
        'Fruits/Vegetables',
        'Nuts/Confectionary',
        'Vegetarian',
        'Vegan',
        'Fusion', 
        'Australian'
    ) then 'American'
    
    when cuisine_description in (
        'not specified',
        'Other',
        'Not Listed/Not Applicable'
    ) then 'not specified'
    
    else 'not specified'
end; 

update inspection_results
set cuisine_description = 'Not specified' where cuisine_description = 'not specified';

select * from inspection_results limit 30;

-- 7. CHECKING FOR AND REMOVING DUPLICATES
select camis, dba, inspection_date_new, violation_code, inspection_type, count(*) as duplicate_count
from inspection_results
group by camis, dba, inspection_date_new, violation_code, inspection_type
having duplicate_count > 1;

delete from inspection_results
where camis = '40911114'
and inspection_date_new = '2017-11-04'
and score = 15; -- SWAY LOUNGE had some duplicated inspection records with two different scores (15 & 20). I decided to keep the higher score (20) since it's the more conservative option. 

-- Simple queries to delete the only other duplicates (in Y & B ENTERTAINMENT)
delete from inspection_results where camis = '50001285' and inspection_date_new = '2019-06-28' and violation_code = '04M' limit 1;
delete from inspection_results where camis = '50001285' and inspection_date_new = '2019-06-28' and violation_code = '06C' limit 1;
delete from inspection_results where camis = '50001285' and inspection_date_new = '2019-06-28' and violation_code = '04H' limit 1;
delete from inspection_results where camis = '50001285' and inspection_date_new = '2019-06-28' and violation_code = '06D' limit 1;
delete from inspection_results where camis = '50001285' and inspection_date_new = '2019-06-28' and violation_code = '09C' limit 1;
delete from inspection_results where camis = '50001285' and inspection_date_new = '2019-06-28' and violation_code = '08A' limit 1;

select count(*) from inspection_results;

  