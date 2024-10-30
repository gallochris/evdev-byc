---
sidebar_position: 1
queries:
  - team_ratings: team_ratings.sql
  - ratings_comparison: ratings_comparison.sql
---

### Team ratings 

`Last update: October 28, 2024`

Shows public facing team ratings, rank, and percentile from: 
- [F+](https://www.bcftoys.com/2024-fplus/): combination of Brian Fremeau's FEI ratings with Bill Connelly's SP+ ratings
- [FPI](https://www.espn.com/college-football/fpi): Football Power Index from ESPN measures team's true strength on net points scale or expected point margin vs average opponent on neutral field.

Ratings updated typically every Monday or Tuesday.

```sql confs
select conf from team_ratings
```

```sql include_ptiles
select 
       f_plus_ptile,
       fpi_ptile
from team_ratings
where not ${inputs.include_ptiles} 
  or (
    ${inputs.include_ptiles}
  )
```

<Dropdown data={confs} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="All conferences"/>
</Dropdown>

<Checkbox
    title="Include percentiles" 
    name=include_ptiles
    defaultValue=true
/>

{#if inputs.include_ptiles == true}

<DataTable data={team_ratings} rows=all search=true rowNumbers=true>
  <Column id=team_name title="Team"/>
  <Column id=f_plus_rk title="Rank" colGroup="F+"/>
  <Column id=f_plus fmt=num2 title="Rating" redNegatives=true colGroup="F+"/>
  <Column id="f_plus_ptile" fmt="pct" title="% tile" contentType=bar barColor=#90EE90 backgroundColor=#f88379 colGroup="F+"/>
  <Column id=fpi_rk title="Rank" colGroup="FPI"/>
  <Column id=fpi fmt=num2 title="Rating" redNegatives=true colGroup="FPI"/>
  <Column id=fpi_ptile fmt=pct title="% tile" contentType=bar barColor=#90EE90 backgroundColor=#f88379 colGroup="FPI"/>
</DataTable>

{:else }

<DataTable data={team_ratings} rows=all rowNumbers=true>
  <Column id=team_name title="Team"/>
  <Column id=f_plus_rk title="Rank" colGroup="F+"/>
  <Column id=f_plus fmt=num2 title="Rating" redNegatives=true colGroup="F+"/>
  <Column id=fpi_rk title="Rank" colGroup="FPI"/>
  <Column id=fpi fmt=num2 title="Rating" redNegatives=true colGroup="FPI"/>
</DataTable>
{/if}

### Compare Ratings

```sql rating_comp
select
    team_name as team,
    conf as conference,
    f_plus_ptile as "F+",
    fpi_ptile as "FPI",
from team_ratings
where conf like '${inputs.conf.value}'
group by all
```

<Dropdown data={confs} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="All conferences"/>
</Dropdown>

<ScatterPlot 
    data={rating_comp}
    x=F+
    y=FPI
    yAxisTitle=FPI
    series=team
    legend=off
    chartAreaHeight=360
    xFmt=pct1
    yFmt=pct1
    xMin=0
    xMax=1
    yMin=0
    yMax=1
    xTickMarks=true
    yTickMarks=true
    title="F+ vs FPI percentiles by team"
    subtitle="Last updated October 28"
    shape=emptyCircle
    colorPalette={['#ffffcc', '#ffeda0', '#fed976', '#feb24c', '#fd8d3c', '#fc4e2a', '#e31a1c', '#bd0026', '#800026']}
/>
