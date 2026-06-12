-- =============================================================
-- Q6: Which passengers paid above the average fare but didn't survive?
-- Pattern: Window AVG(fare) OVER () in a subquery, filtered in the
--          outer query (window functions are not allowed in WHERE).
--          Filter placement defines the population the average covers.
-- Finding: 132 casualties paid above the casualty-average fare (£22.97).
--          Mr. Fortune paid £263 — £240 above average — and died, along
--          with another Fortune and two Allisons: families with premium
--          tickets who didn't make it.
-- =============================================================

select  
a.full_name, 
a.fare, 
round(a.avg_fare,2) avg_fare,
round(a.fare - a.avg_fare ) paid_above_avg_by
from 
(
select 
p.full_name , 
p.fare , 
p.survived ,
avg(p.fare) over() avg_fare 
from 
titanic.main.passengers p 
) a 
where a.survived = 0 and 
a.fare > a.avg_fare  
order by 4 desc ;