class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w\+\-\.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  before_save { self.email = email.downcase }
  before_create :create_remember_token # コールバックメソッドはブロックではなくメソッド参照でも可

  # データベースにpassword_digestカラムを置くだけで、認証システムを簡単に構築できる
  has_secure_password

  # dependent: :destroy でユーザー自体が破棄された時に、そのユーザーに依存するマイクロポストも破棄されることを指定
  # これにより、ユーザーが削除されたときに、依存するユーザーが存在しないマイクロポストがデータベースに取り残されることを防ぐ
  has_many :microposts, dependent: :destroy

  # relationshipsテーブルの外部キー名がuser_idでないため、外部キーを明示的に指定
  # これにより、フォロワーをリレーションから取得できる
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy

  # throughを使用して中間テーブル経由して関連先のモデルを取得できる。
  # 今回はrelationshipsテーブルを経由して、フォローしているユーザーを取得したいため、throughにrelationshipsテーブルを指定する。
  # followed_idを使用してフォローしているユーザーを取得するため、リレーション名としてはfollowedsになるが、英語的におかしいので別名を指定している。
  # 別名を指定するためにsourceを使用する
  has_many :followed_users, through: :relationships, source: :followed

  # relationshipsテーブルのfollower_idとfollowed_idを入れ替えたリレーションを定義
  # ※ class_nameとしてRelationshipを指定しないと、ReverseRelationshipクラスを参照してしまう
  has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy

  # reverse_relationshipsを中間テーブルとして使用してfollowersを定義
  # ※ source: :followerは省略している（別名を使用していないため）
  has_many :followers, through: :reverse_relationships

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false } # uniqueness: { case_sensitive: true }でメールアドレスの大文字小文字を無視した一意性を検証
  validates :password, length: { minimum: 6 }

  def feed
    Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
    # 引数で渡されたユーザーが自分をフォローしているユーザーに含まれるか判定
    self.relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    # 引数で渡されたユーザーとのリレーションを作成する
    self.relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    # 引数で渡されたユーザーとのリレーションを削除する
    self.relationships.find_by(followed_id: other_user.id).destroy
  end

  # クラスメソッド
  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  # クラスメソッド
  def self.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
