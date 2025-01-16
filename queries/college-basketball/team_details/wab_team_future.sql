with team_wab_future_stats as (
  select 
    team,
    round(sum(wabW), 2) as total_wab_future
  from cbb.wab_team_future
  where date > CURRENT_DATE - 1
  group by team
),
ranked_teams as (
  select 
    team,
    total_wab_future,
    rank() over (order by total_wab_future desc) as wab_future_rank,
    dense_rank() over (order by total_wab_future desc) as wab_future_dense_rank
  from team_wab_future_stats
)
select * from ranked_teams
where team like '${params.teams.replace(/'/g, "''")}'