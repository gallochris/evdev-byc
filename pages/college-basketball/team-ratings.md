---
title: Team Percentiles
hide_title: true
sidebar_position: 6
sidebar_link: false
queries:
  - team_sum_tbl: college-basketball/team_sum_tbl.sql
---

### Team Percentiles

Shows the percentile across [Bart Torvik](https://barttorvik.com/#), [Ken Pomeroy](https://kenpom.com/), the [NCAA's NET rankings](https://stats.ncaa.org/selection_rankings/nitty_gritties/42188?utf8=%E2%9C%93&commit=Submit), and [Torvik's WAB](https://adamcwisports.blogspot.com/p/every-possession-counts.html) (wins-above-baseline). The percentile is computed from the actual ranking (1 through 364) instead of the rating as the NET does not expose the actual team rating, only the ranking. 

[Game Score is a rating from Bart Torvik](https://adamcwisports.blogspot.com/2015/11/introducing-g-score.html) that rates each team's games on a scale from 0 (bad) to 100 (perfect). The data shows a team's average across all games and the trend over the course of the entire season. 


```sql confs
select conf from team_sum_tbl
```

```sql game_scores_array
with game_scores_by_team as (
    select 
        team,
        date,
        game_score
    from 
        cbb.game_scores_series
)
select 
    t.team,
    t.record, 
    t.conf,
    t.trk_percentile,
    t.kp_percentile,
    t.net_percentile,
    t.wab_percentile,
    t.avg_gs,
    array_agg({'date': g.date, 'game_score': g.game_score}) as game_scores
from 
    cbb.team_sum_tbl t
    left join game_scores_by_team g on g.team = t.team
where 
    t.conf like '${inputs.conf.value}'
group by 
    t.team,
    t.record, 
    t.conf,
    t.trk_percentile,
    t.kp_percentile,
    t.net_percentile,
    t.wab_percentile,
    t.avg_gs
order by t.avg_gs desc
```

<Dropdown data={confs} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="All conferences"/>
</Dropdown>

<DataTable data={game_scores_array} rows=all search=true rowNumbers=true>
  <Column id=team title="Team"/>
  <Column id=record title="W-L"/>
  <Column id="trk_percentile" fmt="pct" title="Torvik %" contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9/>
  <Column id="kp_percentile" fmt="pct" title="kenpom %" contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9/>
  <Column id="net_percentile" fmt="pct" title="NET %" contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9/>
  <Column id="wab_percentile" fmt="pct" title="WAB %" contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9/>
  <Column id=avg_gs fmt=num1 title="AVG" colGroup="Game Score"/>
  <Column id=game_scores title="Trend" colGroup="Game Score" contentType=sparkarea sparkX=date sparkY=game_score sparkColor=#53768a/>
</DataTable>


