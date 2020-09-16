require 'spec_helper'

describe "Micropost Pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }

  describe "micropost creation" do
    before do
      sign_in user
      visit root_path
    end

    describe "with invalid information" do
      # コンテンツ未入力の場合はマイクロポストは作成されない
      it 'should not create a micropost' do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      # コンテンツ未入力の場合はエラーメッセージが表示される
      describe "error messages" do
        before { click_button "Post" }

        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before { fill_in "micropost_content",	with: "Lorem ipsum" }

      it 'should create a micropost' do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as current user" do
      before do
        sign_in user
        visit root_path
      end

      it 'should delete a micropost' do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end
end
