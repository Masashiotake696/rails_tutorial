class Relationship < ActiveRecord::Base
  # Railsは外部キーをそれに対応するシンボルから推測する
  # :followerからfollower_idを推測し、followedからfollowed_idを推測する
  # しかし、FollowerモデルもFollowedモデルも実際にはないので、クラス名Userを提供する必要がある
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
