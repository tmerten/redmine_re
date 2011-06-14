module ApplicationHelper
  
  def errors_and_flash(artifact)
    s = error_messages_for artifact
    s += render_flash_messages_with_timeout
  end
  
  
  
  def render_flash_messages_with_timeout
  # overrides render_flash_messages in application helper
    s = ''
    flash.each do |k,v|
      id = "#{v} #{k}".gsub(" ", "_") # id should be a token (one word) WC3 valid..
      s << content_tag('div', v, :class => "flash #{k}", :id => id)
      s << content_tag('script', "setTimeout('new Effect.Fade(\"#{id}\");', 6000)", :type => "text/javascript")
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

  # creates a link to the wikipage of an artifact => wiki/#id_#artifact_type_#name/
  # if there is already a wikipage the content will be placed as a tooltip to the link
  def wiki_page_of_re_artifact( project, re_artifact ) #todo subtasks wiki link..
    return t(:re_wiki_page_available_after_save) if re_artifact.id.blank? # only when already saved artifact

    # check instance
    re_artifact = (re_artifact.instance_of?(ReArtifactProperties))? re_artifact : re_artifact.re_artifact_properties

    # check if a wiki page already exist for this artifact
    html_code = ""
    wiki_page_name = "#{re_artifact.id}_#{re_artifact.artifact_type}"
    wiki_page = WikiPage.find_by_title(wiki_page_name)
    has_no_wiki_page_yet = (wiki_page.nil?)? true : false

    # variable icon
    
    if has_no_wiki_page_yet
    html_code += link_to t(:re_create_wiki_page_for_re_artifact), {
      :controller => 'wiki',
      :action => 'edit',
      :id => wiki_page_name,
      :project_id => project.identifier} ,
      { :class => "icon icon-subtask-wiki-new" }
    else
      html_code += link_to t(:re_show_wiki_page_for_re_artifact), {
      :controller => 'wiki',
      :action => 'show',
      :id => wiki_page_name,
      :project_id => project.identifier}

      html_code += " ("
      
      html_code += link_to t(:re_edit), {
      :controller => 'wiki',
      :action => 'edit',
      :id => wiki_page_name,
      :project_id => project.identifier} ,
      { :class => "icon icon-subtask-wiki-edit" }     
      
      html_code += ")"
    end
    return html_code
  end
  
  def add_bb_configuration_link(artifact_type)
    if User.current.allowed_to?(:administrate_requirements, @project)
      link_to(  t(:re_bb_add), 
                :controller => :re_building_block, 
                :action => :edit, 
                :id => "", 
                :project_id => @project.id, 
                :artifact_type => artifact_type)
    else
      ""
    end
  end
  
  def add_bb_section(artifact, bb_hash, bb_error_hash)
    if User.current.allowed_to?(:administrate_requirements, @project)
      render :partial => "re_building_block/bb_section", :locals => {:bb_hash => bb_hash, :bb_error_hash => bb_error_hash}
    else
      ""
    end
  end
  
  
  
  
end
