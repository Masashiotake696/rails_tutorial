module UsersHelper

  # 与えられたユーザーのGravatarを返す
  def gravatar_for(user, options = { size: 50 })
    # gravatarのURLはMD5ハッシュを用いてユーザーのメールアドレスをハッシュ化している
    # 参考: http://ja.gravatar.com/site/implement/hash/
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
