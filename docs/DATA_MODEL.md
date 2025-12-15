# CSSD Audit Dashboard - Data Model

**Version:** 1.0  
**Last Updated:** 2025-12-15

---

## Overview

The CSSD (Central Sterile Supply Department) Audit Dashboard tracks the reprocessing lifecycle of medical instrument sets through various stages from receipt to delivery, with support for non-conformity tracking, contract management, and invoice generation.

---

## Entity Relationship Diagram (Textual)

```
Account (Tenant)
├── Sites (1:many)
│   ├── ReprocessingCycles (1:many)
│   ├── Contracts (1:many)
│   └── CsvImports (1:many)
├── SetCatalogs (1:many)
│   └── ReprocessingCycles (1:many)
├── ReprocessingCycles (1:many)
│   └── NonConformities (1:many)
├── Contracts (1:many)
│   └── InvoicePeriods (1:many)
├── CsvImports (1:many)
    └── CsvImportErrors (1:many)
```

---

## Core Entities

### Account (Existing)
**Purpose:** Multi-tenant organization (hospital, facility, etc.)

**Key Fields:**
- `id` (UUID) - Primary key
- `external_account_id` (bigint) - URL-friendly tenant identifier
- `name` (string) - Organization name
- `cards_count` (bigint) - Counter cache (existing kanban feature)

**Relationships:**
- has_many :sites
- has_many :set_catalogs
- has_many :reprocessing_cycles
- has_many :non_conformities
- has_many :contracts
- has_many :invoice_periods
- has_many :csv_imports

---

### Site
**Purpose:** Physical location where reprocessing occurs (e.g., hospital department, external CSSD facility)

**Key Fields:**
- `id` (UUID)
- `account_id` (UUID) - Tenant scope
- `name` (string) - Site name (e.g., "Main Hospital CSSD")
- `code` (string) - Short identifier used in CSV imports (e.g., "MH01")
- `timezone` (string) - Timezone for this site (default: "Europe/Rome")

**Indexes:**
- `account_id`
- `[account_id, code]` (unique)

**Validations:**
- name: required
- code: required, unique within account
- timezone: required

**Relationships:**
- belongs_to :account
- has_many :reprocessing_cycles
- has_many :contracts
- has_many :csv_imports

---

### SetCatalog
**Purpose:** Master data for instrument sets (catalog of what can be reprocessed)

**Key Fields:**
- `id` (UUID)
- `account_id` (UUID)
- `catalog_barcode` (string) - Unique identifier for this set type (e.g., "SET-001")
- `name` (string) - Human-readable name (e.g., "Orthopedic Surgery Kit A")
- `family` (string, optional) - Category/family grouping (e.g., "Orthopedic", "General Surgery")

**Indexes:**
- `account_id`
- `[account_id, catalog_barcode]` (unique)

**Validations:**
- catalog_barcode: required, unique within account
- name: required

**Relationships:**
- belongs_to :account
- has_many :reprocessing_cycles

---

### ReprocessingCycle
**Purpose:** Individual instance of a set going through the reprocessing workflow

**Key Fields:**
- `id` (UUID)
- `account_id` (UUID)
- `site_id` (UUID)
- `set_catalog_id` (UUID)
- `cycle_barcode` (string) - Unique identifier for this specific cycle (e.g., "CYC-20231215-001")

**Stage Timestamps:**
- `received_at` (datetime) - When set arrived at CSSD
- `washed_at` (datetime, optional) - When cleaning completed
- `packed_at` (datetime, optional) - When packaging completed
- `sterilized_at` (datetime, optional) - When sterilization completed
- `delivered_at` (datetime, optional) - When returned to department

**Status & Source:**
- `status` (string) - "conform" or "nonconform"
- `source` (string) - "csv_upload" (future: "manual", "api", etc.)

**Indexes:**
- `account_id`
- `site_id`
- `set_catalog_id`
- `[account_id, site_id, cycle_barcode]` (unique)
- `[account_id, site_id, received_at]` (for time-series queries)
- `[account_id, status]` (for filtering)

**Validations:**
- cycle_barcode: required, unique within account+site
- received_at: required
- status: required, must be "conform" or "nonconform"
- source: required

