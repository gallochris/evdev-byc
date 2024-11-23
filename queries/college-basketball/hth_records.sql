select 
      conf,
      opp_conf,
      games,
      overall_rec,
      win_pct,
      avg_win_rtg,
      avg_loss_rtg
  from cbb.hth_records
  where conf like '${inputs.conf.value}'