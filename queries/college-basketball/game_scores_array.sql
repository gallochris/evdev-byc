with game_scores_by_team as (
    select 
        team,
        date,
        game_score
    from 
        cbb.game_scores_series
)
select 
    t.region, 
    t.seed,
    t.team,
    '/college-basketball/teams/' || t.team as team_link,
    t.record, 
    t.conf,
    t.tram,
    t.trk,
    t.kp,
    t.trk_percentile,
    t.kp_percentile,
    t.net_percentile,
    t.net,
    t.wab_percentile,
    t.r64,
    t.r32,
    t.s16,
    t.e8, 
    t.f4, 
    t.f2,
    t.champ,
    t.season_avg,
    t.last_five_avg,
    array_agg({'date': g.date, 'game_score': g.game_score}) as game_scores
from 
    cbb.team_sum_tbl t
    left join game_scores_by_team g on g.team = t.team
where 
    t.region like '${inputs.region.value}'
group by 
    t.region, 
    t.seed,
    t.team,
    t.record, 
    t.conf,
    t.tram,
    t.trk,
    t.kp,
    t.trk_percentile,
    t.kp_percentile,
    t.net_percentile,
    t.net,
    t.wab_percentile,
    t.r64,
    t.r32,
    t.s16,
    t.e8, 
    t.f4, 
    t.f2,
    t.champ,
    t.season_avg,
    t.last_five_avg
order by t.champ desc, t.seed asc