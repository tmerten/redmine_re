/* resize the layout horizontally on window resize */
$(window).resize(function() {
  $("#content").height( $(window).height() - $("#top-menu").height() - $("#header").height() - $("#footer").height() - 30 );
});

/* global layout variable such that visualizations etc. can use it */
var reLayout = null;

/* render and initialize the layout on page load */
$(document).ready(function() {
    $("#content").css("padding", "0px");

    setLayoutHeight();

    reLayout = $("#content").layout( {
        applyDefaultStyles: true,
        fxSpeed: "fast",
        
        useStateCookie: true,
        cookie__name: "redmine_re_plugin",
        cookie__path : "/",
        
        togglerAlign_closed:	"top",
        togglerAlign_open:	"top",

        west__size: 200,
        west__spacing_closed: 15,
        west__togglerTip_closed: "Show tree",
        west__togglerTip_open: "Hide tree",
        west__togglerLength_closed: 0,
        west__togglerLength_open: 0,

        east__size: 250,
        east__spacing_closed: 35,
        east__togglerContent_closed: getRightPaneImage(),
        east__slideTrigger_open: "mouseover",
        east__slideTrigger_close: "mouseout",
        east__initClosed: true,
        east__togglerLength_closed: 80,
        east__togglerLength_open: 80,
    });

    $("#detail_view").click(function () {
        reLayout.close("east");
    });
});

/*
 * we need to set the window height on resize
 * to make the layouts work
 */
$(window).on("resize", function(){
    setLayoutHeight();
});

/*
 * calculates the wrappers height on page load
 * and on resize events
 */
function setLayoutHeight() {
    $("#content").height(
        $(window).height() -
        $("#top-menu").height() -
        $("#header").height() -
        $("#footer").height() -
        40 /* 40px is an "empirically created buffer" (tm)
            * which removes the main scrollbar on most browsers */
    );
}

function getRightPaneImage() {
    var param = getURLParam("visualization_type");
    if ( param == "" ) {
        return "<img src='/images/comment.png'><br/><img src='/images/fav_off.png'>";
    } else {
        return "";
    }
}

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

function scrollContentPaneTo(target) {  
    var $Pane = $('#detail_view');
    var $Target = $('#'+target);
    var targetTop = $Target.offset().top;
    var paneTop = $Pane.offset().top;
    $Pane.animate({ scrollTop: '+='+ (targetTop - paneTop) +'px' }, 100); 
}