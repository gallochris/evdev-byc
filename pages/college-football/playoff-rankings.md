---
sidebar_position: 0
queries:
  - cfp_rankings: college-football/cfp_rankings.sql
  - ratings_sankey: college-football/ratings_comparison.sql
---

### Playoff Rankings

`Last update: December 9, 2024`

Shows the number of teams by conference that are in the 12 team playoff. 

<SankeyDiagram
  data={ratings_sankey} 
  title="Sankey Diagram by Conference" 
  sourceCol=source
  targetCol=target 
  valueCol=value
  valueFMT=num1
  nodeLabels=name
  linkLabels=full
  />


### Rankings table
Shows college football rankings and résumé rankings and percentiles from: 
- [FEI](https://www.bcftoys.com/2024-cfp/): Brian Fremeau's FEI résumé ratings using GWD or a strength of schedule rating that represents the number of losses a team two standard deviations above average would expect to have against the schedule of opponents. 
- [SOR](https://www.espn.com/college-football/fpi/_/view/resume): Strength of record from ESPN reflects chance that an average Top 25 team would have team's record or better, given the schedule.

```sql confs
select conf from cfp_rankings
```

<Dropdown data={confs} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="All conferences"/>
</Dropdown>


<DataTable data={cfp_rankings} rows=all rowNumbers=true>
  <Column id=team_name title="Team"/>
  <Column id=cfp_rank title="CFP Rank"/>
  <Column id=sor title="Rank" colGroup="SOR"/>
  <Column id=fei_resume_rank title="Rank" colGroup="FEI"/>
</DataTable>
