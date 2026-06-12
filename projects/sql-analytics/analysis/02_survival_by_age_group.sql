-- =============================================================
-- Q2: Which age group had the highest survival rate?
-- Pattern: Conditional aggregation + derived age_group column + ORDER BY rate
-- Finding: Children survived at 54.0% — nearly 2.4x the Senior rate
--          (22.7%). "Women and children first" is visible in the data.
--          Adults 40.0%, Young Adults 38.0%.
-- =============================================================

select 
p.age_group  , 
count(*) as total_passengers, 
sum(case when p.survived = 1 then 1 else 0 end) survivors, 
sum(case when p.survived = 0 then 1 else 0 end) casualities, 
ROUND(sum(case when p.survived = 1 then 1 else 0 end) * 100.0 / count(*), 1) survival_rate_pct
from 
titanic.main.passengers p 
group by 
p.age_group
order by 5 desc  