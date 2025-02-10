---
title: Wall of WAB
hide_title: true
sidebar_position: 5
description: Shows WAB broken down by different categories. 
---

### Wall of WAB

Shows the wins-above-baseline for played games broken out by different categories: non-conference, conference, home, away, and netural sites. Filter by a conference to see the WAB breakdown for teams in any league. 

```sql wall_of_wab 
select *
  from cbb.wall_of_wab
where conf like '${inputs.conf.value}'
```

<Dropdown data={wall_of_wab} name=conf value=conf defaultValue="%">
  <DropdownOption value="%" valueLabel="Conference"/>
  </Dropdown>

  <DataTable data={wall_of_wab} rows=25 search=true rowNumbers=true>
  <Column id=team title="Team"/>
  <Column id=total contentType=colorscale colorScale={['#fbb0a9', 'floralwhite', '#c3f6c3']} colorMid=0 fmt=num2 title="WAB +/-"/>
  <Column id=non_con contentType=colorscale colorScale={['#fbb0a9', 'floralwhite', '#c3f6c3']} colorMid=0 fmt=num2  title="Non-Conf" colGroup="Type"/>
  <Column id=league contentType=colorscale colorScale={['#fbb0a9', 'floralwhite', '#c3f6c3']} colorMid=0 fmt=num2  title="Conf" colGroup="Type"/>
  <Column id=home contentType=colorscale colorScale={['#fbb0a9', 'floralwhite', '#c3f6c3']} colorMid=0 fmt=num2  title="Home" colGroup="Location"/>
  <Column id=neutral contentType=colorscale colorScale={['#fbb0a9', 'floralwhite', '#c3f6c3']} colorMid=0 fmt=num2  title="Neutral" colGroup="Location"/>
  <Column id=away contentType=colorscale colorScale={['#fbb0a9', 'floralwhite', '#c3f6c3']} colorMid=0 fmt=num2  title="Away" colGroup="Location"/>
  </DataTable>
  

