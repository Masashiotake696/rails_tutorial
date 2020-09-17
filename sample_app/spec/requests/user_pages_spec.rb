require 'spec_helper'

describe "User" do
  subject { page }

  describe "index" do
    # let!を使用することで、各サンプルが実行される前に評価される（letの場合は最初にメソッドが呼ばれた時に評価される）
    let!(:user) { FactoryGirl.create(:user) }

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

  describe "profile page" do
    # Userファクトリーを使用してユーザーオブジェクトを変数に格納
    let(:user) { FactoryGirl.create(:user) }
    let!(:micropost1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:micropost2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    # ユーザーに紐づくmicropostsの表示内容をテスト
    describe "microposts" do
      it { should have_content(micropost1.content) }
      it { should have_content(micropost2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }

      before { sign_in user }

      describe "following a user" do
        # ユーザーページにアクセスしてフォローボタンをクリックし、その後の挙動をテストする
        before { visit user_path(other_user) }

        it 'should increment the followed user count' do
          expect { click_button "Follow" }.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect { click_button "Follow" }.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }

          it { should have_xpath("//input[@value='Unfollow']") }
        end

        describe "follower/following counts" do
          before do
            other_user.follow!(user)
            visit root_path
          end

          it { should have_link('0 following', href: following_user_path(user)) }
          it { should have_link('1 followers', href: followers_user_path(user)) }
        end
      end

      describe "unfollowing a user" do
        # ユーザーをフォロー後、そのユーザーのページでアンフォローボタンをクリックし、その後の挙動をテストする
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it 'should decrement the followed user count' do
          expect { click_button "Unfollow" }.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect { click_button "Unfollow" }.to change(other_user.followers, :count).by(-1)
        end

        describe "toggling the button" do
          before { click_button "Unfollow" }

          it { should have_xpath("//input[@value='Follow']") }
        end

      end
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

  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    before { user.follow!(other_user) }

    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title(full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_title(full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
end
