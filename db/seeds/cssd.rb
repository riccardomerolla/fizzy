create_tenant "CSSD Hospital"

david = find_or_create_user "David Heinemeier Hansson", "david@example.com"
jane = find_or_create_user "Jane Smith", "jane@example.com"
john = find_or_create_user "John Doe", "john@example.com"

login_as david

# Create Sites
main_site = Current.account.sites.find_or_create_by!(code: "MAIN") do |site|
  site.name = "Main Hospital CSSD"
  site.timezone = "Europe/Rome"
end

surgery_site = Current.account.sites.find_or_create_by!(code: "SURG") do |site|
  site.name = "Surgery Center CSSD"
  site.timezone = "Europe/Rome"
end

# Create Set Catalogs
catalogs = [
  { barcode: "SET001", name: "Basic Surgical Set", family: "General Surgery" },
  { barcode: "SET002", name: "Orthopedic Set", family: "Orthopedics" },
  { barcode: "SET003", name: "Cardiovascular Set", family: "Cardiology" },
  { barcode: "SET004", name: "Dental Instruments", family: "Dentistry" },
  { barcode: "SET005", name: "Neurosurgery Set", family: "Neurosurgery" },
  { barcode: "SET006", name: "Laparoscopy Set", family: "General Surgery" },
  { barcode: "SET007", name: "ENT Instruments", family: "ENT" },
  { barcode: "SET008", name: "Gynecology Set", family: "Gynecology" }
]

catalogs.each do |cat_data|
  Current.account.set_catalogs.find_or_create_by!(catalog_barcode: cat_data[:barcode]) do |catalog|
    catalog.name = cat_data[:name]
    catalog.family = cat_data[:family]
  end
end

# Create Contract
contract = Current.account.contracts.find_or_create_by!(name: "Main Hospital Contract") do |c|
  c.site = main_site
  c.price_per_set_cents = 500  # $5.00 per set
  c.exclude_nonconform = true
  c.sla_turnaround_hours = 24  # 24-hour SLA
  c.penalty_per_breach_cents = 100  # $1.00 penalty per breach
end

# Create sample reprocessing cycles
require "csv"

csv_file = Rails.root.join("docs/sample_import.csv")
if File.exist?(csv_file)
  puts "  Loading sample CSV data..."
  
  csv_import = Current.account.csv_imports.create!(
    site: main_site,
    status: :pending,
    original_filename: "sample_import.csv"
  )
  
  csv_import.file.attach(
    io: File.open(csv_file),
    filename: "sample_import.csv",
    content_type: "text/csv"
  )
  
  # Process the CSV synchronously for seed data
  service = CsvImports::ParseAndUpsert.new(csv_import)
  service.call
  
  puts "  ✓ Loaded #{csv_import.processed_count} cycles from CSV"
else
  puts "  Sample CSV not found, skipping data load"
end

# Compute invoice for current month if we have data
if Current.account.reprocessing_cycles.any?
  current_year = Time.zone.now.year
  current_month = Time.zone.now.month
  
  invoice_service = InvoicePeriods::Compute.new(
    contract: contract,
    year: current_year,
    month: current_month
  )
  
  begin
    invoice_period = invoice_service.call
    puts "  ✓ Computed invoice for #{Date::MONTHNAMES[current_month]} #{current_year}: #{invoice_period.total_cents / 100.0} USD"
  rescue => e
    puts "  ⚠ Could not compute invoice: #{e.message}"
  end
end

puts "  ✓ CSSD data seeded successfully"
