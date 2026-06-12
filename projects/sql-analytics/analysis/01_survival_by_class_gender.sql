-- =============================================================
-- Q1: What is the survival rate by passenger class and gender?
-- Pattern: Conditional aggregation (CASE WHEN inside SUM) + rate calc
-- Finding: Class 1 women survived at 96.5% vs 15.0% for Class 3 men —
--          a 6.4x gap. Class 2 men (15.2%) fared no better than Class 3
--          men: lifeboat priority was gender-first, class-second.
-- =============================================================

select 
p.passenger_class , 
p.gender , 
count(*) as total_passengers, 
sum(case when p.survived = 1 then 1 else 0 end) survivors, 
sum(case when p.survived = 0 then 1 else 0 end) casualities, 
ROUND(sum(case when p.survived = 1 then 1 else 0 end) * 100.0 / count(*), 1) survival_rate_pct
from 
titanic.main.passengers p 
group by 
p.passenger_class , 
p.gender 
order by 1,2 