---
title: Conference Standings
hide_title: true
sidebar_position: 2
queries: 
  - conf_standings: college-basketball/conf_standings.sql
  - conf_summary: college-basketball/conf_summary.sql
description: League standings and point differentials by location. 
---

### Conference Standings

```sql confs
select conf from conf_standings
```

<Dropdown data={confs} name=conf value=conf title="Conference">
</Dropdown>

#### {inputs.conf.value}

<Value data={conf_summary} column=teams/> teams in the <Value data={conf_summary} column=conf/> have played  <Value data={conf_summary} column=total_games/> conference games.

A "close" game is decided by fewer than six points. A "blowout" is decided by 16 or more points. 

{#each conf_summary as row}


<BigValue
  data={row}
  value=home_win_pct
  title="Home win %"
  fmt='pct1'
/>

<BigValue
  data={row}
  value=avg_point_diff
  title="Average differential"
  fmt='num1'
/>

<BigValue
  data={row}
  value=close_games_pct
  title="Close game %"
  fmt='pct1'
/>

<BigValue
  data={row}
  value=blowout_games_pct
  title="Blowout game %"
  fmt='pct1'
/>

{/each}

<DataTable data={conf_standings} rows=all rowNumbers=true>
  <Column id=team title="Team"/>
  <Column id=wins title="W" colGroup="{inputs.conf.value}"/>
  <Column id=loss title="L" colGroup="{inputs.conf.value}"/>
  <Column id=delta contentType=colorscale colorScale={['#e57373', 'floralwhite', '#81c784']} colorMid=0 fmt=# title="+/-" colGroup="{inputs.conf.value}"/>
  <Column id=home_wins title="W" colGroup="Home"/>
  <Column id=home_loss title="L" colGroup="Home"/>
  <Column id=home_delta contentType=colorscale colorScale={['#e57373', 'floralwhite', '#81c784']} colorMid=0 fmt=# title="+/-" colGroup="Home"/>
  <Column id=away_wins title="W" colGroup="Away"/>
  <Column id=away_loss title="L" colGroup="Away"/>
  <Column id=away_delta contentType=colorscale colorScale={['#e57373', 'floralwhite', '#81c784']} colorMid=0 fmt=# title="+/-" colGroup="Away"/>
</DataTable>