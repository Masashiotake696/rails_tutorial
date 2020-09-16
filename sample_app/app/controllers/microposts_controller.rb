class MicropostsController < ApplicationController
  # onlyを指定しない場合はデフォルトで全てのアクションに適応される
  before_action :signed_in_user
  before_action :correct_user, only: [:destroy]

  def create
    @micropost = current_user.microposts.build(micropost_params)

    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content)
    end

    def correct_user
      # current_userが保持するマイクロポストから、IDがパラメータから取得したIDと一致するマイクロポストを抽出
      # findを使用するとマイクロポストが存在しない場合に例外が投げられるため、マイクロポストが存在しない場合にnilを返すfind_byを使用する
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
