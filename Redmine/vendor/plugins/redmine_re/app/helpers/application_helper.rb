module ApplicationHelper
  def render_flash_messages_with_timeout
  # overrides render_flash_messages in application helper
    s = ''
    flash.each do |k,v|
      s << content_tag('div', v, :class => "flash #{k}", :id => "#{v}#{k}")
      s << content_tag('script', "setTimeout('new Effect.Fade(\"#{v}#{k}\");', 6000)", :type => "text/javascript")
    end
    s
  end
end
