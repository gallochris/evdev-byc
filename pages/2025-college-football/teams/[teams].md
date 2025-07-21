---
title: Team Sheets
description: Team details across predictive and resume metrics.
hide_title: true
queries:
  - team_table: cfb-25/cfb_schedule_sp_plus.sql
---

```sql team_sp_summary
select *
  from sp_percent_ranks
  where team like '${params.teams.replace(/-/g, ' ').replace(/'/g, "''")}' 
```

# {params.teams.replace(/-/g, ' ').replace(/'/g, "''")}

## Team SP+ Percentile Summary

{#each team_sp_summary as row}

<BigValue
  data={row}
  value=spPercentile
  title="Overall"
  fmt='pct1'
/>

<BigValue
  data={row}
  value=offPercentile
  title="Offense"
  fmt='pct1'
/>

<BigValue
  data={row}
  value=defPercentile
  title="Defense"
  fmt='pct1'
/>

<BigValue
  data={row}
  value=specTeamsPercentile
  title="Special Teams"
  fmt='pct1'
/>
{/each}

SP+, calculated by [Bill Connelly](https://bsky.app/profile/espnbillc.bsky.social), is a tempo-and-opponent-adjusted measure of college football efficiency. These are the preseason ratings based on returning production, recent recruiting, and recent history. The percentile for the team is computed across the ratings for all 136 FBS teams for the 2025 season.


```sql team_sched 
select
   week,
   gameDate as date,
   strftime(startDate, '%I:%M %p') as time,
   team,
   opponent,
   homeAway as location,
   coalesce(daysRest, 0) as rest,
   coalesce(milesTraveled, 0) as miles,
   conference,
   opponentConference,
   conferenceGame,
   opponentSpPercentile as Percentile
from
   bycdata.fbs_schedule
where team like '${params.teams.replace(/-/g, ' ').replace(/'/g, "''")}' 
order by week, date, time
```

## Schedule Analysis

{#if team_table[0].conference === "FBS Independents"}

Average SP+ percentile rankings of opponents os <Value data={team_table} column='avgOppSp' fmt=pct1/>

{:else}

Average SP+ percentile rankings of opponents:

- **All opponents**: <Value data={team_table} column='avgOppSp' fmt=pct1/>
- **<Value data={team_table} column='conference'/> opponents**: <Value data={team_table} column='avgOppSpConf' fmt=pct1/>
- **Non-conference**: <Value data={team_table} column='avgOppSpNonCon' fmt=pct1/>

{/if}

<DataTable data={team_sched} rows=15 rowNumbers=true>
  <Column id=week title="Week"/>
  <Column id=date fmt=m/d/y title="Date"/>
  <Column id=opponent title="Opponent"/>
  <Column id=location title="Location" colGroup="Difficulty"/>
  <Column id=rest fmt=num title="Rest" colGroup="Difficulty"/>
  <Column id=miles fmt=num0 title="Miles" colGroup="Difficulty"/>
  <Column id=Percentile fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="Opp SP+ %" colGroup="Difficulty"/>
</DataTable>


<BarChart 
    data={team_sched}
    title='Opponent Strength'
    subtitle='Measured by SP+ percentile'
    x=opponent
    y=Percentile
    swapXY=true
    yFmt=pct1
/>

## Travel and Rest 

```sql travel_summary
with conference_counts as (
  select 
    team,
    conference,
    opponentConference,
    count(*) as games_vs_conf
  from bycdata.fbs_schedule
  where team like '${params.teams.replace(/-/g, ' ').replace(/'/g, "''")}'
  group by team, conference, opponentConference
)
select 
  fs.team,
  fs.conference,
  sum(fs.milesTraveled) as totalMiles,
  avg(case when fs.daysRest > 0 then fs.daysRest end) as avgRest,
  count(case when fs.homeAway = 'away' then 1 end) as awayGames,
  count(case when fs.conferenceGame = true then 1 end) as conferenceGames,
  count(case when fs.conferenceGame = false then 1 end) as nonConferenceGames,
  count(distinct fs.opponentConference) as distinctConferences,
  array_to_string(
    array_agg(
      distinct case 
        when cc.opponentConference != fs.conference 
        then cc.opponentConference || ' (' || cc.games_vs_conf || ')'
        else null 
      end
    ) filter (where cc.opponentConference != fs.conference), 
    ', '
  ) as conferenceCounts
from bycdata.fbs_schedule fs
join conference_counts cc on fs.team = cc.team and fs.opponentConference = cc.opponentConference
where fs.team like '${params.teams.replace(/-/g, ' ').replace(/'/g, "''")}'
group by fs.team, fs.conference
```

{#if travel_summary[0].conference === "FBS Independents"}

{params.teams.replace(/-/g, ' ').replace(/'/g, "''")}'s schedule includes <Value data={travel_summary} column='nonConferenceGames' fmt="num"/>  games against the <Value data={travel_summary} column='conferenceCounts'/> conferences. There is an average of <Value data={travel_summary} column='avgRest' fmt="num1"/> days of rest across these games. 

The schedule includes <Value data={travel_summary} column='awayGames' fmt="num"/> away games spanning a total of <Value data={travel_summary} column='totalMiles' fmt="num0"/> miles. Below is a map of the travel schedule highlighted by the game furthest away from home: 

{:else}

{params.teams.replace(/-/g, ' ').replace(/'/g, "''")}'s schedule includes <Value data={travel_summary} column='conferenceGames' fmt="num"/> games in the <Value data={travel_summary} column='conference'/> and <Value data={travel_summary} column='nonConferenceGames' fmt="num"/> non-conference games against the <Value data={travel_summary} column='conferenceCounts'/> conferences. There is an average of <Value data={travel_summary} column='avgRest' fmt="num1"/> days of rest across these games. 

The schedule includes <Value data={travel_summary} column='awayGames' fmt="num"/> away games spanning a total of <Value data={travel_summary} column='totalMiles' fmt="num0"/> miles. Below is a map of the travel schedule highlighted by the game furthest away from home: 

{/if}

```sql game_coordinates
select 
    gameLatitude,
    gameLongitude,
    milesTraveled as Miles,
    count(*) as Games,
    case 
        when count(*) > 1 and milesTraveled = 0 then 'Home Games'
        when count(*) > 1 then string_agg(opponent, ', ')
        else max(opponent)
    end as opponents
from game_coordinates
where team like '${params.teams.replace(/-/g, ' ').replace(/'/g, "''")}' 
group by gameLatitude, gameLongitude, Miles
order by Games desc
```

<BaseMap>
   <Points data={game_coordinates} lat=gameLatitude long=gameLongitude color=#179917/>
  <Bubbles 
    data={game_coordinates}
    lat=gameLatitude
    long=gameLongitude
    size=Games
    sizeFmt=num
    value=Miles
    valueFmt=num
    pointName=opponents
    colorPalette={['green','yellow','orange','red']}
    opacity=0.5
  />
</BaseMap>

## Transfers

```sql transfer_summary
select *
from team_portal_summary
where school like '${params.teams.replace(/-/g, ' ').replace(/'/g, "''")}' 
```

{params.teams.replace(/-/g, ' ').replace(/'/g, "''")} has <Value data={transfer_summary} column='incomingCount' fmt="num"/> incoming transfers and <Value data={transfer_summary} column='outgoingCount' fmt="num"/> outgoing transfers. Among players with a rating, {params.teams.replace(/-/g, ' ').replace(/'/g, "''")} incoming transfers have an average rating of <Value data={transfer_summary} column='incomingAvgRating' fmt="num2"/> and outgoing transfers have a <Value data={transfer_summary} column='outgoingAvgRating' fmt="num2"/> average rating.

Below is a breakdown of incoming and outgoing transfers by position and a list of players with ratings if available. Transfer data is provided by [247Sports.com](https://247sports.com/season/2025-football/transferteamrankings/) through [cfbfastR](https://cfbfastr.sportsdataverse.org/reference/cfbd_recruiting_transfer_portal.html) as of July 16, 2025. 

**By Position** 

```sql heatmap_data 
select * 
from team_transfer_heatmap
where team like '${params.teams.replace(/-/g, ' ').replace(/'/g, "''")}' 
order by 
  case position
    when 'QB' then 1
    when 'IOL' then 2
    when 'OT' then 3
    when 'RB' then 4
    when 'WR' then 5
    when 'TE' then 6
    when 'EDGE' then 7
    when 'DL' then 8
    when 'LB' then 9
    when 'CB' then 10
    when 'S' then 11
    else 11
  end
```

<Heatmap 
    data={heatmap_data} 
    x=type 
    y=position 
    value=count 
    title="Transfer Summary"
    subtitle="By Position"
    rightPadding=40
    cellHeight=25
    nullsZero=false
    mobileValueLabels=true
    colorScale={[
        "rgb(255, 179, 179)", "rgb(255, 214, 153)",
        "rgb(255, 235, 156)",  "rgb(144, 238, 144)"
    ]}
/>


**Players by Program**

This shows the transfer paths of players transferring into {params.teams.replace(/-/g, ' ').replace(/'/g, "''")} and transferring out of {params.teams.replace(/-/g, ' ').replace(/'/g, "''")}. 

```sql portal_players
select 
 first_name || ' ' || last_name as name,
 position,
 origin,
 destination,
 rating,
 transferDate
from portal_players
where destination like '${params.teams.replace(/-/g, ' ').replace(/'/g, "''")}'
or origin like '${params.teams.replace(/-/g, ' ').replace(/'/g, "''")}'
order by 
  case when rating = 'NA' then null else cast(rating as decimal) end desc nulls last
```


<DataTable data={portal_players} rows=50 rowNumbers=true>
  <Column id=name title="Name"/>
  <Column id=position/>
  <Column id=rating fmt=num2/>
  <Column id=origin title="From"/>
  <Column id=destination title="To"/>
  <Column id=transferDate fmt=m/d/y title="Date"/>
</DataTable>