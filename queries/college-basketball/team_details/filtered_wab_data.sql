with team_wab_stats as (
  select 
    team,
    sum(wab_result) as total_wab_count,
    concat(
      cast(sum(case when result = 'W' then 1 else 0 end) as varchar),
      '-',
      cast(sum(case when result = 'L' then 1 else 0 end) as varchar)
    ) as team_record
  from wab_team_schedule
  group by team
),
ranked_teams as (
  select 
    team,
    total_wab_count,
    team_record,
    rank() over (order by total_wab_count desc) as wab_rank,
    dense_rank() over (order by total_wab_count desc) as wab_dense_rank
  from team_wab_stats
)
select 
  team,
  total_wab_count,
  team_record,
  wab_rank,
  wab_dense_rank
from ranked_teams
where team like '${params.teams.replace(/'/g, "''")}'