select 
      conf,
      team,
      wins,
      loss,
      delta,
      home_wins,
      home_loss,
      home_delta,
      away_wins,
      away_loss,
      away_delta
  from cbb.conf_standings
  where conf like '${inputs.conf.value}'
