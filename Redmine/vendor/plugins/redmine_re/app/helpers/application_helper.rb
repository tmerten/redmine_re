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

	def number_field_with_slider(objectname, method, min, max)
		fieldid = objectname.to_s + "_" + method.to_s

		js = <<JAVASCRIPT 
		Event.observe(window, 'load', function() {
      var #{fieldid}Slider = new Control.Slider('#{fieldid}-handle' , '#{fieldid}-track',
      {
				range: $R(1,51),
				values: $R(1,50),
				sliderValue: $('#{fieldid}').value,
				onChange: function(v) { $('#{fieldid}').value = v; },
				onSlide:  function(v) { $('#{fieldid}').value = v; }
      } );
      
			$('#{fieldid}').observe('change', function() {
				if (this.value < #{min}) this.value = #{min};
				if (this.value > #{max}) this.value = #{max};
				#{fieldid}Slider.setValue(this.value);  
			});
	  });
JAVASCRIPT
  
		js = javascript_tag(js)

		sliderdivs = content_tag("div", "", :id => "#{fieldid}-handle", :class => "numberfield-handle")
    sliderdivs = content_tag("div", sliderdivs, :id => "#{fieldid}-track", :class => "numberfield-track")
	  field = label(objectname, method, t(fieldid))		
		field << text_field(objectname, method, :size => 3)
    sliderdivs = content_tag(:div, field+sliderdivs, :class => "numberfield-slider")
    js + sliderdivs
	end
end
