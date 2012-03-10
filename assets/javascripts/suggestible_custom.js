(function($) {
    // Creates containers for suggestible inputs
    window.SuggestBoxContainers = function(selectBox, options) {
        var _this = this;
        this.selectBox = selectBox;
        this.options = options;

        var createContainerId = function() {
            var containerId = null;
            if ((_this.options.idPrefix || _this.options.idSuffix) && _this.selectBox.attr('id')) {
                containerId = "";
                if (_this.options.idPrefix) {
                    containerId += _this.options.idPrefix;
                }
                containerId += _this.selectBox.attr('id');
                if (_this.options.idSuffix) {
                    containerId += _this.options.idSuffix;
                }
            }
            return containerId;
        };

        this.createInputContainer = function() {
            var classes = _this.options.classes.inputContainer;
            if (_this.selectBox.attr('class')) {
                classes += ' ' + _this.selectBox.attr('class');
            }
            return $('<div />', { id: createContainerId(), 'class': classes });
        };

        this.createInputWrapper = function() {
            return $('<div />', { 'class': _this.options.classes.inputWrapper });
        };

        this.createBitsBox = function() {
            return $('<ul />', { 'class': _this.options.classes.bitsBox });
        };

        this.createTextBox = function() {
            return $('<input />', {
                'class': _this.options.classes.textBox,
                type: 'text',
                id: _this.selectBox.attr('id'),
                autocomplete: 'off'
            });
        };

        this.createSuggestionsBox = function() {
            return $('<ol />', { 'class': _this.options.classes.suggestionsBox });
        }
    };

    // Encapsulates the creation functions for artifact items
    window.ArtifactsSuggestBoxItems = function(helpers) {
        var _this = this;
        this.helpers = helpers;

        this.createSuggestion = function(record) {
            this.addClass('artifact');
            this.attr('title', record.name);
            $('<span />', { 'class': 'icon ' + record.icon }).appendTo(this);
            $('<span />', { 'class': 'name' }).appendTo(this).html(record.highlighted_name);
            $('<span />', { 'class': 'type' }).appendTo(this).text(record.type_name);
        };

        this.createBit = function(record) {
            var bit = this;
            this.addClass('artifact');
            this.attr('title', record.type_name);
            $('<span />', { 'class': 'icon ' + record.icon }).appendTo(this);

            var nameSpanTag = $('<span />', { 'class': 'name' });
            var nameAnchorTag = $('<a />', { 'href': record.url });
            nameAnchorTag.text(record.name).appendTo(nameSpanTag);
            nameAnchorTag
                .mouseover(function() {
                    bit.addClass('focus');
                })
                .mouseout(function() {
                    bit.removeClass('focus');
                });
            nameSpanTag.appendTo(bit);

            var closeSpanTag = $('<span />', { 'class': 'close' }).text('×');
            closeSpanTag.appendTo(bit);
            closeSpanTag.click(function() {
                _this.helpers.removeItemFromBits(bit, function() { _this.helpers.elements.textBox.focus(); });
                return false;
            });

            return true;
        };
    };

    // Encapsulates the creation functions for issue items
    window.IssuesSuggestBoxItems = function(helpers) {
        var _this = this;
        this.helpers = helpers;

        this.createSuggestion = function(record) {
            this.addClass('issue');
            this.attr('title', record.subject);
            $('<span />', { 'class': 'id' }).appendTo(this).text('#' + record.id);
            $('<span />', { 'class': 'name' }).appendTo(this).html(record.highlighted_name);
        };

        this.createBit = function(record) {
            var bit = this;
            this.addClass('issue');
            this.attr('title', record.subject);
            $('<span />', { 'class': 'id' }).text('#' + record.id).appendTo(this);

            var nameSpanTag = $('<span />', { 'class': 'name' });
            var nameAnchorTag = $('<a />', { 'href': record.url });
            nameAnchorTag.appendTo(nameSpanTag).text(record.subject);
            nameAnchorTag
                .mouseover(function() {
                    bit.addClass('focus');
                })
                .mouseout(function() {
                    bit.removeClass('focus');
                });
            nameSpanTag.appendTo(bit);

            var closeSpanTag = $('<span />', { 'class': 'close' }).text('×');
            closeSpanTag.appendTo(bit);
            closeSpanTag.click(function() {
                _this.helpers.removeItemFromBits(bit, function() { _this.helpers.elements.textBox.focus(); });
                return false;
            });

            return true;
        };
    };

    // Encapsulates the creation functions for user items
    window.UsersSuggestBoxItems = function(helpers) {
        var _this = this;
        this.helpers = helpers;

        this.createSuggestion = function(record) {
            this.addClass('user');
            this.attr('title', record.full_name);
            $('<span />', { 'class': 'name' }).appendTo(this).html(record.highlighted_full_name);
            $('<span />', { 'class': 'login' }).appendTo(this).html(record.highlighted_login);
        };

        this.createBit = function(record) {
            var bit = this;
            this.addClass('user');
            this.attr('title', record.login);

            var nameSpanTag = $('<span />', { 'class': 'name' });
            var nameAnchorTag = $('<a />', { 'href': record.url });
            nameAnchorTag.appendTo(nameSpanTag);
            nameAnchorTag.text(record.full_name);
            nameAnchorTag
                .mouseover(function() {
                    bit.addClass('focus');
                })
                .mouseout(function() {
                    bit.removeClass('focus');
                });
            nameSpanTag.appendTo(bit);

            var closeSpanTag = $('<span />', { 'class': 'close' }).text('×');
            closeSpanTag.appendTo(bit);
            closeSpanTag.click(function() {
                _this.helpers.removeItemFromBits(bit, function() { _this.helpers.elements.textBox.focus(); });
                return false;
            });

            return true;
        };
    };

    // Encapsulates the creation functions for directly selectable artifact items
    window.DirectArtifactsSuggestBoxItems = function(helpers) {
        this.helpers = helpers;

        this.createSuggestion = function(record) {
            this.addClass('artifact');
            this.attr('title', record.name);
            $('<span />', { 'class': 'icon ' + record.icon }).appendTo(this);
            $('<span />', { 'class': 'name' }).appendTo(this).html(record.highlighted_name);
            $('<span />', { 'class': 'type' }).appendTo(this).text(record.type_name);
            this.click(function() {
                $.blockUI();
                document.location = record.url;
                return false;
            });
            helpers.elements.textBox.keydown(function(event) {
                if ((event.keyCode == 9 || event.keyCode == 13) && helpers.hasSelectedSuggestion()) {
                    $.blockUI();
                    document.location = helpers.selectedSuggestion().data('record').url;
                }
            })
        };

        this.createBit = function(record) {
            return false;
        };
    };
})(jQuery);