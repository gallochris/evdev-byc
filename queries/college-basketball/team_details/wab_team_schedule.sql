select 
  date,
  team,
  opp, 
  location,
  wabW,
  wabL,
  quad
from cbb.wab_team_future
where team like '${params.teams.replace(/'/g, "''")}'
    and date > CURRENT_DATE - 1