---
name: query-axiom
description: Query Axiom logs using APL. Pass a natural language description or raw APL query.
allowed-tools: Bash(curl *), Bash(source *), Bash(echo *), Read, Grep
---

# Query Axiom

Query Axiom's log ingestion platform using their APL (Axiom Processing Language) query syntax.

## Setup

The project must have `AXIOM_TOKEN` and `AXIOM_DATASET` defined in a `.env` file in the working directory.

## Instructions

1. Read `AXIOM_TOKEN` and `AXIOM_DATASET` from the local `.env` file using `source .env`
2. If the user provided a natural language request, translate it into an APL query. If they provided raw APL, use it directly.
3. Execute the query against Axiom's API:

```bash
source .env && curl -s -X POST 'https://api.axiom.co/v1/datasets/_apl?format=tabular' \
  -H "Authorization: Bearer ${AXIOM_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{"apl": "<QUERY>"}'
```

4. Parse and summarise the results in a readable format. Highlight errors, patterns, or anything notable.

## APL Quick Reference

APL uses a pipe-delimited syntax similar to KQL:

```
['dataset']                                    // start with dataset name
| where level == 'Error'                       // filter rows
| where message contains 'keyword'             // substring match
| where _time >= ago(1h)                       // time range (1h, 24h, 7d, etc.)
| summarize count() by bin_auto(_time), level  // aggregate
| order by _time desc                          // sort
| limit 50                                     // cap results
| project _time, level, message, context       // select columns
```

Common time filters: `ago(15m)`, `ago(1h)`, `ago(24h)`, `ago(7d)`.

## Notes

- The dataset name in APL must be quoted: `['datasetname']`
- Default to `order by _time desc | limit 20` if the user doesn't specify
- For error triage, include `context` and `extra` fields which contain structured metadata
- Keep queries focused — avoid `select *` style queries on large time ranges
- Never expose the API token in output
