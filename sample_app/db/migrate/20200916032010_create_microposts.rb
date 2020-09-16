class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts do |t|
      t.string :content
      t.integer :user_id

      t.timestamps
    end

    # user_idに関連づけられた全てのマイクロポストを作成時刻の逆順で取り出すためにインデックスを貼る
    # user_idとcreated_at両方のカラムを一つの配列に含めることで、Active Recordで両方のキーを同時に使用する複合キーインデックスを作成できる
    add_index :microposts, [:user_id, :created_at]
  end
end
