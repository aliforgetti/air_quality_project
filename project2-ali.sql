DROP DATABASE IF EXISTS project_2;
CREATE DATABASE IF NOT EXISTS project_2;
SET GLOBAL local_infile=1;
USE project_2;

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
IGNORE 1 ROWS;

SELECT * FROM mega_table
LIMIT 10;

SELECT count(latitude), count(longitude)
from mega_table
group by latitude, longitude;
