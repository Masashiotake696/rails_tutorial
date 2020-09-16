class StaticPagesController < ApplicationController
  # ビューを指定しない場合は対応するビューが出力される(home.html.erb)
  def home
    if signed_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact

  end

end
