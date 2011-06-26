class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.string :from
      t.string :to
      t.string :via
      t.boolean :is_departure_time
      t.boolean :with_transfers
      t.integer :transfers_number
      # refactor ldc
      # t.boolean :ldc
      t.datetime :route_at

      t.timestamps
    end
  end

  def self.down
    drop_table :requests
  end
end
