select 
      team,
      conf,
      division,
      conf_win,
      conf_loss,
      full_diff,
      h_w,
      h_l,
      home_diff,
      a_w,
      a_l,
      away_diff
  from cfb.conference_standings
  where conf like '${inputs.conf.value}'
  group by all
  order by conf_win desc
