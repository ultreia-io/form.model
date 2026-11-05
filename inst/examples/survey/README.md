# Survey form example

`form.xlsx` and `form-empty.xlsx` match `form.yaml`, version `2026.2`.
Both forms use the same layout, styles and Excel date system.

The populated workbook demonstrates valid records and validation findings.
The empty workbook provides the matching template without records.

## Workbook structure

| Sheet        | Data location | Contents                                  |
| ------------ | ------------- | ----------------------------------------- |
| Metadata     | C2:C5         | Submission, date, contact and comment     |
| Observations | A6:K9         | Three root records; row 7 is empty        |
| Samples      | A6:F9         | Children of observations; row 8 is empty  |
| Measurements | A6:E9         | Children of samples                       |
| Equipment    | A6:C7         | Independent equipment records             |
| Notes        | A6:E12        | Optional details attached to observations |
| Instructions | A1:A4         | Template content outside the model        |

Table headers are on row 5. Metadata uses fixed cell locations and an exact physical sheet size.

## Model capabilities

| Capability              | Declaration in the survey                                                |
| ----------------------- | ------------------------------------------------------------------------ |
| Field types             | Text, integer, number, Boolean, date, datetime, email and coordinates    |
| Required values         | Mandatory fields and units required when a measurement is supplied       |
| Allowed values          | Unit and quality enums; submission and observation identifier patterns   |
| Bounds                  | Numeric limits and sample minimum length bounded by maximum length       |
| Primary keys            | Composite observation, sample and measurement keys; equipment identifier |
| Parent keys             | Samples and Notes link to Observations; Measurements link to Samples     |
| Unique values           | Equipment serial numbers                                                 |
| Optional composite keys | Notes uses `[station, observation_id, category]`; incomplete keys pass   |
| Row completeness        | Notes requires category, count or confirmed; missing detail warns        |
| Grouped sequences       | Sample and reading numbers start at one within each parent group         |
| Reference lookups       | Named catalogue bindings for stations, observers and contact email       |

Notes has a parent key and a unique key, without a primary key.
Zero and false count as supplied values for its row-completeness check.

## Example records and findings

| Station | Observation | Samples | Measurements |
| ------- | ----------- | ------- | ------------ |
| ST01    | OBS-001     | 2       | 3            |
| ST02    | OBS-001     | 1       | 1            |
| ST01    | OBS-002     | 0       | 0            |

Observation identifiers repeat across stations while their composite keys remain unique.
Child records from different parents are interleaved.

Submission `001` is text and retains its leading zeros. Dates and Booleans use native Excel values.

| Sheet | Rows | Example                                | Expected result                        |
| ----- | ---- | -------------------------------------- | -------------------------------------- |
| Notes | 6–7  | Same parent and category               | Unique-key errors on both rows         |
| Notes | 8    | Same category under a different parent | No unique-key error                    |
| Notes | 9    | Parent identifiers with no detail      | Row-completeness warning               |
| Notes | 10   | Missing category, count is zero        | Uniqueness and row completeness pass   |
| Notes | 11   | Missing category, confirmed is false   | Uniqueness and row completeness pass   |
| Notes | 12   | Same parent with a different category  | No unique-key error                    |

All records and reference identifiers are synthetic, including `observer-1`, `observer-2` and `survey@example.org`.

Retrieve the populated form with `form_resource("examples/survey/form.xlsx", "form.model")`.
