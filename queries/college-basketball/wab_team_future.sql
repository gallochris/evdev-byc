select 
    date,
    team,
    opp, 
    location,
    wabW,
    wabL,
    quad,
    conf, 
    opp_conf
from cbb.wab_team_future
where team like '${inputs.team.value}'
    and date > CURRENT_DATE - 1
    and (
        '${inputs.quad_filter.value}' = '%'
        or 
        quad = '${inputs.quad_filter.value}' 
    ) 
    and conf like '${inputs.conf.value}'
    and opp_conf like '${inputs.opp_conf.value}' 
order by date asc    