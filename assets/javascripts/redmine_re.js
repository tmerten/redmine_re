/* initialize jQuery's $() as $j() to avoid conflicts with prototype */
var $j = jQuery.noConflict();

/* resize the layout horizontally on window resize */
$j(window).resize(function() {
  $j("#content").height( $j(window).height() - $j("#top-menu").height() - $j("#header").height() - $j("#footer").height() - 30 );
});
/* global layout variable such that visualizations etc. can use it */
var reLayout = null;

/* render and initialize the layout on page load */
$j(document).ready(function () {
  reLayout = $j("#content");
  reLayout.css("padding", "0px");
  reLayout.height(
    $j(window).height() -
    $j("#top-menu").height() -
    $j("#header").height() -
    $j("#footer").height() -
    30 ); /* 30px is an "arbitraty" buffer which seems to work (tm) */

  reLayout.layout({
    west__size: 200,
    applyDefaultStyles: true,
    stateManagement__enabled: true,
    stateManagement__cookie: {
      name:"redmine_re_plugin",
      path:"/"
    },
    west__togglerTip_closed: "show tree",
    west__togglerTip_open: "hide tree"
  });
});

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

function observeParentArtifactField(url) {
  new Ajax.Autocompleter('issue_parent_issue_id',
   'parent_artifact_candidates',
   url,
   { minChars: 3,
     frequency: 0.5,
     paramName: 'q',
     updateElement: function(value) {
       document.getElementById('issue_parent_issue_id').value = value.id;
   }
  });
}

