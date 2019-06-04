class CreateJoinTableDnsRecordsHostnames < ActiveRecord::Migration[5.2]
  def change
    create_join_table :dns_records, :hostnames do |t|
      t.index :dns_record_id
      t.index :hostname_id
    end

    add_index :dns_records_hostnames, [:dns_record_id, :hostname_id],
              unique: true
  end
end
