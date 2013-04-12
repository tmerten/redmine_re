function initIssueSuggestibles(suggestionsUrl, bitsUrl) {
		
              // hidden on init because of UJS
              $('#issue_filter_input_nojs').remove();
              $('#issue_filter .inputs').show();

              $('#issue_filter_input').suggestible(suggestibleOptions({
                  suggestionsUrl: suggestionsUrl,
                  suggestionsLayout: function(helpers) {
                  return new IssuesSuggestBoxItems(helpers);
              },
              bitsUrl: bitsUrl,
              except_ids: null
              }));		
		
}

function initDiagramSuggestibles(suggestionsUrl, bitsUrl) {
		
			  // hidden on init because of UJS
              $('#diagram_filter_input_nojs').remove();
              $('#diagram_filter .inputs').show();

              $('#diagram_filter_input').suggestible(suggestibleOptions({
                  suggestionsUrl: suggestionsUrl,
                  suggestionsLayout: function(helpers) {
                  	return new DiagramsSuggestBoxItems(helpers);
                  },
                  bitsUrl: bitsUrl,
                  except_ids: null
              }));
}

function initRelationSuggestibles(suggestionsUrl, exceptIds) {
		
              // hidden on init because of UJS
              $('#relation_filter_input_nojs').remove();
              $('#relation_filter .inputs').show();

              $('#relation_filter_input').suggestible(suggestibleOptions({
                  suggestionsUrl: suggestionsUrl,
                  suggestionsLayout: function(helpers) {
                  	return new DirectArtifactsSuggestBoxItemsForAddingRelations(helpers);
                  },
                  except_ids: exceptIds
              }));
}

(function($) {
	
    window.suggestibleOptions = function(options) {
        return {
            ajax: {
                suggestions: {
                    url: options.suggestionsUrl,
                    dataType: 'json',
                    data: function(value, helpers) {
                        var params = { query: value };
                        
                        var exceptIds = [];
                        if (options.except_ids !== null && options.except_ids != '' ) {
                        	exceptIds.push(options.except_ids);
                        	exceptIds.push(helpers.recordIdsInBits(helpers.elements.bitsBox));
                        } else {
                        	exceptIds = helpers.recordIdsInBits(helpers.elements.bitsBox);
                        }
                        if (exceptIds.length > 0) {
                            params.except_ids = exceptIds;
                        }

                       var except_types = [];
                        if (options.except_types !== null && options.except_types !== '' ) {
                        	except_types.push(options.except_types);
                        	
                        } 
                        if (except_types.length > 0) {
                            params.except_types = except_types;
                        }

                       var only_types = [];
                        if (options.only_types !== null && options.only_types !== '' ) {
                        	only_types.push(options.only_types);
                        	
                        } 
                        if (except_types.length > 0) {
                            params.only_types = only_types;
                        }

                        return params;
                    },
                    loading: function(helpers) {
                        $('#ajax-indicator').show();
                        helpers.elements.textBox.attr('disabled', 'disabled');
                    },
                    loaded: function(helpers) {
                        $('#ajax-indicator').hide();
                        helpers.elements.textBox.removeAttr('disabled');
                    }
                },
                bits: {
                    url: options.bitsUrl,
                    dataType: 'json',
                    data: function(selectBox, helpers) {
                        return { ids: selectBox.val() };
                    },
                    loading: function(helpers) {
                        $.blockUI();
                    },
                    loaded: function(helpers) {
                        helpers.elements.bitsBox.hide().fadeIn('fast');
                    },
                    allLoaded: function(helpers) {
                        $.unblockUI();
                    }
                }
            },

            layout: {
                containers: function(selectBox, options) {
                    return new SuggestBoxContainers(selectBox, options);
                },
                items: options.suggestionsLayout
            },
            primaryKeyFromRecord: function(record) {
                return record.id;
            },
            primaryKeyFromSelectOption: function(selectOption) {
                return selectOption.val();
            }
        }
    };

})(jQuery);