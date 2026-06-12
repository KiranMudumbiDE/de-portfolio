-- =============================================================
-- Q4: What share of total fare revenue did each passenger contribute?
-- Pattern: Window grand total — SUM(fare) OVER () — to compute share
--          inline without a join (also solved via CTE + CROSS JOIN)
-- Finding: Total revenue £24,771.88. Single highest individual share
--          ~1.06% (£263). Revenue is heavily concentrated in a small
--          number of premium tickets.
-- =============================================================

SELECT
    full_name,
    fare,
    SUM(fare) OVER () total_fare, 
    ROUND(fare * 100.0 / SUM(fare) OVER (), 4) AS revenue_share_pct
FROM titanic.main.passengers
ORDER BY revenue_share_pct DESC;