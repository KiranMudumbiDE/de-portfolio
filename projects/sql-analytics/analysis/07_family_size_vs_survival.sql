-- =============================================================
-- Q7: Did travelling alone vs with family affect survival?
-- Pattern: CASE bucketing on family_size (Solo / Small 1-3 / Large 4+)
--          + conditional aggregation
-- Finding: Non-linear relationship — small families survived best
--          (~57%), solo travellers second (~32%), large families worst
--          (~16%). Small groups helped each other; large families
--          waited for everyone and often none survived.
--          [verify exact %s against query output]
-- =============================================================

select
    case
        when p.family_size = 0 then 'Solo'
        when p.family_size <= 3 then 'Small family (1-3)'
        else 'Large family (4+)'
    end                                                     as family_type,
    count(*)                                                as total,
    sum(case when p.survived = 1 then 1 else 0 end)         as survivors,
    round(sum(case when p.survived = 1 then 1 else 0 end)
          * 100.0 / count(*), 1)                            as survival_rate_pct
from titanic.main.passengers p
group by 1
order by survival_rate_pct desc;