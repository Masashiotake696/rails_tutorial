include ApplicationHelper

def valid_signin(user)
  # upcaseを使用することで大文字小文字を区別しないデータベースが使用されている場合であってもユーザーを確実に検索できるように配慮している
  fill_in "Email",	with: user.email.upcase
  fill_in "Password",	with: user.password
  click_button "Sign in"
end

def valid_create_user
  fill_in "Name",	with: "Example User"
  fill_in "Email",	with: "user@example.com"
  fill_in "Password",	with: "foobar"
  fill_in "Confirmation",	with: "foobar"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-success', text: message)
  end
end