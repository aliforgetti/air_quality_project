DROP DATABASE IF EXISTS project_2;
CREATE DATABASE IF NOT EXISTS project_2;
SET GLOBAL local_infile=1;
USE project_2;

SET SESSION sql_mode = '';

DROP TABLE IF EXISTS  project_2.mega_table;
CREATE TABLE project_2.mega_table (
	id INT PRIMARY KEY auto_increment,
	state_code varchar(100) ,
	county_code varchar(100) ,
	site_num varchar(100) ,
	parameter_code varchar(100) ,
	poc varchar(100) ,
	latitude varchar(100) ,
	longitude varchar(100) ,
	datum varchar(100) ,
	parameter_name varchar(100) ,
	sample_duration varchar(100) ,
	pollutant_standard varchar(100) ,
	metric_used varchar(100) ,
	method_name varchar(150) ,
	`year` varchar(100) ,
	units_of_measure varchar(100) ,
	event_type varchar(100) ,
	observation_count varchar(100) ,
	observation_percent varchar(100) ,
	completeness_indicator varchar(100) ,
	valid_day_count varchar(100) ,
	required_day_count varchar(100) ,
	exceptional_data_count varchar(100) ,
	_data_count varchar(100) ,
	primary_exceedance_count varchar(100) ,
	secondary_exceedance_count varchar(100) ,
	certification_indicator varchar(100) ,
	num_obs_below_mdl varchar(100) ,
	arithmetic_mean varchar(100) ,
	arithmetic_standard_dev varchar(100) ,
	first_max_value varchar(100) ,
	first_max_datetime varchar(100) ,
	second_max_value varchar(100) ,
	second_max_datetime varchar(100) ,
	third_max_value varchar(100) ,
	third_max_datetime varchar(100) ,
	fourth_max_value varchar(100) ,
	fourth_max_datetime varchar(100) ,
	first_max_non_overlapping_value varchar(100) ,
	first_no_max_datetime varchar(100) ,
	second_max_non_overlapping_value varchar(100) ,
	second_no_max_datetime varchar(100) ,
	ninety_nine_percentile varchar(100) ,
	ninety_eight_percentile varchar(100) ,
	ninety_five_percentile varchar(100) ,
	ninety_percentile varchar(100) ,
	seventy_five_percentile varchar(100) ,
	fifty_percentile varchar(100) ,
	ten_percentile varchar(100) ,
	local_site_name varchar(100) ,
	address varchar(200) ,
	state_name varchar(100) ,
	county_name varchar(100) ,
	city_name varchar(100) ,
	cbsa_name varchar(100) ,
	date_of_last_change varchar(100) 
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4;


LOAD DATA INFILE 'C:/wamp64/tmp/epa_air_quality_annual_summary.csv' 
INTO TABLE mega_table 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(state_code, county_code, site_num, parameter_code, poc, latitude,
 longitude,
 datum,
 parameter_name,
 sample_duration,
 pollutant_standard,
 metric_used,
 method_name,
 year,
 units_of_measure,
 event_type,
 observation_count,
 observation_percent,
 completeness_indicator,
 valid_day_count,
 required_day_count,
 exceptional_data_count,
 _data_count,
 primary_exceedance_count,
 secondary_exceedance_count,
 certification_indicator,
 num_obs_below_mdl,
 arithmetic_mean,
 arithmetic_standard_dev,
 first_max_value,
 first_max_datetime,
 second_max_value,
 second_max_datetime,
 third_max_value,
 third_max_datetime,
 fourth_max_value,
 fourth_max_datetime,
 first_max_non_overlapping_value,
 first_no_max_datetime,
 second_max_non_overlapping_value,
 second_no_max_datetime,
 ninety_nine_percentile,
 ninety_eight_percentile,
 ninety_five_percentile,
 ninety_percentile,
 seventy_five_percentile,
 fifty_percentile,
 ten_percentile,
 local_site_name,
 address,
 state_name,
 county_name,
 city_name,
 cbsa_name,
 date_of_last_change);

SELECT * FROM mega_table
LIMIT 10;

-- Deleting all instanes of recordings from Canada
SET SQL_SAFE_UPDATES = 0;
DELETE FROM mega_table
WHERE state_code = 'CC';
SET SQL_SAFE_UPDATES = 1;
-- ------------------------------------------------------------------------------------------
-- LOCATION INFORMATION 
-- Combination of state_code, county_code and site_num determine all of the other variables
-- Split state code and state name into separate tables. 
SET SESSION sql_mode = '';
 
 -- 1. 
DROP TABLE IF EXISTS state_info;
CREATE TABLE IF NOT EXISTS state_info(
 	state_code SMALLINT,
    state_name VARCHAR(20),
    PRIMARY KEY(state_code));
    
-- INSERT INTO state_info
INSERT INTO state_info(state_code,state_name)
SELECT DISTINCT(state_code), state_name
FROM mega_table
ORDER BY state_code;

-- VERIFY CORRECT INSERT
SELECT *
FROM state_info;


-- Each row is a unique combination of state_code, county_code and site num
DROP TABLE IF EXISTS loc_info;
CREATE TABLE IF NOT EXISTS loc_info(
	state_code SMALLINT NOT NULL,
    county_code SMALLINT UNSIGNED NOT NULL,
	site_num INT UNSIGNED ,
    county_name VARCHAR(50),
    city_name VARCHAR(50),
    latitude DECIMAL(11,6),
    longitude DECIMAL(11,6),
    local_site_name VARCHAR(150),
    cbsa_name VARCHAR(50), -- this may need to be split
    -- address VARCHAR(150), -- this may need to be split or maybe just dropped
	PRIMARY KEY(state_code, county_code, site_num),
	CONSTRAINT fk_state_code
		FOREIGN KEY(state_code)
        REFERENCES state_info(state_code)
        ON UPDATE CASCADE
	);

-- INSERT INTO loc_info
INSERT INTO loc_info(state_code, county_code, site_num, city_name, county_name, latitude, longitude, local_site_name, cbsa_name)
SELECT distinct
	state_code, 
	county_code,
    site_num, 
    city_name,
	county_name, 
    IF(latitude='',NULL,CAST(latitude as decimal(11,6))) as latitude,
    IF(longitude='',NULL,CAST(longitude as decimal(11,6))) as longitude,
	local_site_name, 
	cbsa_name
	-- address
FROM mega_table;

-- VERIFY CORRECT INSERT
select * 
from loc_info
order by state_code, county_code, site_num;

-- ------------------------------------------------------------------------------------------
-- MEASUREMENT INFORMATION and PARAMETER INFO
-- each unique combination of parameter_code and poc determine the parameter name, units of measure and metric used. 
-- 'id' determines which measurement we are looking at for the measurement info table

DROP TABLE IF EXISTS parameter_info;
CREATE TABLE IF NOT EXISTS parameter_info(
    parameter_code INT UNSIGNED,
    poc TINYINT UNSIGNED,
    parameter_name VARCHAR(100),
	units_of_measure VARCHAR(150),
	PRIMARY KEY(parameter_code, poc));

-- Insert into parameter_info table
INSERT INTO parameter_info(parameter_code, poc, parameter_name, units_of_measure)
SELECT distinct
	parameter_code, 
    poc, 
    parameter_name, 
    units_of_measure
FROM mega_table;

select * from parameter_info;

-- Creation of measurement info
DROP TABLE IF EXISTS measurement_info;
CREATE TABLE IF NOT EXISTS measurement_info(
	id INT UNSIGNED,
    parameter_code INT UNSIGNED,
    poc TINYINT UNSIGNED,
	datum VARCHAR(10),
	method_name VARCHAR(200),
	year INT UNSIGNED,
    sample_duration VARCHAR(100),
	metric_used VARCHAR(100),
	state_code SMALLINT,
    county_code SMALLINT UNSIGNED,
	site_num INT UNSIGNED DEFAULT NULL,
    PRIMARY KEY(id),
	CONSTRAINT fk_state_county_site
		FOREIGN KEY(state_code, county_code, site_num)
        REFERENCES loc_info(state_code, county_code, site_num)
        ON UPDATE CASCADE,
	CONSTRAINT fk_parameter_poc
		FOREIGN KEY(parameter_code, poc)
        REFERENCES parameter_info(parameter_code, poc)
        ON UPDATE CASCADE
	);
    
-- INSERT INTO measurement_info
INSERT INTO measurement_info(id, parameter_code, poc, datum, method_name, year, sample_duration, metric_used, state_code, county_code, site_num)
SELECT id, 
	parameter_code, 
    poc, 
    datum, 
    method_name, 
    year, 
    sample_duration, 
    metric_used, 
    state_code, 
    county_code, 
    site_num
FROM mega_table;

-- VERIFY CORRECT INSERT
SELECT *
FROM measurement_info
where parameter_code = 42401;

-- ------------------------------------------------------------------------------------------
-- READING INFORMATION 

SET SQL_MODE = '';


DROP TABLE IF EXISTS reading_info;
CREATE TABLE IF NOT EXISTS reading_info(
	id INT UNSIGNED,
    observation_count INT UNSIGNED,
    observation_percent TINYINT UNSIGNED,
	num_obs_below_mdl TINYINT UNSIGNED,
    arithmetic_mean DECIMAL(11,6),
    arithmetic_standard_dev DECIMAL(11,6),
    first_max_value DECIMAL(11,6),
    first_max_datetime datetime DEFAULT NULL,
    second_max_value DECIMAL(11,6),
    second_max_datetime DATETIME DEFAULT NULL,
    third_max_value DECIMAL(11,6),
	third_max_datetime DATETIME DEFAULT NULL, 
    fourth_max_value DECIMAL(11,6),
    fourth_max_datetime DATETIME DEFAULT NULL,
--  first_max_non_overlapping_value DECIMAL(11,6), THESE TABLES ARE DROPPED BECAUSE THEY BREAK THE 1NF AND MOST OF THEM ARE NULL
--  first_no_max_datetime DATETIME DEFAULT NULL,
--  second_max_non_overlapping_value DECIMAL(11,6),
--  second_no_max_datetime DATETIME DEFAULT NULL,
--  ninety_nine_percentile DECIMAL(11,6),
--  ninety_eight_percentile DECIMAL(11,6),
    ninety_five_percentile DECIMAL(11,6),
    ninety_percentile DECIMAL(11,6),
	seventy_five_percentile DECIMAL(11,6),
    fifty_percentile DECIMAL(11,6),
    ten_percentile DECIMAL(11,6),
    pollutant_standard VARCHAR(100),
    PRIMARY KEY(id),
	CONSTRAINT fk_id
		FOREIGN KEY(id) 
        REFERENCES measurement_info(id)
        ON UPDATE CASCADE
);

-- INSERT INTO reading_info
INSERT INTO reading_info(
	id,
    observation_count,
    observation_percent,
	num_obs_below_mdl,
    arithmetic_mean,
    arithmetic_standard_dev,
    first_max_value,
    first_max_datetime,
    second_max_value,
    second_max_datetime,
    third_max_value,
	third_max_datetime,
    fourth_max_value,
	fourth_max_datetime,
--  first_max_non_overlapping_value,
--  first_no_max_datetime,
--  second_max_non_overlapping_value,
--  second_no_max_datetime,
--  ninety_nine_percentile,
--  ninety_eight_percentile,
    ninety_five_percentile,
    ninety_percentile,
	seventy_five_percentile,
    fifty_percentile,
    ten_percentile,
    pollutant_standard)
SELECT 	
	id,
    observation_count,
    observation_percent,
	num_obs_below_mdl,
    IF(arithmetic_mean='',NULL,CAST(arithmetic_mean as decimal(11,6))) as arithmetic_mean,
    IF(arithmetic_standard_dev='',NULL,CAST(arithmetic_standard_dev as decimal(11,6))) as arithmetic_standard_dev,
	IF(first_max_value='',NULL,CAST(first_max_value as decimal(11,6))) as first_max_value,
--  IF(first_max_datetime='',NULL,CAST(first_max_datetime as datetime)) as first_max_datetime,
    first_max_datetime,
    IF(second_max_value='',NULL,CAST(second_max_value as decimal(11,6))) as second_max_value,
--  IF(second_max_datetime='',NULL,CAST(second_max_datetime as DATETIME)) as second_max_datetime,
    second_max_datetime,
    IF(third_max_value='',NULL,CAST(third_max_value as decimal(11,6))) as third_max_value,
--  IF(third_max_datetime='',NULL,CAST(third_max_datetime as DATETIME)) as third_max_datetime,
    third_max_datetime,
    IF(fourth_max_value='',NULL,CAST(fourth_max_value as decimal(11,6))) as fourth_max_value,
--  IF(fourth_max_datetime=0000-00-00 00:00:00,NULL,CAST(fourth_max_datetime as datetime)) as fourth_max_datetime,
    fourth_max_datetime,
--  IF(first_max_non_overlapping_value='',NULL,CAST(first_max_non_overlapping_value as decimal(11,6))) as first_max_non_overlapping_value,
--  IF(first_no_max_datetime='0000-00-00 00:00:00',NULL,CAST(first_no_max_datetime as DATETIME)) as first_no_max_datetime,
--  IF(second_max_non_overlapping_value='',NULL,CAST(second_max_non_overlapping_value as decimal(11,6))) as second_max_non_overlapping_value,
--  IF(second_no_max_datetime='0000-00-00 00:00:00',NULL,CAST(second_no_max_datetime as DATETIME)) as second_no_max_datetime,
--  ninety_nine_percentile,
--  ninety_eight_percentile,
    ninety_five_percentile,
    ninety_percentile,
	seventy_five_percentile,
    fifty_percentile,
    ten_percentile,
    pollutant_standard
FROM mega_table;


-- VERIFY CORRECT INSERT
select *
from reading_info;


-- ------------------------------------------------------------------------------------------
-- VALIDATION INFORMATION 

DROP TABLE IF EXISTS validation_info;
CREATE TABLE IF NOT EXISTS validation_info(
	id INT UNSIGNED,
	completeness_indicator VARCHAR(2),
	valid_day_count INT UNSIGNED,
	required_day_count INT UNSIGNED,
	exceptional_data_count INT UNSIGNED,
	null_data_count INT UNSIGNED,
	primary_exceedance_count INT UNSIGNED,
	secondary_exceedance_count INT UNSIGNED,
	certification_indicator VARCHAR(50),
	event_type VARCHAR(50),
    PRIMARY KEY(id),
    CONSTRAINT fk_idd
		FOREIGN KEY(id) 
        REFERENCES measurement_info(id)
        ON UPDATE CASCADE
);

INSERT INTO validation_info(
	id,
	completeness_indicator,
	valid_day_count,
	required_day_count,
	exceptional_data_count,
	null_data_count,
	primary_exceedance_count,
	secondary_exceedance_count,
	certification_indicator,
	event_type)
SELECT
	id,
	completeness_indicator,
	valid_day_count,
	required_day_count,
	exceptional_data_count,
	_data_count,
	IF(primary_exceedance_count ='',NULL, CAST(primary_exceedance_count as FLOAT)) as primary_exceedance_count,
	IF(secondary_exceedance_count ='',NULL, CAST(secondary_exceedance_count as FLOAT)) as secondary_exceedance_count,
	certification_indicator,
	event_type
FROM mega_table;

-- VERIFY CORRECT INSERT
select *
from validation_info;

 
-- TRIGGERS
DROP TRIGGER IF EXISTS verifyExists;
delimiter //
CREATE TRIGGER verifyExists 
BEFORE INSERT ON state_info
FOR EACH ROW
BEGIN
	IF NEW.state_code in (
    	select state_code
        From state_info
        where (NEW.state_code = state_info.state_code)) 
        THEN 
        SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT =  'INSERT NOT ALLOWED - VALUE REPEATED';
	END IF;
    END //
delimiter ;

INSERT INTO state_info
values(1,'California');

-- TRIGGER TO INSERT INTO THE LOC INFO TABLE

DROP TRIGGER IF EXISTS verifyExistsLoc;
delimiter //
CREATE TRIGGER verifyExistsLoc
BEFORE INSERT ON loc_info
FOR EACH ROW
BEGIN
	IF (NEW.state_code, NEW.county_code, NEW.site_num) in (
    	select state_code, county_code, site_num
        From loc_info
        where (NEW.state_code = loc_info.state_code) AND 
        (NEW.county_code = loc_info.county_code) AND
        (NEW.site_num = loc_info.site_num))
        THEN 
        SIGNAL SQLSTATE 'HY000'
		SET MESSAGE_TEXT =  'INSERT NOT ALLOWED - VALUE REPEATED';
	END IF;
    END //
delimiter ;

SELECT * 
FROM loc_info;

INSERT INTO loc_info
VALUES(20,57,1, 'Ford', 'Dodge_City', 90, 100,'90','pol');

-- CREATE VIEW WITH ALL IMPORTANT COLUMNS TO USE

DROP VIEW last_four;
CREATE VIEW last_four AS
SELECT id, state_name, year, latitude, longitude, parameter_name, arithmetic_mean
FROM loc_info INNER JOIN state_info USING(state_code)
	INNER JOIN measurement_info USING(state_code, county_code, site_num)
    INNER JOIN parameter_info USING(parameter_code, poc)
    INNER JOIN reading_info USING(id)
WHERE year IN(2014,2015,2016,2017,2018) 
AND parameter_name IN('Ozone','Nitrogen dioxide (NO2)','Sulfur dioxide','Carbon monoxide','Carbon dioxide');


SELECT count(id) from last_four;




