---
title: Team Sheet
hide_title: true
queries:
  - team_sum_tbl: college-basketball/team_sum_tbl.sql
---

```sql filtered_team_sum_tbl
    select *
    from ${team_sum_tbl}
    where team like '${params.team}'
```

### Team Sheet for <Value data={filtered_team_sum_tbl} column=team_link/>




