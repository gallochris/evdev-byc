select 
      date,
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
      opp_rk
  from cbb.non_con_data
  where conf like '${inputs.conf.value}'
    and opp_conf like '${inputs.opp_conf.value}'
    and  (
      '${inputs.result_filter.value}' = '%'
      or 
      result = '${inputs.result_filter.value}' 
    )

