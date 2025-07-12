# Evidence project for Bless your chart

## Using the CLI

```bash
cd evdev-byc
npm install 
npm run sources
npm run dev 
```

## Evidence resources

- [Docs](https://docs.evidence.dev/)
- [Github](https://github.com/evidence-dev/evidence)
- [Slack Community](https://slack.evidence.dev/)
- [Evidence Home Page](https://www.evidence.dev)

### Data sources

Data sources include [collegefootballdata.com](https://collegefootballdata.com/) and cfbfastR. The college hoops data is from [cbbdata](https://github.com/andreweatherman/cbbdata/tree/main) + [barttorvik.com](https://barttorvik.com/#), [stats.ncaa.org](https://stats.ncaa.org/selection_rankings/season_divisions/18403/nitty_gritties), and [hoopR](https://hoopr.sportsdataverse.org/).

The data is cleaned and transformed using the R programming language. This site is built using [evidence.dev](https://evidence.dev/), [duckdb](https://duckdb.org/), and [BigQuery](https://cloud.google.com/bigquery?hl=en). 