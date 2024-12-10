select 
      date,
      team,
      opp, 
      location,
      wabW,
      wabL,
      quad
  from cbb.wab_team_future
  where team like '${inputs.team.value}'
    and (
      '${inputs.quad_filter.value}' = '%'
      or 
      quad = '${inputs.quad_filter.value}' 
    )
