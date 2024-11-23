---
sidebar_position: 1
queries: 
  - non_con_games: college-basketball/non_con_games.sql
  - hth_records: college-basketball/hth_records.sql
---

### Head-to-head summary

Shows overall records, win percentage, and average opponent rating by result between two conferences.

```sql confs
  select 
    conf, 
    opp_conf
  from non_con_data
```

```sql power_leagues
  select  
    conf,
    opp_conf,
    games,
    overall_rec,
    win_pct,
    avg_win_rtg,
    avg_loss_rtg
  from hth_records
  where conf like '${inputs.conf.value}'
  and (
      not ${inputs.power_leagues}
        or (
        conf in ('ACC', 'Big Ten', 'SEC', 'Big 12', 'Big East')
            and opp_conf in ('ACC', 'Big Ten', 'SEC', 'Big 12', 'Big East')
          )
  )
```

```sql confs_power_leagues
  select 
    conf, 
    opp_conf
  from non_con_data
  where (
    conf in ('ACC', 'Big Ten', 'SEC', 'Big 12', 'Big East')
      and opp_conf in ('ACC', 'Big Ten', 'SEC', 'Big 12', 'Big East')
    )
```

<Checkbox
    title="Power Leagues" 
    name=power_leagues
    defaultValue=true
/>

{#if inputs.power_leagues == true}

<Dropdown data={confs_power_leagues} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>

<DataTable data={power_leagues} rows=all rowNumbers=true>
  <Column id=conf title="Conference"/>
  <Column id=opp_conf wrapTitle=true title="Opponent League"/>
  <Column id=games title="Games"/>
  <Column id=overall_rec title="Record"/>
  <Column id=win_pct fmt=pct1 contentType=bar barColor=#90EE90 backgroundColor=#f88379 title="Win %"/>
  <Column id=avg_win_rtg title="Win Rating" colGroup="AVG"/>
  <Column id=avg_loss_rtg title="Loss Rating" colGroup="AVG"/>
</DataTable>

{:else }

<Dropdown data={confs} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>

<DataTable data={hth_records} rows=all rowNumbers=true>
  <Column id=conf title="Conference"/>
  <Column id=opp_conf wrapTitle=true title="Opponent League"/>
  <Column id=games title="Games"/>
  <Column id=overall_rec title="Record"/>
  <Column id=win_pct fmt=pct1 contentType=bar barColor=#90EE90 backgroundColor=#f88379 title="Win %"/>
  <Column id=avg_win_rtg title="Win Rating" colGroup="AVG"/>
  <Column id=avg_loss_rtg title="Loss Rating" colGroup="AVG"/>
</DataTable>
{/if}






### Gamelog 

Select two conferences to see the list of games to date between teams from each conference. 


<Dropdown data={confs} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>

<Dropdown data={confs} name=opp_conf value=opp_conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Opp Conference"/>
</Dropdown>

<DataTable data={non_con_games} rows=all rowNumbers=true>
  <Column id=team_with_rk title="Team"/>
  <Column id=score_sentence contentType=colorscale title="Result"/>
  <Column id=opp_with_rk title="Opponent"/>
  <Column id=location title="Location"/>
  <Column id=tempo title="Pace"/>
  <Column id=date fmt=m/d/y title="Date"/>
</DataTable>