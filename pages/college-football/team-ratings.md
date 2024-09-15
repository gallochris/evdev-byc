---
sidebar_position: 1
queries:
  - team_ratings: team_ratings.sql
---

### Team ratings 

`Last update: September 10, 2024`

Shows public facing team ratings, rank, and percentile from: 
- [F+](https://www.bcftoys.com/2024-fplus/): combination of Brian Fremeau's FEI ratings with Bill Connelly's SP+ ratings
- [FPI](https://www.espn.com/college-football/fpi): Football Power Index from ESPN measures team's true strength on net points scale or expected point margin vs average opponent on neutral field.

These ratings are more predictive than a true résumé rating. 

```sql confs
select conf from team_ratings
```

<Dropdown data={confs} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="All conferences"/>
</Dropdown>

<DataTable data={team_ratings} rows=all rowNumbers=true>
  <Column id=team_name title="Team"/>
  <Column id=f_plus_rk title="Rank" colGroup="F+"/>
  <Column id=f_plus fmt=num2 title="Rating" redNegatives=true colGroup="F+"/>
  <Column id=f_plus_ptile fmt=pct title="% tile" contentType=colorscale scaleColor={['#ce5050', 'white', '#6db678']} colGroup="F+"/>
  <Column id=fpi_rk title="Rank" colGroup="FPI"/>
  <Column id=fpi fmt=num2 title="Rating" redNegatives=true colGroup="FPI"/>
  <Column id=fpi_ptile fmt=pct title="% tile" contentType=colorscale scaleColor={['#ce5050', 'white', '#6db678']} colGroup="FPI"/>
</DataTable>




