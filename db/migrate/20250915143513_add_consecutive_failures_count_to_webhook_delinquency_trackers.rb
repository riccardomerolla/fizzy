class AddConsecutiveFailuresCountToWebhookDelinquencyTrackers < ActiveRecord::Migration[8.1]
  def change
    add_column :webhook_delinquency_trackers, :consecutive_failures_count, :integer
    add_column :webhook_delinquency_trackers, :first_failure_at, :datetime

    remove_column :webhook_delinquency_trackers, :total_count, :integer
    remove_column :webhook_delinquency_trackers, :failed_count, :integer
    remove_column :webhook_delinquency_trackers, :last_reset_at, :datetime
  end
end
