use  hotels;
-- hotels with most leakage in whole time frame 
SELECT h.property_name,
       SUM(b.revenue_generated) AS total_generated,
       SUM(b.revenue_realized) AS total_realized,
       SUM(b.revenue_generated - b.revenue_realized) AS leakage
FROM fact_bookings b
JOIN dim_hotels h ON b.property_id = h.property_id
GROUP BY h.property_name
ORDER BY leakage DESC;

-- platform leakage
SELECT booking_platform,
       SUM(revenue_generated) AS total_generated,
       SUM(revenue_realized) AS total_realized,
       SUM(revenue_generated - revenue_realized) AS leakage
FROM fact_bookings
GROUP BY booking_platform
ORDER BY leakage DESC;

-- successful_bookings vs capacity according to room class

SELECT h.property_name,
       a.check_in_date,
       a.room_category,
       c.room_class,
       a.successful_bookings,
       a.capacity,
       ROUND((a.successful_bookings*100.0)/a.capacity,2) AS occupancy_rate
FROM fact_aggregated_bookings a
JOIN dim_hotels h ON a.property_id = h.property_id
join dim_rooms c on a.room_category=c.room_id
ORDER BY occupancy_rate ASC;

-- Average length of stay in according to the hotel
SELECT property_name,AVG(DATEDIFF(checkout_date, check_in_date)) AS avg_stay
FROM fact_bookings f
join dim_hotels d on f.property_id=d.property_id
WHERE booking_status = 'Checked Out'
group by property_name;

-- Guest trends
SELECT property_name,ceil(AVG(no_guests)) AS avg_guests_per_booking
FROM fact_bookings f
join dim_hotels d on f.property_id=d.property_id
WHERE booking_status = 'Checked Out'
group by property_name;

-- Cancellation patterns
SELECT booking_status,
       COUNT(*) AS total_bookings,
       ROUND((COUNT(*)*100.0)/(SELECT COUNT(*) FROM fact_bookings),2) AS pct
FROM fact_bookings
GROUP BY booking_status;

-- which platform has more number of cancelled bookings
SELECT 
    booking_platform,
    COUNT(*) AS cancelled_count
FROM fact_bookings
WHERE booking_status = 'Cancelled'
GROUP BY booking_platform
order by cancelled_count;

-- revenue leakage by hotel category 
SELECT h.category,
       SUM(b.revenue_realized) AS realized_revenue,
       SUM(b.revenue_generated - b.revenue_realized) AS leakage
FROM fact_bookings b
JOIN dim_hotels h ON b.property_id = h.property_id
GROUP BY h.category
order by h.category desc;

-- leakage vs room type 
SELECT b.room_category,
       SUM(b.revenue_realized) AS realized_revenue,
       SUM(b.revenue_generated - b.revenue_realized) AS leakage
FROM fact_bookings b
GROUP BY b.room_category
order by leakage desc;

WITH leakage_per_category AS (
    SELECT 
        b.property_id,
        b.room_category,
        SUM(b.revenue_generated - b.revenue_realized) AS leakage
    FROM fact_bookings b
    GROUP BY b.property_id, b.room_category
),
ranked AS (
    SELECT 
        l.property_id,
        l.room_category,
        l.leakage,
        ROW_NUMBER() OVER (PARTITION BY l.property_id ORDER BY l.leakage DESC) AS rn
    FROM leakage_per_category l
)
SELECT 
    h.property_name,
    r.property_id,
    r.room_category,
    r.leakage
FROM ranked r
JOIN dim_hotels h ON r.property_id = h.property_id
WHERE r.rn = 1
ORDER BY r.leakage DESC;











