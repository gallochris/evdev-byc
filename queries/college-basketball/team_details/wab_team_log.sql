select 
  date,
  team,
  opp, 
  location,
  score_sentence,
  score,
  result,
  wab_result,
  quad,
  game_score
from cbb.wab_team_schedule
where wab_result is not null
  and team like '${params.teams.replace(/'/g, "''")}'