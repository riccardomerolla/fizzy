# Repository Reconnaissance - CSSD Audit Dashboard MVP

**Date:** 2025-12-15  
**Purpose:** Document existing Fizzy infrastructure to guide CSSD Audit Dashboard MVP implementation

---

## Tenancy Model

**Entity:** `Account` (UUID primary key)
- **Pattern:** URL path-based multi-tenancy using `Current.account`
- **URL Structure:** `/{external_account_id}/boards/...`
- **Middleware:** `AccountSlug::Extractor` extracts account ID from URL path
- **Scoping:** All models include `account_id` for data isolation
- **Key Associations:**
  ```ruby
  Account has_many :users, :boards, :cards, :webhooks, :tags, :columns
  User belongs_to :account, :identity
  ```

**Multi-tenancy Implementation:**
- All tenant-scoped models should include `account_id`
- Background jobs automatically serialize/restore `Current.account` via custom extensions
- No acts_as_tenant gem - uses Rails `Current` attributes pattern

---

## Authentication & Authorization

**Type:** Passwordless magic link authentication

**Key Models:**
- `Identity` - Global user (email-based), can have Users in multiple Accounts
- `User` - Account membership with roles: owner, admin, member, system
- `Session` - Managed via signed cookies
- `Access` - Board-level access control records

**Login Flow:**
1. User requests magic link via email
2. `MagicLink` created and emailed
3. Click link → creates `Session` → sets `Current.identity` and `Current.user`

**Development Login:**
- Email: `david@example.com` (from fixtures)
- Password appears in browser console (magic link flow)

---

## Background Jobs

**Queue:** Solid Queue (database-backed, no Redis)
- **Base Class:** `ApplicationJob < ActiveJob::Base`
- **Extensions:** Custom `FizzyActiveJobExtensions` for account context
- **Monitoring:** Mission Control::Jobs
- **Pattern:** Jobs are shallow wrappers that delegate to model methods

**Existing Jobs:**
- `ExportAccountDataJob`
- `Event::WebhookDispatchJob`
- `Mention::CreateJob`
- `NotifyRecipientsJob`
- Various cleanup and notification jobs

**Recurring Tasks:** Configured in `config/recurring.yml`

---

## UI Stack

**Frontend Framework:** Hotwire (Turbo + Stimulus)
- **Asset Pipeline:** Importmap (no webpack/vite)
- **Styling:** Custom CSS (no Tailwind/Bootstrap)
  - CSS files in `app/assets/stylesheets/` (modular, semantic naming)
  - Examples: `cards.css`, `buttons.css`, `forms.css`
- **JavaScript Controllers:** Stimulus controllers in `app/javascript/controllers/`
- **Icons:** SVG-based icon system
- **Charts:** No existing charting library (will need to add or use HTML tables)

**Key Patterns:**
- Turbo Frames for lazy loading (`turbo_frame_tag`)
- Turbo Streams for real-time updates
- Stimulus for interactive behaviors
- Mobile-responsive design with touch support

---

## Existing Domain Models (Kanban)

**Models to Preserve/Ignore (not remove):**
- `Board` - Kanban boards (keep for existing functionality)
- `Card` - Tasks/issues (keep)
- `Column` - Workflow stages (keep)
- `Tag`, `Tagging` - Labels (keep)
- `Comment`, `Event` - Activity tracking (keep, may reference for patterns)
- `Notification`, `Watch` - Notification system (keep)
- `Webhook` - External integrations (keep)

**Strategy:** Add new CSSD domain alongside existing kanban models, don't remove kanban features

---

## Database

**Adapter:** MySQL 8.0+
- **Primary Keys:** UUIDs (UUIDv7 format, base36-encoded as 25-char strings)
- **Search:** 16-shard MySQL full-text search (no Elasticsearch)
- **Migrations:** Standard ActiveRecord migrations
- **Schema:** `db/schema.rb`

**Indexing Strategy:**
- Composite indexes on `(account_id, ...)` for tenant scoping
- Unique constraints where needed
- Timestamp indexes for time-series queries

---

## Testing Infrastructure

**Framework:** Minitest (Rails default)
- **System Tests:** Capybara + Selenium
- **Fixtures:** `test/fixtures/` (YAML-based, deterministic UUIDs)
- **Parallel Execution:** Enabled by default
- **CI:** `bin/ci` runs Rubocop, Bundler audit, Brakeman, tests

