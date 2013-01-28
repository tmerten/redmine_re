/* initialize jQuery's $() as $j() to avoid conflicts with prototype 
   For redmine version already using jquery don't call noConflict 
   as it destroys redmine's $ object*/
//var $j = jQuery.noConflict();
var $j = $;

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

