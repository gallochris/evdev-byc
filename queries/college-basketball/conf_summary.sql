select 
      conf,
      teams,
      total_games,
      avg_point_diff,
      home_wins,
      home_win_pct,
      close_games_pct,
      blowout_games_pct
  from cbb.conf_summary
  where conf like '${inputs.conf.value}'
