use hotels;
-- Booking trends — daily
SELECT
  b.check_in_date AS day,
  COUNT(*) AS bookings,
  SUM(b.revenue_realized) AS revenue_realized,
  SUM(b.revenue_generated) AS revenue_generated
FROM fact_bookings b
WHERE b.booking_status = 'Checked Out' -- or include others as needed
GROUP BY b.check_in_date
ORDER BY b.check_in_date;

--  Booking trends — weekly
SELECT
  WEEK(b.check_in_date, 3) AS iso_week, -- mode 3 = ISO week in MySQL
  COUNT(*) AS bookings,
  SUM(b.revenue_realized) AS revenue_realized
FROM fact_bookings b
GROUP BY  iso_week
ORDER BY bookings desc , iso_week;

-- Booking ends — monthly
SELECT
  DATE_FORMAT(b.check_in_date, '%Y-%m') AS month_year,
  COUNT(*) AS bookings,
  SUM(b.revenue_realized) AS revenue_realized
FROM fact_bookings b
GROUP BY month_year
ORDER BY bookings desc;

-- weekends vs weekdays
SELECT
  DAYNAME(a.check_in_date) AS weekday_name,
  DAYOFWEEK(a.check_in_date) AS dow, -- 1=Sunday..7=Saturday in MySQL
  SUM(a.successful_bookings) AS total_bookings,
  SUM(a.capacity) AS total_capacity,
  ROUND(SUM(a.successful_bookings)*100.0/SUM(a.capacity),2) AS occupancy_pct
FROM fact_aggregated_bookings a
GROUP BY weekday_name, dow
ORDER BY occupancy_pct desc;

-- weekdays vs weekends but property vise 
SELECT 
    h.property_name,
    a.property_id,
    CASE 
        WHEN DAYOFWEEK(a.check_in_date) IN (1,7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(a.successful_bookings) AS total_bookings,
    SUM(a.capacity) AS total_capacity,
    ROUND(SUM(a.successful_bookings) * 100.0 / SUM(a.capacity), 2) AS occupancy_pct
FROM fact_aggregated_bookings a
JOIN dim_hotels h 
    ON a.property_id = h.property_id
GROUP BY h.property_name, a.property_id, day_type
ORDER BY property_name,occupancy_pct desc, day_type;

-- popular rooms vs underperforming ones
SELECT
  b.room_category,
  COUNT(*) AS bookings,
  SUM(b.revenue_realized) AS revenue_realized,
  AVG(DATEDIFF(b.checkout_date, b.check_in_date)) AS avg_nights
FROM fact_bookings b
GROUP BY b.room_category
ORDER BY bookings DESC;

-- underperforming vs popular as per the occupancy rate 
SELECT
  a.room_category,
  SUM(a.successful_bookings) AS total_bookings,
  SUM(a.capacity) AS total_capacity,
  ROUND(SUM(a.successful_bookings)*100.0/SUM(a.capacity),2) AS occupancy_pct
FROM fact_aggregated_bookings a
GROUP BY a.room_category
ORDER BY occupancy_pct desc;







