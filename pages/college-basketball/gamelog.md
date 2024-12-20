---
title: Gamelog
hide_title: true
sidebar_position: 3
queries: 
  - gamelog: college-basketball/gamelog.sql
---

### Gamelog 

Shows games between two D-I teams with point differential, result, date, and quadrant. 

```sql result_filter
select 
  result
from gamelog
```

```sql type_filter
select 
  type
from gamelog
```

<Dropdown data={gamelog} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>

<Dropdown data={gamelog} name=opp_conf value=opp_conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Opp Conference"/>
</Dropdown>

<Dropdown name=result_filter title="Result" >
    <DropdownOption valueLabel ="All" value ="%" default/>
    <DropdownOption valueLabel = "Win" value ="W" />
    <DropdownOption valueLabel = "Loss" value ="L" />
</Dropdown>

<Dropdown name=quad_filter title="Quadrant" >
    <DropdownOption valueLabel ="All" value ="%" default/>
    <DropdownOption valueLabel = "Q1" value ="Q1" />
    <DropdownOption valueLabel = "Q2" value ="Q2" />
    <DropdownOption valueLabel = "Q3" value ="Q3" />
    <DropdownOption valueLabel = "Q4" value ="Q4" />
</Dropdown>

<Dropdown name=type_filter title="Type" >
    <DropdownOption valueLabel ="All" value ="%" default/>
    <DropdownOption valueLabel = "Conference" value ="conf" />
    <DropdownOption valueLabel = "No-Conference" value ="nc" />
</Dropdown>

<DataTable data={gamelog} rows=10 search=true rowNumbers=true>
  <Column id=team_with_rk title="Team"/>
  <Column id=delta contentType=delta fmt=# title="+/-"/>
  <Column id=opp_with_rk title="Opponent"/>
  <Column id=score_sentence contentType=colorscale title="Result"/>
  <Column id=location title="Location"/>
  <Column id=quad title="Quad"/>
  <Column id=date fmt=m/d/y title="Date"/>
</DataTable>