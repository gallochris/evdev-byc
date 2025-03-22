---
title: NCAAT Teams
hide_title: true
sidebar_position: 1
queries:
  - team_sum_tbl: college-basketball/team_sum_tbl.sql
  - game_scores_array: college-basketball/game_scores_array.sql
description: NET rankings percentiles and Game Scores. 
---

### 2025 NCAA Tournament 

Updated March 17 to show the 68-team NCAA Tournament field by region. Shows the odds to reach the first few rounds per [Bart Torvik](https://barttorvik.com/tourneytime.php), [TRAM](https://blessyourchart.substack.com/p/130-riding-the-shot-volume-tram), and Game Scores for each team.

[Game Score is a rating from Torvik](https://adamcwisports.blogspot.com/2015/11/introducing-g-score.html) that rates each team's games on a scale from 0 (bad) to 100 (perfect). The data shows a team's average across all games, the last five games, and the trend over the course of the entire season.

Click through to view an individual team's details. 


```sql regions
select region from team_sum_tbl
```

<Dropdown data={regions} name=region value=region defaultValue="%">
  <DropdownOption value="%" valueLabel="Region"/>
</Dropdown>

<DataTable data={game_scores_array} rows=68 link=team_link search=true groupBy=region groupType=section groupNamePosition=top rowNumbers=false>
  <Column id=region title="Region"/>
  <Column id=seed title="Seed"/>
  <Column id=team title="Team"/>
  <Column id=r32 fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="R32"/>
  <Column id=s16 fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="S16"/>
  <Column id=e8 fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="E8"/>
  <Column id=tram contentType=colorscale colorScale={['#fbb0a9', 'floralwhite', '#c3f6c3']} colorMid=0 fmt=num1 title="TRAM +/-"/>
  <Column id=season_avg fmt=num1 title="Season" colGroup="Game Score Avg"/>
  <Column id=last_five_avg fmt=num1 title="Last 5" colGroup="Game Score Avg"/>
  <Column id=game_scores title="Trend" colGroup="Game Score Avg" contentType=sparkarea sparkX=date sparkY=game_score sparkColor=#53768a/>
</DataTable>


