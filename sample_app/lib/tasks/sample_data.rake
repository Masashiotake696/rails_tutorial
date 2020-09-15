namespace :db do # 名前空間
  desc "Fill database with sample data" # 説明文
  # populateはタスク名
  # :environmentでRailsのアプリケーションコードを読み込んでいる
  task populate: :environment do
    # !をつけることで失敗した場合に例外を投げるようにする
    User.create!(
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
end