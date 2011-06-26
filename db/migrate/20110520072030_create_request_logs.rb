class CreateRequestLogs < ActiveRecord::Migration
  def self.up
    create_table :request_logs do |t|
      t.string :from
      t.string :to
      t.string :ip
      t.datetime :route_at

      t.timestamps
    end
  end

  def self.down
    drop_table :request_logs
  end
end
