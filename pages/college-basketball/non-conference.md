---
title: Gamelog
hide_title: true
sidebar_position: 3
queries: 
  - non_con_games: college-basketball/non_con_games.sql
---

### Gamelog: Non-conference only

```sql result_filter
select 
  result
from non_con_games
```

Select two conferences to see the list of games to date between teams from each conference. 


<Dropdown data={non_con_games} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>

<Dropdown data={non_con_games} name=opp_conf value=opp_conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Opp Conference"/>
</Dropdown>

<Dropdown name=result_filter title="Result" >
    <DropdownOption valueLabel ="All" value ="%" default/>
    <DropdownOption valueLabel = "Win" value ="W" />
    <DropdownOption valueLabel = "Loss" value ="L" />
</Dropdown>

<Dropdown name=quad_filter title="Quadrant" >
    <DropdownOption valueLabel ="All" value ="%" default/>
    <DropdownOption valueLabel = "Q1" value ="Quadrant 1" />
    <DropdownOption valueLabel = "Q2" value ="Quadrant 2" />
    <DropdownOption valueLabel = "Q3" value ="Quadrant 3" />
    <DropdownOption valueLabel = "Q4" value ="Quadrant 4" />
</Dropdown>

<DataTable data={non_con_games} rows=all search=true rowNumbers=true>
  <Column id=team_with_rk title="Team"/>
  <Column id=delta contentType=delta fmt=# title="+/-"/>
  <Column id=opp_with_rk title="Opponent"/>
  <Column id=score_sentence contentType=colorscale title="Result"/>
  <Column id=location title="Location"/>
  <Column id=quad title="Quad"/>
  <Column id=date fmt=m/d/y title="Date"/>
</DataTable>