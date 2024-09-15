---
sidebar_position: 3
queries:
  - spreads_and_totals: spreads_and_totals.sql
---

```sql teams
select team from spreads_and_totals
```

### Point Spreads and Totals 

Shows the point spreads and totals for any games between two FBS teams. Select a team to filter by only results only related to that team. Excludes results for games against FCS teams. 

<Dropdown data={teams} name=team value=team title="Select a team">
<DropdownOption value=% valueLabel="All Teams"/>
</Dropdown>

```sql all_teams
select 
   sum(case when is_favorite = true then 1 else 0 end) as favored_count,
   sum(case when over_or_under = 'over' then 1 else 0 end) / 2 as over_count,
   sum(case when over_or_under = 'under' then 1 else 0 end) / 2 as under_count,
   sum(case when over_or_under = 'over' then 1 else 0 end) / (over_count + under_count) / 2 as over_pct,
   sum(case when over_or_under = 'under' then 1 else 0 end) / (over_count + under_count) / 2 as under_pct,
   sum(case when team_cover = 'Yes' then 1 else 0 end) as covers_count,
   sum(case when team_cover = 'No' then 1 else 0 end) as non_covers_count,
   sum(case when team_cover = 'Push' then 1 else 0 end) as push_count,
   concat(
     cast(sum(case when team_cover = 'Yes' then 1 else 0 end) as varchar),
     '-',
     cast(sum(case when team_cover = 'No' then 1 else 0 end) as varchar),
     '-',
     cast(sum(case when team_cover = 'Push' then 1 else 0 end) as varchar)
   ) as ats_record,
   concat(
     cast(sum(case when is_favorite = true and team_cover = 'Yes' then 1 else 0 end) as varchar),
     '-',
     cast(sum(case when is_favorite = true and team_cover = 'No' then 1 else 0 end) as varchar),
     '-',
     cast(sum(case when is_favorite = true and team_cover = 'Push' then 1 else 0 end) as varchar)
   )  as favorite_record,
   concat(
     cast(sum(case when is_favorite = false and team_cover = 'Yes' then 1 else 0 end) as varchar),
     '-',
     cast(sum(case when is_favorite = false and team_cover = 'No' then 1 else 0 end) as varchar),
     '-',
     cast(sum(case when is_favorite = false and team_cover = 'Push' then 1 else 0 end) as varchar)
   ) as underdog_record,
   cast(
  (sum(case when is_favorite = true and team_cover = 'Yes' then 1 
            when is_favorite = true and team_cover = 'Push' then 0.5 
            else 0 end) * 1.0) / 
  nullif(sum(case when is_favorite = true then 1 else 0 end), 0)
  as decimal(5,4)
) as favorite_cover_pct,

cast(
  (sum(case when is_favorite = false and team_cover = 'Yes' then 1 
            when is_favorite = false and team_cover = 'Push' then 0.5 
            else 0 end) * 1.0) / 
  nullif(sum(case when is_favorite = false then 1 else 0 end), 0)
  as decimal(5,4)
) as underdog_cover_pct,
count(game_id) / 2 as total_games,
mean(combined_score) as avg_total,
mean(abs(point_spread)) as avg_spread,
mean(abs(score_margin)) as avg_margin
from spreads_and_totals
where team like '${inputs.team.value}'
```

{#each all_teams as row}
{#if inputs.team.value == "%"}

<BigValue
  data={row}
  value=total_games
  title="Games"
  fmt='#'
/>

<BigValue
  data={row}
  value=avg_total
  title="Avg Total"
  fmt='num1'
/>

<BigValue
  data={row}
  value=avg_spread
  title="Avg Spread"
  fmt='num1'
/>

<BigValue
  data={row}
  value=avg_margin
  title="Avg Margin"
  fmt='num1'
/>

<BigValue
  data={row}
  value=favorite_cover_pct
  title="Favorites ATS"
  fmt='pct1'
/>

<BigValue
  data={row}
  value=underdog_cover_pct
  title="Underdogs ATS"
  fmt='pct1'
/>

<BigValue
  data={row}
  value=over_pct
  title="Overs"
  fmt='pct1'
/>

<BigValue
  data={row}
  value=under_pct
  title="Unders"
  fmt='pct1'
/>
{/if}
{/each}


```sql team_summaries
select 
   sum(case when is_favorite = true then 1 else 0 end) as favored_count,
   sum(case when team = '${inputs.team.value}' and over_or_under = 'over' then 1 else 0 end) as team_over_count,
   sum(case when team = '${inputs.team.value}' and over_or_under = 'under' then 1 else 0 end) as team_under_count,  -- Fixed alias for under count
   concat(
     cast(sum(case when team_cover = 'Yes' then 1 else 0 end) as varchar),
     '-',
     cast(sum(case when team_cover = 'No' then 1 else 0 end) as varchar),
     '-',
     cast(sum(case when team_cover = 'Push' then 1 else 0 end) as varchar)
   ) as ats_record,
   sum(case when team = '${inputs.team.value}' then 1 else 0 end) as total_games,
   avg(combined_score) as avg_total,  -- Use avg instead of mean
   avg(abs(point_spread)) as avg_spread -- Use avg instead of mean
from spreads_and_totals
where team like '${inputs.team.value}'
```

{#each team_summaries as row}
{#if inputs.team.value != "%"}

<BigValue
  data={row}
  value=ats_record
  title="ATS"
  fmt='#'
/>

<BigValue
  data={row}
  value=favored_count
  title="Favored"
  fmt='#'
/>

<BigValue
  data={row}
  value=team_over_count
  title="Overs"
  fmt='#'
/>

<BigValue
  data={row}
  value=team_under_count
  title="Unders"
  fmt='0'
/>

{/if}
{/each}

<DataTable data={spreads_and_totals} rows=all rowNumbers=true>
  <Column id=week title="Week"/>
  <Column id=team title="Team"/>
  <Column id=opp title="Opponent"/>
  <Column id=location title="Location"/>
  <Column id=score_sentence title="Result"/>
  <Column id=formatted_point_spread fmt=# downIsGood=true title="Spread"/>
  <Column id=formatted_team_cover title="Cover"/>
  <Column id=total title="Total"/>
  <Column id=formatted_over_or_under title="Over or Under"/>
</DataTable>
