class UsersController < ApplicationController
  # アクションが呼び出される前に処理を挟む
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  before_action :admin_not_myself, only: [:destroy]

  def index
    # ページネーションを使用してユーザーを取得
    # per_pageを指定しない場合はデフォルトで1ページ当たり30件のデータを取得する
    # params[:page]はwill_paginateメソッドによって自動的に生成される
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    if signed_in?
      redirect_to root_url
    else
      @user = User.new
    end
  end

  def create
    if signed_in?
      redirect_to root_url
    else
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
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  private
    def user_params
      # requireで指定した値が存在しなければ例外を返す（指定した値だけ抽出）
      # permitで許可したパラメータのみを抽出
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def signed_in_user
      unless signed_in?
        # サインインページ遷移前のページURLをセッションに退避
        store_location
        # redirect_toメソッドにオプションハッシュとしてnoticeを渡すことでフラッシュメッセージを表示する
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url unless current_user?(@user)
    end

    def admin_user
      redirect_to root_url unless current_user.admin?
    end

    def admin_not_myself
      redirect_to root_url unless current_user != User.find(params[:id])
    end
end
