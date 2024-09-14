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

```sql team_summaries
select 
   sum(case when is_favorite = true then 1 else 0 end) as favored_count,
   sum(case when over_or_under = 'over' then 1 else 0 end) / 2 as over_count,
   sum(case when over_or_under = 'under' then 1 else 0 end) / 2 as under_count,
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
   ) as underdog_record
from spreads_and_totals
where team like '${inputs.team.value}'
```

{#each team_summaries as row}
{#if inputs.team.value = "%"}

<BigValue
  data={row}
  value=favorite_record
  title="Favorites ATS"
  fmt='#'
/>

<BigValue
  data={row}
  value=underdog_record
  title="Underdogs ATS"
  fmt='#'
/>

<BigValue
  data={row}
  value=over_count
  title="Overs"
  fmt='#'
/>

<BigValue
  data={row}
  value=under_count
  title="Unders"
  fmt='#'
/>
{/if}
{/each}

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
  value=over_count
  title="Overs"
  fmt='#'
/>

<BigValue
  data={row}
  value=under_count
  title="Unders"
  fmt='0'
/>

{/if}
{/each}

<DataTable data={spreads_and_totals} rows=all rowNumbers=true>
  <Column id=week title="Week"/>
  <Column id=team title="Team"/>
  <Column id=opp title="Opponent"/>
  <Column id=score_sentence title="Result"/>
  <Column id=formatted_point_spread fmt=# downIsGood=true title="Spread"/>
  <Column id=formatted_team_cover title="Cover"/>
  <Column id=total title="Total"/>
  <Column id=formatted_over_or_under title="Over or Under"/>
</DataTable>
