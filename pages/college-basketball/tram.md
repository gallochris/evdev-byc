---
title: TRAM
hide_title: true
sidebar_position: 8
description: Turnover-rebound-adjusted-margin. 
---

### TRAM: shooting independent efficiency

TRAM, Turnover Rebound Adjusted Margin, is a measure of shooting independent efficiency. It calculates shot volume or the quantity of scoring chances created through rebounds and turnovers, and does not include any shooting performance data. This borrows [John Gasaway's work on shot volume](https://johngasaway.com/2025/01/28/ways-to-calculate-what-is-called-shot-volume), and you can [read more about TRAM here](https://blessyourchart.substack.com/p/130-riding-the-shot-volume-tram). 

A team with a higher TRAM is more likely to overcome a poor shooting performance. A lower TRAM means a team is more likely to rely on shooting (eFG% and/or FTRate) to generate efficiency


```sql tram_table
select *
  from cbb.tram_data
  where conf like '${inputs.conf.value}'
  order by tram desc
```

<Dropdown data={tram_table} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
  </Dropdown>

  <DataTable data={tram_table} rows=25 search=true rowNumbers=true>
  <Column id=torvik_team title="Team"/>
  <Column id=tram contentType=colorscale colorScale={['#fbb0a9', 'floralwhite', '#c3f6c3']} colorMid=0 fmt=num1 title="Total +/-" colGroup="TRAM"/>
  <Column id=off_svi contentType=colorscale colorScale={['#fbb0a9', 'floralwhite', '#c3f6c3']} colorMid=95 fmt=num1 title="Offense +/-" colGroup="TRAM"/>
  <Column id=def_svi contentType=colorscale colorScale={['#c3f6c3', 'floralwhite', '#fbb0a9']} colorMid=95 fmt=num1  title="Defense" colGroup="TRAM"/>
  <Column id=to_pct fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="TO%" colGroup="Offense"/>
  <Column id=or_pct fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="OR%" colGroup="Offense"/>
  <Column id=d_to_pct fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="TO%" colGroup="Defense"/>
  <Column id=d_or_pct fmt=pct1 contentType=bar barColor=#c3f6c3 backgroundColor=#fbb0a9 title="OR%" colGroup="Defense"/>
  </DataTable>
