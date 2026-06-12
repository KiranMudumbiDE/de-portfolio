-- =============================================================
-- Q3: Who were the top 3 fare payers in each passenger class?
-- Pattern: ROW_NUMBER() OVER (PARTITION BY class ORDER BY fare DESC),
--          filter rank <= 3 (Top N per group)
-- Finding: Top fares are identical within each class (3x £512.33 in
--          Class 1, 3x £73.50 in Class 2, 3x £56.50 in Class 3) —
--          shared ticket/group bookings. With ties, ROW_NUMBER picks
--          3 arbitrarily; DENSE_RANK would return all tied passengers.
-- =============================================================

select 
a.passenger_class , 
a.full_name , 
a.fare 
from 
(
select 
p.passenger_class, 
p.full_name, 
p.fare, 
row_number() over(PARTITION BY p.passenger_class order by p.fare desc) rn_fare  
from 
titanic.main.passengers p 
) a 
where a.rn_fare  <= 3 
order by 1 