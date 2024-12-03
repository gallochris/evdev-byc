---
title: Quad Summary
hide_title: true
sidebar_position: 2
queries: 
  - quad_summary: college-basketball/quad_summary.sql
---

### Quadrant Summary by Conference

```sql confs
select 
  conf
from quad_summary
```



<Dropdown data={confs} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>


<DataTable data={quad_summary} rows=all>
  <Column id=conf title="League"/>
  <Column id=q1_games title="G" colGroup="Quad 1"/>
  <Column id=q1_wins title="W" colGroup="Quad 1"/>
  <Column id=q1_losses title="L" colGroup="Quad 1"/>
  <Column id=q2_games title="G" colGroup="Quad 2"/>
  <Column id=q2_wins title="W" colGroup="Quad 2"/>
  <Column id=q2_losses title="L" colGroup="Quad 2"/>
  <Column id=q3_games title="G" colGroup="Quad 3"/>
  <Column id=q3_wins title="W" colGroup="Quad 3"/>
  <Column id=q3_losses title="L" colGroup="Quad 3"/>
  <Column id=q4_games title="G" colGroup="Quad 4"/>
  <Column id=q4_wins title="W" colGroup="Quad 4"/>
  <Column id=q4_losses title="L" colGroup="Quad 4"/>
</DataTable>