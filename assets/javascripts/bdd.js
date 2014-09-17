/**
 * Add hook to form to serialize form data before sending to server
 */ 
function addHookToForm(hook_type) {
	console.log("adding hook to form with type"+hook_type);
	if(hook_type == "new") {
		form_id = "#new_re_artifact_properties";
	} else {
		form_id = "[id*=edit_re_artifact_properties]";
	}
	
	$(form_id).submit(function(event){
		try {
			serializeFormToJSON();
		} catch (e) {
			console.log("Could not serialize data"+e.toString());
		}
	});
}

/**
 * Event handler for focus event of the inputs
 */
function handleInputFocusEvent(e) {
	e = $(e);
	if(e.attr('data-touched') == '0') {
		e.val('');
	}	
}

/**
 * Event handler for blur event of the inputs
 */
function handleInputBlurEvent(e) {
	e = $(e);
	e.css('color','#000');
	e.css('fontStyle','normal');
	e.attr('data-touched', "1");	
	
	generateExampleTable(e.parent().parent());
}



/**
 * Checks all inputs for the given scenario for <placeholders>
 * and generates, updates or removes the according example table.
 * 
 * @param jQuery-Object scenario  
 */
function generateExampleTable(scenario) {
	console.log('generateExampleTable()');
	console.log(scenario.attr('class'));
}


function checkScenarioInputsForOutlines(e) {
	pattern = /(\<[a-z]+\>)/gi;
	if(e.match(pattern).length > 0) {
		// We found at least <placeholder>
	} else {
		// No placeholder found, rebuild example table
	}
		
}


/**
 * Validates the entered data, basic logic checks of the scenario
 * steps. 
 */
function validateFeature() {
	var validated = true;
	
	/*
	$('.bdd_feature_outline').each(function(i, obj) {
		if($(this).attr("data-touched") == "0") {
			validated = false;
		}
	});*/
			
	
	return validated;	
}

/**
 * Serializes the user entered data from the form
 * to JSON which will be send as description of the artifact.
 */
function serializeFormToJSON() {
	
	if(validateFeature()) {
	
		// Generate JSON from HTML-form
		var feature = new Object();
		feature.name = $("#bdd_feature_name").val();
		
		feature_description = new Array();
		
		$('.bdd_feature_outline').each(function(i, obj) {
			feature_description.push($(this).val());
		});
				
		feature.description = feature_description;
		feature_background = new Object();
		feature_background_steps = Array();
		if($('#bdd_scenario_background_box').attr('data-toggle')=='1') {
			
			steps = $("#bdd_scenario_background_box").find('.bdd_scenario_outline_step').each(function(i,obj){
				step = "";
				
				$(this).find("select option:selected").each(function(i,obj){			
					step = step + $(this).text() + "#";	
				});
				
				
				step = step + $(this).find(".bdd_scenario_outline").val();
				feature_background_steps.push(step);
			});
			feature_background.steps = feature_background_steps;
		} 
		
		feature.background = feature_background;
		feature_scenarios = new Array();
		
		// iterate over the scenario containers
		$('.bdd_scenario_container').each(function(i, obj){
			var scenario = new Object();
			
			// Get scenario name
			scenario.name = $(this).find(".bbd_scenario_name_input").val();
			
			// Get Scenario steps
			scenario_steps = Array();
			
			steps = $(this).find(".bdd_scenario_outline_step").each(function(i,obj){
				step = "";
				
				$(this).find("select option:selected").each(function(i,obj){			
					step = step + $(this).text() + "#";	
				});
				
				
				step = step + $(this).find(".bdd_scenario_outline").val();
				scenario_steps.push(step);
			});
			
			scenario.steps = scenario_steps;
			
			feature_scenarios.push(scenario);
		});
		
		feature.scenarios = feature_scenarios;
		
		serialized = JSON.stringify(feature);
		
		console.log(serialized);
		$("#bdd_feature_serialized").attr("value", serialized);
		
	} else {
		// @todo trigger error
	}
}

/**
 * Adds a new Scenario input fragment to the Feature Form
 */
function addScenario(event) {
	var new_scenario = $("#bdd_scenario_box").clone();
	new_scenario.attr("id",""); // remove ID
	new_scenario.appendTo("#bdd_feature_form");
	new_scenario.show();
	event.preventDefault();
}

