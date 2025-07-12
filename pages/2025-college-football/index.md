---
title: 2025 CFB
hide_title: true
sidebar_position: 1
---

# 2025 College Football Games

This provides a list of college football games for the 2025 season. The source of the data is [collegefootballdata.com](https://collegefootballdata.com/). 

The table displays one row per team per game, so expect that each game between FBS teams appears twice in the dataset. The difficulty surfaces the opponent's SP+ rating normalized to percentiles (higher is better opponent), the days rest between games, and miles traveled for away or neutral site games.

Search the table or filter by team, the team's conference, or the opponent conference.

```sql cfb_game_list
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
   opponentSpPercentile
from
   bycdata.fbs_schedule
where team like '${inputs.team.value}'
   and conference like '${inputs.conference.value}'
   and opponentConference like '${inputs.opponentConference.value}'
order by week, date, time
```

<Dropdown data={cfb_game_list} name=team value=team defaultValue="%">
  <DropdownOption value="%" valueLabel="Team"/>
</Dropdown>

<Dropdown data={cfb_game_list} name=conference value=conference defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>

<Dropdown data={cfb_game_list} name=opponentConference value=opponentConference defaultValue="%"> <DropdownOption value="%" valueLabel="Opp Conference"/>
</Dropdown>

<DataTable data={cfb_game_list} rows=25 search=true rowNumbers=true>
  <Column id=week title="Week"/>
  <Column id=date fmt=m/d/y title="Date"/>
  <Column id=team title="Team"/>
  <Column id=opponent title="Opponent"/>
  <Column id=location title="Location" colGroup="Difficulty"/>
  <Column id=rest fmt=num title="Rest" colGroup="Difficulty"/>
  <Column id=miles fmt=num0 title="Miles" colGroup="Difficulty"/>
  <Column id=opponentSpPercentile fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="Opp SP+ %" colGroup="Difficulty"/>
</DataTable>
