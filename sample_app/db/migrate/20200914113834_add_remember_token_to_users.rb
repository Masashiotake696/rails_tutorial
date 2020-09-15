class AddRememberTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :remember_token, :string
    add_index :users, :remember_token # remember_tokenで検索できるようにインデックスをカラムに追加
  end
end
