var ResizingTextArea = Class.create();
ResizingTextArea.prototype = {
    defaultRows: 1,
    initialize: function(field)
    {
        this.defaultRows = Math.max(field.rows, 1);
        this.getResizeElement = this.getResizeElement.bindAsEventListener(this);
        Event.observe(field, "click", this.getResizeElement);
        Event.observe(field, "keyup", this.getResizeElement);
        this.resize(field);
    },

    getResizeElement: function(event)
    {
        var element = Event.element(event);
        this.resize(element);
    },
    
    resize: function(element) {
        var lines = element.value.split('\n');
        var newRows = lines.length + 1;
        var oldRows = element.rows;
        for (var i = 0; i < lines.length; i++)
        {
            var line = lines[i];
            if (line.length >= element.cols) newRows += Math.floor(line.length / element.cols);
        }
        if (newRows > element.rows) element.rows = newRows;
        if (newRows < element.rows) element.rows = Math.max(this.defaultRows, newRows);        
    }
}
