with opponent_analysis as (
    select 
        team,
        conference,
        -- Only calculate average from non-null values
        avg(opponentSpPercentile) as avgOppSp,
        avg(case when conferenceGame = true then opponentSpPercentile else null end) as avgOppSpConf,
        avg(case when conferenceGame = false then opponentSpPercentile else null end) as avgOppSpNonCon,
        -- Include all games, but replace null with 0 in the array
        array_agg({
            'date': gameDate, 
            'oppSp': coalesce(opponentSpPercentile, 0.0)
        }) as oppSpByDate
    from bycdata.fbs_schedule
    group by team, conference
)

-- Join with team_sp_summary directly
select 
    oa.team,
    replace(replace(oa.team, ' ', '-'), '''', '') as team_link,
    oa.conference,
    coalesce(tsp.spPercentile, 0.0) as teamSp,
    oa.avgOppSp,
    oa.avgOppSpConf,
    oa.avgOppSpNonCon,
    oa.oppSpByDate
from opponent_analysis oa
left join sp_percent_ranks tsp
    on oa.team = tsp.team
where oa.team like '${inputs.team.value}'
   and oa.conference like '${inputs.conference.value}'
order by 
    coalesce(tsp.spPercentile, 0.0) desc,
    oa.avgOppSp desc
