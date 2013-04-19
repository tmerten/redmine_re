
updateSubtaskPositionFields();

function jsInitScript() {
    jQuery("#subtasks").sortable({
      placeholder: 'ui-state-highlight',
	  containment: '#subtasks',
      start: function(event, ui){
         jQuery(".ui-state-highlight").html("<div style='background:#4466AA; width: 800px; height: 5px; clear: both;'></div>");
      },
      update: function(event, ui){
         updateSubtaskPositionFields();
      },  
    });

	jQuery("div.subtask_select_container select").change(function() {
		changeSubtaskRowColor(jQuery(this).parent().parent().parent(), this.value);
	});
	
};

jQuery(document).ready(function(){
    jsInitScript();
		/* jQuery(".subtask_textarea").autoGrow();*/
	});
	
function changeSubtaskRowColor(element, value) {
    jQuery(element).removeClass('subtask');
	jQuery(element).removeClass('variant');
	jQuery(element).removeClass('problem');
	
	switch(value) {
	  case '0': jQuery(element).addClass('subtask'); break;
	  case '1': jQuery(element).addClass('variant'); break;
	  case '2': jQuery(element).addClass('problem'); break;
	}
}

  //TODO: Update selectors!
  function updateSubtaskPositionFields() {
    var pos = 1;
    jQuery('#subtasks').children('div').each( function(child) {
	  jQuery(this).attr('id','subtask_drag_' + pos);
	  jQuery(this).children('.position').attr('value', pos);
      pos++;
    });
  }
  
  function add_fields(where, type, content ) {
  	var now = new Date;
	var utc_timestamp = Date.UTC(now.getFullYear(),now.getMonth(), now.getDate() , 
  						now.getHours(), now.getMinutes(), now.getSeconds(), 
  						now.getMilliseconds());
  	var ts = Math.round((new Date()).getTime() / 1000);
  	 switch(type) {
  	    case 're_subtask':
    	content = replaceAll(content, "new_re_subtask", utc_timestamp.toString().substring(5,12));
	  	    	addSubtask(where, content);
	  	    break;
	  	 }
	  }
  
	  function remove_fields(link) {
		jQuery(link).prev("input[type=hidden]").val("1");
		jQuery(link).closest(".nested_field").hide();
	  }

  
	  function replaceAll(txt, replace, with_this) {
	  	return txt.replace(new RegExp(replace, 'g'),with_this);
  }