---
title: NCAAT Gamelog
hide_title: true
sidebar_position: 3
description: Log of NCAA Tournament games.  
---

### NCAA Tournament Shooting Stats

Shows shooting stats in 2025 NCAA Tournament games. 

```sql ncaat_log
select 
  *
from cbb.ncaat_log
where round like '${inputs.round.value}'
order by off_ppp desc
```

```sql rounds
select round from cbb.ncaat_log
```

<Dropdown data={rounds} name=round value=round title="Round" defaultValue="%">
  <DropdownOption value="%" valueLabel="Filter"/>
</Dropdown>

<DataTable data={ncaat_log} rows=100 search=true>
  <Column id=team title="Team"/>
  <Column id=opp title="Opp"/>
  <Column id=score_sentence title="Result"/>
  <Column id=shooting_3 fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="3PT%" colGroup="Combined"/>
  <Column id=off_3 fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="3PT%" colGroup="Offense"/>
  <Column id=off_2 fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="2PT%" colGroup="Offense"/>
  <Column id=def_3 fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="3PT%" colGroup="Defense"/>
  <Column id=def_2 fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="2PT%" colGroup="Defense"/>
</DataTable>