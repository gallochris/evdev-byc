select 
    week,
    team,
    opp,
    score_sentence,
    case 
        when point_spread > 0 then '+' || cast(point_spread as varchar)
        else cast(point_spread as varchar)
    end as formatted_point_spread,
    upper(team_cover) as formatted_team_cover,
    total,
    combined_score,
    upper(over_or_under) as formatted_over_or_under,
    case 
        when is_favorite = true then 'favorite'
        when is_favorite = false then 'underdog'
        else 'pick''em'
    end as formatted_is_favorite
from cfb.spreads_and_totals
where team like '${inputs.team.value}'
group by all
order by week asc