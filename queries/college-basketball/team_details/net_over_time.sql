select 
  date,
  team,
  net, 
  conf,
  net_percentile
from cbb.net_archive
where team like '${params.teams.replace(/'/g, "''")}'