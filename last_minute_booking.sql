
use hotels;
-- high vs low segmentation of the clients ( high paying vs low paying ) 
-- get thresholds (example: top 10% = high spender)
-- if we know the name form the booking_id from the data we can surely have the analysis which one is spending more and target it in custom manner 

WITH ordered AS (
    SELECT 
        booking_id,
        revenue_realized,
        ROW_NUMBER() OVER (ORDER BY revenue_realized) AS rn,
        COUNT(*) OVER () AS total_rows
    FROM fact_bookings
),
thresholds AS (
    SELECT 
        MAX(CASE WHEN rn = CEIL(0.9 * total_rows) THEN revenue_realized END) AS p90,
        MAX(CASE WHEN rn = CEIL(0.5 * total_rows) THEN revenue_realized END) AS median
    FROM ordered
)
SELECT 
    f.booking_id,
    f.revenue_realized,
    CASE 
        WHEN f.revenue_realized >= t.p90 THEN 'High Spender'
        WHEN f.revenue_realized >= t.median THEN 'Mid Spender'
        ELSE 'Low Spender'
    END AS segment
FROM fact_bookings f
CROSS JOIN thresholds t
order by revenue_realized desc;

-- booking pattern how many are last minute booking and how many are on weekends
SELECT
  CASE
    WHEN lead_days >= 30 THEN '30+ days (Advance)'
    WHEN lead_days BETWEEN 7 AND 29 THEN '7-29 days'
    WHEN lead_days BETWEEN 1 AND 6 THEN 'Last-minute'
    ELSE 'Same-day'
  END AS booking_bucket,
  COUNT(*) AS bookings,
  AVG(revenue_realized) AS avg_revenue
FROM (
  SELECT *,
    DATEDIFF(check_in_date, booking_date) AS lead_days
  FROM fact_bookings
) t
GROUP BY booking_bucket
ORDER BY FIELD(booking_bucket, '30+ days (Advance)','7-29 days','Last-minute','Same-day');



