class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w\+\-\.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  before_save { self.email = email.downcase }
  before_create :create_remember_token # コールバックメソッドはブロックではなくメソッド参照でも可

  # データベースにpassword_digestカラムを置くだけで、認証システムを簡単に構築できる
  has_secure_password

  # dependent: :destroy でユーザー自体が破棄された時に、そのユーザーに依存するマイクロポストも破棄されることを指定
  # これにより、ユーザーが削除されたときに、依存するユーザーが存在しないマイクロポストがデータベースに取り残されることを防ぐ
  has_many :microposts, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false } # uniqueness: { case_sensitive: true }でメールアドレスの大文字小文字を無視した一意性を検証
  validates :password, length: { minimum: 6 }

  def feed
    Micropost.where(user_id: self.id)
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
