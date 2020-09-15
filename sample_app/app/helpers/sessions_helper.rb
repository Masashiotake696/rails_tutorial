module SessionsHelper
  def sign_in(user)
    # トークンを新規作成
    remember_token = User.new_remember_token
    # 暗号化されていないトークンをブラウザの永続化クッキー(有効期間は20年)として設定（cookiesはユーティリティ）
    cookies.permanent[:remember_token] = remember_token
    # 暗号化したトークンをユーザーDBのremember_tokenとして設定
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    # 現在のユーザーとして与えられたユーザーを設定
    self.current_user = user
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def signed_in?
    !current_user.nil?
  end

  # 参考: https://www.yokoyan.net/entry/2018/12/17/181500
  def current_user=(user)
    # インスタンス変数にuserを格納
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    # ||= は @current_userが未定義の場合にのみ、@current_userインスタンス変数に記憶トークンを設定する
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def current_user?(user)
    user === current_user
  end

  def redirect_back_or(default)
    # セッションに格納したリクエストURLを取得してリダイレクト（リクエストURLがなければデフォルトURLへリダイレクト）
    redirect_to session[:return_to] || default
    session.delete(:return_to)
  end

  def store_location
    # リクエストURLをセッションに格納
    session[:return_to] = request.url
  end
end
