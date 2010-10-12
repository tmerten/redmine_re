/*
 This class initializes and slides the bar to the right.

 it uses the css "stylesheets/redmine_re.css" TODO: create my own file
 and the images "images/sidebar/*.gif"
 */
var ReSideBar;
ReSideBar = Class.create({

    initialize: function(id) {
        Event.observe(id, 'click', this.slide, true);
    },

    slide: function() {
        var image_name;
        image_name = $$('#reSideBarTab img')[0].src;
        if ( this.extended === undefined || this.extended === 0) {
            $$('#reSideBarTab img')[0].src = image_name.replace(/(\.[^.]+)$/, '-active$1');
            this.extended = 1;
        }
        else {
            $$('#reSideBarTab img')[0].src = image_name.replace(/-active(\.[^.]+)$/, '$1');
            this.extended = 0;
        }

        new Effect.toggle('reSideBarContents', 'blind', {duration: 0.25, scaleX: 'true', scaleY: 'true;', scaleContent: false});

    }
});
