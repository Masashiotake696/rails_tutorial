module MicropostsHelper
  def wrap(content)
    sanitize(raw(content.split.map { |text| wrap_long_string(text) }.join(' ')))
  end

  private

    # 文字列をmax_widthごとに区切って改行する
    def wrap_long_string(text, max_width = 30)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text :
                                  text.scan(regex).join(zero_width_space)
    end
end
