class CsvImportJob < ApplicationJob
  queue_as :default

  def perform(csv_import)
    csv_import.update!(status: "processing")
    
    CsvImports::ParseAndUpsert.new(csv_import).call
    
    csv_import.update!(status: "completed")
  rescue StandardError => e
    csv_import.update!(
      status: "failed",
      error_message: "#{e.class}: #{e.message}"
    )
    raise
  end
end
