select 
      conf,
      opp_conf,
      games,
      wins,
      losses,
      win_pct,
      avg_win_rtg,
      avg_loss_rtg,
      q1_wins,
      q1_losses,
      q2_wins, 
      q2_losses,
      q3_wins,
      q3_losses,
      q4_wins,
      q4_losses
  from cbb.hth_records
  where conf like '${inputs.conf.value}'
   and opp_conf like '${inputs.opp_conf.value}'