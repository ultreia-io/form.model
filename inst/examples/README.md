# Survey workbook example

`survey.xlsx` and `survey-empty.xlsx` match `survey-form.yaml`, version `2026.2`.
Both workbooks use the same layout, styles and Excel date system.

| Sheet        | Data location | Contents                                  |
| ------------ | ------------- | ----------------------------------------- |
| Metadata     | C2:C5         | Submission, date, contact and comment     |
| Observations | A6:K9         | Three root records; row 7 is empty        |
| Samples      | A6:F9         | Children of observations; row 8 is empty  |
| Measurements | A6:E9         | Children of samples                       |
| Equipment    | A6:C7         | Independent table shared by every output  |
| Instructions | A1:A4         | Template content outside the model        |

Table headers are on row 5. Observations are keyed by `[station, observation_id]`.
The sample and reading numbers start at one within each parent group.
Sample minimum length is bounded by its `maximum_length` field.
Equipment identifiers are primary keys; serial numbers are unique.

| Station | Observation | Samples | Measurements |
| ------- | ----------- | ------- | ------------ |
| ST01    | OBS-001     | 2       | 3            |
| ST02    | OBS-001     | 1       | 1            |
| ST01    | OBS-002     | 0       | 0            |

This intentionally repeats one key component while keeping each composite key unique.
Records from different parents are interleaved, and zeros and missing optional values are included.
Submission `001` is text and retains its leading zeros. Dates and Booleans use native Excel values.

Splitting by Observations with `Equipment` declared shared produces:

* `survey_ST01_OBS-001.xlsx`
* `survey_ST02_OBS-001.xlsx`
* `survey_ST01_OBS-002.xlsx`

Each output contains one observation, its descendants, fixed metadata and both equipment rows.
Blank rows are omitted and related rows retain their source order.
Full validation reports the blank internal rows as missing mandatory values and primary keys.
The Instructions sheet is copied from the template unchanged.

All records and reference identifiers are synthetic, including `observer-1`, `observer-2` and `survey@example.org`.
The example does not provide reference snapshots for code-list or registry validation.
Retrieve a workbook with `form_resource("examples/survey.xlsx", "form.model")`.