**Test Patterns:**
- Model tests: `test/models/`
- Controller tests: `test/controllers/`
- System tests: `test/system/`
- Job tests: `test/jobs/`

**Test Helpers:**
- `SessionTestHelper` - Auth helpers
- `CardTestHelper` - Card creation helpers
- `CachingTestHelper` - Cache testing

---

## Navigation & Settings

**Main Navigation:** `app/views/my/_menu.html.erb`
- Hotwire dialog-based menu (keyboard shortcut: `J`)
- Turbo Frame lazy-loaded from `my/menu_path`
- Expandable sections for different areas

**Settings Pages:**
- Account settings: `account/settings` namespace
- User settings: Under `users/:id/` routes
- Board settings: Under `boards/:id/` routes

**Where to Add CSSD Nav:**
- Add new section to `app/views/my/menus/_jump.html.erb` (or create similar)
- New routes under root or `account/` namespace
- Consider adding settings page under `account/` namespace

---

## Fixtures & Seeds

**Fixtures Location:** `test/fixtures/`
- Accounts, Users, Identities
- Boards, Cards, Columns
- Comments, Events, Tags

**Seeds:** `db/seeds.rb`
- Creates demo account and user
- Loads initial data for development

**Pattern for CSSD:**
- Add fixtures for Site, SetCatalog, ReprocessingCycle, etc.
- Update `db/seeds.rb` to create sample CSSD data
- Use consistent UUID generation for deterministic testing

---

## File Upload & Storage

**System:** ActiveStorage
- All attachments scoped by `account_id`
- Support for direct uploads
- Image variants for avatars

**Pattern for CSV Imports:**
- Use `has_one_attached :file` on `CsvImport` model
- Store in tenant-scoped storage
- Purge files after processing or on record deletion

---

## Code Style & Conventions

**See:** `STYLE.md` for detailed guidelines

**Key Points:**
- Expanded conditionals over guard clauses (unless early return at method start)
- Method ordering: class methods → public (initialize first) → private
- Vertical method ordering by invocation order
- No newline under visibility modifiers, indent content
- CRUD resources over custom actions
- Vanilla Rails: thin controllers, rich models
- Jobs suffix: `_later` for async, `_now` for sync version

---

## Recommended Approach for CSSD MVP

1. **Create new domain models** under `app/models/` (Site, SetCatalog, etc.)
2. **Add controllers** under `app/controllers/` (dashboards_controller, imports_controller, etc.)
3. **Views** under `app/views/` matching controller names
4. **Jobs** under `app/jobs/` (csv_import_job.rb)
5. **Services** under `app/services/` if complex logic (csv_imports/parse_and_upsert.rb)
6. **Tests** following existing structure
7. **Routes** in `config/routes.rb` (consider namespacing under `cssd` or at root)
8. **Navigation** update `app/views/my/_menu.html.erb` or create new menu section

**Naming Convention:**
- Prefer: `CsvImport`, `ReprocessingCycle`, `NonConformity` (match domain language)
- Controllers: `CsvImportsController`, `DashboardsController`, `NonConformitiesController`
- Routes: RESTful where possible

---

## Chart/Visualization Options

**Current State:** No charting library in repo

**Options for MVP:**
1. **Add lightweight library** via importmap:
   - Chart.js (popular, simple)
   - ApexCharts (feature-rich)
   - Plotly (scientific/data viz)

2. **HTML tables with visual elements:**
   - CSS bar charts (div widths)
   - Sparklines (simple line charts)
   - Color-coded cells

3. **Server-side SVG generation:**
   - Ruby gems like `gruff` or `chartkick`
   - Generate static chart images

**Recommendation:** Start with HTML tables + CSS visualization, add Chart.js if needed

---

## Next Steps

1. Create data model migrations and models (Phase 1)
2. Add CSV import system (Phase 2)
3. Build dashboard with KPIs (Phase 3)
4. Implement remaining features per plan
5. Update navigation and polish UI

---

## Notes

- Fizzy uses **boring Rails** approach - prefer conventions over abstractions
- All data **must be tenant-scoped** via `account_id`
- Follow existing patterns for consistency
- Tests are **required** for all new code
- Keep changes **minimal** and **reversible**
