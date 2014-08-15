/**
 * Add hook to form to serialize form data before sending to server
 */ 
function addHookToForm() {
	$("#new_re_artifact_properties").submit(function(event){
		try {
			serializeFormToJSON();
		} catch (e) {
			console.log("Could not serialize data"+e.toString());
		}
		//event.preventDefault(); // todo remove for production
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