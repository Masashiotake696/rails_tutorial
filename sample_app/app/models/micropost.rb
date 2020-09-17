class Micropost < ActiveRecord::Base
  belongs_to :user

  # default_scopeをラムダで定義（遅延評価）
  default_scope -> { order(created_at: :desc) }

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  def self.from_users_followed_by(user)
    # followed_user_idsメソッドは、Active Recordによって、has_many :followed_users関連付けから自動生成されたもの
    # これにより、user.followed_usersコレクションに対応するidを得るための_idsを、関連付けの名前に追加するだけで済む
    # このコードはフォローしている全てのユーザーをメモリから一気に取り出し、フォローしているユーザーの完全な配列を作るが、
    # 条件として集合に内包されているかどうかだけしかチェックされていないため、この部分をもっと効率的なコードにできる
    # followed_user_ids = user.followed_user_ids

    # フォローしているユーザーのidの検索をする時にサブセレクトを使用する
    followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"

    Micropost.where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user.id)
  end
end
