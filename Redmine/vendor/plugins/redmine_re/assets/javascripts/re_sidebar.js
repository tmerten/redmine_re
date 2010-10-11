var ReSideBar;

/*
This
 */
ReSideBar = Class.create({

    isExtended : false,
    
    initialize: function(id) {
        Event.observe(id, 'click', this.slide, true);
        this.isExtended = 0;
    },

    slide: function() {
        new Effect.toggle('reSideBarContents', 'blind', {duration: 0.0, scaleX: 'true', scaleY: 'true;', scaleContent: false});
        if (this.isExtended == 0) {
            $('reSideBarTab').childNodes[0].src = $('reSideBarTab').childNodes[0].src.replace(/(\.[^.]+)$/, '-active$1');
            new Effect.Fade('reSideBarContents',
            { duration:0.25, from:0.0, to:1.0 });
            this.isExtended = 1;
        }
        else {
            $('reSideBarTab').childNodes[0].src = $('reSideBarTab').childNodes[0].src.replace(/-active(\.[^.]+)$/, '$1');
            new Effect.Fade('reSideBarContents',
            { duration:0.25, from:1.0, to:0.0 });
            this.isExtended = 0;
        }
    }
});
