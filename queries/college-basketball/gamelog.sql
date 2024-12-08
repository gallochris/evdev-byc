select 
      date,
      type,
      team_with_rk,
      conf,
      opp_with_rk,
      opp_conf,
      location,
      result,
      score_sentence,
      delta,
      tempo,
      team_rk,
      opp_rk,
      quad
  from cbb.gamelog
  where conf like '${inputs.conf.value}'
    and opp_conf like '${inputs.opp_conf.value}'
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
    and (
      '${inputs.type_filter.value}' = '%'
      or 
      type = '${inputs.type_filter.value}' 
    )
