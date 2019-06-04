class CreateDnsRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :dns_records do |t|
      t.string :ip_address, null: false, limit: 15

      t.timestamps
    end
    add_index :dns_records, :ip_address, unique: true
  end
end
