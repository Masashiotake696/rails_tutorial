class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      # flashメッセージの表示
      flash[:success] = "Welcome to the Sample App"
      # redirect_to(user_url(@user))のuser_urlは省略可能
      # http://localhost:3000/users/{@user.id}にリダイレクトされる
      redirect_to @user
    else
      render 'new'
    end
  end

  private
    def user_params
      # requireで指定した値が存在しなければ例外を返す（指定した値だけ抽出）
      # permitで許可したパラメータのみを抽出
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
