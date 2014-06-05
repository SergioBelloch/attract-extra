ExtendedObjects <- {
    VERSION = 1.3,
    callbacks = [],
    layers = [],
    objects = [],
    add_callback = function (i, f) { callbacks.append(ExtendedCallback(i, f)); },
    run_callback = function(func, params) { local busy = false; foreach(cb in callbacks) { if (func in cb.i) { if (cb.i[func](params) == true) busy = true; } } return busy; },
    add = function(o) { objects.append(o); run_callback("onObjectAdded", { object = o } ); return o; }
    add_text = function(id, t, x, y, w, h, layer = null) { return add(ExtendedText(id, t, x, y, w, h, layer)); },
    add_image = function(id, i, x, y, w, h, layer = null) { return add(ExtendedImage(id, i, x, y, w, h, layer)); },
    add_artwork = function(id, a, x, y, w, h, layer = null) { return add(ExtendedArtwork(id, a, x, y, w, h, layer)); },
    add_listbox = function(id, x, y, w, h, layer = null) { return add(ExtendedListBox(id, x, y, w, h, layer)); },
    get = function(id) { foreach (o in objects) { if (o.id == id) return o; } return null; },
}

//create surface layers we will draw on
Layer <- { Back = 0, Middle = 1, Front = 2 }
if (FeVersionNum >= 130) {
    for (local i = 0; i < 3; i++) {
        ExtendedObjects.layers.append(fe.add_surface(fe.layout.width, fe.layout.height));
    }
}

const OFFSCREEN = 20;
TRANSITIONS <- ["StartLayout", "EndLayout", "ToNewSelection", "FromOldSelection", "ToGame", "FromGame", "ToNewList"];

