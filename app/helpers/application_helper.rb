module ApplicationHelper

  def rendered_relation_type(relation_type)
    relation_type_alias = @re_relation_settings[relation_type]['alias']
    relation_type_humanized =  relation_type.humanize

    if relation_type_alias.blank? or  relation_type_humanized.eql?(relation_type_alias)
      return t('re_' + relation_type)
    else
      return relation_type_alias
    end
  end

  # artifact_type bsp: => "re_task"
  def rendered_artifact_type(artifact_type)
    artifact_type_alias = ''

    unless @re_artifact_settings[artifact_type].nil?
      artifact_type_alias = @re_artifact_settings[artifact_type]['alias']
    end
    artifact_type_humanized =  artifact_type.gsub(/^re_/, '').humanize

    if artifact_type_alias.blank? or  artifact_type_humanized.eql?(artifact_type_alias)
      return t(artifact_type)
    else
      return artifact_type_alias
    end
  end

  def current_user
    User.current
  end

  # Error messages have to be created for the artifact
  # or builiding block that is named in the variable artifact 
  def errors_and_flash(artifact)
    s = error_messages_for artifact
    s += render_flash_messages_with_timeout
  end
  
  def render_flash_messages_with_timeout
    s = ''
    flash.each do |k,v|
      id = "#{v} #{k}".gsub(" ", "_") # id should be a token (one word) WC3 valid..
      s << content_tag('div', v, :class => "flash #{k}", :id => id)
      s << content_tag('script', "setTimeout('new Effect.Fade(\"#{id}\");', 6000)", :type => "text/javascript")
    end
    s
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




##### Helpers for building blocks ######


  # This helper builds up a link to add a new bb to the artifact_type
  # given in the variable. The link is delivered back if the user has
  # the appropriate rights (adminstration of requirements). Otherwise  
  # an empty string is returned.
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


  # This method builds up some html to describe a part of the condensed 
  # representation of artifacts. To be more precise, the html constructed
  # here consists of a tabel-data-entry for each bb of the given artifact 
  # which is configured to be part of the standard condensed representation.
  # The html is returned to be integrated in a view.
  def insert_building_blocks_one_line_representations(artifact)
    bb_hash = ReBuildingBlock.find_all_bbs_and_data(artifact, @project.id)
    html_code = ""
    bb_hash.keys.each do |re_bb|
      data = re_bb.find_my_data(artifact) 
      bb_class_name = re_bb.type.is_a?(String) ? re_bb.type : re_bb.type.name
      html_code += render :partial => "re_building_block/#{bb_class_name.underscore}/one_line_representation", :locals => {:re_bb => re_bb, :data => data}
    end
    html_code
  end


  # This method allows to add the whole bb-section to an edit-artifact-
  # view with only one line of code. This is needed because the section 
  # has to be included in views of non-bb-models and therefore shall be
  # hidden behind a very easy command.
  def add_bb_section(artifact, bb_hash, bb_error_hash)
    if User.current.allowed_to?(:edit_requirements, @project)
      render :partial => "re_building_block/bb_section", :locals => {:bb_hash => bb_hash, :bb_error_hash => bb_error_hash}
    else
      ""
    end
  end
  

  # This method builds up a html-string to add an icon to the view which 
  # has all error messages of the given bb as a tooltip. The html-code is 
  # returned by the method.
  def validation_warning(bb_error_hash, re_bb, key_for_error_hash)
    unless bb_error_hash.nil? or bb_error_hash[re_bb.id].nil? or bb_error_hash[re_bb.id][key_for_error_hash].nil?
      %Q{
        <div class="tooltip userdefined_fields"> #{image_tag("icons/invalid.png", :plugin => 'redmine_re')}
          <span class="tip userdefined_fields_tip"> #{bb_error_hash[re_bb.id][key_for_error_hash].collect {|error|  error + '<br/>'}}</span>
        </div>
      }
    end
  end
  
  # Helper for the slider for the number bb. 
  def number_field_with_slider(re_bb_id, re_bb_data_id, data_value, min, max)
    # To match the id's needed for building block form elements, the use of
    # []-bracets is needed. Rails changes these brackets to underscores in the 
    # text_field_tag-helper to use this changed string as the id. But as the javascript 
    # won't do these adaptions on their own, the field_id must be change manually to be 
    # used as input for the sliders.
    fieldid = "re_bb[" + re_bb_id.to_s + "][" + re_bb_data_id.to_s + "][value]"
    fieldid_slider = fieldid.gsub('[', '_').gsub(']', '')
    #data = ReBbDataNumber.find(re_bb_data_id) unless re_bb_data_id == 'no_id'

    js = <<JAVASCRIPT   
    Event.observe(window, 'load', function() {
      var #{fieldid_slider}Slider = new Control.Slider('#{fieldid_slider}-handle' , '#{fieldid_slider}-track',
      {
        range: $R(#{min},#{max}),
        values: $R(#{min},#{max}),
        sliderValue: $('#{fieldid_slider}').value,
        onChange: function(v) { $('#{fieldid_slider}').value = v; },
        onSlide:  function(v) { $('#{fieldid_slider}').value = v; }
      } );
      
      $('#{fieldid_slider}').observe('change', function() {
        if (this.value < #{min}) this.value = #{min};
        if (this.value > #{max}) this.value = #{max};
        #{fieldid_slider}Slider.setValue(this.value);  
      });
    });
JAVASCRIPT

    js = javascript_tag(js)

    sliderdivs = content_tag("div", "", :id => "#{fieldid_slider}-handle", :class => "numberfield-handle")
    sliderdivs = content_tag("div", sliderdivs, :id => "#{fieldid_slider}-track", :class => "numberfield-track")
    size = max.nil? ? '5' : max.to_i.to_s.length.to_i
    field = text_field_tag(fieldid, data_value, :size => size)
    sliderdivs = content_tag(:div, field+sliderdivs, :class => "numberfield-slider")
    js + sliderdivs
  end

  def redmine_version_is_higher_or_equal_than?(compare_version_str)
  # helper which checks if the current redmine version is higher or equal than another

    # complete version string example: 1.1.2.stable
    current_version_str = Redmine::VERSION.to_s

    # get the version numbers 1.2.1.stable => [1, 2, 1]
    get_version_numbers = Regexp.new(/\A(\d+)\.(\d+)\.(\d+)/)

    m = compare_version_str.match(get_version_numbers)
    raise ArgumentError, "The version string: #{compare_version_str} contains not a valid version!" if m.nil?
    compare_version_numbers = [$1.to_i, $2.to_i, $3.to_i]

    current_version_str.match(get_version_numbers)
    current_version_numbers = [$1.to_i, $2.to_i, $3.to_i]

    # compare the version numbers 
    result = true
    current_version_numbers.each_index do |i|
      if( current_version_numbers[i] < compare_version_numbers[i] )
        result = false
      end
    end

    return result
  end

  def edit_artifact_path(artifact)
    url_for :controller => artifact.artifact_type.underscore,
            :action => 'edit',
            :id => artifact.artifact_id
  end

end
