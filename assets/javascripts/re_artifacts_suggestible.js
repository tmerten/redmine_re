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
                        if (options.except_ids !== null && options.except_ids !== '' ) {
                        	exceptIds.push(options.except_ids);
                        	
                        } else {
                        	exceptIds = helpers.recordIdsInBits(helpers.elements.bitsBox);
                        }
                        if (exceptIds.length > 0) {
                            params.except_ids = exceptIds;
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