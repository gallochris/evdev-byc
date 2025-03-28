---
sidebar_position: 2
sidebar_link: false
queries:
  - conference_standings: college-football/conference_standings.sql
  - non_con_results: college-football/non_con_results.sql
---

```sql confs
select conf from conference_standings
```

### Conference standings and point differentials 

- Conference only records for teams in a FBS conference with a conference championship game (excludes FBS independents and the Pac-12)
- Point differentials by location: home or away
- Close percentage: games decided by under 7.5 points
- Blowout percentage: games decided by 17.5 or more points


<Details title="A note on neutral site conference games">

If there are neutral site conference games, the winner is listed as the home team and the loser is listed as the away team for the record and point differentials.

For example, Georgia Tech's win over Florida State in Ireland is counted as a home win and +3 in home point differential. 

In terms of the home win percentage for the entire conference, this neutral site game is filtered out of the percentages. 
</Details>


<Dropdown data={confs} name=conf value=conf title="Conference">
</Dropdown>


```sql conf_records
select
  conf,
  home_win_pct,
  avg_diff,
  close_pct,
  blowout_pct
from cfb.conf_sum_data
where conf like '${inputs.conf.value}'
```

{#each conf_records as row}

#### {inputs.conf.value}

<BigValue
  data={row}
  value=home_win_pct
  title="Home win %"
  fmt='pct1'
/>

<BigValue
  data={row}
  value=avg_diff
  title="Average differential"
  fmt='num1'
/>

<BigValue
  data={row}
  value=close_pct
  title="Close game %"
  fmt='pct1'
/>

<BigValue
  data={row}
  value=blowout_pct
  title="Blowout game %"
  fmt='pct1'
/>

{/each}

{#if inputs.conf.value == 'Sun Belt'}

<DataTable data={conference_standings} groupBy=division rows=all rowNumbers=true>
  <Column id=team title="Team"/>
  <Column id=conf_win title="W" colGroup="{inputs.conf.value}"/>
  <Column id=conf_loss title="L" colGroup="{inputs.conf.value}"/>
  <Column id=full_diff contentType=delta fmt=# title="+/-" colGroup="{inputs.conf.value}"/>
  <Column id=h_w title="W" colGroup="Home"/>
  <Column id=h_l title="L" colGroup="Home"/>
  <Column id=home_diff contentType=delta fmt=# title="+/-" colGroup="Home"/>
  <Column id=a_w title="W" colGroup="Away"/>
  <Column id=a_l title="L" colGroup="Away"/>
  <Column id=away_diff contentType=delta fmt=# title="+/-" colGroup="Away"/>
</DataTable>

{:else }

<DataTable data={conference_standings} rows=all rowNumbers=true>
  <Column id=team title="Team"/>
  <Column id=conf_win title="W" colGroup="{inputs.conf.value}"/>
  <Column id=conf_loss title="L" colGroup="{inputs.conf.value}"/>
  <Column id=full_diff contentType=delta fmt=# title="+/-" colGroup="{inputs.conf.value}"/>
  <Column id=h_w title="W" colGroup="Home"/>
  <Column id=h_l title="L" colGroup="Home"/>
  <Column id=home_diff contentType=delta fmt=# title="+/-" colGroup="Home"/>
  <Column id=a_w title="W" colGroup="Away"/>
  <Column id=a_l title="L" colGroup="Away"/>
  <Column id=away_diff contentType=delta fmt=# title="+/-" colGroup="Away"/>
</DataTable>
{/if}



```sql conf_head_to_head
select conf from non_con_results
```


### FBS vs FBS Conference Records

<Dropdown data={conf_head_to_head} name=conf_head_to_head value=conf title="Conference">
</Dropdown>

```sql conf_summaries
select
   concat(
     cast(sum(wins) as int),
     '-',
     cast(sum(losses) as int)
   ) as conf_overall_record
from non_con_results
where conf like '${inputs.conf_head_to_head.value}'
```

<BigValue
  data={conf_summaries}
  value=conf_overall_record
  title="{inputs.conf_head_to_head.value}'s record against other FBS conferences:"
  fmt='0'
/>

<DataTable data={non_con_results} rows=all totalRow=true rowNumbers=true>
  <Column id=opp_conf title="Opponent Conference" />
  <Column id=wins title="W"/>
  <Column id=losses title="L"/>
  <Column id=result title="Record"/>
</DataTable>
