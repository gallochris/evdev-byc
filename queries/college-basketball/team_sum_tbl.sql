select 
      team,
      record, 
      conf,
      trk_percentile,
      kp_percentile,
      net_percentile,
      wab_percentile,
      avg_gs
  from cbb.team_sum_tbl
  where conf like '${inputs.conf.value}'
  order by avg_gs, avg_gs desc
