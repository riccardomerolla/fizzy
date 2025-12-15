require "csv"

class CsvImports::ParseAndUpsert
  REQUIRED_HEADERS = %w[site_code cycle_barcode catalog_barcode received_at sterilized_at status].freeze
  OPTIONAL_HEADERS = %w[washed_at packed_at delivered_at nonconform_kind nonconform_notes].freeze
  HEADER_ALIASES = {
    "site" => "site_code",
    "barcode" => "cycle_barcode",
    "catalog" => "catalog_barcode",
    "set_barcode" => "catalog_barcode",
    "received" => "received_at",
    "sterilized" => "sterilized_at",
    "washed" => "washed_at",
    "packed" => "packed_at",
    "delivered" => "delivered_at",
    "kind" => "nonconform_kind",
    "notes" => "nonconform_notes"
  }.freeze

  attr_reader :csv_import, :account, :site

  def initialize(csv_import)
    @csv_import = csv_import
    @account = csv_import.account
    @site = csv_import.site
  end

  def call
    file_content = csv_import.file.download
    csv_data = CSV.parse(file_content, headers: true, header_converters: :downcase)
    
    csv_import.update!(row_count: csv_data.size)
    
    processed = 0
    rejected = 0

    csv_data.each_with_index do |row, index|
      row_number = index + 2 # +1 for header, +1 for 1-based indexing
      
      if process_row(normalize_row(row), row_number)
        processed += 1
      else
        rejected += 1
      end
    end

    csv_import.update!(
      processed_count: processed,
      rejected_count: rejected
    )
  end

  private
    def normalize_row(row)
      normalized = {}
      row.each do |key, value|
        normalized_key = HEADER_ALIASES[key] || key
        normalized[normalized_key] = value&.strip
      end
      normalized
    end

    def process_row(row, row_number)
      validate_required_fields!(row)
      
      cycle_data = extract_cycle_data(row)
      set_catalog = find_or_create_set_catalog(row["catalog_barcode"])
      
      cycle = account.reprocessing_cycles.find_or_initialize_by(
        site: site,
        cycle_barcode: row["cycle_barcode"]
      )
      
      cycle.assign_attributes(
        set_catalog: set_catalog,
        **cycle_data
      )
      
      cycle.save!
      
      # Handle non-conformity if status is nonconform
      if cycle.nonconform? && row["nonconform_kind"].present?
        upsert_non_conformity(cycle, row)
      end
      
      true
    rescue StandardError => e
      record_error(row_number, e.message, row)
      false
    end

    def validate_required_fields!(row)
      missing = REQUIRED_HEADERS.select { |header| row[header].blank? }
      
      if missing.any?
        raise "Missing required fields: #{missing.join(', ')}"
      end
      
      unless %w[conform nonconform].include?(row["status"]&.downcase)
        raise "Invalid status: must be 'conform' or 'nonconform'"
      end
    end

    def extract_cycle_data(row)
      {
        received_at: parse_datetime(row["received_at"]),
        washed_at: parse_datetime(row["washed_at"]),
        packed_at: parse_datetime(row["packed_at"]),
        sterilized_at: parse_datetime(row["sterilized_at"]),
        delivered_at: parse_datetime(row["delivered_at"]),
        status: row["status"].downcase,
        source: "csv_upload"
      }
    end

    def parse_datetime(value)
      return nil if value.blank?
      
      Time.zone.parse(value)
    rescue ArgumentError
      raise "Invalid datetime format: #{value}"
    end

    def find_or_create_set_catalog(catalog_barcode)
      account.set_catalogs.find_or_create_by!(catalog_barcode: catalog_barcode) do |catalog|
        catalog.name = catalog_barcode # Default name same as barcode
      end
    end

    def upsert_non_conformity(cycle, row)
      kind = row["nonconform_kind"]&.downcase
      
      unless NonConformity::KINDS.include?(kind)
        raise "Invalid nonconform_kind: #{kind}. Must be one of: #{NonConformity::KINDS.join(', ')}"
      end
      
      non_conformity = cycle.non_conformities.find_or_initialize_by(kind: kind)
      non_conformity.assign_attributes(
        account: account,
        notes: row["nonconform_notes"],
        occurred_at: cycle.sterilized_at || cycle.received_at
      )
      non_conformity.save!
    end

    def record_error(row_number, message, raw_row)
      csv_import.errors.create!(
        row_number: row_number,
        message: message,
        raw_row: raw_row.to_h
      )
    end
end
