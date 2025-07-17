---
title: FBS Teams
hide_title: true
sidebar_position: 2
description: Summary of FBS teams. 
queries:
  - team_summary: cfb-25/cfb_sp_plus.sql
---

### 2025 FBS Teams 

SP+, calculated by [Bill Connelly](https://bsky.app/profile/espnbillc.bsky.social), is a tempo-and-opponent-adjusted measure of college football efficiency. These preseason ratings incorporate returning production, recent recruiting, and recent history. Percentiles are computed across all 136 FBS teams for 2025.

<Dropdown data={team_summary} name=team value=team defaultValue="%">
  <DropdownOption value="%" valueLabel="Team"/>
</Dropdown>

<Dropdown data={team_summary} name=conference value=conference defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
</Dropdown>


<DataTable data={team_summary} rows=40 search=true link=team_link rowNumbers=false>
  <Column id=team title="Team"/>
  <Column id=teamSp fmt=pct1 title="SP+ %" contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9/>
  <Column id=avgOppSp fmt=pct1 title="Opp SP+ %" colGroup="Schedule Difficulty: Avg Opponent SP+ Percentile"/>
  <Column id=oppSpByDate title="Opp Strength" colGroup="Schedule Difficulty: Avg Opponent SP+ Percentile" contentType=sparkbar sparkX=date sparkY=oppSp sparkColor=#53768a/>
</DataTable>



