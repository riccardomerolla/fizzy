# Generating large CSSD seed CSV files

This repository includes a small script to generate realistic CSV data for the CSSD import flow.

Script: `script/generate_cssd_seed_csv.rb`

Usage:

```bash
# generate 50_000 rows for the current month and write to docs/sample_import_YYYY_MM_50000.csv
ruby script/generate_cssd_seed_csv.rb
```

```bash
# generate custom rows and output path
ruby script/generate_cssd_seed_csv.rb 10000 docs/sample_import_2025_12_10000.csv 2025-12
```

Notes:
- By default the script uses the current local month. Provide a `YYYY-MM` third arg to override.
- The generated file uses the same header as existing `docs/sample_import.csv` and includes a mixture of conform and nonconform rows.
- The script is intentionally pure Ruby and has no extra gem dependencies.

If you'd like, I can also:
- Add an entry to `Rakefile` to call this script from `bin/rake db:seed:generate_csv`.
- Produce multiple files split by site for parallel seeding.
- Add a tiny test that validates the produced CSV format.

