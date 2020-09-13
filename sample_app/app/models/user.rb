class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w\+\-\.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  before_save { self.email = email.downcase }
  has_secure_password # データベースにpassword_digestカラムを置くだけで、認証システムを簡単に構築できる

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false } # uniqueness: { case_sensitive: true }でメールアドレスの大文字小文字を無視した一意性を検証
  validates :password, length: { minimum: 6 }
end
