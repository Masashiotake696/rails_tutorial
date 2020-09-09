require 'spec_helper'

describe "Static pages" do # テスト対象のコントローラー

  describe "Home page" do # テスト対象のアクション
    it "should have the content 'Sample App'" do # テスト内容
      # visitはCapybaraのメソッドで指定したパスにGETリクエストを送る。
      # リクエスト結果がpage変数に格納される
      visit '/static_pages/home'
      # pageのコンテンツとして'Sample App'という文字列が含まれているかテスト
      expect(page).to have_content('Sample App')
    end
  end

  describe "Help page" do
    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end
  end

  describe "About page" do
    it "should have the content 'About Us'" do
      visit '/static_pages/about'
      expect(page).to have_content('About Us')
    end
  end

end
