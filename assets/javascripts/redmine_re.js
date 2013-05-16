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
    40 ); /* 40px is an "arbitraty" buffer which removes the main scrollbar on most browsers (tm) */

	var param = getURLParam("visualization_type");
	// output: 123
 
	   function getURLParam(strParamName) {
	      var strReturn = "";
	      var strHref = window.location.href;
	      if ( strHref.indexOf("?") > -1 ) {
	         var strQueryString = strHref.substr(strHref.indexOf("?")).toLowerCase();
	         var aQueryString = strQueryString.split("&");
	         for ( var iParam = 0; iParam < aQueryString.length; iParam++ ){
	            if (aQueryString[iParam].indexOf(strParamName.toLowerCase() + "=") > -1 ) {
	               var aParam = aQueryString[iParam].split("=");
	               strReturn = aParam[1];
	               break;
	            }
	         }
	      }
	      return unescape(strReturn);
	   }
   	if(param == "")
   	{
       	var image = "<img src='../images/comment.png'><br/><img src='../images/fav_off.png'>";
   	}else
   	{
   		var image = "";
   	}
  reLayout = reLayout.layout({
    applyDefaultStyles: true,
    fxSpeed: "fast",
    stateManagement__enabled: true,
    stateManagement__cookie: {
      name:"redmine_re_plugin",
      path:"/"
    },
    togglerAlign_closed:	"top",
    togglerAlign_open:	"top",
    togglerLength_closed: 80,
    togglerLength_open: 80,
    
    west__size: 200,
    west__spacing_closed:	15,
    west__togglerTip_closed: "Show tree",
    west__togglerTip_open: "Hide tree",
    
    east__size: 250,
    east__spacing_closed:	35,
	east__togglerContent_closed: image,
    east__slideTrigger_open: "mouseover",
    east__slideTrigger_close: "mouseout",
    east__initClosed:	true,
  });
  
  $j("#detail_view").click(function () {
    reLayout.close("east");
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

function scrollContentPaneTo(target) {  
	var $Pane = $('#detail_view');
	var $Target = $('#'+target);
	
	var targetTop = $Target.offset().top;
	var paneTop = $Pane.offset().top;
	$Pane.animate({ scrollTop: '+='+ (targetTop - paneTop) +'px' }, 100); 
}