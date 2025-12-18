#!/usr/bin/env ruby
# Generate a CSV suitable for CSSD seed/import. Defaults to current month and 50_000 rows.
# Usage:
#   ruby script/generate_cssd_seed_csv.rb [rows] [output_path] [YYYY-MM]
# Examples:
#   ruby script/generate_cssd_seed_csv.rb 50000 docs/sample_import_2025_12_50000.csv
#   ruby script/generate_cssd_seed_csv.rb       # writes docs/sample_import_YYYY_MM_50000.csv

require 'csv'
require 'date'
require 'securerandom'

rows = (ARGV[0] || 50_000).to_i
output = ARGV[1]
ym = ARGV[2]

now = Time.now
if ym && ym =~ /\A\d{4}-\d{2}\z/
  year, month = ym.split('-').map(&:to_i)
else
  year = now.year
  month = now.month
  ym = "%04d-%02d" % [year, month]
end

start_date = Date.new(year, month, 1)
end_date = (start_date >> 1) - 1

output ||= File.join("docs", "sample_import_#{year}_#{format('%02d', month)}_#{rows}.csv")

sites = %w[MH01 MH02 MH03 MH04 MH05]
catalogs = %w[
  SET-ORTHO-A SET-ORTHO-B SET-ORTHO-C
  SET-GEN-SURG-A SET-GEN-SURG-B
  SET-CARDIAC-A SET-CARDIAC-B
  SET-NEURO-A SET-LAP-A SET-ENT-A
]
nonconform_kinds = %w[missing_item sterilization_fail packaging_error failed_wash high_turnaround]
nonconform_notes = {
  'missing_item' => [
    'Surgical scissors missing from set',
    'Retractor missing',
    'Incomplete instrument tray'
  ],
  'sterilization_fail' => [
    'Biological indicator failed - cycle aborted and repeated',
    'Autoclave pressure anomaly'
  ],
  'packaging_error' => [
    'Torn sterilization wrap detected',
    'Incorrect package seal'
  ],
  'failed_wash' => [
    'Visible debris after wash cycle',
    'Detergent dosing failure'
  ],
  'high_turnaround' => [
    'High turnaround time - SLA breach',
    'Delayed delivery due to staffing'
  ]
}

header = %w[
  site_code cycle_barcode catalog_barcode received_at washed_at packed_at sterilized_at delivered_at status nonconform_kind nonconform_notes
]

puts "Generating #{rows} rows for #{ym} -> #{output}"

CSV.open(output, "w") do |csv|
  csv << header

  seq = 1
  rows.times do
    site = sites.sample

    # pick a date in month
    day = start_date + rand(0..(end_date - start_date))

    # received between 06:00 and 14:59
    received_time = Time.new(year, month, day.day, rand(6..14), rand(0..59), rand(0..59))

    # chance of missing intermediate timestamps to simulate partial records
    has_wash = rand < 0.95
    has_pack = has_wash && (rand < 0.97)
    has_sterilize = has_pack && (rand < 0.98)
    has_deliver = has_sterilize && (rand < 0.99)

    # typical durations
    washed_at = has_wash ? (received_time + (30 + rand(0..180)) * 60) : nil
    packed_at = has_pack && washed_at ? (washed_at + (10 + rand(0..60)) * 60) : nil
    sterilized_at = has_sterilize && packed_at ? (packed_at + (60 + rand(0..360)) * 60) : nil
    delivered_at = has_deliver && sterilized_at ? (sterilized_at + (60 + rand(0..600)) * 60) : nil

    # select a catalog
    catalog = catalogs.sample

    # Decide nonconform: base rate ~8% + some that are high_turnaround if delivered_at far from received
    nonconform = false
    kind = ''
    notes = ''

    if rand < 0.08
      nonconform = true
      kind = nonconform_kinds.sample
      notes = nonconform_notes[kind].sample
      # simulate missing delivered for many nonconforms
      if rand < 0.5
        delivered_at = nil
      end
    end

    # detect SLA breach: if delivered and more than 24h -> label high_turnaround sometimes
    if delivered_at && ((delivered_at - received_time) > 24*3600) && rand < 0.5
      nonconform = true
      kind = 'high_turnaround'
      notes = nonconform_notes['high_turnaround'].sample
    end

    status = nonconform ? 'nonconform' : 'conform'

    cycle_barcode = "CYC-#{year}#{format('%02d', month)}#{format('%02d', day.day)}-#{format('%05d', seq)}"
    seq += 1

    row = [
      site,
      cycle_barcode,
      catalog,
      received_time.strftime('%Y-%m-%d %H:%M:%S'),
      (washed_at && washed_at.strftime('%Y-%m-%d %H:%M:%S')),
      (packed_at && packed_at.strftime('%Y-%m-%d %H:%M:%S')),
      (sterilized_at && sterilized_at.strftime('%Y-%m-%d %H:%M:%S')),
      (delivered_at && delivered_at.strftime('%Y-%m-%d %H:%M:%S')),
      status,
      kind,
      notes
    ]

    csv << row
  end
end

puts "Done: wrote #{output}"

