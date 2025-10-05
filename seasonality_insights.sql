use hotels;

-- Seasonality insights — occupancy% vs revenue correlation by month/season

WITH monthly AS (
  SELECT
    DATE_FORMAT(check_in_date, '%Y-%m') AS ym,
    SUM(successful_bookings) AS total_bookings,
    SUM(capacity) AS total_capacity
  FROM fact_aggregated_bookings
  GROUP BY ym
),
monthly_rev AS (
  SELECT
    DATE_FORMAT(check_in_date, '%Y-%m') AS ym,
    SUM(revenue_realized) AS revenue_realized
  FROM fact_bookings
  GROUP BY ym
)
SELECT
  m.ym,
  m.total_bookings,
  m.total_capacity,
  ROUND(m.total_bookings*100.0/m.total_capacity,2) AS occupancy_pct,
  mr.revenue_realized
FROM monthly m
LEFT JOIN monthly_rev mr ON m.ym = mr.ym
ORDER BY m.ym;


-- compute Pearson r between occupancy_pct and revenue_realized
WITH x AS (
  SELECT
    ym,
    (total_bookings*1.0/total_capacity) AS occ,
    revenue_realized AS rev
  FROM (
    SELECT
      DATE_FORMAT(check_in_date, '%Y-%m') AS ym,
      SUM(successful_bookings) AS total_bookings,
      SUM(capacity) AS total_capacity
    FROM fact_aggregated_bookings
    GROUP BY ym
  ) t
  JOIN (
    SELECT DATE_FORMAT(check_in_date, '%Y-%m') AS ym, SUM(revenue_realized) AS revenue_realized
    FROM fact_bookings
    GROUP BY ym
  ) r USING (ym)
)
SELECT
  ( (SUM(occ*rev) - SUM(occ)*SUM(rev)/COUNT(*)) /
    (SQRT(SUM(occ*occ) - SUM(occ)*SUM(occ)/COUNT(*)) * SQRT(SUM(rev*rev) - SUM(rev)*SUM(rev)/COUNT(*))) ) AS pearson_r
FROM x;

-- Peak vs off-season patterns

-- Step 1: monthly occupancy (from aggregated bookings)
WITH occ AS (
  SELECT 
    DATE_FORMAT(check_in_date, '%Y-%m') AS ym,
    SUM(successful_bookings) AS total_bookings,
    SUM(capacity) AS total_capacity
  FROM fact_aggregated_bookings
  GROUP BY ym
),

-- Step 2: monthly revenue (from fact_bookings)
rev AS (
  SELECT 
    DATE_FORMAT(check_in_date, '%Y-%m') AS ym,
    SUM(revenue_realized) AS total_revenue
  FROM fact_bookings
  GROUP BY ym
)

-- Step 3: join summarized tables
SELECT 
  o.ym,
  ROUND(o.total_bookings*100.0/o.total_capacity,2) AS occupancy_pct,
  ROUND(r.total_revenue*1.0/o.total_capacity,2) AS RevPAR,
  CASE 
    WHEN (o.total_bookings*100.0/o.total_capacity) >= 70 
         AND (r.total_revenue*1.0/o.total_capacity) >= 5000 THEN 'Peak'
    WHEN (o.total_bookings*100.0/o.total_capacity) <= 50 
         AND (r.total_revenue*1.0/o.total_capacity) <= 3000 THEN 'Off'
    ELSE 'Shoulder'
  END AS season_type
FROM occ o
JOIN rev r ON o.ym = r.ym
ORDER BY o.ym;



