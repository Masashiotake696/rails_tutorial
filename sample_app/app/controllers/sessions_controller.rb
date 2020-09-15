class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase) # メールアドレスは全て小文字で保存されているため、検索するときも小文字に変換して検索する
    if user && user.authenticate(params[:password])
      sign_in user
      redirect_to user
    else
      # flashを使用するとrenderでテンプレートを再描画してもリクエストと見なされないため、期待よりも長い間フラッシュメッセージが表示されてしまう
      # flash.nowは他のリクエストが発生したらすぐにメッセージを消すので、これを使用することで正しい挙動になる
      flash.now[:error] = "Invalid email/password combination"
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

end
