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

  # Userオブジェクトが各メソッドを持っているかテスト
  it { should respond_to(:authenticate) }

  # 検証チェック
  it { should be_valid }

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

end
