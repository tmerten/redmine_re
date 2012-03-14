(function($) {

    var inputSelector = 'input, select, textarea';

    window.prepareFields = function() {
        $('.field').each(function() {
            var field = $(this);
            var columns = field.find('.value, .actions');

            var modeSelectBox = field.find('.mode').find(inputSelector);
            var processMode = function() {
                var mode = modeSelectBox.val();
                var hiddenModes = ['any', 'some', 'none', 'is_me', 'is_not_me', 'is_public', 'for_me'];
                if ($.inArray(mode, hiddenModes) >= 0) {
                    columns.hide();
                    columns.find(inputSelector).attr('disabled', 'disabled');
                } else {
                    columns.show();
                    columns.find(inputSelector).removeAttr('disabled');
                }
            };
            processMode();
            modeSelectBox.change(function() {
                processMode();
            });

            var valueSelectBox = field.find('.value').find(inputSelector);
            columns.filter('.actions').find('a.select_all, a.unselect_all').click(function() {
                // Closest select/unselect button
                var anchorTag = $(this);
                var selectOptions = valueSelectBox.children();
                if (!valueSelectBox.is(':disabled')) {
                    var valueSelectBoxChanged = false;
                    selectOptions.each(function() {
                        var selectOption = $(this);
                        var selected = selectOption.is(':selected');
                        if (anchorTag.is('.select_all')) {
                            if (!selected) {
                                selectOption.attr('selected', 'selected');
                                valueSelectBoxChanged = true;
                            }
                        } else {
                            if (selected) {
                                selectOption.removeAttr('selected');
                                valueSelectBoxChanged = true;
                            }
                        }
                    });
                    if (valueSelectBoxChanged) {
                        valueSelectBox.trigger('change');
                    }
                }
                return false;
            });

        });
    };

    window.determineOtherFieldsVisibility = function(selectBoxSelector, otherInputsSelector) {
        var selectBox = $(selectBoxSelector);
        var ownField = selectBox.closest('.field');
        var otherInputs = null;
        if (otherInputsSelector) {
            otherInputs = $(otherInputsSelector);
        } else {
            otherInputs = ownField;
        }
        var otherFields = otherInputs.closest('.fields').find('.field').not(ownField);
        var activateOrDeactivate = function() {
            switch (selectBox.val()) {
                case 'any':
                case 'none':
                    otherFields.find(inputSelector).filter(':visible').attr('disabled', 'disabled');
                    otherFields.hide();
                    break;
                default:
                    otherFields.show();
                    otherFields.find(inputSelector).filter(':visible').removeAttr('disabled');
                    break;
            }
        };
        activateOrDeactivate();
        selectBox.change(function() {
            activateOrDeactivate();
        })
    };

    window.suggestibleOptions = function(options) {
        return {
            ajax: {
                suggestions: {
                    url: options.suggestionsUrl,
                    dataType: 'json',
                    data: function(value, helpers) {
                        var params = { query: value };
                        var exceptIds = helpers.recordIdsInBits(helpers.elements.bitsBox);
                        if (exceptIds.length > 0) {
                            params.except_ids = exceptIds;
                        }
                        //var typeField = helpers.elements.inputContainer.closest('.fields').find('.field.type');
                        //var selectedMode = typeField.find('.column.mode select').val();
                        //var selectedTypes = typeField.find('.column.value select').val();
                        //if (selectedTypes && selectedTypes.length > 0) {
                        //    switch (selectedMode) {
                        //        case 'contains':
                        //            params.only_types = selectedTypes;
                        //            break;
                        //        case 'not_contains':
                        //            params.except_types = selectedTypes;
                        //            break;
                        //    }
                        //}
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
            dependencies: function(helpers) {
                var typeField = helpers.elements.inputContainer.closest('.fields').find('.field.type');
                var typeModeSelectBox = typeField.find('.column.mode select');
                var typeSelectBox = typeField.find('.column.value select');
                var result = [];
                if (typeModeSelectBox) {
                    result.push(typeModeSelectBox);
                }
                if (typeSelectBox) {
                    result.push(typeSelectBox);
                }
                return result;
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