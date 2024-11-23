select 
  conf as source,
  tier as target,
  total as value
from cfb.conf_ratings_comp
order by 
  case when tier = 'Playoff' then 0 else 1 end,
  total desc;
