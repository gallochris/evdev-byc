---
sidebar_position: 0
queries:
  - cfp_rankings: cfp_rankings.sql
---

### College Football Playoff Rankings

`Last update: November 6, 2024`

Shows college football rankings and résumé rankings and percentiles from: 
- [FEI](https://www.bcftoys.com/2024-cfp/): Brian Fremeau's FEI résumé ratings using GWD or a strength of schedule rating that represents the number of losses a team two standard deviations above average would expect to have against the schedule of opponents, and then shows the difference between a team's schedule strength ratings and its actual losses.
- [SOR](https://www.espn.com/college-football/fpi/_/view/resume): Strength of record from ESPN reflects chance that an average Top 25 team would have team's record or better, given the schedule.

Ratings updated typically every Wednesday starting November 6. 

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
