select 
      conf_name,
      min as min_rank,
      first_quartile,
      median as median_rank,
      third_quartile,
      max as max_rank
  from cfb.conf_ratings_comp
  group by all
  order by median_rank asc
