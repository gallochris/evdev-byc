---
title: WAB
hide_title: true
sidebar_position: 4
active: false
queries: 
  - wab_team_schedule: college-basketball/wab_team_schedule.sql
  - wab_team_future: college-basketball/wab_team_future.sql
---

### WAB Team Schedule 

Shows the wins-above-baseline for any played games or future games. WAB is a résumé metric that reflects how many **more** (or fewer) games a team has won against its schedule than a bubble-quality team would be expected to win against that same schedule.

```sql result_filter
select 
  result
from wab_team_schedule
```

<Tabs id="played-games">
    <Tab label="Played">
    

<Dropdown data={wab_team_schedule} name=team value=team defaultValue="%">
  <DropdownOption value="%" valueLabel="Team"/>
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

```sql team_wab_count
select 
   sum(wab_result) as total_wab_count
from wab_team_schedule
where team = '${inputs.team.value}'
group by team
```

{#each team_wab_count as row}
{#if inputs.team.value != "%"}

<BigValue
  data={row}
  value=total_wab_count
  title="WAB"
  fmt='num2'
/>

{/if}
{/each}

<DataTable data={wab_team_schedule} rows=50 search=true rowNumbers=true>
  <Column id=team title="Team"/>
  <Column id=wab_result contentType=delta fmt=num2 title="WAB +/-"/>
  <Column id=opp title="Opponent"/>
  <Column id=score_sentence contentType=colorscale title="Result"/>
  <Column id=location title="Location"/>
  <Column id=quad title="Quad"/>
  <Column id=date fmt=m/d/y title="Date"/>
</DataTable>

</Tab>
    
<Tab label="Scheduled">
        
<Dropdown data={wab_team_future} name=team value=team defaultValue="%">
  <DropdownOption value="%" valueLabel="Team"/>
</Dropdown>


<Dropdown name=quad_filter title="Quadrant" >
    <DropdownOption valueLabel ="All" value ="%" default/>
    <DropdownOption valueLabel = "Q1" value ="Q1" />
    <DropdownOption valueLabel = "Q2" value ="Q2" />
    <DropdownOption valueLabel = "Q3" value ="Q3" />
    <DropdownOption valueLabel = "Q4" value ="Q4" />
</Dropdown>

<DataTable data={wab_team_future} rows=50 search=true rowNumbers=true>
  <Column id=date fmt=m/d/y title="Date"/>
  <Column id=team title="Team"/>
  <Column id=opp title="Opponent"/>
  <Column id=location title="Location"/>
  <Column id=wabW contentType=delta fmt=num2 title="WAB +"/>
  <Column id=wabL contentType=delta fmt=num2 title="WAB -"/>
  <Column id=quad title="Quad"/>
</DataTable>

</Tab>
</Tabs>
