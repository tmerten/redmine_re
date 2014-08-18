/**
 * Add hook to form to serialize form data before sending to server
 */ 
function addHookToForm(hook_type) {
	console.log("adding hook to form...");
	if(hook_type == "new") {
		form_id = "#new_re_artifact_properties";
	} else {
		form_id = "#edit_re_artifact_properties_*";
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
	if(e.getAttribute('data-touched') == '0') {
		e.value = '';
	}	
}

/**
 * Event handler for blur event of the inputs
 */
function handleInputBlurEvent(e) {
	e.style.color = "#000";
	e.style.fontStyle = "normal";
	e.setAttribute("data-touched", "1");	
}

/**
 * Validates the entered data, basic logic checks of the scenario
 * steps. 
 */
function validateFeature() {
	return true;	
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
		
		feature_description = "";
		
		$('.bdd_feature_outline').each(function(i, obj) {
			feature_description = feature_description + $(this).val() + ";";
		});
				
		feature.description = feature_description;
		
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

function getFeatureOutlineElement(string) {
	lines = string.split(";");
	view = '';
	
	for(var i = 0; i < lines.length; i++) {
		view = view + '<div class="bdd_feature_outline">'+lines[i]+'</div>';	
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

function createFeatureViewFormFromJSON(feature_json) {
	
	// Set styles on all inputs to display solid text
	$('#bdd_feature_form input').css("color","#000")
								.css("fontStyle","normal")
								.attr("data-touched","1");
	
	// Parse JSON to Object and fill form accordingly
	feature = JSON.parse(feature_json);
	$('#bdd_feature_name').val(feature.name);
	
	outline_chunks = feature.description.split(";");
	
	// @todo: currently not stable when outline has not == 4 entries
	for(var i = 0; i < outline_chunks.length; i++) {
		outline_name = "bdd_feature_outline_"+(i+1).toString();
		$('input[name='+outline_name+']').val(outline_chunks[i]);	
	}
	
	// Dynamically generate Scenario boxes
	scenario_tpl = $("#bdd_scenario_box").clone();
	scenario_tpl.attr("id","");
	$("#bdd_scenario_box").remove();
	
	for(var j = 0; j < feature.scenarios.length; j++) {
		
		scenario = feature.scenarios[j];
		scenario_view = scenario_tpl.clone();
		
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
		
		// Add populated view to form
		scenario_view.appendTo("#bdd_feature_form");
		$('<br/>').appendTo("#bdd_feature_form");
		scenario_view.show();
	}
	
}

function scenarioStepKeywordToIndex(word) {
	keywords = ["Given","When","Then","And"];
	return keywords.indexOf(word);
}


