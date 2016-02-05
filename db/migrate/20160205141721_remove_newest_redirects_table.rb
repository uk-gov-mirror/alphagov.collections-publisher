class RemoveNewestRedirectsTable < ActiveRecord::Migration
  def up
    drop_table :newest_redirects
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "newest_redirect table can't be recreated"
  end
end
