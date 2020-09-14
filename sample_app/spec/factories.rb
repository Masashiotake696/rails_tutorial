FactoryGirl.define do
  # Userモデルオブジェクトをシミュレートするためのファクトリー
  factory :user do
    name "Michael Hartl"
    email "michael@example.com"
    password "foobar"
    password_confirmation "foobar"
  end
end