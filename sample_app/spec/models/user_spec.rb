require 'spec_helper'

describe User do
  # 前処理として、新しくユーザーを作成して@userインスタンス変数に格納
  before { @user = User.new(name: "Example User", email: "user@example.com", password: "foober", password_confirmation: "foober") }

  # @userをテストサンプルのデフォルトのsubjectとして設定
  subject { @user }

  # Userオブジェクトが各属性を持っているかテスト
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }

  # Userオブジェクトが各メソッドを持っているかテスト
  it { should respond_to(:authenticate) }
  it { should respond_to(:feed) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }

  # Userオブジェクトが各リレーションを持っているかテスト
  it { should respond_to(:microposts) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:followers) }

  it { should be_valid }
  it { should_not be_admin } # admin?メソッドが使用できる必要がある(admin属性をUserモデルに追加すると自動的にadmin?メソッドが使えるようになる)

  # ---------- 属性のバリデーションテスト ----------

  # 名前に空文字を格納して存在の検証
  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  # 名前に長さ51文字の文字列を格納して長さの検証
  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  # メールアドレスに空文字を格納して存在の検証
  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  # メールアドレスの形式の検証（フォーマットが不正）
  describe "when email format is invalid" do
    it 'should be invalid' do
      addresses =  %w[user@foo,com user_at_foo.org example.user@foo.foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  # メールアドレスの形式の検証（フォーマットが正当）
  describe "when email format is valid" do
    it 'should be valid' do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  # メールアドレスのユニーク性の検証
  describe "when email address is already taken" do
    # 事前に@userを複製しデータベースに保存しておく
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase # メールアドレスの大文字小文字は区別されないため、そのような場合も考慮して大文字に一括変換する
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  # メールアドレス小文字変換の検証
  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it 'should be saved as all lower-case' do
      @user.email = mixed_case_email
      @user.save
      # reloadメソッドを使用してデータベースから値を再度読み込み検証する
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  # パスワードの存在検証
  describe "when password is not present" do
    before do
      @user.password = ""
      @user.password_confirmation = ""
    end

    it { should_not be_valid }
  end

  # パスワードとパスワード確認の一致検証
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }

    it { should_not be_valid }
  end

  # パスワードの長さの検証
  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }

    it { should_not be_valid }
  end

  # ---------- メソッドのテスト ----------

  # パスワードが一致する場合と一致しない場合に関して検証
  describe "return value of authenticate method" do
    before { @user.save } # データベースに事前保存
    let(:found_user) { User.find_by(email: @user.email) } # emailを元に保存したユーザーを取得

    # パスワードが一致する場合は、@userとfound_user.authenticate(@user.password)の戻り値が等しいことをテスト
    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    # パスワードが一致しない場合は、authenticateメソッドの戻り値がfalseになることをテスト
    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password}
      specify { expect(user_for_invalid_password).to be_false } # specifyはitのエイリアスで自然な英文を作るために使用する
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }

    before do
      @user.save
      @user.follow!(other_user)
    end

    # following?メソッドを使用している
    it { should be_following(other_user) }
    # @userのfollowed_usersにother_userが含まれているかテスト
    its(:followed_users) { should include(other_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end

  # ---------- Active Recordコールバックのテスト ----------

  # ユーザーを保存するとremember_tokenが自動的に設定されることをテスト
  describe "remember token" do
    before { @user.save }
    # itsメソッドはitが指すテストのsubjectそのものではなく、引数として与えられたその属性に対してテスト行う
    its(:remember_token) { should_not be_blank }
  end

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin) # toggle!で指定した属性を反転し保存する
    end

    it { should be_admin }
  end

  # ---------- リレーションのテスト ----------

  describe "micropost associations" do
    before { @user.save }

    # Factory Girlを使用することで、Active Recordがアクセスを許可しないようなcreated_at属性も手動で設定できる
    # letではなくlet!を使用することで、マイクロポストを遅延することなく即座に作成することができる（letを使用した場合は、参照された時に初めて初期化される）
    let!(:older_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) }
    let!(:newer_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) }

    # 新しいマイクロポストほど順番が先に来ることをテスト
    it 'should have the right microposts in the right order' do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it 'should destroy associated microposts' do
      # to_aメソッドが呼び出されることでマイクロポストのコピー(オブジェクト自体のコピー)が作成される
      # これにより、ユーザーを削除した時にmicroposts変数に含まれているポストは削除されない(microposts変数としてメモリ上に残る)
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user)) }
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create(content: "Lorem ipsum") }
      end

      # includeは与えられた要素が配列に含まれるかどうかをチェックするinclude?メソッドを使用している
      # feedに自身のマイクロポストが含まれることをテスト
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      # feedにフォローしていないユーザーのマイクロポストは含まないことをテスト
      its(:feed) { should_not include(unfollowed_post) }
      # feedにフォローしているユーザーのマイクロポストが含まれることをテスト
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe "relationship associations" do
    before do
      @user.save
      # 3人のユーザーをフォロー
      3.times { @user.follow!(FactoryGirl.create(:user)) }
    end

    # ユーザーを削除後にリレーションも削除されることをテスト
    it 'should destroy associated relationships' do
      relationships = @user.relationships.to_a
      @user.destroy
      expect(relationships).not_to be_empty
      relationships.each do |relationship|
        expect(Relationship.where(id: relationship.id)).to be_empty
      end
    end
  end
end