**Relationships:**
- belongs_to :account
- belongs_to :site
- belongs_to :set_catalog
- has_many :non_conformities

**Computed Methods:**
- `turnaround_hours` - Time between received_at and sterilized_at in hours
- `sla_breached?(sla_hours)` - Whether turnaround exceeds SLA threshold
- `conform?` / `nonconform?` - Status helpers

---

### NonConformity
**Purpose:** Record of quality issues or deviations during reprocessing

**Key Fields:**
- `id` (UUID)
- `account_id` (UUID)
- `reprocessing_cycle_id` (UUID)
- `kind` (string) - Type of non-conformity (see KINDS constant)
- `notes` (text, optional) - Details about the issue
- `occurred_at` (datetime) - When the issue was identified

**Non-Conformity Kinds:**
- `missing_item` - Items missing from set
- `failed_wash` - Cleaning validation failed
- `packaging_error` - Packaging integrity issue
- `sterilization_fail` - Sterilization indicators failed
- `other` - Other issues

**Indexes:**
- `account_id`
- `reprocessing_cycle_id`
- `[account_id, kind]` (for pareto analysis)
- `[account_id, occurred_at]` (for time-series)

**Validations:**
- kind: required, must be one of KINDS
- occurred_at: required

**Relationships:**
- belongs_to :account
- belongs_to :reprocessing_cycle

**Class Methods:**
- `pareto_summary` - Aggregate counts by kind for pareto chart

---

### Contract
**Purpose:** Pricing and SLA agreement for a site (or default for account)

**Key Fields:**
- `id` (UUID)
- `account_id` (UUID)
- `site_id` (UUID, optional) - If null, this is the default contract for the account
- `name` (string) - Contract name/reference

**Pricing Rules:**
- `price_per_set_cents` (integer) - Cost per billable set in cents (default: 0)
- `exclude_nonconform` (boolean) - If true, non-conforming cycles are not billable (default: true)

**SLA Settings:**
- `sla_turnaround_hours` (integer, optional) - Maximum allowed turnaround time
- `penalty_per_breach_cents` (integer, optional) - Penalty for each SLA breach

**Indexes:**
- `account_id`
- `site_id`
- `[account_id, site_id]`

**Validations:**
- name: required
- price_per_set_cents: required, >= 0
- penalty_per_breach_cents: >= 0 if present
- sla_turnaround_hours: > 0 if present

**Relationships:**
- belongs_to :account
- belongs_to :site (optional)
- has_many :invoice_periods

**Methods:**
- `default_contract?` - Returns true if site_id is nil

---

### InvoicePeriod
**Purpose:** Denormalized monthly invoice summary for a contract

**Key Fields:**
- `id` (UUID)
- `account_id` (UUID)
- `contract_id` (UUID)
- `year` (integer) - Invoice year
- `month` (integer) - Invoice month (1-12)

**Computed Fields (Denormalized):**
- `processed_count` (integer) - Total cycles in period
- `nonconform_count` (integer) - Non-conforming cycles
- `billable_count` (integer) - Cycles eligible for billing
- `sla_breach_count` (integer) - Cycles that breached SLA
- `subtotal_cents` (integer) - billable_count × price_per_set
- `penalties_cents` (integer) - sla_breach_count × penalty_per_breach
- `total_cents` (integer) - subtotal - penalties (or + penalties, depending on model)

**Metadata:**
- `computed_at` (datetime) - When these values were last calculated

**Indexes:**
- `account_id`
- `contract_id`
- `[account_id, contract_id, year, month]` (unique)

**Validations:**
- year: required, integer
- month: required, integer, 1-12
- unique combination of account_id, contract_id, year, month

**Relationships:**
- belongs_to :account
- belongs_to :contract

**Methods:**
- `period_label` - Returns formatted string (e.g., "December 2023")
- `computed?` - Returns true if computed_at is present

---

## Import Entities

### CsvImport
**Purpose:** Track CSV file upload and processing status

**Key Fields:**
- `id` (UUID)
- `account_id` (UUID)
- `site_id` (UUID) - Target site for this import
- `status` (string) - "pending", "processing", "completed", "failed"
- `original_filename` (string) - Name of uploaded file
- `row_count` (integer) - Total rows in CSV (excluding header)
- `processed_count` (integer) - Successfully processed rows
- `rejected_count` (integer) - Rows with errors
- `error_message` (text, optional) - Overall error if import failed

