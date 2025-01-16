---
title: Teams
hide_title: true
sidebar_position: 1
queries:
  - team_sum_tbl: college-basketball/team_sum_tbl.sql
  - game_scores_array: college-basketball/game_scores_array.sql
---

### Teams

Shows the percentile from the [NCAA's NET rankings](https://stats.ncaa.org/selection_rankings/nitty_gritties/42188?utf8=%E2%9C%93&commit=Submit). The percentile is computed from the actual ranking (1 through 364) instead of the rating as the NET does not expose the actual team rating, only the ranking. 

[Game Score is a rating from Bart Torvik](https://adamcwisports.blogspot.com/2015/11/introducing-g-score.html) that rates each team's games on a scale from 0 (bad) to 100 (perfect). The data shows a team's average across all games, the last five games, and the trend over the course of the entire season.

Click through to view an individual team's details. 


```sql confs
select conf from team_sum_tbl
```

<Dropdown data={confs} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="All conferences"/>
</Dropdown>

<DataTable data={game_scores_array} rows=50 link=team_link search=true rowNumbers=true>
  <Column id=team title="Team"/>
  <Column id=record title="W-L"/>
  <Column id="net_percentile" fmt="pct" title="NET %" contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9/>
  <Column id=season_avg fmt=num1 title="Season" colGroup="Game Score Avg"/>
  <Column id=last_five_avg fmt=num1 title="Last 5" colGroup="Game Score Avg"/>
  <Column id=game_scores title="Trend" colGroup="Game Score Avg" contentType=sparkarea sparkX=date sparkY=game_score sparkColor=#53768a/>
</DataTable>


