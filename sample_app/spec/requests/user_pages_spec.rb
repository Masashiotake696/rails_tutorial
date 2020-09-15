require 'spec_helper'

describe "User" do
  subject { page }

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }

    describe "page" do
      before do
        sign_in user
        visit users_path
      end

      it { should have_title('All users') }
      it { should have_content('All users') }
    end

    describe "pagination" do
      before do
        sign_in user
        visit users_path
      end

      # 30人のユーザーを作成（一回だけ実行される）
      # ※ before(:each)の場合はitの度に実行される（beforeでパラメータ未指定の場合はデフォルトで:eachになる）
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      # 事後処理として作成したユーザーを全て削除
      after(:all) { User.delete_all}

      it { should have_selector('div.pagination') }
      it 'should list each user' do
        # ページネーションを使用して、DBから最初の1ページを取得
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do
      describe "as an admin user" do
        FactoryGirl.create(:user) # 一覧表示用のユーザーを作成
        let(:admin) { FactoryGirl.create(:admin) } # adminユーザーの作成

        before do
          sign_in admin
          visit users_path
        end

        # ユーザー削除リンクが存在することをチェック
        it { should have_link('delete', href: user_path(User.first)) }

        it 'should be able to delete another user' do
          # click_link('delete', match: :first)は、最初に見つけたリンクをクリックするようにCapybaraに伝える
          expect { click_link('delete', match: :first) }.to change(User, :count).by(-1)
        end

        # 管理者自身のユーザー削除リンクは存在しないことをチェック
        it { should_not have_link('delete', href: user_path(admin)) }
      end

      describe "as an not admin user" do
        before do
          sign_in user
          visit users_path
        end

        it { should_not have_link('delete') }
      end
    end
  end

  describe "profile" do
    describe "page" do
      # Userファクトリーを使用してユーザーオブジェクトを変数に格納
      let(:user) { FactoryGirl.create(:user) }
      before { visit user_path(user) }

      it { should have_content(user.name) }
      it { should have_title(user.name) }
    end
  end

  describe "signup" do
    before { visit signup_path }

    describe "page" do
      it { should have_content('Sign up') }
      it { should have_title(full_title('Sign up')) }
    end

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it 'should not create a user' do
        # change(User, :count)でUser.countを計算する
        # expect { click_button submit }でカウント計算をclick_buttonの実行前と実行後の両方で行われるようにする
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title("Sign up") }
        it { should have_content("error") }
      end
    end

    describe "with valid information" do
      before { valid_create_user }

      it 'should create a user' do
        # by(1)で一件件数増えたことを検証
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }

        let(:user) { User.find_by(email: "user@example.com") }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_success_message('Welcome') }
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content('Update your profile') }
      it { should have_title('Edit user') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }

      before do
        fill_in "Name",	with: new_name
        fill_in "Email",	with: new_email
        fill_in "Password",	with: user.password
        fill_in "Confirmation Password",	with: user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_success_message }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe "forbidden attributes" do
      # admin: true を持つパラメータを定義
      let(:params) do
        {
          user: {
            admin: true,
            password: user.password,
            password_confirmation: user.password
          }
        }
      end

      before do
        sign_in user, no_capybara: true
        # 更新処理
        patch user_path(user), params
      end

      # user_paramsでadmin属性は許可されていないため、admin権限が付与されていないことをテスト
      specify { expect(user.reload).not_to be_admin }
    end
  end
end
