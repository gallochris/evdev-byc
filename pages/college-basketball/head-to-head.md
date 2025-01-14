---
title: H2H Conferences
hide_title: true
sidebar_position: 5
queries: 
  - hth_records: college-basketball/hth_records.sql
---

### Head-to-head summary

Shows overall records, win percentage, and average opponent rating by result between two conferences. A lower rating means tougher competition. 

```sql power_leagues
  select  
    conf,
    opp_conf,
    games,
    wins,
    losses,
    win_pct,
    avg_win_rtg,
    avg_loss_rtg,
    q1_wins,
    q1_losses,
    q2_wins, 
    q2_losses,
    q3_wins,
    q3_losses,
    q4_wins,
    q4_losses
  from hth_records
  where conf like '${inputs.conf.value}'
  and (
      not ${inputs.power_leagues}
        or (
        conf in ('ACC', 'Big Ten', 'SEC', 'Big 12', 'Big East')
            and opp_conf in ('ACC', 'Big Ten', 'SEC', 'Big 12', 'Big East')
          )
  )
  group by all
```

<Checkbox
    title="Power Leagues" 
    name=power_leagues
    defaultValue=true
/>

{#if inputs.power_leagues == true}

<Dropdown data={power_leagues} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>


<DataTable data={power_leagues} rows=all groupBy=conf groupType=section groupNamePosition=top subtotals=true totalRowColor=#fff0cc totalRow=true>
  <Column id=opp_conf wrapTitle=true title="Conference"/>
  <Column id=conf title="League"/>
  <Column id=games title="Games"/>
  <Column id=wins title="W"/>
  <Column id=losses title="L"/>
  <Column id=win_pct fmt=pct1 totalAgg=weightedMean  weightCol=games contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="Win %"/>
  <Column id=q1_wins title="W" colGroup="Quad 1"/>
  <Column id=q1_losses title="L" colGroup="Quad 1"/>
  <Column id=q2_wins title="W" colGroup="Quad 2"/>
  <Column id=q2_losses title="L" colGroup="Quad 2"/>
  <Column id=q3_wins title="W" colGroup="Quad 3"/>
  <Column id=q3_losses title="L" colGroup="Quad 3"/>
  <Column id=q4_wins title="W" colGroup="Quad 4"/>
  <Column id=q4_losses title="L" colGroup="Quad 4"/>
</DataTable>

{:else }

<Dropdown data={hth_records} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>

<Dropdown data={power_leagues} name=opp_conf value=opp_conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Opponent Conference"/>
</Dropdown>

<DataTable data={hth_records} rows=10 groupBy=conf groupType=accordion groupsOpen=false accordionRowColor=#fff0cc subtotals=true  totalRow=true groupNamePosition=top>
  <Column id=opp_conf wrapTitle=true title="Conference"/>
  <Column id=conf title="League"/>
  <Column id=wins title="W"/>
  <Column id=losses title="L"/>
  <Column id=win_pct fmt=pct1 totalAgg=weightedMean weightCol=games contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="Win %"/>
  <Column id=q1_wins title="W" colGroup="Quad 1"/>
  <Column id=q1_losses title="L" colGroup="Quad 1"/>
  <Column id=q2_wins title="W" colGroup="Quad 2"/>
  <Column id=q2_losses title="L" colGroup="Quad 2"/>
  <Column id=q3_wins title="W" colGroup="Quad 3"/>
  <Column id=q3_losses title="L" colGroup="Quad 3"/>
  <Column id=q4_wins title="W" colGroup="Quad 4"/>
  <Column id=q4_losses title="L" colGroup="Quad 4"/>
</DataTable>

{/if}
