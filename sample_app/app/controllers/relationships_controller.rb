class RelationshipsController < ApplicationController
  before_action :signed_in_user

  respond_to :html, :js

  def create
    # フォローされるユーザーのIDからユーザー情報を取得
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    # formatに応じて返すレスポンスを変更する
    respond_with @user
  end

  def destroy
    # アンフォローされるユーザーのIDからアンフォローされるユーザー情報を取得
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_with @user
  end
end
