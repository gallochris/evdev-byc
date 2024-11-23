select 
      team_name,
      conf,
      f_plus_rk,
      f_plus,
      f_plus_ptile,
      fpi_rk,
      fpi,
      fpi_ptile
  from cfb.team_ratings
  where conf like '${inputs.conf.value}'
  order by f_plus_rk, fpi_rk asc
