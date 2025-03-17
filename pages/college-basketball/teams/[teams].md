---
title: Team Sheet
description: Team details across predictive and resume metrics.
hide_title: true
queries:
  - team_sum_tbl: college-basketball/team_sum_tbl.sql
  - game_scores_array: college-basketball/game_scores_array.sql
  - filtered_team_summary: college-basketball/team_details/filtered_team_summary.sql
  - filtered_wab_data: college-basketball/team_details/filtered_wab_data.sql
  - net_for_today: college-basketball/team_details/net_for_today.sql
  - net_over_time: college-basketball/team_details/net_over_time.sql
  - wab_team_log: college-basketball/team_details/wab_team_log.sql
  - wab_team_schedule: college-basketball/team_details/wab_team_schedule.sql
  - wab_team_future: college-basketball/team_details/wab_team_future.sql
---

### {params.teams}

{#each filtered_wab_data as row}

<BigValue
  data={row}
  value=team_record
  title="W-L"
/>

<BigValue
  data={row}
  value=wab_dense_rank
  title="WAB Rank"
  fmt=num
/>
{/each}

{#each filtered_team_summary as row}

<BigValue
  data={row}
  value=trk
  title="Torvik Rank"
  fmt='num'
/>

<BigValue
  data={row}
  value=kp
  title="kenpom Rank"
  fmt='num'
/>
{/each}

NCAA Tournament odds to advance to each round per Torvik. 

```sql team_data
  select * from team_sum_tbl
  where team like '${params.teams.replace(/'/g, "''")}' 
```

{#each team_data as row}

<BigValue
  data={row}
  value=r32
  fmt=pct1
  title="Round of 32"
/>

<BigValue
  data={row}
  value=s16
  fmt=pct1
  title="Sweet 16"
/>

<BigValue
  data={row}
  value=e8
  fmt=pct1
  title="Elite 8"
/>

<BigValue
  data={row}
  value=f4
  fmt=pct1
  title="Final Four"
/>

<BigValue
  data={row}
  value=f2
  fmt=pct1
  title="Title Game"
/>

<BigValue
  data={row}
  value=champ
  fmt=pct1
  title="Champ"
/>
{/each}

```sql game_scores_over_time
  select * from game_scores_series
  where team like '${params.teams.replace(/'/g, "''")}' 
```

<LineChart
    data={game_scores_over_time} 
    x=date
    y=game_score
    xFmt=mdy
    yFmt=num1
    title='Game Score over time'
    yMax=100
    yMin=0
    emptySet=pass
    connectGroup=score_sentence
    fillColor="#22c55e"
/>

### Results by game

<DataTable data={wab_team_log} rows=all groupBy=team search=true rowNumbers=true>
  <Column id=wab_result contentType=delta fmt=num2 title="WAB +/-"/>
  <Column id=opp title="Opponent"/>
  <Column id=score_sentence contentType=colorscale title="Result"/>
  <Column id=location title="Location"/>
  <Column id=quad title="Quad"/>
  <Column id=game_score title="Game Score"/>
  <Column id=date fmt=m/d/y title="Date"/>
</DataTable>

### Game results by WAB

```wab_gs
select
concat(opp, ', ', score_sentence) as opp_sentence,
sum(wab_result) as total_wab
from wab_team_schedule
where team like '${params.teams.replace(/'/g, "''")}'
group by opp, location, score_sentence
order by total_wab desc
```

<BarChart 
    data={wab_gs} 
    swapXY
    labels=true
    yFmt=num2
    fillColor="black"
    fillOpacity=.75
/>

### Scheduled Games

{#if wab_team_future.length !== 0 } 

{#each wab_team_future as row}
<BigValue
  data={row}
  value=total_wab_future
  title="WAB Opportunity"
  fmt='num2'
/>

<BigValue
  data={row}
  value=wab_future_dense_rank
  title="WAB Opportunity Rank"
  fmt='#'
/>
{/each}
  
<DataTable data={wab_team_schedule} rows=all groupBy=team search=true rowNumbers=true>
  <Column id=opp title="Opponent"/>
  <Column id=location title="Location"/>
  <Column id=quad title="Quad"/>
  <Column id=wabW contentType=delta fmt=num2 title="WAB +"/>
  <Column id=wabL contentType=delta fmt=num2 title="WAB -"/>
  <Column id=date fmt=m/d/y title="Date"/>
</DataTable>

{:else}

No scheduled games or known opponents.

{/if}
