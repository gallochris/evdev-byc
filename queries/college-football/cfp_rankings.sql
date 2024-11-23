select 
      team_name,
      conf,
      cfp_rank,
      sor,
      sor_ptile,
      fei_resume_rank,
      fei_resume_ptile,
  from cfb.cfp_rankings
  where conf like '${inputs.conf.value}'
  order by cfp_rank asc
