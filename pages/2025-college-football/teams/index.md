---
title: FBS Teams
hide_title: true
sidebar_position: 2
description: Summary of FBS teams. 
---

### 2025 FBS Teams 


```sql team_summary 
with team_sp_percentiles as (
    -- Get each team's SP percentile from any one of their opponent's records
    -- (since it's static right now, we just need one row per team)
    select distinct
        opponent as team,
        opponentSpPercentile as teamSp
    from  bycdata.fbs_schedule
    where opponentSpPercentile is not null
),

opponent_analysis as (
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
    from  bycdata.fbs_schedule
    -- Remove the where clause to include all games
    group by team, conference
)

-- Join team SP percentiles with opponent analysis
select 
    oa.team,
    oa.conference,
    coalesce(tsp.teamSp, 0.0) as teamSp,
    oa.avgOppSp,
    oa.avgOppSpConf,
    oa.avgOppSpNonCon,
    oa.oppSpByDate
from opponent_analysis oa
left join team_sp_percentiles tsp
    on oa.team = tsp.team
where oa.team like '${inputs.team.value}'
   and oa.conference like '${inputs.conference.value}'
order by 
    coalesce(tsp.teamSp, 0.0) desc,
    oa.avgOppSp desc;
```

<Dropdown data={team_summary} name=team value=team defaultValue="%">
  <DropdownOption value="%" valueLabel="Team"/>
</Dropdown>

<Dropdown data={team_summary} name=conference value=conference defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>


<DataTable data={team_summary} rows=68 search=true rowNumbers=false>
  <Column id=team title="Team"/>
  <Column id=teamSp fmt=pct1 title="SP+ %" contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9/>
  <Column id=avgOppSp fmt=pct1 title="Opp SP+ %" colGroup="Schedule Difficulty: Avg Opponent SP+ Percentile"/>
  <Column id=avgOppSpConf fmt=pct1 title="League" colGroup="Schedule Difficulty: Avg Opponent SP+ Percentile"/>
  <Column id=avgOppSpNonCon fmt=pct1 title="Non-Conf" colGroup="Schedule Difficulty: Avg Opponent SP+ Percentile"/>
  <Column id=oppSpByDate title="Opp Strength" colGroup="Schedule Difficulty: Avg Opponent SP+ Percentile" contentType=sparkbar sparkX=date sparkY=oppSp sparkColor=#53768a/>
</DataTable>



