select 
      conf,
      opp_conf,
      games,
      wins,
      losses,
      win_pct,
      avg_win_rtg,
      avg_loss_rtg
  from cbb.hth_records
  where conf like '${inputs.conf.value}'
   and opp_conf like '${inputs.opp_conf.value}'