function createFeatureViewFromJSON(feature_json) {
	
	if(feature_json.length > 0) {
	
		feature = JSON.parse(feature_json);
		
		view = getKeywordElement('Feature',feature.name);
		view = view + '<br/>';
		view = view + getFeatureOutlineElement(feature.description);
		view = view + '<br/>';
		
		// Add Background only if available
		if(feature.background.steps != null) {
			if(feature.background.steps.length > 0) {
				view = view + getBackgroundElement(feature.background);	
			}
		}
		
		for(var i = 0; i < feature.scenarios.length; i++) {
			view = view + getScenarioElement(feature.scenarios[i], i);
		}
		
		$('.bdd_feature_card').append(view);
	}
}

function getKeywordElement(keyword_label,string) {
	return '<strong class="bdd_keyword">'+keyword_label+'</strong>: '+string;
}

function getKeyWordElementNoDeco(keyword_label,string) {
	
	align_spaces = "";
	
	max = "Given".length - keyword_label.length;
	
	for(var i = 0; i < max; i++) {
		align_spaces = align_spaces + "&nbsp";
	}
	
	return '<strong class="bdd_keyword">'+align_spaces+keyword_label+'</strong> '+string;	
}

function getFeatureOutlineElement(description_array) {
	view = '';
	
	for(var i = 0; i < description_array.length; i++) {
		view = view + '<div class="bdd_feature_outline">'+description_array[i]+'</div>';	
	}
	
	return view;
}

function getScenarioElement(scenario, i) {
	
	view = '<div class="bdd_cenario_container">';
	
	view = view + getKeywordElement('Scenario #'+(i+1).toString(), scenario.name);
	view = view + '<br/>';
	
	for(var j = 0; j < scenario.steps.length; j++) {
		
		chunks = scenario.steps[j].split('#');
		view = view + '<div class="bdd_scenario_subcontainer">' + getKeyWordElementNoDeco(chunks[0], chunks[1], "") + '</div>';
	}
	
	view = view + '</div>';
	
	return view;
}

function getBackgroundElement(background) {
	
	view = '<div class="bdd_cenario_container">';
	
	view = view + getKeywordElement('Background', "");
	view = view + '<br/>';
	
	for(var j = 0; j < background.steps.length; j++) {
		
		chunks = background.steps[j].split('#');
		view = view + '<div class="bdd_scenario_subcontainer">' + getKeyWordElementNoDeco(chunks[0], chunks[1], "") + '</div>';
	}
	
	view = view + '</div><br/>';
	
	return view;
}


function createFeatureViewFormFromJSON(feature_json) {
	
	console.log(feature_json);
	
	// Set styles on all inputs to display solid text
	$('#bdd_feature_form input').css("color","#000")
								.css("fontStyle","normal")
								.attr("data-touched","1");
	
	// Parse JSON to Object and fill form accordingly
	feature = JSON.parse(feature_json);
	$('#bdd_feature_name').val(feature.name);
	
	if(feature.background.steps != null) {
	
		if(feature.background.steps.length > 0) {
			
			// Enable Background Box
			$('#toggleBackgroundBoxBtn').click();	
			
			// Before setting the background step data remove or add step inputs
			if(feature.background.steps.length < 4) {
				
				max = 4 - feature.background.steps.length;
				
				for(var c = 0; c < max; c++) {
					$('#bdd_scenario_background_box').find(".bdd_scenario_outline_step").last().remove();
				}
				
			} else if(feature.background.steps.length > 4) {
				
				max = feature.background.steps.length - 4;
				for(var c = 0; c < max; c++) {
					$('#bdd_scenario_background_box').find(".bdd_scenario_outline_step").last().clone().appendTo($('#bdd_scenario_background_box'));
				} 
			}
			
			for(var h = 0; h < feature.background.steps.length; h++) {
				step = feature.background.steps[h];
				step_chunks = step.split("#");
				step_keyword = step_chunks[0];
				step_text = step_chunks[1];
				
				// Set selected option for current keyword
				$('#bdd_scenario_background_box')
							 .find("select:nth("+h.toString()+")")
							 .find("option:nth("+scenarioStepKeywordToIndex(step_keyword)+")")
							 .prop('selected',true);
				
				// Set input text for steps
				$('#bdd_scenario_background_box').find("input:nth("+h.toString()+")").val(step_text);
			}
				
		}
	}
	// Before setting the feature outline text remove or add required inputs
	if(feature.description.length < 4) {
		
		max = 4 - feature.description.length;
		for(var c = 0; c < max; c++) {
			$(".bdd_feature_outline").last().remove();	
		}
		
	} else if(feature.description.length > 4) {
		max = feature.description.length - 4;
		for(var c = 0; c < max; c++) {
			addFeatureOutline();
		}
	}
	
	for(var i = 0; i < feature.description.length; i++) {
		outline_name = "bdd_feature_outline_"+(i+1).toString();
		$('input[name='+outline_name+']').val(feature.description[i]);	
	}
	
	// Dynamically generate Scenario boxes
	scenario_tpl = $("#bdd_scenario_box").clone();
	scenario_tpl.attr("id","");
	$("#bdd_scenario_box").remove();
	
	bdd_scenario_box_id_set = false;
	
	for(var j = 0; j < feature.scenarios.length; j++) {
		
		scenario = feature.scenarios[j];
		scenario_view = scenario_tpl.clone();
		
		// Before setting the step data remove or add step inputs
		if(scenario.steps.length < 4) {
			
			max = 4 - scenario.steps.length;
			
			for(var c = 0; c < max; c++) {
				scenario_view.find(".bdd_scenario_outline_step").last().remove();
			}
			
		} else if(scenario.steps.length > 4) {
			
			max = scenario.steps.length - 4;
			for(var c = 0; c < max; c++) {
				scenario_view.find(".bdd_scenario_outline_step").last().clone().appendTo(scenario_view);
			} 
		}
		
		scenario_view.find("input:nth(0)").val(scenario.name);
		
		for(var k = 0; k < scenario.steps.length; k++) {
			step = scenario.steps[k];
			step_chunks = step.split("#");
			step_keyword = step_chunks[0];
			step_text = step_chunks[1];
			
			// Set selected option for current keyword
			scenario_view.find("select:nth("+k.toString()+")")
						 .find("option:nth("+scenarioStepKeywordToIndex(step_keyword)+")")
						 .prop('selected',true);
			
			// Set input text for steps
			scenario_view.find("input:nth("+(k+1).toString()+")").val(step_text);
		}
		
		if(bdd_scenario_box_id_set == false) {
			scenario_view.attr("id","bdd_scenario_box");
			bdd_scenario_box_id_set = true;
		}
		
		// Add populated view to form
		scenario_view.appendTo("#bdd_feature_form");
		$('<br/>').appendTo("#bdd_feature_form");
		scenario_view.show();
	}
	
}

