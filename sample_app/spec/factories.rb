FactoryGirl.define do
  # Userモデルオブジェクトをシミュレートするためのファクトリー
  factory :user do
    sequence(:name) { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :micropost do
    content "Lorem ipsum"
    user # micropostに関連付けられるuser（これでリレーションを構築できる）
  end
end