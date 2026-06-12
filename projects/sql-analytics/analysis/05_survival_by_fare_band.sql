-- =============================================================
-- Q5: Which fare band had the best survival rate?
-- Pattern: Conditional aggregation over derived fare_band buckets.
--          Note: rate = survivors/total, NOT survivors/casualties (ratio)
-- Finding: Survival climbs monotonically with fare: Low 19.9% →
--          Mid 43.3% → High 56.3% → Premium 75.0%. Premium passengers
--          were ~3.8x more likely to survive than Low-fare passengers.
-- =============================================================

select 
p.fare_band , 
count(*) total_passengers, 
round((sum(case when p.survived = 1 then 1 else 0 end) * 100) / count(*), 1) survival_rate
from 
titanic.main.passengers p 
group by p.fare_band 
order BY survival_rate desc