POSITIONS <- {
    centerX = function() { return fe.layout.width / 2; },
    centerY = function() { return fe.layout.height / 2; },
    screenPercentX = function(p) { return (p.tofloat() / 100) * fe.layout.width; },   
    screenPercentY = function(p) { return (p.tofloat() / 100) * fe.layout.height; },   
    start = function(o) { return [ o.config.start_x, o.config.start_y ]; },
    last = function(o) { if ("last_x" in o.config == false || "last_y" in o.config == false) return start(o); return [ o.config.last_x, o.config.last_y ]; },
    current = function(o) { return [ o.getX(), o.getY() ]; },
    center = function(o) { return [ centerX() - (o.getWidth() / 2), centerY() - (o.getHeight() / 2) ]; },
    top = function(o) { return [ centerX() - (o.getWidth() / 2), 0 ]; },
    left = function(o) { return [ 0, centerY() - (o.getHeight() / 2) ]; },
    bottom = function(o) { return [ centerX() - (o.getWidth() / 2), fe.layout.height - o.getHeight() ]; },
    right = function(o) { return [ fe.layout.width - o.getWidth(), centerY() - (o.getHeight() / 2) ]; },
    topleft = function(o) { return [ 0, 0 ]; },
    topright = function(o) { return [ fe.layout.width - o.getWidth(), 0 ]; },
    bottomleft = function(o) { return [ 0, fe.layout.height - o.getHeight() ]; },
    bottomright = function(o) { return [ fe.layout.width - o.getWidth(), fe.layout.height - o.getHeight() ]; },
    midtop = function(o) { return [ centerX() - (o.getWidth() / 2), (centerY() / 2) - (o.getHeight() / 2) ] },
    midbottom = function(o) { return [ centerX() - (o.getWidth() / 2), centerY() + (centerY() / 2) - (o.getHeight() / 2) ] },
    midleft = function(o) { return [ (centerX() / 2) - (o.getWidth() / 2), centerY() - (o.getHeight() / 2)  ] },
    midright = function(o) { return [ centerX() + (centerX() / 2) - (o.getWidth() / 2), centerY() - (o.getHeight() / 2) ] },
    midtopleft = function(o) { return [ (centerX() / 2) - (o.getWidth() / 2), (centerY() / 2) - (o.getHeight() / 2) ] },
    midbottomleft = function(o) { return [ (centerX() / 2) - (o.getWidth() / 2), centerY() + (centerY() / 2) - (o.getHeight() / 2) ] },
    midtopright = function(o) { return [ centerX() + (centerX() / 2) - (o.getWidth() / 2), (centerY() / 2) - (o.getHeight() / 2) ] },
    midbottomright = function(o) { return [ centerX() + (centerX() / 2) - (o.getWidth() / 2), centerY() + (centerY() / 2) - (o.getHeight() / 2) ] },
    offmidtopleftx = function(o) { return [ -o.getWidth() - OFFSCREEN, (centerY() / 2) - (o.getHeight() / 2) ] },
    offmidtoplefty = function(o) { return [ (centerX() / 2) - (o.getWidth() / 2), -o.getHeight() - OFFSCREEN ] },
    offmidbottomleftx = function(o) { return [ -o.getWidth() - OFFSCREEN, centerY() + (centerY() / 2) - (o.getHeight() / 2) ] },
    offmidbottomlefty = function(o) { return [ (centerX() / 2) - (o.getWidth() / 2), fe.layout.height + OFFSCREEN ] },
    offmidtoprightx = function(o) { return [ fe.layout.width + OFFSCREEN, (centerY() / 2) - (o.getHeight() / 2) ] },
    offmidtoprighty = function(o) { return [ centerX() + (centerX() / 2) - (o.getWidth() / 2),  -o.getHeight() - OFFSCREEN ] },
    offmidbottomrightx = function(o) { return [ fe.layout.width + OFFSCREEN, centerY() + (centerY() / 2) - (o.getHeight() / 2) ] },
    offmidbottomrighty = function(o) { return [ centerX() + (centerX() / 2) - (o.getWidth() / 2), fe.layout.height + OFFSCREEN ] },
    offtop = function(o) { return [ centerX() - (o.getWidth() / 2), -o.getHeight() - OFFSCREEN ]; },
    offbottom = function(o) { return [ centerX() - (o.getWidth() / 2), fe.layout.height + o.getHeight() + OFFSCREEN ]; },
    offleft = function(o) { return [ - o.getWidth() - OFFSCREEN, centerY() - (o.getHeight() / 2) ]; },
    offright = function(o) { return [ fe.layout.width + o.getWidth() + OFFSCREEN, centerY() - (o.getHeight() / 2) ]; },
    offtopleftx = function(o) { return [ - o.getWidth() - OFFSCREEN, 0 ]; },
    offtoplefty = function(o) { return [ 0, - o.getHeight() - OFFSCREEN ]; },
    offtopleft = function(o) { return [ - o.getWidth() - OFFSCREEN, - o.getHeight() - OFFSCREEN ]; },
    offtoprightx = function(o) { return [ fe.layout.width + OFFSCREEN, 0 ]; },
    offtoprighty = function(o) { return [ 0, - o.getHeight() - OFFSCREEN ]; },
    offtopright = function(o) { return [ fe.layout.width + OFFSCREEN, - o.getHeight() - OFFSCREEN ]; },
    offbottomleftx = function(o) { return [ - o.getWidth() - OFFSCREEN, 0 ]; },
    offbottomlefty = function(o) { return [ 0, fe.layout.height + OFFSCREEN ]; },
    offbottomleft = function(o) { return [ - o.getWidth() - OFFSCREEN, fe.layout.height + OFFSCREEN ]; },
    offbottomrightx = function(o) { return [ fe.layout.width + OFFSCREEN, 0 ]; },
    offbottomrighty = function(o) { return [ 0, fe.layout.height + OFFSCREEN ]; },
    offbottomright = function(o) { return [ fe.layout.width + OFFSCREEN, fe.layout.height + OFFSCREEN ]; }
}

//extended callback stores which callback you want, and the object from where the function will run
class ExtendedCallback { i = null; f = null ; constructor(i, f) { this.i = i; this.f = f; } }

//forward transition to interested listeners
function extended_objects_transition( ttype, var, ttime ) {
    return ExtendedObjects.run_callback("onTransition", { ttype = ttype, var = var, ttime = ttime } );
}

