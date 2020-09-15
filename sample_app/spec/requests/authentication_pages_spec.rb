require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      let(:user) { FactoryGirl.create(:user) }

      it { should have_title('Sign in') }
      it { should_not have_link('Users', href: users_path) }
      it { should_not have_link('Profile', href: user_path(user)) }
      it { should_not have_link('Settings', href: edit_user_path(user)) }
      it { should_not have_link('Sign out', href: signout_path) }
      it { should have_link('Sign in', href: signin_path) }

      before { click_button "Sign in" }

      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_error_message }
      end
    end

    describe "with valid information" do
      # Userファクトリーを使用してユーザーオブジェクト変数に格納
      let(:user) { FactoryGirl.create(:user) }

      before { sign_in user }

      it { should have_title(user.name) }
      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }

        it { should have_link('Sign in') }
      end
    end
  end

  describe "ahthorization" do
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#new action" do
        before { get signup_path }

        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a POST request to the Users#create action" do
        before { post users_path }

        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a GET request to the Sessions#new action" do
        before { get signin_path }

        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a POST request to the Sessions#create action" do
        before { post sessions_path }

        specify { expect(response).to redirect_to(root_url) }
      end

      describe "as admin user" do
        let(:admin) { FactoryGirl.create(:admin) }

        before { sign_in admin, no_capybara: true }

        # アドミンユーザーで自身の削除処理を実行する
        describe "submitting a DELETE request to the Users#destroy action" do
          before { delete user_path(admin) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end

    end

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "visiting the user index" do
        before { visit users_path }
        it { should have_title('Sign in') }
      end

      describe "visiting the edit page" do
        before { visit edit_user_path(user) }
        it { should have_title('Sign in') }
      end

      describe "attempting to visit a protected page" do
        before do
          # サインインしていないため、signinページにリダイレクトされる
          visit edit_user_path(user)
          fill_in "Email",	with: user.email
          fill_in "Password",	with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do
          it 'should render the desired protected page' do
            # ログイン後にログイン前にアクセスしていた編集ページに遷移している
            expect(page).to have_title('Edit user')
          end
        end
      end

      describe "submitting to the update action" do
        # patchメソッドを使用して直接HTTPリクエストを発行する（他にもget, post, deleteメソッドがサポートされている）
        before { patch user_path(user) }
        # patchメソッドを使用してHTTPリクエストを直接発行すると、低レベルのresponseオブジェクトにアクセスできるようになる
        # responseオブジェクトはサーバーの応答自体のテストに使用できる
        specify { expect(response).to redirect_to(signin_url) }
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      # factoryにオプションとしてemailを渡して、デフォルトで作成されるユーザーのメールアドレスと異なるメールアドレスになるようにする
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }

      # 今回はCapybaraを使わずにテスト(userでログイン)
      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }

        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }

        specify { expect(response).to redirect_to(root_url)}
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      # 非アドミンユーザーでサインインする
      before { sign_in non_admin, no_capybara: true }

      # 非アドミンユーザーで削除処理を実行する
      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
  end
end
