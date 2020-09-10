class User
  # ユーザー名とメールアドレスに対応するアトリビュートアクセサをそれぞれ作成
  # @name及び@emailインスタンス変数について、ゲッターとセッターを作成している
  # Railsではインスタンス変数（接頭辞として@が付いた変数）を作成するだけでビューで自動的に使えるようになる
  # 一般的にインスタンス変数は、Rubyのそのクラス内のどこでも利用できるようにしたい変数として使われる
  attr_accessor :name, :email

  # Rubyのコンストラクター
  # 引数としてattributesを渡している（attributesが空のハッシュの場合、@nameや@emailはnilになる）
  def initialize(attributes = {})
    @name = attributes[:name]
    @email = attributes[:email]
  end

  def formatted_email
    # インスタンス変数にアクセス
    "#{@name} <#{@email}>"
  end
end