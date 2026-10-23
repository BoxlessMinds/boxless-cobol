# Examples

Each example is a small, complete program.

| Example | What it shows |
|---|---|
| [fizzbuzz](fizzbuzz/fizzbuzz.cob) | `EVALUATE ... ALSO`, `FUNCTION MOD` |
| [payroll-report](payroll-report/payroll.cob) | Fixed-width input records, overtime and tax calculation, a control-break report with department subtotals, and a call to the `DATEUTIL` library module |

Run an example with `.\build.ps1 run -Name examples\payroll-report\payroll.cob`.

Data files (`*.dat`) are fixed-width text with LF line endings. `.gitattributes` keeps them LF. Don't let an editor strip their trailing spaces, because the record layouts depend on exact column positions.