//forward tick to interested listeners 
function extended_objects_tick( ttime ) {
    ExtendedObjects.run_callback("onTick", { ttime = ttime } );
}

class ExtendedObject {
    id = null;
    config = null;
    object = null;
    layer = null;
    constructor(id, x, y, layer) {
        this.id = id;
        this.layer = layer;
        this.config = {
            start_x = x,
            start_y = y
        }
    }
    
    function getAlpha() { return object.alpha; }
    function getColor() { return [ object.red, object.green, object.blue ]; }
    function getHeight() { return object.height; }
    function getIndexOffset() { return object.index_offset; }
    function getLayer() { return this.layer; }
    function getRotation() { return object.rotation; }
    function getShader() { return object.shader; }
    function getVisible() { return object.visible; }
    function getWidth() { return object.width; }
    function getX() { return object.x; }
    function getY() { return object.y; }

    function setAlpha(a) { if (a < 0) a = 0; if (a > 255) a = 255; object.alpha = a; }
    function setColor(r, g, b) { object.set_rgb( r, g, b); }
    function setHeight(h) { object.height = h; }
    function setIndexOffset(i) { object.index_offset = i; }
    function setRotation(r) { object.rotation = r; }
    function setShader(s) { object.shader = s; }
    function setVisible(v) { object.visible = v; }
    function setWidth(w) { object.width = w; }
    function setX(x) { object.x = x; }
    function setY(y) { object.y = y; }
    
    //added functions
    function getType() { return "ExtendedObject"; }
    function setPosition(p) { if (typeof p == "string") p = POSITIONS[p](this); setX(p[0]); setY(p[1]); }
    function setSize(w,h) { setWidth(w); setHeight(h); }
    function toString() { 
        local str = getType() + " (" + id + "): " + getX() + "," + getY() + " " + getWidth() + "x" + getHeight() + " layer:" + this.layer;
        if ("animations" in config) str += " a: " + config.animations.len();
        return str;
    }

}

class ShadowedObject extends ExtendedObject {
    shadow = null;
    constructor(id, x, y, layer) {
        base.constructor(id, x, y, layer);
        config.shadowEnabled <- true;
        config.shadowAlpha <- 150;
        config.shadowColor <- [ 20, 20, 20 ];
        config.shadowOffset <- 2;
    }

    function createTextShadow(t, x, y, w, h) { 
        if (FeVersionNum >= 130) {
            if (layer == null || layer > ExtendedObjects.layers.len() - 1) layer = ExtendedObjects.layers.len() - 1;
            if (layer < 0) layer = 0;
            shadow = ExtendedObjects.layers[layer].add_text(t, x, y, w, h);
            object = ExtendedObjects.layers[layer].add_text(t, x, y, w, h);
        } else {
            shadow = fe.add_text(t, x, y, w, h);
            object = fe.add_text(t, x, y, w, h);
        }
        setShadow(config.shadowEnabled);
        setShadowOffset(config.shadowOffset);
        setShadowColor(config.shadowColor[0], config.shadowColor[1] ,config.shadowColor[2]);
        setShadowAlpha(config.shadowAlpha);
    }
    
    function createImageShadow(i, x, y, w, h, imgtype = null) {
        if (FeVersionNum >= 130) {
            if (layer == null || layer > ExtendedObjects.layers.len() - 1) layer = ExtendedObjects.layers.len() - 1;
            if (layer < 0) layer = 0;
            if (imgtype == null) shadow = ExtendedObjects.layers[layer].add_image(i, x, y, w, h) else shadow = ExtendedObjects.layers[layer].add_artwork(i, x, y, w, h);
            object = ExtendedObjects.layers[layer].add_clone(shadow);
        } else {
            if (imgtype == null) shadow = fe.add_image(i, x, y, w, h) else shadow = fe.add_artwork(i, x, y, w, h);
            object = fe.add_clone(shadow);
        }
        //config.shadowEnabled = false;
        setShadow(config.shadowEnabled);
        setShadowOffset(config.shadowOffset);
        setShadowColor(config.shadowColor[0], config.shadowColor[1] ,config.shadowColor[2]);
        setShadowAlpha(config.shadowAlpha);
    }
    
