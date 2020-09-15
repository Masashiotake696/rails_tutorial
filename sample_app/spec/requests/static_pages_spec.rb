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
