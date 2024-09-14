---
sidebar_position: 2
queries:
  - conference_standings: conference_standings.sql
  - non_con_results: non_con_results.sql
---

```sql confs
select conf from conference_standings
```

### Conference standings and point differentials 

Shows the conference only records for teams in a FBS conference with a conference championship game. Excludes
FBS independents and the Pac-12. Point differentials by location: home or away.

If there are neutral site conference games, the winner is listed as the home team and the loser is listed as the away team for the record and point differentials.

<Dropdown data={confs} name=conf value=conf title="Conference">
</Dropdown>


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



### FBS vs FBS Conference Records

<Dropdown data={confs} name=conf value=conf title="Conference">
</Dropdown>

```sql conf_summaries
select
   concat(
     cast(sum(wins) as int),
     '-',
     cast(sum(losses) as int)
   ) as conf_overall_record
from non_con_results
where conf like '${inputs.conf.value}'
```

<BigValue
  data={conf_summaries}
  value=conf_overall_record
  title="{inputs.conf.value}'s record against other FBS conferences:"
  fmt='0'
/>

<DataTable data={non_con_results} rows=all totalRow=true rowNumbers=true>
  <Column id=opp_conf title="Opponent Conference" />
  <Column id=wins title="W"/>
  <Column id=losses title="L"/>
  <Column id=result title="Record"/>
</DataTable>