**Attachment:**
- `file` (ActiveStorage) - The uploaded CSV file

**Indexes:**
- `account_id`
- `site_id`
- `[account_id, status]`

**Validations:**
- status: required, must be one of STATUSES
- original_filename: required

**Relationships:**
- belongs_to :account
- belongs_to :site
- has_one_attached :file
- has_many :errors (CsvImportError)

**Methods:**
- `success_rate` - Percentage of successfully processed rows

---

### CsvImportError
**Purpose:** Individual row-level errors during CSV import

**Key Fields:**
- `id` (UUID)
- `csv_import_id` (UUID)
- `row_number` (integer) - Row number in CSV (1-indexed, excluding header)
- `message` (text) - Error description
- `raw_row` (json, optional) - Original CSV row data for debugging

**Indexes:**
- `csv_import_id`

**Validations:**
- row_number: required
- message: required

**Relationships:**
- belongs_to :csv_import

---

## CSV Import Schema

**Required Headers:**
- `site_code` - Matches Site.code
- `cycle_barcode` - Unique identifier for this cycle
- `catalog_barcode` - Matches SetCatalog.catalog_barcode
- `received_at` - ISO 8601 datetime or parseable date
- `sterilized_at` - ISO 8601 datetime or parseable date
- `status` - "conform" or "nonconform"

**Optional Headers:**
- `washed_at` - Datetime
- `packed_at` - Datetime
- `delivered_at` - Datetime
- `nonconform_kind` - One of NonConformity::KINDS (required if status is "nonconform")
- `nonconform_notes` - Text description of issue

**Import Behavior:**
- **Idempotent:** Upserts ReprocessingCycle by (account_id, site_id, cycle_barcode)
- **Atomic per row:** Each row processes independently; errors don't stop import
- **Catalog creation:** SetCatalog records are upserted by catalog_barcode if not found
- **Validation:** Invalid timestamps, unknown sites, or missing required fields create CsvImportError

---

## Tenant Scoping

**All models MUST include `account_id`** for proper multi-tenancy isolation.

**Pattern:**
```ruby
# In controllers
@site = Current.account.sites.find(params[:id])

# In queries
Current.account.reprocessing_cycles.where(...)
```

**Background Jobs:**
- Jobs automatically serialize/restore `Current.account` context
- No manual account passing needed

---

## Performance Considerations

### Indexes Strategy
- All foreign keys indexed
- Composite indexes for common query patterns:
  - `[account_id, site_id, received_at]` for time-series dashboards
  - `[account_id, status]` for filtering
  - `[account_id, kind]` for pareto analysis

### Denormalization
- `InvoicePeriod` stores computed values to avoid expensive aggregations
- Recompute via background job or on-demand

### Future Optimizations
- Consider materialized views for dashboard KPIs if queries become slow
- Add counter caches if needed (e.g., `non_conformities_count` on ReprocessingCycle)
- Partition `reprocessing_cycles` table by date if volume is very high

---

## Future Enhancements

**Potential additions (out of MVP scope):**
- `User` assignments to Sites (who can see which sites)
- `Attachment` support for non-conformity photos
- `ChangeLog` / audit trail for contract modifications
- `Alert` model for SLA breach notifications
- `Report` model for saved dashboard configurations
- Additional sources: manual entry, barcode scanner, API integration

---

## Notes

- UUIDs are base36-encoded as 25-character strings
- All timestamps use UTC internally
- Site timezones used only for display/reporting purposes
- Money fields stored in cents (integer) to avoid floating-point issues
- CSV uploads processed asynchronously via `CsvImportJob`

---

## Migration Order

Migrations should run in this order (timestamps already reflect this):
1. 20251215150000 - CreateSites
2. 20251215150100 - CreateSetCatalogs
3. 20251215150200 - CreateReprocessingCycles
4. 20251215150300 - CreateNonConformities
5. 20251215150400 - CreateContracts
6. 20251215150500 - CreateInvoicePeriods
7. 20251215150600 - CreateCsvImports
8. 20251215150700 - CreateCsvImportErrors
