select 
      region, 
      seed,
      team,
      record, 
      conf,
      tram,
      trk,
      kp, 
      net,
      wab,
      trk_percentile,
      kp_percentile,
      net_percentile,
      wab_percentile,
      r64,
      r32,
      s16,
      e8, 
      f4, 
      f2,
      champ,
      season_avg,
      last_five_avg
  from cbb.team_sum_tbl
  where conf like '${inputs.conf.value}'
  order by season_avg, season_avg desc
