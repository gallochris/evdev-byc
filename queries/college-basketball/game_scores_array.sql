with game_scores_by_team as (
    select 
        team,
        date,
        game_score
    from 
        cbb.game_scores_series
)
select 
    t.team,
    '/college-basketball/teams/' || t.team as team_link,
    t.record, 
    t.conf,
    t.trk_percentile,
    t.kp_percentile,
    t.net_percentile,
    t.wab_percentile,
    t.season_avg,
    t.last_five_avg,
    array_agg({'date': g.date, 'game_score': g.game_score}) as game_scores
from 
    cbb.team_sum_tbl t
    left join game_scores_by_team g on g.team = t.team
where 
    t.conf like '${inputs.conf.value}'
group by 
    t.team,
    t.record, 
    t.conf,
    t.trk_percentile,
    t.kp_percentile,
    t.net_percentile,
    t.wab_percentile,
    t.season_avg,
    t.last_five_avg
order by t.season_avg desc