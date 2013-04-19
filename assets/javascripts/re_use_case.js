
	function jsInitScript() {
	    jQuery("#steps").sortable({
	      placeholder: 'ui-state-highlight',
	      containment: '#steps',
	      start: function(event, ui){
	         jQuery(".ui-state-highlight").html("<div style='background:#4466AA; width: 800px; height: 5px; clear: both;'></div>");
	      },
	      update: function(event, ui){
	         updateStepPositionFields();
	      },  
	    });
	}

	jQuery(document).ready(function() {
		jsInitScript();
		updateStepPositionFields();
	});
  
  function addExpansion(element, rendered_expansion) {
  	// Hate me, but i works
    jQuery(element).parent().parent().prev().children().next().children().children().next().append( rendered_expansion );
  }
  
  function add_fields(where, type, content ) {
  	var now = new Date;
	var utc_timestamp = Date.UTC(now.getFullYear(),now.getMonth(), now.getDate() , 
  						now.getHours(), now.getMinutes(), now.getSeconds(), 
  						now.getMilliseconds());
  	var ts = Math.round((new Date()).getTime() / 1000);
  	 switch(type) {
  	    case 're_use_case_step_expansion':
  	    case 're_use_case_step_expansions':
  	    	content = replaceAll(content, "new_re_use_case_step_expansions", utc_timestamp.toString().substring(5,12));
  	    	addExpansion(where, content);
  	    break;
  	 }
  }
  
  function replaceAll(txt, replace, with_this) {
  	return txt.replace(new RegExp(replace, 'g'),with_this);
  }

  function updateStepPositionFields() {
    var pos = 1;
    jQuery('#steps').children().each( function(child) {
      jQuery(this).attr('id','use_case_step_expansion_drag_' + pos);
      jQuery(this).children().children('.position').attr('value', pos);
      pos++;
    });
  }

  function remove_fields(link) {
	jQuery(link).prev("input[type=hidden]").val("1");
	jQuery(link).closest(".nested_field").hide();
  }