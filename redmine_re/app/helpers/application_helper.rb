module ApplicationHelper

  def current_user
    User.current
  end

def custom_ajaxful_rating_script
      if protect_against_forgery?
        authenticity_script = %{
          csrf_param = "authenticity_token";
          csrf_token = #{form_authenticity_token.inspect};

          // Always send the authenticity_token with ajax
          $(document).ajaxSend(function(event, request, settings) {
            if ( settings.type == 'post' ) {
              settings.data = (settings.data ? settings.data + "&" : "")
                + encodeURIComponent( csrf_param ) + "=" + encodeURIComponent( csrf_token );
            }
          });
        }
      end

      %{<script>
        #{authenticity_script}

        $(document).ready(function(){
          $('.ajaxful-rating a').bind('click',function(event){
            event.preventDefault();
            $.ajax({
              type: $(this).attr('data-method'),
              url: $(this).attr('href')+'?stars='+$(this).attr('data-stars')+'&dimension='+$(this).attr('data-dimension'),
              data: {
                      stars: $(this).attr('data-stars'),
                      dimension: $(this).attr('data-dimension'),
                      size: $(this).attr('data-size'),
                      show_user_rating: $(this).attr('data-show_user_rating')
                    },
              success: function(response){
                $('#' + response.id + ' .show-value').css('width', response.width + '%');
              }
            });
          });
        });
      </script>}
    end
  
  def errors_and_flash(artifact)
    s = error_messages_for 'artifact'
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
  
  
  # renders a table data field for every building block in bb_hash that is
  # used for condensed view (bb.for_condensed_view == true)
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

  def add_bb_section(artifact, bb_hash, bb_error_hash)
    if User.current.allowed_to?(:edit_requirements, @project)
      render :partial => "re_building_block/bb_section", :locals => {:bb_hash => bb_hash, :bb_error_hash => bb_error_hash}
    else
      ""
    end
  end
  

  def validation_warning(bb_error_hash, re_bb, key_for_error_hash)
    unless bb_error_hash.nil? or bb_error_hash[re_bb.id].nil? or bb_error_hash[re_bb.id][key_for_error_hash].nil?
      %Q{
        <div class="tooltip userdefined_fields"> #{image_tag("icons/invalid.png", :plugin => 'redmine_re')}
          <span class="tip userdefined_fields_tip"> #{bb_error_hash[re_bb.id][key_for_error_hash].collect {|error|  error + '<br/>'}}</span>
        </div>
      }
    end
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
end
