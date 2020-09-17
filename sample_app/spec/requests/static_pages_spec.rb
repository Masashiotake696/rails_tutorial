require 'spec_helper'

describe "Static pages" do # テスト対象のコントローラー

  # page変数がテストの主題(subject)であることをRSpecに伝える
  # shouldの呼び出しを自動的にCapybaraにより提供されるpage変数を使用するように指定
  subject { page }

  # Shared Examplesを使用して処理をまとめる
  # 使用している変数であるheadingとpage_titleは呼び出し側でletで定義する
  shared_examples_for "all static pages" do
    it { should have_content(heading) } # pageのコンテンツとして変数headingという文字列が含まれているかテスト
    it { should have_title(full_title(page_title)) } # Titleタグの内容をテスト
  end

  describe "Home page" do # テスト対象のアクション
    # beforeで共通処理をまとめる
    # visitはCapybaraのメソッドで、指定したパスにGETリクエストを送る。
    # リクエスト結果がpage変数に格納される
    before { visit root_path }

    # ローカル変数定義(Shared Examples用)
    let(:heading) { "Sample App" }
    let(:page_title) { "" }

    # shared_examples_forの呼び出し
    it_should_behave_like "all static pages"
    # should_notを使用
    it { should_not have_title("| Home") }

    # リンクのテスト
    it "should have the right links on the layout" do
      # click_linkはinner HTMLを指定
      click_link "About"
      expect(page).to have_title(full_title("About Us"))
      click_link "Help"
      expect(page).to have_title(full_title("Help"))
      click_link "Contact"
      expect(page).to have_title(full_title("Contact"))
      click_link "Home"
      expect(page).to have_title(full_title(""))
      click_link "Sign up now!"
      expect(page).to have_title(full_title("Sign up"))
      click_link "sample app"
      expect(page).to have_title(full_title(""))
    end

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }

        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link('0 following', href: following_user_path(user)) }
        it { should have_link('1 followers', href: followers_user_path(user)) }
      end

      describe "micropost" do
        describe "destruction" do
          describe "as current user" do
            it 'should delete a micropost' do
              expect { click_link "delete", match: :first }.to change(Micropost, :count).by(-1)
            end
          end
        end

        describe "count" do
          describe "singular" do
            it { should have_content("1 micropost") }
          end

          describe "multiple" do
            before do
              FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
              visit root_path
            end

            it { should have_content("2 microposts") }
          end
        end

        describe "pagination" do
          before do
            30.times { FactoryGirl.create(:micropost, user: user) }
            visit root_path
          end

          it { should have_selector('div.pagination') }
          it 'should list each micropost' do
            Micropost.paginate(page: 1).each do |micropost|
              expect(page).to have_selector('li', text: micropost.content)
            end
          end
        end
      end
    end

    describe "for other signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:another_user) { FactoryGirl.create(:user) }

      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        sign_in another_user
        visit root_path
      end

      it { should_not have_link("delete")}
    end
  end

  describe "Help page" do
    before { visit help_path }

    let(:heading) { "Help" }
    let(:page_title) { "Help" }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }

    let(:heading) { "About" }
    let(:page_title) { "About Us" }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }

    let(:heading) { "Contact" }
    let(:page_title) { "Contact" }

    it_should_behave_like "all static pages"
  end
end
