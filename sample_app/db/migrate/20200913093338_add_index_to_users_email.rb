class AddIndexToUsersEmail < ActiveRecord::Migration
  def change
    # メールアドレスがユニークであることを強制する
    add_index :users, :email, unique: true
  end
end
