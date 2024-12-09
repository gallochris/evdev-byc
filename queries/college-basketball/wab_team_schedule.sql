select 
      date,
      team,
      opp, 
      location,
      result,
      score,
      wab as wabW,
      quad
  from cbb.wab_team_schedule
  where team like '${inputs.team.value}'
    and  (
      '${inputs.result_filter.value}' = '%'
      or 
      result = '${inputs.result_filter.value}' 
    )
    and (
      '${inputs.quad_filter.value}' = '%'
      or 
      quad = '${inputs.quad_filter.value}' 
    )
