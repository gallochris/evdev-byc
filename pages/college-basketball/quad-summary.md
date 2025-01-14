---
title: Quad Summary
hide_title: true
sidebar_position: 6
queries: 
  - quad_summary: college-basketball/quad_summary.sql
---

### Quadrant Summary by Conference

<DataTable data={quad_summary} rows=all search=true>
  <Column id=conf title="League"/>
  <Column id=q1_games title="G" colGroup="Quad 1"/>
  <Column id=q1_win_pct fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="Win %" colGroup="Quad 1"/>
  <Column id=q2_games title="G" colGroup="Quad 2"/>
  <Column id=q2_win_pct fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="Win %" colGroup="Quad 2"/>
  <Column id=q3_games title="G" colGroup="Quad 3"/>
  <Column id=q3_win_pct fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="Win %" colGroup="Quad 3"/>
  <Column id=q4_games title="G" colGroup="Quad 4"/>
  <Column id=q4_win_pct fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="Win %" colGroup="Quad 4"/>
</DataTable>