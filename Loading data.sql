select * from dim_hotels;
select * from fact_bookings;
select * from fact_aggregated_bookings;

LOAD DATA LOCAL INFILE "D:\Project\fact_bookings.csv"
INTO TABLE fact_bookings
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(booking_id, property_id, booking_date, check_in_date, checkout_date,
 no_guests, room_category, booking_platform, ratings_given, 
 booking_status, revenue_generated, revenue_realized);
 
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 0;
SET GLOBAL local_infile = 1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_bookings.csv'
INTO TABLE fact_bookings
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(booking_id, property_id, booking_date, check_in_date, checkout_date,
 no_guests, room_category, booking_platform, @ratings_given, booking_status,
 revenue_generated, revenue_realized)
SET ratings_given = NULLIF(@ratings_given,'');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_aggregated_bookings.csv'
INTO TABLE fact_aggregated_bookings
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(property_id, check_in_date, room_category, successful_bookings, capacity);


 
