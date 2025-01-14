select 
      team,
      record, 
      conf,
      trk,
      kp, 
      net,
      wab,
      trk_percentile,
      kp_percentile,
      net_percentile,
      wab_percentile,
      season_avg,
      last_five_avg
  from cbb.team_sum_tbl
  where conf like '${inputs.conf.value}'
  order by season_avg, season_avg desc