function scenarioStepKeywordToIndex(word) {
	keywords = ["Given","When","Then","And","But"];
	return keywords.indexOf(word);
}


function addFeatureOutline(){
	
	var clone = $(".bdd_feature_outline:nth(0)").clone();
	clone.val("...");
	
	var last = $(".bdd_feature_outline").last();
	
	clone.insertAfter(last);
	
	last = $(".bdd_feature_outline").last();
	$("<br/>").insertBefore(last);
		
	clone.show();

}

function removeFeatureOutline() {
	$(".bdd_feature_outline").last().remove();
	$("#bdd_feature_outline").find("br").last().remove();
}

function removeScenario(event) {
	if($(".bdd_scenario_container").length > 1) {
		// One Scenario should remain
		$(".bdd_scenario_container").last().remove();
	}
	event.preventDefault();
}

function addScenarioStep(button) {
	var clone = $(button).parent().find(".bdd_scenario_outline_step").last().clone();	
	clone.find("input").last().val("...");
	clone.appendTo($(button).parent());
}

function removeScenarioStep(button) {
	$(button).parent().find(".bdd_scenario_outline_step").last().remove();	
}


/**
 * Toggles the Background Box to allow
 * editing of the text or not
 * 
 * @param onClick event
 */
function toggleScenarioBackgroundBox(event) {
	console.log("Toggling Background");
	var value = '';
	
	if($('.bdd_scenario_background_container').attr('data-toggle')=='0') {
		// Enable Box
		value = '1';
		data = '1';
		
		$('#bdd_scenario_background_box img').each(function(obj,i){
			$(this).removeClass('bdd_click_image_dis');
			$(this).addClass('bdd_click_image');
		});
		
		$('#bdd_scenario_background_box input').each(function(obj,i){
			$(this).attr('disabled',false);
		});
		
		$('#bdd_scenario_background_box select').each(function(obj,i){
			$(this).attr('disabled',false);
		});	
	} else {
		// Disable Box
		value = '0.4';
		data = '0';
		
		$('#bdd_scenario_background_box img').each(function(obj,i){
			$(this).removeClass('bdd_click_image');
			$(this).addClass('bdd_click_image_dis');
		});
		
		$('#bdd_scenario_background_box input').each(function(obj,i){
			$(obj).attr('disabled',true);
		});
		
		$('#bdd_scenario_background_box select').each(function(obj,i){
			$(obj).attr('disabled',true);
		});
	}
	$('.bdd_scenario_background_container').css('opacity',value);
	$('.bdd_scenario_background_container').attr('data-toggle',data);
	console.log("New Value "+value.toString());
	event.preventDefault();
}
