
/*
This class initializes and slides the bar to the right.

it uses the css "stylesheets/redmine_re.css" TODO: create my own file
and the images "images/sidebar/*.gif"
 */
var ReSideBar;
ReSideBar = Class.create({

    isExtended : false,
    
    initialize: function(id) {
        Event.observe(id, 'click', this.slide, true);
        this.isExtended = 0;
    },

    slide: function() {
        new Effect.toggle('reSideBarContents', 'blind', {duration: 0.25, scaleX: 'true', scaleY: 'true;', scaleContent: false});
        if (this.isExtended == 0) {
            $('reSideBarTab').childNodes[0].src = $('reSideBarTab').childNodes[0].src.replace(/(\.[^.]+)$/, '-active$1');
            /*$('reSideBarTab').CHANGEWIDTH TODO */
            new Effect.Fade('reSideBarContents', { duration:0.25, from:0.0, to:1.0 });
            this.isExtended ++;
        }
        else {
            $('reSideBarTab').childNodes[0].src = $('reSideBarTab').childNodes[0].src.replace(/-active(\.[^.]+)$/, '$1');
            new Effect.Fade('reSideBarContents', { duration:0.25, from:1.0, to:0.0 });
            this.isExtended = 0;
        }
    }
});
