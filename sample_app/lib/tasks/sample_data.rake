namespace :db do # 名前空間
  desc "Fill database with sample data" # 説明文
  # populateはタスク名
  # :environmentでRailsのアプリケーションコードを読み込んでいる
  task populate: :environment do
    make_users
    make_microposts
    make_relationships
  end
end

def make_users
  # 1人目のユーザーを作成（管理ユーザー）
  # !をつけることで失敗した場合に例外を投げるようにする
  admin = User.create!(
    name: "Example User",
    email: "example@railstutorial.jp",
    password: "foobar",
    password_confirmation: "foobar",
    admin: true
  )

  # 99人のユーザーを作成
  99.times do |n|
    name = Faker::Name.name # 適当な名前を生成
    email = "example-#{n+1}@railstutorial.jp"
    password = "password"
    User.create!(
      name: name,
      email: email,
      password: password,
      password_confirmation: password
    )
  end
end

def make_microposts
  # 6人のユーザーを取得
  users = User.all(limit: 6)
  50.times do
    # ダミーテキストを生成
    content = Faker::Lorem.sentence(5)
    # 各ユーザーに対してマイクロポスト生成
    # create!を使用することで作成に失敗した場合に例外を投げる
    users.each { |user| user.microposts.create!(content: content) }
  end
end

def make_relationships
  users = User.all
  user = users.first
  followed_users = users[2..50] # ユーザーがフォローしているユーザー配列
  followers = users[3..40] # ユーザーがフォローされているユーザー配列
  followed_users.each { |followed_user| user.follow!(followed_user) }
  followers.each { |follower| follower.follow!(user) }
end