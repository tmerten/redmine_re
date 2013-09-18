// jQuery Plugin for creating a text box with AJAX suggestions and select functionality

(function($) {

    $.suggestible = function() {};
    // jQuery object is extended with a suggestible function
    $.extend($.suggestible, {
        ajax: {
            bits: {
                url: null,
                method: 'get',
                dataType: 'json',
                data: function(selectBox, helpers) { return null; },
                loading: function(helpers) {},
                loaded: function(helpers) {}
            },
            suggestions: {
                url: null,
                method: 'get',
                dataType: 'json',
                data: function(value, helpers) { return null; },
                loading: function(helpers) {},
                loaded: function(helpers) {},
                allLoaded: function(helpers) {}
            }
        },
        primaryKeyFromRecord: function(record) { return null; },
        primaryKeyFromSelectOption: function(selectOption) { return null; },
        classes: {
            inputContainer: 'input_container suggestible',
            inputWrapper: 'input',
            bitsBox: 'bits',
            bit: 'bit',
            textBox: null,
            suggestionsBox: 'suggestions',
            suggestion: 'suggestion',
            suggestionFocus: 'focus'
        },
        layout: {
            containers: function(selectBox, options) {
                return null;
            },
            items: function(helpers) {
                return null;
            }
        },
        dependencies: function(helpers) {
            return null;
        },
        idPrefix: null,
        idSuffix: '_container',
        pageStep: 5,
        prepopulated: false,
        textBoxDelay: 700
    });

    var createHtmlElements = function(selectBox, options) {
        var containerLayout = options.layout.containers(selectBox, options);

        var inputContainer = containerLayout.createInputContainer();
        var inputWrapper = containerLayout.createInputWrapper();
        var bitsBox = containerLayout.createBitsBox();
        var textBox = containerLayout.createTextBox();
        var suggestionsBox = containerLayout.createSuggestionsBox();

        bitsBox.appendTo(inputWrapper);
        textBox.appendTo(inputWrapper);
        inputWrapper.appendTo(inputContainer);
        suggestionsBox.appendTo(inputContainer);

        return {
            inputName: selectBox.attr('name'),
            inputContainer: inputContainer,
            inputWrapper: inputWrapper,
            bitsBox: bitsBox,
            textBox: textBox,
            textBoxTimeout: null,
            suggestionsBox: suggestionsBox
        };
    };

    $.fn.suggestible = function(options) {
        options = $.extend(true, {}, $.suggestible, options);

        var resultElements = [];

        // Find fields and substitute
        this.filter('select[multiple]').each(function(index) {
            var selectBox = $(this);

            var elements = createHtmlElements(selectBox, options);
            var helpers = new Helpers(elements, options);

            // Hide all suggestion boxes from the beginning
            elements.suggestionsBox.hide();

            // When clicked on the input wrapper, the contained text box will be focused
            elements.inputWrapper.click(function() { elements.textBox.focus(); });

            // Determine default values by getting prepopulated options
            if (options.ajax.bits.url) {
                helpers.preloadBits(selectBox);
            }

            // Replace select box with artifact suggest box
            selectBox.replaceWith(elements.inputContainer);

            // Detect dependency changes
            helpers.detectDependencyChange();

            // Input events for suggestions box
            elements.textBox
                .keydown(function(event) {
                  switch (event.keyCode) {
                    case 8: // backspace
                      // If nothing is selected and cursor position is at 0, then remove last bit on backspace keystroke
                      if (this.selectionStart == 0 && this.selectionStart == this.selectionEnd) {
                        helpers.removeItemFromBits(elements.bitsBox.children(':last'));
                        helpers.hideSuggestionsBox();
                        return false;
                      }
                      return true;
                    case 9:  // tab
                    case 13: // enter
                      var suggestionsHidden = elements.suggestionsBox.is(':hidden');
                      if (helpers.hasSuggestions(elements.suggestionsBox)) {
                        if (helpers.hasSelectedSuggestion(elements.suggestionsBox)) {
                          helpers.addSelectedSuggestionToBits();
                          helpers.hideSuggestionsBox();
                        } else {
                          if (event.keyCode == 9) {
                            return true;
                          }
                        }
                      }
                      return suggestionsHidden;
                    case 27: // esc
                      helpers.hideSuggestionsBox();
                      return false;
                    case 33: // page up
                    case 34: // page down
                    case 35: // end
                    case 36: // pos1
                    case 38: // up
                    case 40: // down
                      if (helpers.hasSuggestions(elements.suggestionsBox)) {
                        if (elements.suggestionsBox.is(':visible')) {
                          switch (event.keyCode) {
                            case 33:
                              if (elements.suggestionsBox.data('selected') <= 0) {
                                helpers.selectSuggestion(-1, true);
                              } else {
                                helpers.selectSuggestionDiff(-options.pageStep, false);
                              }
                              break;
                            case 34:
                              if (elements.suggestionsBox.data('selected') < 0 ||
                                  elements.suggestionsBox.data('selected') == elements.suggestionsBox.children().length - 1) {
                                helpers.selectSuggestion(0, false);
                              } else {
                                helpers.selectSuggestionDiff(options.pageStep, false);
                              }
                              break;
                            case 35:
                              if (helpers.hasSelectedSuggestion()) {
                                helpers.selectSuggestion(-1, true);
                              } else {
                                return true;
                              }
                              break;
                            case 36:
                              if (helpers.hasSelectedSuggestion()) {
                                helpers.selectSuggestion(0, false);
                              } else {
                                return true;
                              }
                              break;
                            case 38:
                              if (elements.suggestionsBox.data('selected') < 0) {
                                helpers.selectSuggestion(-1, true);
                              } else {
                                helpers.selectSuggestionDiff(-1, true);
                              }
                              break;
                            case 40:
                              helpers.selectSuggestionDiff(1, true);
                              break;
                          }
                        } else {
                          // Displays the selection box on arrow up or down keystroke
                          // unless it is not already visible
                          if (event.keyCode == 35 || event.keyCode == 36) {
                            return true;
                          } else {
                            helpers.showSuggestionsBox();
                          }
                        }
                      } else {
                        if (event.keyCode == 35 || event.keyCode == 36) {
                          return true;
                        }
                      }
                      return false;
                  }
                })
                .keyup(function() {
                    if (elements.textBox.val() != elements.textBox.data('oldValue')) {
                        window.clearTimeout(elements.textBoxTimeout);
                        elements.textBoxTimeout = window.setTimeout(function() {
                            helpers.showSuggestionsOrReloadIfChanged();
                        }, options.textBoxDelay);
                    }
                })
                .focus(function() {
                    elements.inputContainer.trigger('focus');
                    helpers.showSuggestionsOrReloadIfChanged();
                })
                .blur(function() {
                    elements.inputContainer.trigger('blur');
                    helpers.hideSuggestionsBox();
                });

            // Make all elements and some helpers publicly available on the specific container
            // (so manipulation can be easily done from the outside)
            elements.inputContainer.data('elements', elements);
            elements.inputContainer.data('helpers', helpers);

            // Add container to result elements
            resultElements[index] = elements.inputContainer[0];
        });

        // Return Array of input containers to preserve chainability
        return $(resultElements);
    };

    function Helpers(elements, options) {
        var _this = this;
        this.elements = elements;
        this.options = options;

        this.preloadBits = function(selectBox, callback) {
            $(_this.elements.bitsBox)
                .ajaxStop(function() {
                    _this.options.ajax.bits.allLoaded(_this);
                });

            var values = selectBox.val();
            if (values) {
                _this.options.ajax.bits.loading(_this);
                $.ajax({
                    url: _this.options.ajax.bits.url,
                    method: _this.options.ajax.bits.method,
                    data: _this.options.ajax.bits.data(selectBox, _this),
                    dataType: _this.options.ajax.bits.dataType,
                    success: function(records) {
                        if (records.length > 0) {
                            $.each(records, function() {
                                _this.addItemToBits(this);
                            });
                        }
                    },
                    complete: function() {
                        _this.options.ajax.bits.loaded(_this);
                        if (callback) {
                            callback();
                        }
                    }
                });
            } else {
                if (callback) {
                    callback();
                }
            }
        };

        this.showSuggestionsOrReloadIfChanged = function(callback) {
            if (_this.textHasChanged() || _this.bitsHaveChanged() || _this.dependenciesHaveChanged()) {
                _this.loadAndShowSuggestions(callback);
            } else {
                if (_this.hasSuggestions()) {
                    _this.showSuggestionsBox(callback);
                }
            }
        };

        this.loadAndShowSuggestions = function(callback) {
            var value = _this.elements.textBox.val();
            if (value && value != '') {
                _this.options.ajax.suggestions.loading(_this);
                if (_this.options.prepopulated) {
                    // TODO Prepopulated Behavior
                    _this.clearAndHideSuggestionsBox();
                    _this.options.ajax.suggestions.loaded(_this);
                    if (callback) {
                        callback();
                    }
                } else {
                    // AJAX request
                    $.ajax({
                        url: _this.options.ajax.suggestions.url,
                        method: _this.options.ajax.suggestions.method,
                        data: _this.options.ajax.suggestions.data(value, _this),
                        dataType: _this.options.ajax.suggestions.dataType,
                        success: function(records) {
                            if (records.length > 0) {
                                // Populate and show suggestions box if records were found
                                _this.clearSuggestionsBox();
                                _this.populateSuggestionsBox(records);
                                _this.showSuggestionsBox();
                            } else {
                                _this.hideSuggestionsBox();
                            }
                        },
                        complete: function() {
                            _this.options.ajax.suggestions.loaded(_this);
                            _this.elements.textBox.focus();
                            if (callback) {
                                callback();
                            }
                        }
                    });
                }
                _this.elements.textBox.data('oldValue', value);
            } else {
                _this.clearAndHideSuggestionsBox(callback);
                _this.elements.textBox.data('oldValue', null);
            }
            _this.elements.bitsBox.data('changed', false);
            _this.elements.inputContainer.data('dependenciesChanged', false);
        };

        this.populateSuggestionsBox = function(records) {
            $.each(records, function(index) {
                var suggestion = _this.createSuggestion(this);
                suggestion
                    .appendTo(_this.elements.suggestionsBox)
                    .mouseover(function() { _this.selectSuggestion(index, false); })
                    .mouseout(function() { _this.unselectAllSuggestions(); })
                    .click(function() { _this.addSuggestionToBits(suggestion); });
            });
        };

        this.selectSuggestion = function(index, cycle) {
            var suggestions = _this.elements.suggestionsBox.children();
            var targetIndex = null;
            if (cycle) {
              targetIndex = ((index % suggestions.length) + suggestions.length) % suggestions.length; // modulo fix
            } else {
                if (index < 0) {
                    targetIndex = 0;
                } else if (index >= suggestions.length) {
                    targetIndex = suggestions.length - 1;
                } else {
                    targetIndex = index;
                }
            }
            _this.elements.suggestionsBox.data('selected', targetIndex);
            suggestions.removeClass(_this.options.classes.suggestionFocus);
            $(suggestions[targetIndex]).addClass(_this.options.classes.suggestionFocus);
        };

        this.selectSuggestionDiff = function(diffIndex, cycle) {
            var targetIndex = _this.elements.suggestionsBox.data('selected') + diffIndex;
            _this.selectSuggestion(targetIndex, cycle);
        };

        this.unselectAllSuggestions = function() {
            _this.elements.suggestionsBox.data('selected', -1);
            _this.elements.suggestionsBox.children().removeClass(_this.options.classes.suggestionFocus);
        };

        this.hasSuggestions = function() {
            return _this.elements.suggestionsBox.children().length > 0
        };

        this.hasSelectedSuggestion = function() {
            return _this.elements.suggestionsBox.data('selected') >= 0;
        };

        this.selectedSuggestion = function() {
            var index = _this.elements.suggestionsBox.data('selected');
            if (!index || index < 0) {
              index = 0;
            }
            return $(_this.elements.suggestionsBox.children()[index]);
        };

        this.showSuggestionsBox = function(callback) {
            if (_this.elements.suggestionsBox.is(':visible')) {
                if (callback) {
                    callback();
                }
                return;
            }
             
            _this.unselectAllSuggestions();
            _this.elements.suggestionsBox.css({
                top: _this.elements.inputWrapper.outerHeight(),
                width: _this.elements.inputWrapper.parent().width()                               
            });
            
            _this.elements.suggestionsBox.fadeIn('fast', function() {
                if (callback) {
                    callback();
                }
            });
        };

        this.hideSuggestionsBox = function(callback) {
            _this.elements.suggestionsBox.fadeOut('fast', function() {
                _this.unselectAllSuggestions();
                if (callback) {
                    callback();
                }
            });
        };

        this.clearSuggestionsBox = function(callback) {
            _this.elements.suggestionsBox.children().remove();
            if (callback) {
                callback();
            }
        };

        this.clearAndHideSuggestionsBox = function(callback) {
            _this.elements.suggestionsBox.fadeOut('fast', function() {
                _this.clearSuggestionsBox();
                _this.unselectAllSuggestions();
                if (callback) {
                    callback();
                }
            });
        };

        this.addItemToBits = function(record, callback) {
            var bit = this.createBit(record);
            if (bit) {
                bit.appendTo(_this.elements.bitsBox);
            }
            if (callback) {
                callback();
            }
        };

        this.addSuggestionToBits = function(suggestion, callback) {
            _this.elements.bitsBox.data('changed', true);
            _this.addItemToBits(suggestion.data('record'));
            this.resetTextBox();
            this.clearAndHideSuggestionsBox(function() {
                _this.elements.textBox.focus();
                if (callback) {
                    callback();
                }
            });
            return false;
        };

        this.addSelectedSuggestionToBits = function(callback) {
            _this.addSuggestionToBits(_this.selectedSuggestion());
        };

        this.removeItemFromBits = function(bit, callback) {
            bit.remove();
            _this.elements.bitsBox.data('changed', true);
            _this.loadAndShowSuggestions(callback);
        };

        this.recordIdsInBits = function(bits) {
            var ids = [];
            var i = 0;
            bits.children().each(function() {
                ids[i++] = $(this).data('record').id;
            });
            return ids;
        };

        this.resetTextBox = function() {
           _this.elements.textBox.data('oldValue', null).val('');
        };

        this.bitsHaveChanged = function() {
            return _this.elements.bitsBox.data('changed')
        };

        this.textHasChanged = function() {
            return _this.elements.textBox.data('oldValue') != _this.elements.textBox.val();
        };

        this.createBit = function(record) {
            var bit = $('<li />', { 'class': _this.options.classes.bit });
            $('<input />', {
                type: 'hidden',
                name: _this.elements.inputName,
                value: _this.options.primaryKeyFromRecord(record)
            }).appendTo(bit);
            var returnVal = _this.options.layout.items(_this).createBit.call(bit, record);
            if (returnVal) {
                bit.data('record', record);
                return bit;
            } else {
                return false;
            }
        };

        this.createBitFromSelectOption = function(selectOption) {
            var record = { id: selectOption.val() };
            // TODO
            _this.options.layout.items(_this).bitRecordFromOption.call(record, selectOption);
            return this.createBit(record);
        };

        this.createSuggestion = function(record) {
            var suggestion = $('<li />', { 'class': _this.options.classes.suggestion });
            _this.options.layout.items(_this).createSuggestion.call(suggestion, record);
            suggestion.data('record', record);
            return suggestion;
        };

        this.detectDependencyChange = function() {
            var dependencies = _this.options.dependencies(_this);
            if (!dependencies) {
                return;
            }
            $.each(dependencies, function() {
                if (this && this.length > 0) {
                    this.bind('change', function() {
                        _this.elements.inputContainer.data('dependenciesChanged', true);
                    });
                }
            });
        };

        this.dependenciesHaveChanged = function() {
            return _this.elements.inputContainer.data('dependenciesChanged');
        };
    }

})(jQuery);