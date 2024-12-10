select 
      date,
      team,
      opp, 
      location,
      score_sentence,
      score,
      result,
      wab_result,
      quad
  from cbb.wab_team_schedule
  where wab_result is not null
    and team like '${inputs.team.value}'
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
