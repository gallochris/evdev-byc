select 
      conf,
      opp_conf,
      wins,
      losses,
      result
  from cfb.non_con_results
  where conf like '${inputs.conf_head_to_head.value}'
  group by all
