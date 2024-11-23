  select 
    team,
    conf,
    division,
    conf_win,
    conf_loss,
    cast(conf_win as float) / nullif((conf_win + conf_loss), 0) as conf_win_pct,
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
  order by 
    conf_win_pct desc,
    full_diff desc
