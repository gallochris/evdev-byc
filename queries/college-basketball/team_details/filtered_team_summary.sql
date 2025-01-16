select 
  team,
  record, 
  conf,
  trk,
  kp, 
  net,
  wab,
  trk_percentile,
  kp_percentile,
  net_percentile,
  wab_percentile,
  season_avg,
  last_five_avg
from cbb.team_sum_tbl
where team like '${params.teams.replace(/'/g, "''")}'