include ApplicationHelper

def sign_in(user, options = {})
  if options[:no_capybara]
    # Capybaraを使用していない場合にもサインインする
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
  else
    visit signin_path
    fill_in "Email",	with: user.email.upcase # upcaseを使用することで大文字小文字を区別しないデータベースが使用されている場合であってもユーザーを確実に検索できるように配慮している
    fill_in "Password",	with: user.password
    click_button "Sign in"
  end
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