    function createCloneShadow(img) {
        if (FeVersionNum >= 130) {
            if (layer == null || layer > ExtendedObjects.layers.len() - 1) layer = ExtendedObjects.layers.len() - 1;
            if (layer < 0) layer = 0;
            shadow = ExtendedObjects.layers[layer].add_clone(img.object);
            object = ExtendedObjects.layers[layer].add_clone(img.object);
        } else {
            shadow = fe.add_clone(img);
            object = fe.add_clone(shadow);
        }
        //config.shadowEnabled = false;
        setShadow(config.shadowEnabled);
        setShadowOffset(config.shadowOffset);
        setShadowColor(config.shadowColor[0], config.shadowColor[1] ,config.shadowColor[2]);
        setShadowAlpha(config.shadowAlpha);
    }
    
    function getShadow() { return config.shadowEnabled; }
    function getShadowAlpha() { return config.shadowAlpha; }
    function getShadowColor() { return config.shadowColor; }
    function getShadowOffset() { return config.shadowOffset; }

    function setShadow(e) { config.shadowEnabled = shadow.visible = e; }
    function setShadowAlpha(a) { if (a < 0) a = 0; if (a > 255) a = 255; config.shadowAlpha = shadow.alpha = a; }
    function setShadowColor(r, g, b) { config.shadowColor = [r, g, b]; shadow.set_rgb(r, g, b); }
    function setShadowOffset(o) { config.shadowOffset = o; setX(getX()); setY(getY()); }

    //overrides
    function setAlpha(a) {  base.setAlpha(a); if (a < 50) shadow.alpha = 0; }
    function setX(x) { object.x = x; shadow.x = x + config.shadowOffset; }
    function setY(y) { object.y = y; shadow.y = y + config.shadowOffset; }
    function setWidth(w) { object.width = shadow.width = w; }
    function setHeight(h) { object.height = shadow.height = h; }
    function setRotation(r) { object.rotation = shadow.rotation = r; }
    function setShader(s) { object.shader = shadow.shader = s; }
    function setVisible(v) { object.visible = shadow.visible = v; }
}

class ExtendedText extends ShadowedObject {
    
    constructor(id, t, x, y, w, h, layer) {
        base.constructor(id, x, y, layer);
        createTextShadow(t, x, y, w, h);
    }
    function getType() { return "ExtendedText"; }
    
    function getAlign() { return object.align; }
    function getBGColor() {return [ object.bg_red, object.bg_green, object.bg_blue ]; }
    function getBGAlpha() { return object.bg_alpha; }
    function getCharSize() { return object.charsize; }
    function getFont() { return object.font; }
    function getStyle() { return object.style; }
    function getText() { return object.msg; }
    function getWordWrap() { return object.word_wrap; return false; }
    
    function setAlign(a) { object.align = shadow.align = a; }
    function setBGColor(r, g, b) { object.set_bg_rgb(r, g, b); }
    function setBGAlpha(a) { object.bg_alpha = a; }
    function setCharSize(c) { object.charsize = shadow.charsize = c; }
    function setFont(f) { object.font = shadow.font = f; }
    function setStyle(s) { object.style = shadow.style = s; }
    function setText(t) { object.msg = shadow.msg = t; }
    function setWordWrap(w) { object.word_wrap = shadow.word_wrap = w; }
}

class ExtendedImage extends ShadowedObject {
    imgType = null;
    constructor(id, i, x, y, w, h, layer) {
        base.constructor(id, x, y, layer);
        createImageShadow(i, x, y, w, h, imgType);
    }
    function getType() { return "ExtendedImage"; }

    function getMovieEnabled() { return object.movie_enabled; }
    function getPinch() { return [ object.pinch_x, object.pinch_y ]; }
    function getPreserveAspectRatio() { return object.preserve_aspect_ratio; }
    function getSkew() { return [ object.skew_x, object.skew_y ]; }
    function getSubImagePosition() { return [ object.subimg_x, object.subimg_y ]; }
    function getSubImageSize() { return [ object.subimg_width, object.subimg_height ]; }
    function getTextureSize() { return [ object.texture_width, object.texture_height ]; }
    
