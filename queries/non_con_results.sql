select 
      conf,
      opp_conf,
      wins,
      losses,
      result
  from cfb.non_con_results
  where conf like '${inputs.conf.value}'
  group by all
