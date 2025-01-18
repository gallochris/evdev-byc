select 
      date,
      team,
      opp, 
      conf,
      opp_conf,
      location,
      score_sentence,
      score,
      result,
      wab_result,
      quad
  from cbb.wab_team_schedule
  where conf like '${inputs.conf.value}'
    and opp_conf like '${inputs.opp_conf.value}'
    and wab_result is not null
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
