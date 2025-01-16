select 
  date,
  team,
  net, 
  conf,
  net_percentile,
  concat(cast(coalesce(q1_win, 0) as int), '-', cast(coalesce(q1_loss, 0) as int)) as q1_record,
  concat(cast(coalesce(q2_win, 0) as int), '-', cast(coalesce(q2_loss, 0) as int)) as q2_record,
  concat(cast(coalesce(q3_win, 0) as int), '-', cast(coalesce(q3_loss, 0) as int)) as q3_record,
  concat(cast(coalesce(q4_win, 0) as int), '-', cast(coalesce(q4_loss, 0) as int)) as q4_record
from cbb.net_for_today
where team like '${params.teams.replace(/'/g, "''")}'