    function setMovieEnabled(e) { object.movie_enabled = shadow.movie_enabled = e; }
    function setPinch(x, y) { setPinchX(x); setPinchY(y); }
    function setPinchX(x) { object.pinch_x = shadow.pinch_x = x; }
    function setPinchY(y) { object.pinch_y = shadow.pinch_y = y; }
    function setPreserveAspectRatio(p) { object.preserve_aspect_ratio = shadow.preserve_aspect_ratio = p; }
    function setSkew(x, y) { setSkewX(x); setSkewY(y); }
    function setSkewX(x) { object.skew_x = shadow.skew_x = x; }
    function setSkewY(y) { object.skew_y = shadow.skew_y = y; }
    function setSubImagePosition(x, y) { object.subimg_x = x; shadow.subimg_x = x; object.subimg_y = shadow.subimg_y = y; }
    function setSubImageSize(w, h) { object.subimg_width = shadow.subimg_width = w; object.subimg_height = shadow.subimg_height = h; }
}

class ExtendedArtwork extends ExtendedImage {
    constructor(id, i, x, y, w, h, layer) {
        imgType = "artwork";
        base.constructor(id, i, x, y, w, h, layer);
    }
    function getType() { return "ExtendedArtwork"; }
}

class ExtendedClone extends ShadowedObject {
    constructor(id, img, layer) {
        base.constructor(id, x, y, layer);
        createCloneShadow(img);
        //clone properties
        
    }
}

class ExtendedListBox extends ExtendedObject {
    constructor(id, x, y, w, h, layer) {
        base.constructor(id, x, y, layer);
        if (FeVersionNum >= 130) {
            if (layer == null || layer > ExtendedObjects.layers.len() - 1) layer = ExtendedObjects.layers.len() - 1;
            if (layer < 0) layer = 0;
            object = ExtendedObjects.layers[layer].add_listbox(x, y, w, h);
        } else {
            object = fe.add_listbox(x, y, w, h);
        }
    }
    function getType() { return "ExtendedListBox"; }
    function getAlign() { return object.align; }
    function getBGColor() {return [ object.bg_red, object.bg_green, object.bg_blue ]; }
    function getBGAlpha() { return object.bg_alpha; }
    function getCharSize() { return object.charsize; }
    function getFont() { return object.font; }
    function getRows() { return object.rows; }
    function getSelectionColor() { return [ object.sel_red, object.sel_green, object.sel_blue ]; }
    function getSelectionAlpha() { return object.sel_alpha; }
    function getSelectionBGColor() { return [ object.selbg_red, object.selbg_green, object.selbg_blue ]; }
    function getSelectionBGAlpha() { return object.sel_bgalpha; }
    function getSelectionStyle() { return object.sel_style; }
    function getStyle() { return object.style; }
    
    function setAlign(a) { object.align = a; }
    function setBGColor(r, g, b) { object.set_bg_rgb(r, g, b); }
    function setBGAlpha(a) { object.bg_alpha = a; }
    function setCharSize(c) { object.charsize = c; }
    function setFont(f) { object.font = f; }
    function setRows(r) { object.rows = r; }
    function setSelectionColor(r, g, b) { object.set_sel_rgb(r, g, b); }
    function setSelectionAlpha(a) { object.sel_alpha = a; }
    function setSelectionBGColor(r, g, b) { object.set_selbg_rgb(r, g, b); }
    function setSelectionBGAlpha(a) { object.selbg_alpha = a; }   
    function setSelectionStyle(s) { object.sel_style = s; }
    function setStyle(s) { object.style = s; }
}

//init
fe.layout.width = ScreenWidth;
fe.layout.height = ScreenHeight;
fe.add_transition_callback( "extended_objects_transition" );
fe.add_ticks_callback( "extended_objects_tick" );

//pre-included extensions
fe.do_nut("extended/extensions/debugger/debugger.nut");

//pre-included objects


