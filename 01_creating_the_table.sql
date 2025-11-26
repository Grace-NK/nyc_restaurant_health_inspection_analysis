-- CREATING THE TABLE


CREATE TABLE inspection_results (
    camis BIGINT,
    dba TEXT,
    boro TEXT,
    building TEXT,
    street TEXT,
    zipcode TEXT,
    phone TEXT,
    cuisine_description TEXT,
    inspection_date_raw TEXT, -- IMPORTANT: temporary text column for the date
    `action` TEXT,
    violation_code TEXT,
    violation_description TEXT,
    critical_flag TEXT,
    score TEXT, 
    grade TEXT,
    grade_date TEXT,
    record_date TEXT,
    inspection_type TEXT,
    latitude DOUBLE,
    longitude DOUBLE,
    community_board TEXT,
    council_district TEXT,
    census_tract TEXT,
    bin TEXT, 
    bbl TEXT, 
    nta TEXT,
    location_point1 TEXT
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/inspection_results.csv'
INTO TABLE inspection_results
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES -- Skip the header row
(camis, dba, boro, building, street, zipcode, phone, cuisine_description, inspection_date_raw, `action`, violation_code, violation_description, critical_flag, score, grade, grade_date, record_date, inspection_type, latitude, longitude, community_board, council_district, census_tract, bin, bbl, nta, location_point1)
;

SHOW CREATE TABLE inspection_results; 

ALTER TABLE inspection_results 
MODIFY latitude VARCHAR(30) NULL;

ALTER TABLE inspection_results 
MODIFY longitude VARCHAR(30) NULL;

select count(*)  from inspection_results;