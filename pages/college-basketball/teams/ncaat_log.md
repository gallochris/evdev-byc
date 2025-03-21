---
title: NCAAT Gamelog
hide_title: true
sidebar_position: 3
description: Log of NCAA Tournament games.  
---

### NCAA Tournament Gamelog 

Shows 2025 NCAA Tournament games using accounting across the four factors. 

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
  <Column id=off_ppp title="Off PPP"/>
  <Column id=def_ppp title="Def PPP"/>
  <Column id=shooting contentType=colorscale colorScale={['#e57373', 'floralwhite', '#81c784']} colorMid=0 fmt=num1 title="+/-" colGroup="Shooting"/>
  <Column id=turnovers contentType=colorscale colorScale={['#e57373', 'floralwhite', '#81c784']} colorMid=0 fmt=num1 title="+/-" colGroup="Turnovers"/>
  <Column id=rebounds contentType=colorscale colorScale={['#e57373', 'floralwhite', '#81c784']} colorMid=0 fmt=num1 title="+/-" colGroup="Rebounds"/>
  <Column id=freethrows contentType=colorscale colorScale={['#e57373', 'floralwhite', '#81c784']} colorMid=0 fmt=num1 title="+/-" colGroup="Free Throws"/>
</DataTable>