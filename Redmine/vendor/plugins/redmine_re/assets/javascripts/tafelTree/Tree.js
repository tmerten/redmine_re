// Copyright (c) 2006 Tafel, Fabien Tafelmacher
//
// See http://membres.lycos.fr/tafelmak/arbre.php for more info
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// This is distributed under Free-BSD licence.

/*
@todo
------------------
check-restore default
gestion xml (load + save)
multidrop
scrolldrop
*/






/**
 *------------------------------------------------------------------------------
 *							TafelTree Class
 *------------------------------------------------------------------------------
 */

var TAFELTREE_WRONG_BRANCH_STRUCTURE = "La structure de la branche n'est pas correcte. Il faut au moins un id et un texte";
var TAFELTREE_NO_BODY_TAG = "Il n'y a pas de balise BODY!";
var TAFELTREE_DEBUG = false;

var TafelTree = Class.create();

/**
 * Fragment de script pour supprimer les <ul></ul> lors du loadFromUL()
 */
//TafelTree.scriptFragment = /(?:<ul.*?>)((\n|\r|.)*)*/img;

TafelTree.version = '1.9.1';
TafelTree.lastUpdate = '2007-07-21';

TafelTree.scriptFragment = /[\s]*<[/]?[ul|li].*>.*/ig;

TafelTree.debugReturn = '<br />';
TafelTree.debugTab = '&nbsp;&nbsp;&nbsp;&nbsp;';

/**
 * Attributs des LI
 */
TafelTree.prefixAttribute = 'T';
TafelTree.textAttributes = [
	TafelTree.prefixAttribute + 'img',
	TafelTree.prefixAttribute + 'imgopen',
	TafelTree.prefixAttribute + 'imgclose',
	TafelTree.prefixAttribute + 'imgselect',
	TafelTree.prefixAttribute + 'imgselectopen',
	TafelTree.prefixAttribute + 'imgselectclose',
	TafelTree.prefixAttribute + 'style',
	TafelTree.prefixAttribute + 'droplink',
	TafelTree.prefixAttribute + 'openlink',
	TafelTree.prefixAttribute + 'editlink',
	TafelTree.prefixAttribute + 'tooltip',
	TafelTree.prefixAttribute + 'title'
];
TafelTree.numericAttributes = [
	TafelTree.prefixAttribute + 'canhavechildren',
	TafelTree.prefixAttribute + 'acceptdrop',
	TafelTree.prefixAttribute + 'draggable',
	TafelTree.prefixAttribute + 'editable',
	TafelTree.prefixAttribute + 'open',
	TafelTree.prefixAttribute + 'check',
	TafelTree.prefixAttribute + 'checkbox',
	TafelTree.prefixAttribute + 'select',
	TafelTree.prefixAttribute + 'last'
];
TafelTree.functionAttributes = [
	TafelTree.prefixAttribute + 'onbeforecheck',
	TafelTree.prefixAttribute + 'oncheck',
	TafelTree.prefixAttribute + 'onclick',
	TafelTree.prefixAttribute + 'ondblclick',
	TafelTree.prefixAttribute + 'onbeforeopen',
	TafelTree.prefixAttribute + 'onopen',
	TafelTree.prefixAttribute + 'onedit',
	TafelTree.prefixAttribute + 'oneditajax',
	TafelTree.prefixAttribute + 'onmouseover',
	TafelTree.prefixAttribute + 'onmouseout',
	TafelTree.prefixAttribute + 'onmousedown',
	TafelTree.prefixAttribute + 'onmouseup',
	TafelTree.prefixAttribute + 'ondrop',
	TafelTree.prefixAttribute + 'ondragstarteffect',
	TafelTree.prefixAttribute + 'ondragendeffect',
	TafelTree.prefixAttribute + 'onerrorajax',
	TafelTree.prefixAttribute + 'ondropajax',
	TafelTree.prefixAttribute + 'onopenpopulate'
];
	


/**
 *------------------------------------------------------------------------------
 *							TafelTree static methods
 *------------------------------------------------------------------------------
 */

/**
 * Constructeur d'un nouvel arbre via UL
 *
 * @access	public
 * @param	string				id						L'id de l'élément HTML conteneur
 * @param	string				imgBase					Le path vers les images, ou les options
 * @param	integer				width					La largeur de l'arbre
 * @param	integer				height					La hauteur de l'arbre
 * @param	object				options					Les options de génération
 * @return	TafelTree									L'arbre créé sur la base des UL - LI
 */	
TafelTree.loadFromUL = function (id, imgBase, width, height, options, debug) {
	// 2006-11-25 : "options" est maintenant à la place de "imgBase"
	if (typeof(imgBase) == 'object') {
		options = imgBase;
		debug = width;
		imgBase = (options.imgBase) ? options.imgBase : 'imgs/';
		width = (options.width) ? options.width : '100%';
		height = (options.height) ? options.height : 'auto';
	}

	// Suite
	var obj = $(id);
	var load = document.createElement('img');
	load.setAttribute('title', 'load');
	load.setAttribute('alt', 'load');
	load.src = ((imgBase) ? imgBase : 'imgs/') + 'load.gif';
	obj.parentNode.insertBefore(load, obj);
	Element.hide(obj);
	
	var tab = '';
	var tabModel = (debug) ? TafelTree.debugTab : '';
	var rt = (debug) ? TafelTree.debugReturn : '';
	var virgule = '';
	var str = (debug) ? 'var struct = [' : '([';
	for (var i = 0; i < obj.childNodes.length; i++) {
		if (obj.childNodes[i].nodeName.toLowerCase() == 'li') {
			str += this._loadFromUL(obj.childNodes[i], virgule, rt, tab, tabModel);
			virgule = ',';
		}
	}
	str += rt + ((debug) ? '];' : '])');
	
	var div = document.createElement('div');
	div.id = obj.id;
	obj.id += '____todelete';
	obj.parentNode.insertBefore(div, obj);
	if (!debug) {
		var m = TafelTree.prefixAttribute;
		var struct = eval(str);
		var _tree = new TafelTree(id, struct, options);
	} else {
		div.innerHTML = str.replace(/</img, '&lt;');
		var _tree = str;
	}
	obj.parentNode.removeChild(load);
	obj.parentNode.removeChild(obj);
	return _tree;
};

/**
 * Méthode récursive qui va récupérer les infos de tous les LI
 *
 * @access	private
 * @param	HTMLLiElement		obj						La LI courante
 * @param	string				virgule					Détermine s'il y a une virgule avant l'accolade ouvrante
 * @param	string				rt						Retour de ligne (pour le debug)
 * @param	string				tab						La tabulation courante (pour le debug)
 * @param	string				tabModel				La grandeur d'une tabulation (pour le debug)
 * @return	string										La string JSON dérivée de la structure UL - LI
 */
TafelTree._loadFromUL = function (obj, virgule, rt, tab, tabModel) {
	tab += tabModel;
	var contenu = TafelTree.trim(obj.innerHTML.replace(TafelTree.scriptFragment, ''));
	var str = virgule + rt + tab + '{' + rt;
	// Définition de toutes les propriétés
	str += tab + "'id' : '" + obj.id + "'";
	if (contenu) {
		str += "," + rt + tab + "'txt' : '" + contenu + "'";
	}
	TafelTree.textAttributes.each(function (attr) {
		if (obj.getAttribute(attr)) str += "," + rt + tab + "'" + attr.replace(TafelTree.prefixAttribute, '') + "' : '" + obj.getAttribute(attr) + "'";
	});
	TafelTree.numericAttributes.each(function (attr) {
		if (obj.getAttribute(attr)) str += "," + rt + tab + "'" + attr.replace(TafelTree.prefixAttribute, '') + "' : " + obj.getAttribute(attr);
	});
	TafelTree.functionAttributes.each(function (attr) {
		if (obj.getAttribute(attr)) str += "," + rt + tab + "'" + attr.replace(TafelTree.prefixAttribute, '') + "' : " + obj.getAttribute(attr);
	});
	// Définition des enfants
	for (var i = 0; i < obj.childNodes.length; i++) {
		if (obj.childNodes[i].nodeName.toLowerCase() == 'ul') {
			virgule = '';
			str += ',' + rt + tab + "'items' : [";
			for (var j = 0; j < obj.childNodes[i].childNodes.length; j++) {
				if (obj.childNodes[i].childNodes[j].nodeName.toLowerCase() == 'li') {
					str += this._loadFromUL(obj.childNodes[i].childNodes[j], virgule, rt, tab, tabModel);
					virgule = ',';
				}
			}
			str += rt + tab + ']';
		}			
	}
	str += rt + tab + '}';
	return str;
};

TafelTree.trim = function (string) {
	return string.replace(/(^\s*)|(\s*$)|\n|\r|\t/g,'');
};




/**
 *------------------------------------------------------------------------------
 *							TafelTree Class Constructor
 *------------------------------------------------------------------------------
 */

TafelTree.prototype = {
	/**
	 * Constructeur d'un nouvel arbre. Supporte facilement 700 éléments
	 *
	 * 2006-11-25 : changement des paramètres dans le constructeur. On peut mettre les options
	 * à la place de "imgBase". Les autres paramètres peuvent maintenant être passé via
	 * "options"
	 *
	 * @access	public
	 * @param	string				id						L'id de l'élément HTML conteneur
	 * @param	object				struct					La structure de l'arbre
	 * @param	string				imgBase					Le path vers les images (ou les options)
	 * @param	integer				width					La largeur de l'arbre
	 * @param	integer				height					La hauteur de l'arbre
	 * @param	object				options					Les fonctions de load et autres binz de génération
	 */	
	initialize : function (id, struct, imgBase, width, height, options) {
		// 2006-11-25 : "options" est maintenant à la place de "imgBase"
		if (typeof(imgBase) == 'object') {
			options = imgBase;
			imgBase = (options.imgBase) ? options.imgBase : 'imgs/';
			width = (options.width) ? options.width : '100%';
			height = (options.height) ? options.height : 'auto';
		}
		// Variables images
		this.imgBase = (imgBase) ? imgBase : 'imgs/';
		this.setLineStyle('line');
		this.options = (options) ? options : {};
		this.copyName = ' (%n)';
		this.copyNameBreak = '_';
		
		// Variables CSS
		this.classTree = 'tafelTree';
		this.classTreeRoot = this.classTree + '_root';
		this.classTreeBranch = this.classTree + '_row';
		this.classCopy = (this.options.copyCSS) ? this.options.copyCSS : null;
		this.classCut = (this.options.cutCSS) ? this.options.cutCSS : null;
		this.classDrag = 'tafelTreedrag';
		this.classSelected = 'tafelTreeselected';
		this.classEditable = 'tafelTreeeditable';
		this.classContent = 'tafelTreecontent';
		this.classCanevas = 'tafelTreecanevas';
		this.classDragOver = 'tafelTreedragOver';
		this.classTooltip = 'tafelTreetooltip';
		this.classOpenable = 'tafelTreeopenable';

		// Default structure
		this.defaultStruct = [];
		/*for (var i = 0; i < struct.length; i++) {
			this.defaultStruct.push(Object.clone(struct[i]));
		}*/
		
		// Autres variables
		this.idTree = 0;
		this.behaviourDrop = 0;
		this.durationTooltipShow = 1000;
		this.durationTooltipHide = 100;
		this.baseStruct = struct;
		this.width = (width) ? width : '100%';
		this.height = (height) ? height : 'auto';
		this.div = $(id);
		this.div.style.width = this.width;
		this.div.style.height = this.height;
		this.id = this.div.id;
		this.isTree = true;
		this.dropALT = true;
		this.openAll = false;
		this.rtlMode = false;
		this.dropCTRL = true;
		this.multiline = false;
		this.checkboxes = false;
		this.propagation = true;
		this.dragRevert = true;
		this.dragGhosting = true;
		this.bigTreeLoading = -1;
		this.dropAsSibling = true;
		this.onlyOneOpened = false;
		this.openedAfterAdd = true;
		this.editableBranches = true;
		this.reopenFromServer = true;
		this.selectedBranchShowed = true,
		this.checkboxesThreeState = false;
		this.roots = [];
		this.icons = [null, null, null];
		this.iconsSelected = [null, null, null];
		this.otherTrees = [];
		this.cuttedBranches = [];
		this.copiedBranches = [];
		this.checkedBranches = [];
		this.selectedBranches = [];
		this.idTreeBranch = this.classTree + '_' + this.id + '_id_';
        this.loaded = false;
		Element.addClassName(this.div, this.classTree);

		// Cookie
		this.useCookie = true;
		this.cookieSeparator = '|';
		this.cookieCheckSeparator = '[check]';
		this.cookieOpened = null;
		this.cookieChecked = null;
        this.setOptions(this.options);
		var fromCookie = this.getCookie(this.classTree + this.id);
		if (fromCookie) {
			var branches = fromCookie.split(this.cookieCheckSeparator);
			// Branches ouvertes
			this.cookieOpened = [];
			this.cookieOpened = branches[0].split(this.cookieSeparator);
			this.cookieOpened.shift();
			// Branches checkées (avec anti-bug pour les anciennes versions et anciens cookies)
			this.cookieChecked = [];
			if (branches.length > 1) {
				this.cookieChecked = branches[1].split(this.cookieSeparator);
			}
		}

		// Instance de debug
		this.debugObj = document.createElement('div');
		this.debugObj.setAttribute('id', this.classTree + '_debug');
		Element.hide(this.debugObj);
		this.div.appendChild(this.debugObj);
		// Instance Ajax
		this.ajaxObj = document.createElement('div');
		this.ajaxObj.setAttribute('id', this.classTree + '_ajax');
		Element.hide(this.ajaxObj);
		this.div.appendChild(this.ajaxObj);
		Event.observe(this.div, 'mousedown', this.evt_setAsCurrent.bindAsEventListener(this), false);
		Event.observe(this.div, 'focus', this.evt_setAsCurrent.bindAsEventListener(this), false);
		// don't generate if cookie is on server side
        if (!this.serverCookie) {
            if (this.options.generate) {
    			this.generate();
    		}
    		if (this.options.generateBigTree) {
    			this.generate(true);
    		}
        }
		TafelTreeManager.add(this);
	},


	/**
	 *------------------------------------------------------------------------------
	 *							TafelTree global events management
	 *------------------------------------------------------------------------------
	 */

	/**
	 * Set l'arbre comme étant l'arbre courant
	 *
	 * Toutes les actions claviers auront effet seulement sur cet arbre et non sur les autres*
	 *
	 * @access	public
	 * @param	Event			ev						L'événement déclencheur
	 * @return	void
	 */
	evt_setAsCurrent : function (ev) {
		var obj = Event.element(ev);
		TafelTreeManager.setCurrentTree(this);
	},
	
	/**
	 * Retourne une liste de branches ordrée (en fonction de leur position dans l'arbre)
	 *
	 * @access	public
	 * @param	array				list					Un tableau de TafelTreeBranch
	 * @return	array										Un tableau ordré de TafelTreeBranch
	 */
	orderListBranches : function (list) {
		var ordered = [];
		var level = [];
		var nivmin = 100;
		var nivmax = 0;
		// On ordre par niveau
		var niv = 0;
		for (var i = 0; i < list.length; i++) {
			niv = list[i].getLevel();
			if (typeof(level[niv]) == 'undefined') {
				level[niv] = [];
			}
			level[niv].push(list[i]);
			if (niv > nivmax) nivmax = niv;
			if (niv < nivmin) nivmin = niv;
		}
		// On enlève le cheni de m... à cause de la gestion tableau javascript
		for (var i = nivmin; i <= nivmax; i++) {
			if (level[i]) {
				ordered.push(level[i]);
			}
		}
		// Pour chaque niveau, on ordre par position dans l'arbre

		// On ne récupère que les 1er niveaux. S'il y a des enfants, on les ignore
		return ordered;
	},
	
	/**
	 * Retourne les branches copiées de l'arbre, ou d'un arbre lié
	 *
	 * Si le tableau n'a pas de branches, la méthode va voir dans les arbres liés
	 * pour récupérer les branches qui seraient copiées dans l'autre arbre
	 *
	 * @access	public
	 * @return	array									Les branches copiées
	 */
	getCopiedBranches : function () {
		var branches = this.copiedBranches;
		if (branches.length == 0) {
			for (var i = 0; i < this.otherTrees.length; i++) {
				branches = this.otherTrees[i].copiedBranches;
				if (branches.length > 0) break;
			}
		}
		return branches;
	},
	
	/**
	 * Retourne les branches coupées de l'arbre, ou d'un arbre lié
	 *
	 * Si le tableau n'a pas de branches, la méthode va voir dans les arbres liés
	 * pour récupérer les branches qui seraient coupées dans l'autre arbre
	 *
	 * @access	public
	 * @return	array									Les branches coupées
	 */
	getCuttedBranches : function () {
		var branches = this.cuttedBranches;
		if (branches.length == 0) {
			for (var i = 0; i < this.otherTrees.length; i++) {
				branches = this.otherTrees[i].cuttedBranches;
				if (branches.length > 0) break;
			}
		}
		return branches;
	},
	
	/**
	 * Fonction qui coupe la sélection et la met dans un cache
	 *
	 * @access	public
	 * @return	return										True si ça coupe, false sinon
	 */
	cut : function () {
		this.unsetCut();
		this.unsetCopy();
		var level = this.orderListBranches(this.selectedBranches);
		//this.debug(level);
		var sel = null;
		for (var i = 0; i < level.length; i++) {
			for (var j = 0; j < level[i].length; j++) {
				sel = level[i][j];
				this._cut(sel);
				this.cuttedBranches.push(sel);
			}
		}
		return true;
	},
	
	/**
	 * Fonction qui copie la sélection dans un cache
	 *
	 * @access	public
	 * @return	return										True si ça copie, false sinon
	 */
	copy : function () {
		this.unsetCut();
		this.unsetCopy();
		var level = this.orderListBranches(this.selectedBranches);
		var sel = null;
		for (var i = 0; i < this.selectedBranches.length; i++) {
			sel = this.selectedBranches[i];
			this._copy(sel);
			this.copiedBranches[i] = sel;
		}
		return true;
	},

	/**
	 * Fonction qui colle le cache à l'endroit sélectionné. Il ne doit y avoir qu'une sélection
	 *
	 * @access	public
	 * @return	return										True si ça colle, false sinon
	 */
	paste : function () {
		if (this.selectedBranches.length != 1) return false;
		var branch = this.selectedBranches[0];
		var copied = this.getCopiedBranches();
		var cutted = this.getCuttedBranches();
		var nbCopy = copied.length;
		var nbCut = cutted.length;
		if (nbCopy > 0) {
			var list = copied;
			var b = null;
			for (var i = 0; i < list.length; i++) {
				if (this._okForPaste(branch, list, i)) {
					b = branch.insertIntoLast(list[i].clone());
				}
			}
		}
		if (nbCut > 0) {
			var list = cutted;
			for (var i = 0; i < list.length; i++) {
				if (this._okForPaste(branch, list, i)) {
					list[i].move(branch);
				}
			}
		}
		//this.unsetCopy();
		this.unsetCut();
		return true;
	},

	/**
	 * Détermine si on peut coller la partie courante du cache ou non
	 *
	 * @access	private
	 * @param	TafelTreeBranch		branch					La branche dans laquelle on colle
	 * @param	array				list					Le tableau de cache ordré par niveau
	 * @param	integer				i						La position courante dans le cache
	 * @return	boolean										True si on peut coller, false sinon
	 */
	_okForPaste : function (branch, list, i) {
		var ok = true;
		if (!branch.isChild(list[i])) {
			for (var j = 0; j < i; j++) {
				if (list[i].isChild(list[j])) {
					ok = false;
					break;
				}
			}
		} else {
			ok = false;
		}
		return ok;
	},
	
	unsetCut : function () {
		// On enlève les branches coupées des autres arbres (suppression du "presse-papier")
		var _tree = null;
		var branches = null;
		for (var i = 0; i < this.otherTrees.length; i++) {
			_tree = this.otherTrees[i];
			branches = _tree.cuttedBranches;
			for (var t = 0; t < branches.length; t++) {
				_tree._unsetCut(branches[t]);
			}
			_tree.cuttedBranches = [];
		}
		var cut = null;
		for (var i = 0; i < this.cuttedBranches.length; i++) {
			cut = this.cuttedBranches[i];
			this._unsetCut(cut);
		}
		this.cuttedBranches = [];
	},
	
	unsetCopy : function () {
		// On enlève les branches copiées des autres arbres (suppression du "presse-papier")
		var _tree = null;
		var branches = null;
		for (var i = 0; i < this.otherTrees.length; i++) {
			_tree = this.otherTrees[i];
			branches = _tree.copiedBranches;
			for (var t = 0; t < branches.length; t++) {
				_tree._unsetCopy(branches[t]);
			}
			_tree.copiedBranches = [];
		}
		var copy = null;
		for (var i = 0; i < this.copiedBranches.length; i++) {
			copy = this.copiedBranches[i];
			this._unsetCopy(copy);
		}		
		this.copiedBranches = [];
	},

	/**
	 * Annule les [n] dernières actions (todo...)
	 *
	 * @access	public
	 * @return	boolean									True si quelque chose a été annulé
	 */
	undo : function () {

	},


	/**
	 *------------------------------------------------------------------------------
	 *							TafelTree private keyboard methods
	 *------------------------------------------------------------------------------
	 */

	/**
	 * Méthode récursive qui fait l'effet "couper" sur toutes les sous-branches
	 *
	 * @access	private
	 * @param	TafelTreeBranch		branch					La branche courante
	 * @return	void
	 */
	_cut : function (branch) {
		if (!this.classCut) {
			new Effect.Opacity(branch.txt, {
				duration: 0.1, 
				transition: Effect.Transitions.linear, 
				from: 1.0, to: 0.4
			});
			new Effect.Opacity(branch.img, {
				duration: 0.1, 
				transition: Effect.Transitions.linear, 
				from: 1.0, to: 0.4
			});
		} else {
			Element.addClassName(branch.txt, this.classCut);
			Element.addClassName(branch.img, this.classCut);
		}
		if (branch.hasChildren()) {
			for (var i = 0; i < branch.children.length; i++) {
				this._cut(branch.children[i]);
			}
		}
	},

	/**
	 * Méthode récursive qui enlève l'effet "couper" sur toutes les sous-branches
	 *
	 * @access	private
	 * @param	TafelTreeBranch		branch					La branche courante
	 * @return	void
	 */
	_unsetCut : function (branch) {
		if (!this.classCut) {
			new Effect.Opacity(branch.txt, {
				duration: 0.1, 
				transition: Effect.Transitions.linear, 
				from: 0.4, to: 1.0
			});
			new Effect.Opacity(branch.img, {
				duration: 0.1, 
				transition: Effect.Transitions.linear, 
				from: 0.4, to: 1.0
			});
		} else {
			Element.removeClassName(branch.txt, this.classCut);
			Element.removeClassName(branch.img, this.classCut);
		}
		if (branch.hasChildren()) {
			for (var i = 0; i < branch.children.length; i++) {
				this._unsetCut(branch.children[i]);
			}
		}
	},

	/**
	 * Méthode récursive qui fait l'effet "copier" sur toutes les sous-branches
	 *
	 * @access	private
	 * @param	TafelTreeBranch		branch					La branche courante
	 * @return	void
	 */
	_copy : function (branch) {
		if (this.classCopy) {
			Element.addClassName(branch.txt, this.classCopy);
			Element.addClassName(branch.img, this.classCopy);
		}
		if (branch.hasChildren()) {
			for (var i = 0; i < branch.children.length; i++) {
				this._copy(branch.children[i]);
			}
		}
	},

	/**
	 * Méthode récursive qui enlève l'effet "copier" sur toutes les sous-branches
	 *
	 * @access	private
	 * @param	TafelTreeBranch		branch					La branche courante
	 * @return	void
	 */
	_unsetCopy : function (branch) {
		if (this.classCopy) {
			Element.removeClassName(branch.txt, this.classCopy);
			Element.removeClassName(branch.img, this.classCopy);
		}
		if (branch.hasChildren()) {
			for (var i = 0; i < branch.children.length; i++) {
				this._unsetCopy(branch.children[i]);
			}
		}
	},

	/**
	 *------------------------------------------------------------------------------
	 *							TafelTree getters and setters methods
	 *------------------------------------------------------------------------------
	 */
	
	enableMultiline : function (multiline) {
		this.multiline = (multiline) ? true : false;
	},
	
	enableRTL : function (rtl) {
		this.rtlMode = (rtl) ? true : false;
		if (this.rtlMode) {
			// plante sous Safari...
            //this.div.style.float = 'right';
			this.div.style.textAlign = 'right';
			this.div.style.direction = 'rtl';
		} else {
            // plante sous Safari
			//this.div.style.float = 'left';
			this.div.style.textAlign = 'left';
			this.div.style.direction = 'ltr';
		}
		this.setLineStyle(this.lineStyle);
	},
	
	isRTL : function () {
		return this.rtlMode;
	},

	disableDropALT : function (alt) {
		this.dropALT = (alt) ? true : false;
	},
	
	disableDropCTRL : function (copy) {
		this.dropCTRL = (copy) ? true : false;
	},

	enableCheckboxes : function (enable) {
		this.checkboxes = (enable) ? true : false;
	},

	enableCheckboxesThreeState : function (enable) {
		this.enableCheckboxes(enable);
		this.checkboxesThreeState = (enable) ? true : false;
	},
	
	/**
	 * Permet d'utiliser les cookies ou non. Le séparateur est optionnel, '|' par défaut
	 *
	 * @access	public
	 * @param	boolean				enable					True (par défaut) pour gérer les cookies
	 * @param	string				separator				Le séparateur dans le cookie )
	 */
	enableCookies : function (enable, separator) {
		this.useCookie = (enable) ? true : false;
		if (typeof(separator) != 'undefined') {
			this.cookieSeparator = separator;
		}
	},

	openOneAtOnce : function (yes) {
		this.onlyOneOpened = (yes) ? true : false;
	},

	openAfterAdd : function (yes) {
		this.openedAfterAdd = (yes) ? true : false;
	},

	reopenFromServerAfterLoad : function (yes) {
		this.reopenFromServer = (yes) ? true : false;
	},
	
	/**
	 * Fonction qui set par défaut l'état des branches (ouvert ou fermé)
	 *
	 * @access	public
	 * @param	boolean				open					True pour tout ouvrir, false pour tout fermer
	 * @return	void
	 */
	openAtLoad : function (open) {
		this.openAll = (open) ? true : false;
	},

	showSelectedBranch : function (show) {
		this.selectedBranchShowed = (show) ? true : false;
	},
	
	/**
	 * Permet de choisir quel comportement par defaut le drop aura
	 *
	 * L'autre comportement s'obtient en gardant la touche ALT appuyée et/ou CTRL
	 *
	 * @access	public
	 * @param	string			def							'sibling', 'siblingcopy', 'child' ou 'childcopy'
	 * @return	void
	 */
	setBehaviourDrop : function (def) {
		switch (def) {
			case 'sibling' : this.behaviourDrop = 1; break;
			case 'childcopy' : this.behaviourDrop = 2; break;
			case 'siblingcopy' : this.behaviourDrop = 3; break;
			case 'child' :
			default :
				this.behaviourDrop = 0;
		}
	},
	
	/**
	 * Set les icônes par défaut pour toutes les branches
	 *
	 * Si imgopen n'est pas défini, il prend la valeur d'img. Pareil pour imgclose.
	 *
	 * @access	public
	 * @param	string				img						L'image quand la branche n'a pas d'enfants
	 * @param	string				imgopen					L'image quand la branche des enfants et est ouverte
	 * @param	string				imgclose				L'image quand la branche a des enfants et est fermée
	 * @return	void
	 */
	setIcons : function (img, imgopen, imgclose) {
		this.icons[0] = img;
		this.icons[1] = (imgopen) ? imgopen : img;
		this.icons[2] = (imgclose) ? imgclose : img;
	},
	
	/**
	 * Set les icônes de sélection par défaut pour toutes les branches
	 *
	 * @access	public
	 * @param	string				img						L'image quand la branche n'a pas d'enfants
	 * @param	string				imgopen					L'image quand la branche des enfants et est ouverte
	 * @param	string				imgclose				L'image quand la branche a des enfants et est fermée
	 * @return	void
	 */
	setIconsSelected : function (img, imgopen, imgclose) {
		this.iconsSelected[0] = img;
		this.iconsSelected[1] = (imgopen) ? imgopen : null;
		this.iconsSelected[2] = (imgclose) ? imgclose : null;
	},

	/**
	 * Fonction qui permet de choisir le style des lignes entre les branches
	 *
	 * @access	public
	 * @param	string				style					LE style des lignes, 'none' ou 'line'
	 * @return	void
	 */
	setLineStyle : function (style) {
		this.lineStyle = style;
		switch (style) {
			case 'none' :
				this.imgLine0 = 'empty.gif'; this.imgLine1 = 'empty.gif'; this.imgLine2 = 'empty.gif'; 
				this.imgLine3 = 'empty.gif'; this.imgLine4 = 'empty.gif'; this.imgLine5 = 'empty.gif';
				this.imgWait = 'wait.gif'; this.imgEmpty = 'empty.gif';
				this.imgMinus1 = 'minus0.gif'; this.imgMinus2 = 'minus0.gif'; this.imgMinus3 = 'minus0.gif';
				this.imgMinus4 = 'minus0.gif'; this.imgMinus5 = 'minus0.gif';
				this.imgPlus1 = 'plus0.gif'; this.imgPlus2 = 'plus0.gif'; this.imgPlus3 = 'plus0.gif';
				this.imgPlus4 = 'plus0.gif'; this.imgPlus5 = 'plus0.gif';
				this.imgCheck1 = 'check1.gif'; this.imgCheck2 = 'check2.gif'; this.imgCheck3 = 'check3.gif';
				// Les 2 premiers sont des noms d'images, les 2 autres de classes CSS
				this.imgMulti1 = 'empty.gif'; this.imgMulti2 = 'empty.gif';
				this.imgMulti3 = ''; this.imgMulti4 = '';
				break;
			case 'full' :
				if (this.isRTL()) {
				this.imgLine0 = 'rtl_linefull0.gif'; this.imgLine1 = 'rtl_linefull1.gif'; this.imgLine2 = 'rtl_linefull2.gif';
				this.imgLine3 = 'rtl_linefull3.gif'; this.imgLine4 = 'rtl_linefull4.gif'; this.imgLine5 = 'rtl_linefull5.gif';
				this.imgWait = 'wait.gif'; this.imgEmpty = 'empty.gif';
				this.imgMinus1 = 'rtl_minusfull1.gif'; this.imgMinus2 = 'rtl_minusfull2.gif'; this.imgMinus3 = 'rtl_minusfull3.gif';
				this.imgMinus4 = 'rtl_minusfull4.gif'; this.imgMinus5 = 'rtl_minusfull5.gif';
				this.imgPlus1 = 'rtl_plusfull1.gif'; this.imgPlus2 = 'rtl_plusfull2.gif'; this.imgPlus3 = 'rtl_plusfull3.gif';
				this.imgPlus4 = 'rtl_plusfull4.gif'; this.imgPlus5 = 'rtl_plusfull5.gif';
				this.imgCheck1 = 'check1.gif'; this.imgCheck2 = 'check2.gif'; this.imgCheck3 = 'check3.gif';
				// Les 2 premiers sont des noms d'images, les 2 autres de classes CSS
				this.imgMulti1 = 'rtl_linebgfull.gif'; this.imgMulti2 = 'rtl_linebgfull2.gif';
				this.imgMulti3 = 'multiline'; this.imgMulti4 = 'multiline2';
				} else {
				this.imgLine0 = 'linefull0.gif'; this.imgLine1 = 'linefull1.gif'; this.imgLine2 = 'linefull2.gif';
				this.imgLine3 = 'linefull3.gif'; this.imgLine4 = 'linefull4.gif'; this.imgLine5 = 'linefull5.gif';
				this.imgWait = 'wait.gif'; this.imgEmpty = 'empty.gif';
				this.imgMinus1 = 'minusfull1.gif'; this.imgMinus2 = 'minusfull2.gif'; this.imgMinus3 = 'minusfull3.gif';
				this.imgMinus4 = 'minusfull4.gif'; this.imgMinus5 = 'minusfull5.gif';
				this.imgPlus1 = 'plusfull1.gif'; this.imgPlus2 = 'plusfull2.gif'; this.imgPlus3 = 'plusfull3.gif';
				this.imgPlus4 = 'plusfull4.gif'; this.imgPlus5 = 'plusfull5.gif';
				this.imgCheck1 = 'check1.gif'; this.imgCheck2 = 'check2.gif'; this.imgCheck3 = 'check3.gif';
				// Les 2 premiers sont des noms d'images, les 2 autres de classes CSS
				this.imgMulti1 = 'linebgfull.gif'; this.imgMulti2 = 'linebgfull2.gif';
				this.imgMulti3 = 'multiline'; this.imgMulti4 = 'multiline2';
				}
				break;
			case 'line' :
			default :
				if (this.isRTL()) {
				this.imgLine0 = 'rtl_line0.gif'; this.imgLine1 = 'rtl_line1.gif'; this.imgLine2 = 'rtl_line2.gif';
				this.imgLine3 = 'rtl_line3.gif'; this.imgLine4 = 'rtl_line4.gif'; this.imgLine5 = 'rtl_line5.gif';
				this.imgWait = 'wait.gif'; this.imgEmpty = 'empty.gif';
				this.imgMinus1 = 'rtl_minus1.gif'; this.imgMinus2 = 'rtl_minus2.gif'; this.imgMinus3 = 'rtl_minus3.gif';
				this.imgMinus4 = 'rtl_minus4.gif'; this.imgMinus5 = 'rtl_minus5.gif';
				this.imgPlus1 = 'rtl_plus1.gif'; this.imgPlus2 = 'rtl_plus2.gif'; this.imgPlus3 = 'rtl_plus3.gif';
				this.imgPlus4 = 'rtl_plus4.gif'; this.imgPlus5 = 'rtl_plus5.gif';
				this.imgCheck1 = 'check1.gif'; this.imgCheck2 = 'check2.gif'; this.imgCheck3 = 'check3.gif';
				// Les 2 premiers sont des noms d'images, les 2 autres de classes CSS
				this.imgMulti1 = 'rtl_linebg.gif'; this.imgMulti2 = 'rtl_linebg2.gif';
				this.imgMulti3 = 'multiline'; this.imgMulti4 = 'multiline2';
				} else {
				this.imgLine0 = 'line0.gif'; this.imgLine1 = 'line1.gif'; this.imgLine2 = 'line2.gif';
				this.imgLine3 = 'line3.gif'; this.imgLine4 = 'line4.gif'; this.imgLine5 = 'line5.gif';
				this.imgWait = 'wait.gif'; this.imgEmpty = 'empty.gif';
				this.imgMinus1 = 'minus1.gif'; this.imgMinus2 = 'minus2.gif'; this.imgMinus3 = 'minus3.gif';
				this.imgMinus4 = 'minus4.gif'; this.imgMinus5 = 'minus5.gif';
				this.imgPlus1 = 'plus1.gif'; this.imgPlus2 = 'plus2.gif'; this.imgPlus3 = 'plus3.gif';
				this.imgPlus4 = 'plus4.gif'; this.imgPlus5 = 'plus5.gif';
				this.imgCheck1 = 'check1.gif'; this.imgCheck2 = 'check2.gif'; this.imgCheck3 = 'check3.gif';
				// Les 2 premiers sont des noms d'images, les 2 autres de classes CSS
				this.imgMulti1 = 'linebg.gif'; this.imgMulti2 = 'linebg2.gif';
				this.imgMulti3 = 'multiline'; this.imgMulti4 = 'multiline2';
				}
		}
	},
	
	setTooltipDuration : function (show, hide) {
		this.durationTooltipShow = show;
		this.durationTooltipHide = hide;
	},

	/**
	 * Méthode qui permet d'interdir les mouvements dans la branche dragguée
	 *
	 * @access	public
	 * @param	boolean				propagateRestiction		True pour interdir le mouvement des enfants de la branche droppée
	 * @return	void
	 */
	propagateRestriction : function (propagate) {
		this.propagation = (typeof(propagate) == 'undefined') ? true : propagate;
	},
	
	getSelectedBranches : function () {
		return this.selectedBranches;
	},

	setContextMenu : function (menu) {
		var div = document.createElement('div');
		div.innerHTML = menu;
		this.div.appendChild(div);
	},


	/**
	 *------------------------------------------------------------------------------
	 *							TafelTree public methods
	 *------------------------------------------------------------------------------
	 */
	
	/**
	 * Fonction pour générer l'arbre
	 *
	 * @access	public
	 * @param	boolean				bigTree					True pour spécifier que c'est un gros arbre
	 * @return	void
	 */
	generate : function (bigTree) {
		if (!bigTree) {
			var isNotFirst = false;
			var isNotLast = false;
			for (var i = 0; i < this.baseStruct.length; i++) {
				isNotFirst = (i > 0) ? true : false;
				isNotLast = (i < this.baseStruct.length - 1) ? true : false;
				this.roots[i] = new TafelTreeRoot(this, this.baseStruct[i], 0, isNotFirst, isNotLast, i);
				this.div.appendChild(this.roots[i].obj);
			}
			this.loadComplete();
		} else {
			this.bigTreeLoading = 0;
			setTimeout(this._checkLoad.bind(this), 100);
			setTimeout(this._generateBigTree.bind(this), 10);
		}
	},
	
	/**
	 * Lance les fonctions générales de l'arbre
	 *
	 * @access	public
	 * @param	object				options					Les fonctions et autres ouvertures automatiques*
	 * @return	void
	 */
	setOptions : function (options) {
		// Fonctions événementielles
		if (options.onLoad) this.setOnLoad(options.onLoad);
		if (options.onDebug) this.setOnDebug(options.onDebug);
		if (options.onCheck) this.setOnCheck(options.onCheck);
		if (options.onBeforeCheck) this.setOnBeforeCheck(options.onBeforeCheck);
		if (options.onClick) this.setOnClick(options.onClick);
		if (options.onMouseDown) this.setOnMouseDown(options.onMouseDown);
		if (options.onMouseUp) this.setOnMouseUp(options.onMouseUp);
		if (options.onDblClick) this.setOnDblClick(options.onDblClick);
		if (options.onBeforeOpen) this.setOnBeforeOpen(options.onBeforeOpen);
		if (options.onOpen) this.setOnOpen(options.onOpen);
		if (options.onMouseOver) this.setOnMouseOver(options.onMouseOver);
		if (options.onMouseOut) this.setOnMouseOut(options.onMouseOut);
		if (options.onDrop) this.setOnDrop(options.onDrop);
		if (options.onDragStartEffect) this.setOnDragStartEffect(options.onDragStartEffect);
		if (options.onDragEndEffect) this.setOnDragEndEffect(options.onDragEndEffect); 
		if (options.onErrorAjax) this.setOnDropAfter(options.onErrorAjax);
		if (options.onEdit) this.setOnEdit(options.onEdit);
		if (options.onEditAjax) this.setOnEditAjax(options.onEditAjax[0], options.onEditAjax[1]);
		if (options.onDropAjax) this.setOnDropAjax(options.onDropAjax[0], options.onDropAjax[1]);
		if (options.onOpenPopulate) this.setOnOpenPopulate(options.onOpenPopulate[0], options.onOpenPopulate[1]);
		// Fonctions avancées
		if (typeof(options.rtlMode) != 'undefined') this.enableRTL(options.rtlMode);
		if (typeof(options.dropALT) != 'undefined') this.disableDropALT(options.dropALT);
		if (typeof(options.dropCTRL) != 'undefined') this.disableDropCTRL(options.dropCTRL);
		if (typeof(options.multiline) != 'undefined') this.enableMultiline(options.multiline);
		if (typeof(options.checkboxes) != 'undefined') this.enableCheckboxes(options.checkboxes);
		if (typeof(options.checkboxesThreeState) != 'undefined') this.enableCheckboxesThreeState(options.checkboxesThreeState);
		if (typeof(options.cookies) != 'undefined') this.enableCookies(options.cookies);
		if (typeof(options.openOneAtOnce) != 'undefined') this.openOneAtOnce(options.openOneAtOnce);
		if (typeof(options.openAtLoad) != 'undefined') this.openAtLoad(options.openAtLoad);
		if (typeof(options.openAfterAdd) != 'undefined') this.openAfterAdd(options.openAfterAdd);
		if (typeof(options.showSelectedBranch) != 'undefined') this.showSelectedBranch(options.showSelectedBranch);
		if (typeof(options.reopenFromServer) != 'undefined') this.reopenFromServerAfterLoad(options.reopenFromServer);
		if (typeof(options.propagateRestriction) != 'undefined') this.propagateRestriction(options.propagateRestriction);
		if (options.lineStyle) this.setLineStyle(options.lineStyle);
		if (options.behaviourDrop) this.setBehaviourDrop(options.behaviourDrop);
		if (options.contextMenu) this.setContextMenu(options.contextMenu);
		// Fonctions diverses
		if (options.bind) {
			for (var i = 0; i < options.bind.length; i++) {
				this.bind(options.bind[i]);
			}
		}
		if (options.bindAsUnidirectional) {
			for (var i = 0; i < options.bindAsUnidirectional.length; i++) {
				this.bind(options.bindAsUnidirectional[i]);
			}
		}
		if (options.defaultImg) {
			var imgopen = (options.defaultImgOpen) ? options.defaultImgOpen : options.defaultImg;
			var imgclose = (options.defaultImgClose) ? options.defaultImgClose : options.defaultImg;
			this.setIcons(options.defaultImg, imgopen, imgclose);
		}
		if (options.defaultImgSelected || options.defaultImgOpenSelected || options.defaultImgCloseSelected) {
			var img = (options.defaultImgSelected) ? options.defaultImgSelected : null;
			var imgopen = (options.defaultImgOpenSelected) ? options.defaultImgOpenSelected : null;
			var imgclose = (options.defaultImgCloseSelected) ? options.defaultImgCloseSelected :null;
			this.setIconsSelected(img, imgopen, imgclose);
		}
        this.serverCookie = (options.serverCookie) ? options.serverCookie : false;
	},

	loadComplete : function () {
		this._adjustOpening();
		this._adjustCheck();
		this.setCookie(this.classTree + this.id);
        this.loaded = true;
		if (typeof(this.onLoad) == 'function') {
			this.onLoad();
		}
	},

	loadRunning : function (loaded) {
		if (typeof(this.onLoading) == 'function') {
			this.onLoading(loaded);
		}
	},

	replace : function (modelBranch, replacedBranch, copy) {
		var branch1 = this.getBranchById(modelBranch);
		if (!branch1) return false;
		return branch1.replace(replacedBranch, copy);
	},

	switchBranches : function (branch1, branch2) {
		var branch1 = this.getBranchById(branch1);
		if (!branch1) return false;
		branch1.switchWith(branch2);
	},

	/**
	 * Restaure les valeurs par défaut d'ouverture et check (selon type)
	 *
	 * Le type peut prendre la valeur "open", "check" ou "all"
	 *
	 * @access	public
	 * @param	string			type					Le type de default (open, check ou all)
	 * @return	void
	 */
	restoreDefault : function (type) {
		var s = this.defaultStruct;
		this._restaureDefault(s, type);
	},

	_restaureDefault : function (s, type) {
		var b = null;
		var open = false;
		var check = 0;
		for (var i = 0; i < s.length; i++) {
			b = this.getBranchById(s[i].id);
			if (b) {
				open = (s[i].open) ? true : this.openAll;
				check = (s[i].check == 1) ? 1 : 0;
				switch (type) {
					case 'open' :
						if (b.hasChildren()) {
							b.openIt(open);
						}
						break;
					case 'check' :
						b.check(check);
						b._adjustParentCheck();
						break;
					case 'all' :
					default :
						if (b.hasChildren()) {
							b.openIt(open);
						}
						//alert(b.getText() + ' : ' + check);
						b.check(check);
						b._adjustParentCheck();
				}
				// S'il y a des enfants, on va les restaurer aussi
				if (typeof(s[i].items) != 'undefined') {
					this._restaureDefault(s[i].items, type);
				}
			}
		}
	},
	
	/**
	 * Fonction qui lie des arbres TafelTree entre eux, bidirecitonnellement
	 *
	 * On lui passe autant de TafelTree voulu, en les séparant par des virgules
	 *
	 * @access	public
	 * @param	TafelTree			argument				Un ou plusieurs TafelTree
	 * @return	void
	 */
	bind : function () {
		var trees = this.bind.arguments;
		for (var i = 0; i < trees.length; i++) {
			if (!this.isBindedWith(trees[i])) {
				this.otherTrees.push(trees[i]);
				if (!trees[i].isBindedWith(this)) {
					trees[i].bind(this);
				}
			}
		}
	},
	
	/**
	 * Fonction qui lie des arbres TafelTree entre eux, mais unnidirecitonnel
	 *
	 * On lui passe autant de TafelTree voulu, en les séparant par des virgules
	 *
	 * @access	public
	 * @param	TafelTree			argument				Un ou plusieurs TafelTree
	 * @return	void
	 */
	bindAsUnidirectional : function () {
		var trees = this.bindAsUnidirectional.arguments;
		for (var i = 0; i < trees.length; i++) {
			if (!this.isBindedWith(trees[i])) {
				this.otherTrees.push(trees[i]);
			}
		}
	},

	isBindedWith : function (_tree) {
		var binded = false;
		for (var i = 0; i < this.otherTrees.length; i++) {
			if (this.otherTrees[i].id == _tree.id) {
				binded = true;
				break;
			}
		}
		return binded;
	},
	
	unselect : function () {
		var branch = null;
		for (var i = 0; i < this.selectedBranches.length; i++) {
			branch = this.selectedBranches[i];
			Element.removeClassName(branch.txt, this.classSelected);
			// On set l'icône s'il doit changer
			if (branch.getIconSelected() || branch.getOpenIconSelected() || branch.getCloseIconSelected()) {
				if (branch.hasChildren()) {
					branch.img.src = (branch.isOpened()) ? branch.tree.imgBase + branch.struct.imgopen : branch.tree.imgBase + branch.struct.imgclose;
				} else {
					branch.img.src = branch.tree.imgBase + branch.struct.img;
				}
			}
		}
		this.selectedBranches = [];
	},

	/**
	 * Retourne toutes les branches contenues entre deux d'entre-elles
	 *
	 * @access	public
	 * @param	TafelTreeBranch		branch1				La première borne
	 * @param	TafelTreeBranch		branch2				La deuxième borne
	 * @return	array									Un tableau de branche, ou false si rien n'a été trouvé
	 */
	getBranchesBetween : function (branch1, branch2) {
		var branch1 = this.getBranchById(branch1);
		var branch2 = this.getBranchById(branch2);
		if (!branch1 || !branch2) return false;
		// On quitte si ce n'est pas le même arbre
		if (branch1.tree.id != branch2.tree.id) return false;
		var found = false;
		var selected = [];
		var pos1 = branch1.getWithinOffset();
		var pos2 = branch2.getWithinOffset();
		var next = (pos1[1] <= pos2[1]) ? true : false;
		// On va chercher l'autre branche plus bas
		branch = (next) ? branch1.getNextBranch() : branch1.getPreviousBranch();
		while (branch) {
			selected.push(branch);
			if (branch.getId() == branch2.getId()) {
				found = true;
				break;
			}
			branch = (next) ? branch.getNextBranch() : branch.getPreviousBranch();
		}
		return (found) ? selected : false;
	},

	/**
	 * Retourne le nombre de branche comprises dans l'arbre
	 *
	 * @access	public
	 * @return	integer										Le nombre de branches
	 */
	countBranches : function () {
		var nb = this.roots.length;
		for (var i = 0; i < this.roots.length; i++) {
			nb += this.roots[i].countBranches();
		}
		return nb;
	},
	
	/**
	 * Retourne toutes les branches de l'arbre
	 *
	 * @access	public
	 * @param	function		filter						Le filtre des branches
	 * @return	array										Un tableau des branches de l'arbre
	 */
	getBranches : function (filter) {
		var branches = [];
		for (var i = 0; i < this.roots.length; i++) {
			if (typeof(filter) == 'function') {
				if (filter(this.roots[i])) {
					branches.push(this.roots[i]);
				}
			} else {
				branches.push(this.roots[i]);
			}
			branches = this.roots[i].getBranches(filter, branches);
		}
		return branches;
	},
	
	/**
	 * Récupère toutes les branches ouvertes
	 *
	 * @access	public
	 * @return	void
	 */
	getOpenedBranches : function () {
		var openedBranches = [];
		for (var i = 0; i < this.roots.length; i++) {
			if (this.roots[i].isOpened() && this.roots[i].hasChildren()) {
				openedBranches.push(this.roots[i]);
			}
			openedBranches = this.roots[i].getOpenedBranches(openedBranches);
		}
		return openedBranches;
	},
	
	/**
	 * Récupère toutes les branches checkées
	 *
	 * @access	public
	 * @return	void
	 */
	getCheckedBranches : function () {
		var checkedBranches = [];
		for (var i = 0; i < this.roots.length; i++) {
			if (this.roots[i].isChecked() == 1) {
				checkedBranches.push(this.roots[i]);
			}
			checkedBranches = this.roots[i].getCheckedBranches(checkedBranches);
		}
		return checkedBranches;
	},
	
	/**
	 * Récupère toutes les branches non checkées
	 *
	 * @access	public
	 * @return	void
	 */
	getUnCheckedBranches : function () {
		var uncheckedBranches = [];
		for (var i = 0; i < this.roots.length; i++) {
			if (this.roots[i].isChecked() == 0) {
				uncheckedBranches.push(this.roots[i]);
			}
			uncheckedBranches = this.roots[i].getUnCheckedBranches(uncheckedBranches);
		}
		return uncheckedBranches;
	},
	
	/**
	 * Récupère toutes les branches partiellement checkées
	 *
	 * @access	public
	 * @return	void
	 */
	getPartCheckedBranches : function () {
		var uncheckedBranches = [];
		for (var i = 0; i < this.roots.length; i++) {
			if (this.roots[i].isChecked() == -1) {
				uncheckedBranches.push(this.roots[i]);
			}
			uncheckedBranches = this.roots[i].getPartCheckedBranches(uncheckedBranches);
		}
		return uncheckedBranches;
	},

	getParentBranches : function () {
		var parents = [];
		for (var i = 0; i < this.roots.length; i++) {
			if (this.roots[i].hasChildren()) {
				parents.push(this.roots[i]);
			}
			parents = this.roots[i].getParentBranches(parents);
		}
		return parents;
	},

	getLeafBranches : function () {
		var leafs = [];
		for (var i = 0; i < this.roots.length; i++) {
			if (!this.roots[i].hasChildren()) {
				leafs.push(this.roots[i]);
			}
			leafs = this.roots[i].getLeafBranches(leafs);
		}
		return leafs;
	},

	/**
	 * Fonction qui ouvre tout l'arbre d'un coup
	 *
	 * @access	public
	 * @return	void
	 */
	expend : function () {
		for (var i = 0; i < this.roots.length; i++) {
			this.roots[i].expend();
		}
	},

	/**
	 * Fonction qui ferme tout l'arbre d'un coup
	 *
	 * @access	public
	 * @return	void
	 */
	collapse : function () {
		for (var i = 0; i < this.roots.length; i++) {
			this.roots[i].collapse();
		}
	},

	/**
	 * Méthode pour récupérer une branche en fonction de son id
	 *
	 * @access	public
	 * @param	string				position				L'id de la branche soeur ou parente, ou l'objet
	 * @param	object				item					La nouvelle branche
	 * @param	boolean				sibling					True pour 'sibling', false pour 'child'
	 * @param	boolean				isFirst					True pour l'insérer, soit comme 1er enfant, soit avant la soeur
	 * @return	void
	 */
	insertBranch : function (position, item, sibling, isFirst) {
		var position = this.getBranchById(position);
		if (!position) return false;
		if (!sibling) {
			if (!isFirst) {
				position.insertIntoLast(item);
			} else {
				position.insertIntoFirst(item);
			}
		} else {
			if (!isFirst) {
				position.insertAfter(item);
			} else {
				position.insertBefore(item);
			}
		}
	},

	moveBranch : function (position, item, sibling, isFirst) {
		var position = this.getBranchById(position);
		if (!position) return false;
		if (!sibling) {
			if (!isFirst) {
				position.moveIntoLast(item);
			} else {
				position.moveIntoFirst(item);
			}
		} else {
			if (!isFirst) {
				position.moveAfter(item);
			} else {
				position.moveBefore(item);
			}
		}
	},

	/**
	 * Fonction qui efface la branche
	 *
	 * @access	public
	 * @return	void
	 */
	removeBranch : function (branch) {
		try {
			var branch = this.getBranchById(branch);
			if (!branch) return false;
			// On enlève le drag&drop
			if (branch.objDrag) {
				branch.removeDragDrop();
			}
			if (!branch.isRoot) {
				// On supprime le noeud HTML
				branch.parent.obj.removeChild(branch.obj);
				// On l'enlève de la structure Javacript
				branch.parent.children.splice(branch.pos, 1);
				branch.parent.struct.items.splice(branch.pos, 1);
				if (branch.parent.children.length == 0) {
					branch.parent.setOpenableIcon(false);
					if (branch.tree.multiline) {
						branch._manageMultiline(branch.parent.tdImg, 2, false);
					}
				}
				// On repositionne la structure
				branch.parent._manageLine();
			} else {
				// On supprime le noeud HTML
				this.div.removeChild(branch.obj);
				// On l'enlève de la structure Javacript
				this.roots.splice(branch.pos, 1);
				if (this.roots[branch.pos-1]) {
					this.roots[branch.pos-1]._manageAfterRootInsert();
				}
			}
			branch = null;
		} catch (err) {
			throw new Error ('remove(base) : ' + err.message);
		}
	},

	/**
	 * Méthode pour récupérer une branche en fonction de son id généré
	 *
	 * @access	public
	 * @param	string				id						L'id généré de la branche
	 * @return	TafelBranch									La branche sélectionnée
	 */
	getBranchByIdObj : function (id) {
		try {
			var obj = null;
			for (var r = 0; r < this.roots.length; r++) {
				obj = this._getBranchByIdObj(id, this.roots[r]);
				if (obj) {
					break;
				}
			}
			return obj;
		} catch (err) {
			throw new Error ('getBranchByIdObj(func) : ' + err.message);
		}
	},

	/**
	 * Méthode pour récupérer une branche en fonction de son id utilisateur
	 *
	 * @access	public
	 * @param	string				id						L'id utilisateur de la branche
	 * @return	TafelBranch									La branche sélectionnée
	 */
	getBranchById : function (id) {
		try {
			if (typeof(id) == 'object') return id;
			var obj = null;
			for (var r = 0; r < this.roots.length; r++) {
				obj = this._getBranchById(id, this.roots[r]);
				if (obj) break;
			}
			if (!obj) {
				// On magouille avec les roots pour ne pas passer
				// dans une boucle infinie (à cause du getBranchById)
				var ro = null;
				for (var i = 0; i < this.otherTrees.length; i++) {
					ro = this.otherTrees[i].roots;
					for (var r = 0; r < ro.length; r++) {
						obj = this.otherTrees[i]._getBranchById(id, ro[r]);
						if (obj) break;
					}
					if (obj) break;
				}
			}
			return obj;
		} catch (err) {
			throw new Error ('getBranchById(func) : ' + err.message);
		}
	},

	/**
	 * Méthode de gestion de debug
	 *
	 * @access	public
	 * @param	string				str						Une string à afficher (optionnel)
	 * @return	void
	 */
	debug : function (str) {
		try {
			this.debugObj.style.display = 'block';
			if (typeof(this.onDebug) == 'function') {
				this.onDebug(this, this.debugObj, (str) ? str : '');
			} else {
				this.debugObj.innerHTML += str;
			}
		} catch (err) {
			throw new Error ('debug(func) : ' + err.message);
		}
	},

	/**
	 * Fonction pour afficher l'ojbet de manière cool
	 *
	 * @access	public
	 * @return	string										La string de l'objet
	 */
	toString : function () {
		var obj = {
			'id' : this.id,
			'width' : this.div.offsetWidth,
			'height' : this.div.offsetHeight,
			'imgPath' : this.imgBase,
			'roots' : this.roots.length
		};
		var str = 'TafelTree {';
		for (var i in obj) {
			str += TafelTree.debugReturn + TafelTree.debugTab + i + ' : ' + obj[i];
		}
		str += TafelTree.debugReturn + '}';
		return str;
	},

	/**
	 * Fonction qui sérialise l'arbre pour en faire une string JSON
	 *
	 * @access	public
	 * @return	string										La string de l'objet
	 */	
	serialize : function (debug) {
		var rt = (debug) ? TafelTree.debugReturn : '';
		var str = (debug) ? 'TafelTree (' + this.id + ') [' : '[';
		for (var i = 0; i < this.roots.length; i++) {
			str += this.roots[i].serialize(debug, true);
			if (i < this.roots.length - 1) {
				str += ',';
			}
		}
		str += rt + ((debug) ? '];' : ']');
		if (debug) {
			return str;
		} else {
			return encodeURIComponent(str);
		}
	},
	
	/**
	 * Fonction qui renvoie les paramètres de l'URL
	 *
	 * ils sont renvoyés sous cette forme :
			params[0] = {
				'name' : 'paramName',
				'value': 'paramValue'
			}
	 *
	 * @access	public
	 * @param	string				url						L'url à decomposer
	 * @return	array										Le tableau de paramètres
	 */
	getURLParams : function (url) {
		var params = [];
		if (url.indexOf('?') > -1) {
			var a1 = url.split('?');
			var a2 = a1[1].split('&');
			var a3 = '';
			for (var i = 0; i < a2.length; i++) {
				a3 = a2[i].split('=');
				if (a3.length == 2) {
					params.push({
						'name' : a3[0],
						'value': a3[1]
					})
				}
			}
		}
		return params;
	},


	/**
	 *------------------------------------------------------------------------------
	 *							TafelTree private methods
	 *------------------------------------------------------------------------------
	 */

	_generateBigTree : function () {
		var i = this.bigTreeLoading;
		var isNotFirst = false;
		var isNotLast = false;
		if (i < this.baseStruct.length) {
			isNotFirst = (i > 0) ? true : false;
			isNotLast = (i < this.baseStruct.length - 1) ? true : false;
			this.roots[i] = new TafelTreeRoot(this, this.baseStruct[i], 0, isNotFirst, isNotLast, i);
			this.div.appendChild(this.roots[i].obj);
			this.loadRunning(this.roots[i]);
			this.bigTreeLoading++;
			setTimeout(this._generateBigTree.bind(this), 10);
		} else {
			this.loaded = true;
		}
	},

	_checkLoad : function () {
		var complete = true;
		if (this.loaded) {
			for (var i = 0; i < this.roots.length; i++) {
				if (!this.roots[i].loaded || !this._checkLoadChildren(this.roots[i])) {
					complete = false;
					break;
				}
			}
		} else {
			complete = false;
		}
		if (!complete){
			setTimeout(this._checkLoad.bind(this), 100);
		} else {
			this.loadComplete();
		}
	},
	
	_checkLoadChildren : function (branch) {
		var complete = true;
		if (branch.loaded) {
			for (var i = 0; i < branch.children.length; i++) {
				if (!branch.children[i].loaded || !this._checkLoadChildren(branch.children[i])) {
					complete = false;
					break;
				}
			}
		} else {
			complete = false;
		}
		return complete;
	},
	
	_adjustOpening : function () {
		// Si on utilise les cookies, on s'en sert pour ouvrir ou fermer les branches
		if (this.useCookie && this.cookieOpened) {
			var branch = null;
			for (var i = 0; i < this.cookieOpened.length; i++) {
				branch = this.getBranchById(this.cookieOpened[i]);
				if (typeof(branch) == 'object' && branch.hasChildren()) {
					if (branch.children.length > 0) {
						// Cette branche est une branche normale
						branch.openIt(true);
					} else {
						// Cette branche est une branche qui a ses enfants sur le serveur
						// On va donc les récupérer
						if (typeof(branch.struct.onopenpopulate) == 'function' && branch.eventable) {
							branch._openPopulate();
							branch.openIt(true);
						}
					}
				}
			}
		}
	},

	_adjustCheck : function () {
		// On ajuste les checks d'après les cookies
		var branch = null;
		if (this.checkboxes && this.useCookie && this.cookieChecked) {
			for (var i = 0; i < this.cookieChecked.length; i++) {
				branch = this.getBranchById(this.cookieChecked[i]);
				if (typeof(branch) == 'object') {
					branch.check(1);
				}
			}
		}
		// Si on a des checkboxes, on corrige les images en fonction des checks
		if (this.checkboxes && this.checkboxesThreeState) {
			var checked = this.getCheckedBranches();
			for (var i = 0; i < checked.length; i++) {
				checked[i]._adjustParentCheck();
			}
		}
	},

	/**
	 * Méthode récursive pour récupérer une branche en fonction de son id généré
	 *
	 * @access	private
	 * @param	string				id						L'id généré de la branche recherchée
	 * @param	TafelTreeBranch		obj						La branche courante
	 * @return	TafelBranch									La branche sélectionnée
	 */
	_getBranchByIdObj : function (id, obj) {
		try {
			var ob = '';
			if (obj.idObj == id) {
				return obj;
			}
			if (typeof(obj.children) == 'object') {
				for (var c = 0; c < obj.children.length; c++) {
					ob = this._getBranchByIdObj(id, obj.children[c]);
					if (ob) {
						return ob;
					}
				}
			}
			return ob;
		} catch (err) {
			throw new Error ('_getBranchByIdObj(func) : ' + err.message);
		}
	},

	/**
	 * Méthode récursive pour récupérer une branche en fonction de son id utilisateur
	 *
	 * @access	private
	 * @param	string				id						L'id utilisateur de la branche recherchée
	 * @param	TafelTreeBranch		obj						La branche courante
	 * @return	TafelBranch									La branche sélectionnée
	 */
	_getBranchById : function (id, obj) {
		try {
			var ob = '';
			if (obj.getId() == id) {
				return obj;
			}
			if (typeof(obj.children) == 'object') {
				for (var c = 0; c < obj.children.length; c++) {
					ob = this._getBranchById(id, obj.children[c]);
					if (ob) {
						return ob;
					}
				}
			}
			return ob;
		} catch (err) {
			throw new Error ('_getBranchById(func) : ' + err.message);
		}
	},

	/**
	 * Fonction qui change la structure de la branche
	 *
	 * @access	private
	 * @param	TafelTreeBranch		branch					La nouvelle structure
	 * @return	void
	 */
	_changeStruct : function (branch) {
		try {
			while (typeof(branch.parent) != 'undefined') {
				branch.parent.struct.items.splice(branch.pos, 1, branch.struct);
				if (typeof(branch.parent) != 'undefined') {
					branch = branch.parent;
				}
			}
		} catch (err) {
			throw new Error ('_changeStruct(func) : ' + err.message);
		}
	},

	/**
	 * Méthode pour ajouter l'élément principal
	 *
	 * @access	private
	 * @return	HTMLDivElement								L'élément DIV créé
	 */
	_addTree : function () {
		var div = document.createElement('div');
		div.className = this.classTree;
		return div;
	},


	/**
	 *------------------------------------------------------------------------------
	 *							TafelTree Cookies Management
	 *------------------------------------------------------------------------------
	 */
	
	/**
	 * Méthode qui sauve le contenu dans le cookie. Propre à l'application
	 *
	 * @access	public
	 * @param	string				name					Nom du cookie
	 * @return	void
	 */
	setCookie : function (name) {
		try {
			var str = 'cookieactivate' + this.cookieSeparator;
			// Les branches ouvertes
			var arr = this.getOpenedBranches();
			for (var i = 0; i < arr.length; i++) {
				str = str + arr[i].getId() + this.cookieSeparator;
			}
			// Les branches checkées
			str += this.cookieCheckSeparator;
			var arr = this.getCheckedBranches();
			for (var i = 0; i < arr.length; i++) {
				str = str + arr[i].getId() + this.cookieSeparator;
			}
            if (!this.serverCookie) {
                this._saveCookie(name, str, '', '/', '', '');
            } else {
                // send cookie server only if tree is loaded (optimization)
                if (this.loaded) {
                    new Ajax.Request(this.serverCookie, {
                        'method' : 'post',
                        'parameters' : 'type=set&cookieString=' + str,
                        'onComplete' : this._cookieSend.bind(this),
                        'onFailure' : this._cookieFailure.bind(this)
                    });
                }
            }
		} catch (err) {
			throw new Error ('setCookie(func) : ' + err.message);
		}
	},
	
	/**
	 * Méthode qui récupère le contenu d'un cookie en fonction du nom
	 *
	 * @access	public
	 * @param	string				name					Nom du cookie
	 * @return	string										Le contenu du cookie
	 */
	getCookie : function (name) {
		try {
            if (!this.serverCookie) {
    			if (name != ''){
    				var start = document.cookie.indexOf(name + '=');
    				var len = start + name.length + 1;
    				if ((!start) && (name != document.cookie.substring(0, name.length))){
    					return null;
    				}
    				if ( start == -1 ) return null;
    				var end = document.cookie.indexOf(';', len);
    				if (end == -1){
    					end = document.cookie.length;
    				}
    				return unescape(document.cookie.substring(len, end));
    			}
            } else {
                new Ajax.Request(this.serverCookie, {
                    'method' : 'post',
                    'parameters' : 'type=get',
                    'onComplete' : this._getCookieComplete.bind(this),
                    'onFailure' : this._cookieFailure.bind(this)
                });
            }
            return null;
		} catch (err) {
			throw new Error ('getCookie(func) : ' + err.message);
		}
	},
    
    _cookieSend : function (response) {
        alert('ok');
    },
    
    _getCookieComplete : function (response) {
        var fromCookie = response.responseText;
        if (fromCookie) {
            var branches = fromCookie.split(this.cookieCheckSeparator);
            // Branches ouvertes
            this.cookieOpened = [];
            this.cookieOpened = branches[0].split(this.cookieSeparator);
            this.cookieOpened.shift();
            // Branches checkées (avec anti-bug pour les anciennes versions et anciens cookies)
            this.cookieChecked = [];
            if (branches.length > 1) {
                this.cookieChecked = branches[1].split(this.cookieSeparator);
            }
        }    
        if (this.options.generate) {
			this.generate();
		}
		if (this.options.generateBigTree) {
			this.generate(true);
		}
    },
    
    _cookieFailure : function (response) {
        // do nothing
    },
	
	/**
	 * Méthode qui supprime un cookie. Seul le nom est obligatoire
	 *
	 * @access	public
	 * @param	string				name					Nom du cookie
	 * @param	string				path					Le chemin
	 * @param	string				domain					Le domaine
	 * @return	void
	 */
	deleteCookie : function (name, path, domain) {
		try {
			if (get_cookie(name)) document.cookie = name + '=' +
			( ( path ) ? ';path=' + path : "") +
			( ( domain ) ? ';domain=' + domain : '') +
			';expires=Thu, 01-Jan-1970 00:00:01 GMT';
		} catch (err) {
			throw new Error ('deleteCookie(func) : ' + err.message);
		}
	},
	
	/**
	 * Méthode qui sauve le contenu dans le cookie. Propre à toute application
	 *
	 * @access	private
	 * @param	string				name					Nom du cookie
	 * @param	string				value					La valeur à enregistrer
	 * @param	integer				expires					La durée de vie du cookie, en jour
	 * @param	string				path					Le chemin
	 * @param	string				domain					Le domaine
	 * @param	string				secure					?
	 * @return	void
	 */
	_saveCookie : function (name, value, expires, path, domain, secure) {
		try {
			// set time, it's in milliseconds
			var today = new Date();
			today.setTime(today.getTime());
			if (expires){
				expires = expires * 1000 * 60 * 60 * 24;
			}
			var expires_date = new Date(today.getTime() + (expires));
			
			document.cookie = name + '=' +escape(value) +
			( ( expires ) ? ';expires=' + expires_date.toGMTString() : '') + 
			( ( path ) ? ';path=' + path : '') + 
			( ( domain ) ? ';domain=' + domain : '') +
			( ( secure ) ? ';secure' : '');
		} catch (err) {
			throw new Error ('_saveCookie(func) : ' + err.message);
		}
	},


	/**
	 *------------------------------------------------------------------------------
	 *							TafelTree Events Management
	 *------------------------------------------------------------------------------
	 */

	/**
	 * Méthode qui appelle la méthode utilisateur après le load de l'arbre
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnLoad : function (func) {
		this.onLoad = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur pendant le load de l'arbre
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnLoading : function (func) {
		this.onLoading = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur après l'ouverture ou fermeture d'un noeud
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnOpen : function (func) {
		this.onOpen = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur avant l'ouverture ou fermeture d'un noeud
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnBeforeOpen : function (func) {
		this.onBeforeOpen = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur lorsque la souris est sur un noeud
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnMouseOver : function (func) {
		this.onMouseOver = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur lorsque la souris quitte le noeud
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnMouseOut : function (func) {
		this.onMouseOut = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur après un clic sur un noeud
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnClick : function (func) {
		this.onClick = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur après un mouse down
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnMouseDown : function (func) {
		this.onMouseDown = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur après un mouse up
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnMouseUp : function (func) {
		this.onMouseUp = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur lors d'un double-clic sur un noeud
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnDblClick : function (func) {
		this.onDblClick = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur lors de la fin de l'édition d'une branche
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @param	string				link					Le lien de la page ajax
	 * @return	void
	 */
	setOnEdit : function (func, link) {
		if (link) {
			this.onEditAjax = {
				'func' : eval(func),
				'link' : link
			};
		} else {
			this.onEdit = eval(func);
		}
		this.editableBranches = true;
	},

	/**
	 * Méthode qui appelle la méthode utilisateur lorsqu'on clique sur une checkbox, avant que celle-ci change de status
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnBeforeCheck : function (func) {
		this.onBeforeCheck = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur lorsqu'on clique sur une checkbox, après qu'elle ait changé de status
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnCheck : function (func) {
		this.onCheck = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur lors d'un drop sur un noeud
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnDrop : function (func) {
		this.onDrop = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur après un drop sur un noeud
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @return	void
	 */
	setOnDropAfter : function (func) {
		this.onErrorAjax = eval(func);
	},

	/**
	 * Méthode qui appelle la méthode utilisateur lors d'un drop sur un noeud
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @param	string				link					Le lien de la page ajax
	 * @param	boolean				propagateRestiction		True pour interdir le mouvement des enfants de la branche droppée
	 * @return	void
	 */
	setOnDropAjax : function (func, link) {
		this.onDropAjax = {
			'func' : eval(func),
			'link' : link
		};
	},
	
	/**
	 * Fonction appelée au retour de la requête Ajax après un open de la branche
	 *
	 * @access	public
	 * @param	function|boolean	func					La fonction utilisateur ou true
	 * @param	string				link					Le lien de la page ajax
	 * @return	void
	 */
	setOnOpenPopulate : function (func, link) {
		this.onOpenPopulate = {
			'func' : eval(func),
			'link' : link
		};
	},

	/**
	 * Méthode qui appelle la méthode utilisateur lors de la fin de l'édition d'une branche
	 *
	 * @access	public
	 * @param	function			func					La fonction utilisateur
	 * @param	string				link					Le lien de la page ajax
	 * @return	void
	 */
	setOnEditAjax : function (func, link) {
		this.onEditAjax = {
			'func' : eval(func),
			'link' : link
		};
		this.editableBranches = true;
	},
	
	setOnDragStartEffect : function (func) {
		this.onDragStartEffect = eval(func);
	},
	
	setOnDragEndEffect : function (func) {
		this.onDragEndEffect = eval(func);
	} 
};















































/**
 *------------------------------------------------------------------------------
 *							Abstract TafelTreeBaseBranch Class
 *------------------------------------------------------------------------------
 */

var TafelTreeBaseBranch = Class.create();

TafelTreeBaseBranch.prototype = {
	
	initialize : function () {},


	/**
	 *------------------------------------------------------------------------------
	 *							TafelTreeBaseBranch getters & setters
	 *------------------------------------------------------------------------------
	 */
	
	getId : function () {
		return this.struct.id;
	},
	
	getText : function () {
		return this.struct.txt;
	},
	
	getLevel : function () {
		return this.level;
	},
	
	getTree : function () {
		return this.tree;
	},

	getParent : function () {
		return (this.isRoot) ? null : this.parent;
	},

	/**
	 * Retourne la racine parente, null s'il n'y en a pas
	 *
	 * @access	public
	 * @return	TafelTreeRoot							La racine parente
	 */
	getAncestor : function () {
		return (this.isRoot) ? null : this.root;
	},

	/**
	 * Retourne tous les parents, racine comprise.
	 *
	 * Le 1er élément du tableau est le parent direct, le dernier étant
	 * la racine
	 *
	 * @access	public
	 * @return	array									Les parents
	 */
	getParents : function () {
		var parents = [];
		var branch = this;
		while (branch.parent) {
			parents.push(branch.parent);
			branch = branch.parent;
		}
		return parents;
	},
	
	getChildren : function () {
		return this.children;
	},
	
	getIcon : function () {
		return this.struct.img;
	},
	
	getOpenIcon : function () {
		return this.struct.imgopen;
	},
	
	getCloseIcon : function () {
		return this.struct.imgclose;
	},
	
	getIconSelected : function () {
		return this.struct.imgselected;
	},
	
	getOpenIconSelected : function () {
		return this.struct.imgopenselected;
	},
	
	getCloseIconSelected : function () {
		return this.struct.imgcloseselected;
	},
	
	getCurrentIcon : function () {
		var img = this._getImgInfo(this.img);
		return img.fullName;
	},
	
	setText : function (text) {
		this.struct.txt = text;
		this.txt.innerHTML = text;
	},
	
	setIcons : function (icon, iconOpen, iconClose) {
		this.struct.img = icon;
		this.struct.imgopen = (iconOpen) ? iconOpen : icon;
		this.struct.imgclose = (iconClose) ? iconClose : icon;
		if (this.hasChildren()) {
			this.img.src = (this.isOpened()) ? this.tree.imgBase + this.struct.imgopen : this.tree.imgBase + this.struct.imgclose;
		} else {
			this.img.src = this.tree.imgBase + this.struct.img;
		}
	},
	
	setIconsSelected : function (icon, iconOpen, iconClose) {
		this.struct.imgselected = icon;
		this.struct.imgopenselected = (iconOpen) ? iconOpen : null;
		this.struct.imgcloseselected = (iconClose) ? iconClose : null;
		if (this.isSelected()) {
			if (this.hasChildren()) {
				this.img.src = (this.isOpened()) ? this.tree.imgBase + this.struct.imgopenselected : this.tree.imgBase + this.struct.imgcloseselected;
			} else {
				this.img.src = this.tree.imgBase + this.struct.imgselected;
			}
		}
	},
	
	/**
	 * Méthode qui change l'id de l'élément. A utiliser avec parcimonie
	 *
	 * @access	public
	 * @param	string			newId					Le nouvel id
	 * @return	boolean									True si tout est ok, false si l'id existe déjà dans l'arbre
	 */
	changeId : function (newId) {
		var used = this.tree.getBranchById(newId);
		if (!used) {
			this.struct.id = newId;
			this.tree._changeStruct(this);
			return true;
		} else {
			return false;
		}
	},
	
	/**
	 * Méthode qui détermine si l'élément a des enfants ou non*
	 *
	 * @access	public
	 * @return	boolean									True s'il a des enfants, false sinon
	 */
	hasChildren : function () {
		return (this.struct.items.length > 0 || this.struct.canhavechildren) ? true : false;
	},

	isOpened : function () {
		return (this.struct.open) ? true : false;
	},

	isAlwaysLast : function () {
		return (this.struct.last) ? true : false;
	},

	isOpenedInCookie : function () {
		if (this.tree.useCookie && this.tree.cookieOpened) {
			for (var i = 0; i < this.tree.cookieOpened.length; i++) {
				if (this.getId() == this.tree.cookieOpened[i]) return true;
			}
		}
		return false;
	},

	/**
	 * Retourne true si la branche est visible
	 *
	 * @access	public
	 * @return	boolean									True si la branche est visible, false sinon
	 */
	isVisible : function () {
		var visible = true;
		var branch = this;
		while (branch.parent) {
			if (branch.parent.isOpened()) {
				branch = branch.parent;
			} else {
				visible = false;
				break;
			}
		}
		return visible;
	},

	/**
	 * Retourne TRUE si la branche est sélectionnée
	 *
	 * @access	public
	 * @return	boolean										True si la branche est sélectionnée, false sinon
	 */
	isSelected : function () {
		return (Element.hasClassName(this.txt, this.tree.classSelected)) ? true : false;
	},


	/**
	 *------------------------------------------------------------------------------
	 *							TafelTreeBaseBranch public functions
	 *------------------------------------------------------------------------------
	 */

	/**
	 * Rafraichit les enfants de la branche en fonction de ce qu'il y a sur le serveur
	 *
	 * @access	public
	 * @return	void
	 */
	refreshChildren : function () {
		this.removeChildren();
		this._openPopulate();
	},
	
	/**
	 * Clone toute la structure de la branche
	 *
	 * @access	public*
	 * @param	boolean			withDefaultFunc			True pour copier les fonctions par defaut de l'arbre
	 * @return	object									La structure JSON de la branche
	 */
	clone : function (withDefaultFunc) {
		var struct = {};
		for (var property in this.struct) {
			if (property != 'items') {
				// On prend les fonctions seulement si elles sont définies pour la branche
				if (!withDefaultFunc && typeof(this.struct[property]) == 'function') {
					if (!eval('this.' + property + 'Default')) {
						struct[property] = this.struct[property];
					}
				} else {
					struct[property] = this.struct[property];
				}
			}
		}
		if (this.hasChildren()) {
			struct.items = [];
			for (var i = 0; i < this.children.length; i++) {
				struct.items.push(this.children[i].clone(withDefaultFunc)); 
			}
		}
		this.copiedTimes++;
		struct.id = struct.id + this.tree.copyNameBreak + this.tree.idTree;
		struct.txt = struct.txt + this.tree.copyName.replace('%n', this.copiedTimes);
		return struct;
	},

	/**
	 * Retourne le premier enfant de la branche, ou null s'il y en a pas
	 *
	 * @access	public
	 * @return	TafelTreeBranch								Le premier enfant de la branche
	 */
	getFirstBranch : function () {
		return (this.children.length > 0) ? this.children[0] : null;
	},

	/**
	 * Retourne le dernier enfant de la branche, ou null s'il y en a pas
	 *
	 * @access	public
	 * @return	TafelTreeBranch								Le dernier enfant de la branche
	 */
	getLastBranch : function () {
		var pos = this.children.length - 1;
		return (pos >= 0) ? this.children[pos] : null;
	},
	
	/**
	 * Fonction qui récupère la branche précédente du même niveau
	 *
	 * @access	public
	 * @return	TafelTreeBranch								La branche si elle existe, null sinon
	 */
	getPreviousSibling : function () {
		var pos = this.pos - 1;
		var branch = null;
		if (this.isRoot) {
			if (pos >= 0) branch = this.tree.roots[pos];
		} else {
			if (pos >= 0) branch = this.parent.children[pos];
		}
		return branch;
	},
	
	/**
	 * Fonction qui récupère la branche suivante du même niveau
	 *
	 * @access	public
	 * @return	TafelTreeBranch								La branche si elle existe, null sinon
	 */
	getNextSibling : function () {
		var pos = this.pos + 1;
		var branch = null;
		if (this.isRoot) {
			if (pos < this.tree.roots.length) branch = this.tree.roots[pos];
		} else {
			if (pos < this.parent.children.length) branch = this.parent.children[pos];
		}
		return branch;
	},

	/**
	 * Retourne la branche précédente dans l'arbre, pas forcément de même niveau
	 *
	 * @access	public
	 * @return	TafelTreeBranch								La branche précédente, null s'il n'y en a pas
	 */
	getPreviousBranch : function () {
		var branch = null;
		var previous = this.getPreviousSibling();
		// Si elle a une soeur précédente
		if (previous) {
			// On regarde si elle a des enfants et est ouverte
			if (previous.hasChildren()) {
				// Si oui, on prend son dernier enfant
				while (previous.hasChildren()) {
					previous = previous.getLastBranch();
				}
				branch = previous;
			} else {
				// Si ce n'est pas le cas, on la prend elle
				branch = previous;
			}
		} else {
			// Si elle n'a pas de soeur précédente, on prend le parent (s'il existe)
			if (this.parent) {
				branch = this.parent;
			}
		}
		return branch;
	},

	/**
	 * Retourne la branche suivante dans l'arbre, pas forcément de même niveau
	 *
	 * @access	public
	 * @return	TafelTreeBranch								La branche suivante, null s'il n'y en a pas
	 */
	getNextBranch : function () {
		var branch = null;
		// Récupère le premier enfant, s'il y en a un
		branch = this.getFirstBranch();
		if (!branch) {
			// Récupère sa prochaine soeur
			branch = this.getNextSibling();
			if (!branch) {
				// Récupère la soeur du parent ou tout du moins d'un ancêtre
				var b = null;
				branch = this.parent;
				while (!b && branch) {
					b = branch.getNextSibling();
					branch = branch.parent;
				}
				branch = b;
			}
		}
		return branch;
	},
	
	/**
	 * Retourne la branch ouverte précédente (pas forcément du même niveau)
	 *
	 * @access	public
	 * @return	TafelTreeBranch								La branche précédente ouverte, null s'il n'y en a pas
	 */
	getPreviousOpenedBranch : function () {
		var branch = null;
		var previous = this.getPreviousSibling();
		// Si elle a une soeur précédente
		if (previous) {
			// On regarde si elle a des enfants et est ouverte
			if (previous.hasChildren() && previous.isOpened()) {
				// Si oui, on prend son dernier enfant
				while (previous.hasChildren() && previous.isOpened()) {
					previous = previous.getLastBranch();
				}
				branch = previous;
			} else {
				// Si ce n'est pas le cas, on la prend elle
				branch = previous;
			}
		} else {
			// Si elle n'a pas de soeur précédente, on prend le parent (s'il existe)
			if (this.parent) {
				branch = this.parent;
			}
		}
		return branch;
	},
	
	/**
	 * Retourne la branch ouverte suivante (pas forcément du même niveau)
	 *
	 * @access	public
	 * @return	TafelTreeBranch								La branche suivante ouverte, null s'il n'y en a pas
	 */
	getNextOpenedBranch : function () {
		var branch = null;
		// Si elle a des enfants et qu'elle est ouverte, on prend le 1er
		if (this.hasChildren() && this.isOpened()) {
			branch = this.getFirstBranch();
		} else {
			// Si elle a pas d'enfants, on prend sa prochaine soeur
			var next = this;
			while (!branch) {
				branch = next.getNextSibling();
				next = next.parent;
				if (!next) break;
			}
		}
		return branch;
	},

	/**
	 * Fonction qui supprime tous les enfants
	 *
	 * @access	public
	 * @return	boolean										True si la branche est un enfant de elem
	 */
	removeChildren : function () {
		// On utilise concat() pour ne pas faire de référence sur this.children
		var children = this.children.concat();
		for (var i = 0; i < children.length; i++) {
			this.tree.removeBranch(children[i]);
		}
	},

	/**
	 * Fonction qui détermine si la branche est enfant de elem
	 *
	 * @access	public
	 * @param	TafelTreeBranch		elem					La branche dont on veut savoir si elle est un ancêtre
	 * @return	boolean										True si la branche est un enfant de elem
	 */
	isChild : function (elem) {
		var elem = this.tree.getBranchById(elem);
		if (!elem) return false;
		return this._isChild(this, elem);
	},

	/**
	 * Fonction qui ouvre ou ferme la branche
	 *
	 * @access	public
	 * @param	boolean				open					True pour ouvrir la branche
	 * @return	void
	 */
	openIt : function (open) {
		try {
			if (!open) {
				this._closeChild();
				if (this.tree.multiline) {
					this._manageMultiline(this.tdImg, 2, false);
				}
			} else {
				if (this.tree.onlyOneOpened) {
					this.closeSiblings();
				}
				this._openChild();
				if (this.tree.multiline) {
					this._manageMultiline(this.tdImg, 2, true);
				}
			}
			if (this.tree.useCookie) {
				this.tree.setCookie(this.tree.classTree + this.tree.id);
			}
		} catch (err) {
			throw new Error ('openIt(base) : ' + err.message);
		}
	},

	/**
	 * Fonction qui insère une branche comme enfant, en fin de liste
	 *
	 * @access	public
	 * @param	object				item					La nouvelle branche
	 * @return	void
	 */
	insert : function (item) {
		return this.insertIntoLast(item);
	},
	insertIntoLast : function (item) {
		var pos = this.children.length;
		var isNotFirst = (this.hasChildren()) ? true : false;
		this.children[pos] = new TafelTreeBranch((this.isRoot) ? this : this.root, this, item, this.level + 1, isNotFirst, false, pos);
		this.struct.items[pos] = item;
		this.obj.appendChild(this.children[pos].obj);
		this._manageAfterInsert(pos);
		return this.children[pos];
	},

	insertIntoFirst : function (item) {
		var pos = 0;
		var posBefore = 1;
		var isNotLast = (this.hasChildren()) ? false : true;
		this._movePartStruct(pos);
		this.struct.items[pos] = item;
		this.children[pos] = new TafelTreeBranch((this.isRoot) ? this : this.root, this, item, this.level + 1, false, isNotLast, pos);
		try {
			this.obj.insertBefore(this.children[pos].obj, this.children[posBefore].obj);
		} catch (err) {
			this.obj.appendChild(this.children[pos].obj);
		}
		this._manageAfterInsert(pos);
		return this.children[pos];
	},
	
	/**
	 * Fonction qui ferme toutes les branches soeurs
	 *
	 * @access	public
	 * @return	void
	 */
	closeSiblings : function () {
		var obj = null;
		if (this.parent) {
			for (var i = 0; i < this.parent.children.length; i++) {
				obj = this.parent.children[i];
				if (obj.idObj != this.idObj && obj.hasChildren()) {
					obj.openIt(false);
				}
			}
		} else if (this.isRoot) {
			for (var i = 0; i < this.tree.roots.length; i++) {
				obj = this.tree.roots[i];
				if (obj.idObj != this.idObj && obj.hasChildren()) {
					obj.openIt(false);
				}
			}
		}
	},
	
	/**
	 * Ajoute une classe CSS au texte
	 *
	 * @access	public
	 * @param	string			style					Le style CSS à ajouter
	 * @return	void
	 */
	addClass : function (style) {
		Element.addClassName(this.txt, style);
	},
	
	/**
	 * Retire une classe CSS du texte
	 *
	 * @access	public
	 * @param	string			style					Le style CSS à enlever
	 * @return	void
	 */
	removeClass : function (style) {
		Element.removeClassName(this.txt, style);
	},

	/**
	 * Retourne un objet anonyme représentant l'image précédant l'icône (un plus, par ex.)
	 *
	 * L'objet a cette structure :
		var obj = {
			'img'     : HTMLimgElement,
			'number'  : Le numéro de l'image (juste avant l'extension),
			'type'    : le nom de l'image sans le numéro et sans l'extension
			'name'    : Le nom de l'image sans l'extension,
			'fullName': Le nom de l'image avec l'extension
		};
	 *
	 * @access	public
	 * @return	object										L'objet anonyme de l'image
	 */
	getImgBeforeIcon : function () {
		try {
			var img = this.beforeIcon.getElementsByTagName('img')[0];
			return this._getImgInfo(img);
		} catch (err) {
			throw new Error ('getImgBeforeIcon(base) : ' + err.message);
		}
	},
	
	/**
	 * Fonction change l'icône en fonction des enfants, s'il y en a ou pas
	 *
	 * @access	public
	 * @param	boolean			openable					True pour mettre l'icone d'ouverture
	 * @return	void
	 */
	setOpenableIcon : function (openable) {
		var im = this.getImgBeforeIcon();
		var img = im.img;
		if (openable) {
			this.struct.open = true;
			this.img.src = this.tree.imgBase + this.struct.imgopen;
			if (!this.isRoot) {
				img.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgMinus3 : this.tree.imgBase + this.tree.imgMinus2;
			} else {
				if (this.hasSiblingsBefore) {
					img.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgMinus3 : this.tree.imgBase + this.tree.imgMinus2;
				} else {
					img.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgMinus4 : this.tree.imgBase + this.tree.imgMinus5;
				}
			}
			Event.observe(img, 'click', this.setOpen.bindAsEventListener(this), false);
			Event.observe(img, 'mouseover', this.evt_openMouseOver.bindAsEventListener(this), false);
			Event.observe(img, 'mouseout', this.evt_openMouseOut.bindAsEventListener(this), false);
		} else {
			this.struct.open = false;
			this.struct.canhavechildren = false;
			this.img.src = this.tree.imgBase + this.struct.img;
			var td = img.parentNode;
			var newImg = document.createElement('img');
			td.removeChild(img);
			if (!this.isRoot) {
				newImg.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgLine3 : this.tree.imgBase + this.tree.imgLine2;
			} else {
				if (this.hasSiblingsBefore) {
					newImg.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgLine3 : this.tree.imgBase + this.tree.imgLine2;
				} else {
					newImg.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgLine4 : this.tree.imgBase + this.tree.imgLine5;
				}
			}
			td.appendChild(newImg);
		}
	},

	/**
	 * Fonction qui affiche la branche de manière cool
	 *
	 * @access	public
	 * @return	string										La string à afficher
	 */
	toString : function () {		
		var str = (this.isRoot) ? 'TafelTreeRoot {' : 'TafelTreeBranch {';
		// Définition de toutes les propriétés
		var strSave = '';
		for (var attr in this.struct) {
			if (attr != 'items') {
				strSave = (typeof(this.struct[attr]) != 'function') ? this.struct[attr] : true;
				str += TafelTree.debugReturn + TafelTree.debugTab + attr + ' : ' + strSave;
			}
		}
		str += TafelTree.debugReturn + TafelTree.debugTab + 'children : ' + this.children.length;
		str += TafelTree.debugReturn + '}';
		return str;
	},
	
	isChecked : function (dbg) {
		if (this.tree.checkboxes && this.checkbox) {
			var img = this._getImgInfo(this.checkbox);
			if (img.fullName.replace('_over', '') == this.tree.imgCheck2) {
				return 1;
			}
			if (img.fullName.replace('_over', '') == this.tree.imgCheck3) {
				return -1;
			}
			return 0;
		}
		return 0;
	},

	getCheckbox : function () {
		return (this.checkbox) ? this.checkbox : false;
	},
	
	check : function (checked) {
		if (this.checkbox) {
			if (checked == -1) {
				this.checkbox.src = this.tree.imgBase + this.tree.imgCheck3;
				this.struct.check = -1;
			} else if (checked) {
				this.checkbox.src = this.tree.imgBase + this.tree.imgCheck2;
				this.struct.check = 1;
				if (this.tree.useCookie) {
					this.tree.setCookie(this.tree.classTree + this.tree.id);
				}
			} else {
				this.checkbox.src = this.tree.imgBase + this.tree.imgCheck1;
				this.struct.check = 0;
				if (this.tree.useCookie) {
					this.tree.setCookie(this.tree.classTree + this.tree.id);
				}
			}
		}
	},
	
	/**
	 * Fonction qui retourne 1 si tous les enfants sont checkés, 0 si aucun et -1 si quelques uns
	 *
	 * @access	public
	 * @return	integer										1 si tout check, 0 si aucun, -1 si pas tous
	 */
	hasAllChildrenChecked : function () {
		var allChecked = false;
		var anyChecked = false;
		for (var i = 0; i < this.children.length; i++) {
			if (this.children[i].isChecked() == -1) {
				allChecked = true;
				anyChecked = true;
				break;
			}
			if (this.children[i].isChecked() == 1) allChecked = true;
			else anyChecked = true;
		}
		if (allChecked && anyChecked) return -1;
		if (allChecked) return 1;
		else return 0;
	},

	/**
	 * Permet d'intervertir les deux branches. Elles conserveront toutes leurs
	 * caractéristiques (heureusement)
	 *
	 * @access	public
	 * @param	TafelTreeBranch		branchId			L'id de l'autre branche ou l'autre branche elle-même
	 * @return	void
	 */
	switchWith : function (branchId) {
		var branch = this.tree.getBranchById(branchId);
		if (!branch) return false;

		var copyThis = this.copiedTimes;
		var newThis = this.clone();
		var txtThis = this.getText();
		var idThis = this.getId();
		var copyBanch = branch.copiedTimes;
		var newBranch = branch.clone();
		var txtBranch = branch.getText();
		var idBranch = branch.getId();
		// On change l'id de la branche courante
		this.changeId('temp_switch_change_' + this.tree.idTree);
		// Inversion des branches
		var n1 = branch.insertBefore(newThis);
		this.tree.removeBranch(branch);
		n1.setText(txtThis);
		n1.changeId(idThis);
		n1.copiedTimes = copyThis;
		var n2 = this.insertBefore(newBranch);
		this.tree.removeBranch(this);
		n2.setText(txtBranch);
		n2.changeId(idBranch);
		n2.copiedTimes = copyBranch;
	},

	/**
	 * Remplace la branche passée en paramètre par l'autre.
	 *
	 * @access	public
	 * @param	TafelTreeBranch		branchId			L'id de la branche à remplacer ou l'objet lui-même
	 * @param	boolean				copy				True pour faire une copie de la branche qui remplace
	 * @return	TafelTreeBranch							La branche remplacée
	 */
	replace : function (branchId, copy) {
		var branch = this.tree.getBranchById(branchId);
		if (!branch) return false;

		// Préparation du remplacement
		var copyThis = this.copiedTimes;
		var newThis = this.clone();
		var n1 = branch.insertBefore(newThis);
		this.tree.removeBranch(branch);
		if (!copy) {
			var idThis = this.getId();
			n1.setText(this.getText())
			this.tree.removeBranch(this);
			n1.changeId(idThis);
			n1.copiedTimes = copyThis;
		}
		return n1;
	},

	/**
	 * Méthode récursive qui ouvre la branche
	 *
	 * @access	public
	 * @return	void
	 */
	expend : function () {
		if (this.isOpened() != true && this.hasChildren()) {
			this.openIt(true);
		}
		for (var i = 0; i < this.children.length; i++) {
			this.children[i].expend();
		}
	},
	
	/**
	 * Méthode récursive qui ferme la branche
	 *
	 * @access	public
	 * @return	void
	 */
	collapse : function () {
		if (this.isOpened() != false && this.hasChildren()) {
			this.openIt(false);
		}
		for (var i = 0; i < this.children.length; i++) {
			this.children[i].collapse();
		}
	},
	
	/**
	 * Retourne toutes les branches de l'arbre
	 *
	 * @access	public
	 * @param	function		filter					Le filtre des branches
	 * @param	array			[branches]				Optionnel, le tableau des branches incomplet
	 * @return	array									Un tableau des branches de l'arbre
	 */
	getBranches : function (filter, branches) {
		if (!branches) branches = [];
		for (var i = 0; i < this.children.length; i++) {
			if (typeof(filter) == 'function') {
				if (filter(this.children[i])) {
					branches.push(this.children[i]);
				}
			} else {
				branches.push(this.children[i]);
			}
			branches = this.children[i].getBranches(filter, branches);
		}
		return branches;
	},

	/**
	 * Retourne les branches parentes (qui ont des enfants)
	 *
	 * @access	public
	 * @param	array			[parent]				Optionnel, le tableau des branches parentes incomplet
	 * @return	array									Le tableau des branches parentes complet
	 */
	getParentBranches : function (parents) {
		if (!parents) parents = [];
		for (var i = 0; i < this.children.length; i++) {
			if (this.children[i].hasChildren()) {
				parents.push(this.children[i]);
			}
			parents = this.children[i].getParentBranches(parents);
		}
		return parents;
	},

	/**
	 * Retourne les branches qui n'ont pas d'enfants
	 *
	 * @access	public
	 * @param	array			[leafs]					Optionnel, le tableau des branches incomplet
	 * @return	array									Le tableau des branches complet
	 */
	getLeafBranches : function (leafs) {
		if (!leafs) leafs = [];
		for (var i = 0; i < this.children.length; i++) {
			if (!this.children[i].hasChildren()) {
				leafs.push(this.children[i]);
			}
			leafs = this.children[i].getLeafBranches(leafs);
		}
		return leafs;
	},

	/**
	 * Retourne le nombre de branche comprises dans la branche courante
	 *
	 * @access	public
	 * @return	integer										Le nombre de branches
	 */
	countBranches : function () {
		var nb = this.children.length;
		for (var i = 0; i < this.children.length; i++) {
			nb += this.children[i].countBranches();
		}
		return nb;
	},
	
	/**
	 * Méthode récursive qui détermine si la branche est ouverte ou non
	 *
	 * @access	public
	 * @param	array				openedBranches			Le tableau des branches ouvertes
	 * @return	void
	 */
	getOpenedBranches : function (openedBranches) {
		if (!openedBranches) openedBranches = [];
		for (var i = 0; i < this.children.length; i++) {
			if (this.children[i].isOpened() && this.children[i].hasChildren()) {
				openedBranches.push(this.children[i]);
			}
			openedBranches = this.children[i].getOpenedBranches(openedBranches);
		}
		return openedBranches;
	},
	
	/**
	 * Méthode récursive qui détermine si la branche est checkée
	 *
	 * @access	private
	 * @param	array				checkedBranches			Le tableau des branches checkées
	 * @return	void
	 */
	getCheckedBranches : function (checkedBranches) {
		return this._getCheckedBranches(checkedBranches, 1);
	},
	
	/**
	 * Méthode récursive qui détermine si la branche est checkée
	 *
	 * @access	private
	 * @param	array				checkedBranches			Le tableau des branches checkées
	 * @return	void
	 */
	getUnCheckedBranches : function (checkedBranches) {
		return this._getCheckedBranches(checkedBranches, 0);
	},
	
	/**
	 * Méthode récursive qui détermine si la branche est checkée
	 *
	 * @access	private
	 * @param	array				checkedBranches			Le tableau des branches checkées
	 * @return	void
	 */
	getPartCheckedBranches : function (checkedBranches) {
		return this._getCheckedBranches(checkedBranches, -1);
	},

	/**
	 * Sélectionne la branche
	 *
	 * @access	public
	 * @param	Event			ev							L'événement déclencheur
	 * @return	void
	 */
	select : function (ev) {
		var ctrl = (ev) ? TafelTreeManager.ctrlOn(ev) : false;
		var shift = (ev) ? TafelTreeManager.shiftOn(ev) : false;
		if (ctrl) {
			this.tree.selectedBranches.push(this);
		} else if (shift && this.tree.selectedBranches.length > 0) {
			var last = this.tree.selectedBranches.length - 1;
			var sel = this.tree.getBranchesBetween(this.tree.selectedBranches[last], this);
			for (var i = 0; i < sel.length; i++) {
				this.tree.selectedBranches.push(sel[i]);
				Element.addClassName(sel[i].txt, this.tree.classSelected);
			}
		} else {
			this.tree.unselect();
			this.tree.selectedBranches.push(this);
		}
		Element.addClassName(this.txt, this.tree.classSelected);
		// On set l'icône s'il doit changer
		if (this.isOpened() && this.hasChildren() && this.getOpenIconSelected()) {
			this.img.src = this.tree.imgBase + this.getOpenIconSelected();
		} else if (!this.isOpened() && this.hasChildren() && this.getCloseIconSelected()) {
			this.img.src = this.tree.imgBase + this.getCloseIconSelected();
		} else if (!this.hasChildren() && this.getIconSelected()) {
			this.img.src = this.tree.imgBase + this.getIconSelected();
		}
		if (ev) Event.stop(ev);
	},

	/**
	 * Désélectionne la branche
	 *
	 * @access	public
	 * @return	boolean											True si la branche a pu être déselectionnée, false sinon
	 */
	unselect : function () {
		var ln = this.tree.selectedBranches.length;
		if (ln > 0) {
			for (var i = 0; i < ln; i++) {
				if (this.tree.selectedBranches[i].getId() == this.getId()) {
					this.tree.selectedBranches.splice(i, 1);
					Element.removeClassName(this.txt, this.tree.classSelected);
					// On set l'icône s'il doit changer
					if (this.hasChildren()) {
						this.img.src = (this.isOpened()) ? this.tree.imgBase + this.struct.imgopen : this.tree.imgBase + this.struct.imgclose;
					} else {
						this.img.src = this.tree.imgBase + this.struct.img;
					}
					return true;
				}
			}
		}
		return false;
	},
	
	/** 
	 * Calcule la position de la branche à l'intérieur de l'arbre
	 *
	 * @access	public
	 * @return	array									[0] Left pos, [1] Top pos
	 */
	getWithinOffset : function () {
		var realPos = Position.positionedOffset(this.txt);
		var posTree = Position.positionedOffset(this.tree.div);
		var pos = [
			realPos[0] - posTree[0],
			realPos[1] - posTree[1]
		];
		return pos;
	},
	
	/** 
	 * Calcule la position de la branche dans l'écran
	 *
	 * @access	public
	 * @return	array									[0] Left pos, [1] Top pos
	 */
	getAbsoluteOffset : function () {
		return Position.positionedOffset(this.txt);
	},	
	
	/**
	 * Permet de sérialiser la branche, pour en faire une string au format JSON
	 *
	 * Les fonctions ne sont pas encodées dans la string (comme onopen, onclick, etc.). Par contre, on indique
	 * true si la fonction existe bel et bien pour la branche
	 *
	 * @access	public
	 * @param	boolean				debug					True pour afficher le debug de la string
	 * @param	boolean				noEncoding				True pour ne pas encoder la string automatiquement
	 * @return	string										La string JSON de la branche
	 */
	serialize : function (debug, noEncoding) {
		var tab = '';
		var rt = '';
		if (debug) {
			rt = TafelTree.debugReturn;
			for (var i = 0; i < this.level; i++) {
				tab += TafelTree.debugTab;
			}
		}
		var strSave = '';
		var str = rt + tab + '{' + rt;
		// Définition de toutes les propriétés
		str += tab + '"id":"' + this._encode(this.struct.id) + '"';
		for (var attr in this.struct) {
			if (attr != 'items' && attr != 'id') {
				strSave = (typeof(this.struct[attr]) != 'function') ? this.struct[attr] : true;
				if (this.isBool(strSave)) {
					str += "," + rt + tab + '"' + attr + '":' + this._encode(strSave);
				} else {
					str += "," + rt + tab + '"' + attr + '":"' + this._encode(strSave) + '"';
				}
			}
		}
		// Définition des enfants
		if (this.hasChildren()) {
			str += ',' + rt + tab + '"items":[';
			for (var i = 0; i < this.children.length; i++) {
				str += this.children[i].serialize(debug, true);
				if (i < this.children.length - 1) {
					str += ',';
				}
			}
			str += rt + tab + ']';
		}
		str += rt + tab + '}';
		if (!noEncoding) {
			return encodeURIComponent(str);
		} else {
			return str;
		}
	},

	isBool : function (str) {
		switch (str) {
			case 'true':	case 'false':
			case true:		case false:
			case '1':		case '0' :
			case 1:			case 0 :
				return true;
			default :
				return false;
		}
	},
	
	showTooltip : function () {
		if (this.displayTooltip) {
			this.tooltip.style.display = 'block';
		}
	},
	
	hideTooltip : function () {
		if (!this.displayTooltip) {
			Element.hide(this.tooltip);
		}
	},

	/**
	 * Fonction récursive qui supprime les liens avec Droppables et Draggable
	 *
	 * @access	public
	 * @param	TafelTreeBranch			obj					La branche courante
	 * @return	void
	 */
	removeDragDrop : function () {
		if (this.objDrag) {
			this.objDrag.destroy();
		}
		Droppables.remove(this.txt);
		for (var i = 0; i < this.children.length; i++) {
			this.children[i].removeDragDrop();
		}
	},
	
	
	/**
	 *------------------------------------------------------------------------------
	 *							TafelTreeBaseBranch private methods
	 *------------------------------------------------------------------------------
	 */
	
	/**
	 * Fonction qui met à jour l'élément en terme de multiline
	 *
	 * @access	private
	 * @param	HTMLElement		element					L'élément HTML incriminé
	 * @param	integer			type					1 ou 2 (suivant le type de ligne)
	 * @param	boolean			add						True si on ajoute le multiline, false si on l'enlève
	 * @return	void
	 */
	_manageMultiline : function (element, type, add) {
		switch (type) {
			case 2 :
				if (!add) {
					Element.removeClassName(element, this.tree.imgMulti4);
					element.style.background = 'none';
				} else {
					Element.addClassName(element, this.tree.imgMulti4);
					element.style.background = 'url("' + this.tree.imgBase + this.tree.imgMulti2 + '")';
					element.style.backgroundRepeat = 'repeat-y';
				}
				break;
			case 1 :
			default :
				if (!add) {
					Element.removeClassName(element, this.tree.imgMulti3);
					element.style.background = 'none';
				} else {
					Element.addClassName(element, this.tree.imgMulti3);
					element.style.background = 'url("' + this.tree.imgBase + this.tree.imgMulti1 + '")';
					element.style.backgroundRepeat = 'repeat-y';
				}
		}
	},
	
	_createTooltip : function () {
		var div = document.createElement('div');
		div.className = this.tree.classTooltip;
		div.innerHTML = (this.struct.tooltip) ? this.struct.tooltip : '&nbsp;';
		Event.observe(div, 'mouseover', this.showTooltip.bindAsEventListener(this), false);
		return div;
	},

	_manageAfterInsert : function (pos) {
		this.tree._changeStruct(this);
		this._manageLine();
		// Si on a des checkboxes, on corrige les images en fonction des checks par défaut
		if (this.tree.checkboxes && this.tree.checkboxesThreeState) {
			this.children[pos]._adjustParentCheck();
		}
		if (this.children.length == 1 && !this.struct.canhavechildren) {
			this.setOpenableIcon(true);
		}
		this.openIt((!this.tree.openedAfterAdd && !this.isOpened()) ? false : true);
	},
	
	_movePartStruct : function (pos) {
		var nb = this.struct.items.length - 1;
		var newPos = 0;
		for (var i = nb; i >= pos; i--) {
			newPos = i + 1;
			this.struct.items[newPos] = this.struct.items[i];
			this.children[newPos] = this.children[i];
			this.children[newPos].pos = newPos;
		}
	},

	/**
	 * Méthode récursive qui détermine si la branche est checkée ou non
	 *
	 * @access	private
	 * @param	array				checkedBranches			Le tableau des branches checkées
	 * @param	boolean				checked					1 pour récupérer les branches checkées
	 * @return	void
	 */
	 _getCheckedBranches : function (checkedBranches, checked) {
		if (!checkedBranches) checkedBranches = [];
		for (var i = 0; i < this.children.length; i++) {
			if (this.children[i].isChecked() == checked) {
				checkedBranches.push(this.children[i]);
			}
			checkedBranches = this.children[i]._getCheckedBranches(checkedBranches, checked);
		}
		return checkedBranches;
	 },

	_generate : function () {
		var i = this.bigTreeLoading;
		if (i < this.struct.items.length) {
			if (this.tree.checkboxesThreeState && this.struct.check && typeof(this.struct.items[i].check) == 'undefined') {
				this.struct.items[i].check = 1;
			}
			isNotFirst = (i > 0) ? true : false;
			isNotLast = (i < this.struct.items.length - 1) ? true : false;
			this.children[i] = new TafelTreeBranch((this.isRoot) ? this : this.root, this, this.struct.items[i], this.level + 1, isNotFirst, isNotLast, i);
			this.obj.appendChild(this.children[i].obj);
			this.openIt((this.tree.useCookie) ?  this.isOpenedInCookie : this.struct.open);
			this.tree.loadRunning(this.children[i]);
			this.bigTreeLoading++;
			setTimeout(this._generate.bind(this), 10);
		} else {
			this.loaded = true;
		}
	},
	
	_getPos : function () {
		pos = this.children.length;
		for (var i = 0; i < this.children.length; i++) {
			if (this.children[i].isAlwaysLast()) {
				pos--;
			}
		}
		if (pos < 0 ) pos = 0;
		return pos;
	},
	
	/**
	 * Fonction qui ajuste le check des parent de la branche, suite à un changement
	 *
	 * @access	private
	 * @param	boolean			fromBranch				True pour commencer l'ajustement depuis la branche même
	 * @return	void
	 */
	_adjustParentCheck : function (fromBranch) {
		if (this.parent) {
			var branch = (!fromBranch) ? this.parent : this;
			while (branch && branch.checkbox) {
				branch.check(branch.hasAllChildrenChecked());
				branch = branch.parent;
			}
		}
	},
	
	/**
	 * Fonction récursive qui va changer le status des checkboxes enfants
	 *
	 * @access	private
	 * @param	TafelTreeBranch		branch					La branche courante
	 * @param	boolean				checked					True ou false
	 * @return	void
	 */
	_manageCheckThreeState : function (branch, checked) {
		for (var i = 0; i < branch.children.length; i++) {
			if (branch.tree.checkboxes && branch.children[i].checkbox) {
				branch.children[i].check(checked);
				branch._manageCheckThreeState(branch.children[i], checked);
			}
		}
	},
	
	_getImgInfo : function (img) {
		var url = img.src.split('/');
		var name = url[url.length-1].split('.');
		var obj = {
			'img': img,
			'number': name[0].charAt(name[0].length-1),
			'type': name[0].substr(0, name[0].length-1),
			'name': name[0],
			'fullName': url[url.length-1]
		};
		return obj;
	},
	
	/**
	 * Permet d'encoder la string avant l'envoi en JSON
	 *
	 * @access	private
	 * @param	string				str						La string correspondant à la propriété (this.struct.*)
	 * @return	string										La valeur de la propriété encodée
	 */
	_encode : function (str) {
		//var obj = eval(str);
		var obj = (str === null) ? '' : str;
		return obj.toString().replace(/\"/g, '\\"');
	},
	
	_closeChild : function (img) {
		try {
			img = this.getImgBeforeIcon().img;
			this.struct.open = false;
			if (this.isSelected() && this.getCloseIconSelected()) {
				this.img.src = this.tree.imgBase + this.getCloseIconSelected();
			} else {
				this.img.src = this.tree.imgBase + this.struct.imgclose;
			}
			for (var i = 0; i < this.obj.childNodes.length; i++) {
				if (this.obj.childNodes[i].nodeName.toLowerCase() == 'div') {
					Element.hide(this.obj.childNodes[i]);
				}
			}
			if (!this.isRoot) {
				img.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgPlus3 : this.tree.imgBase + this.tree.imgPlus2;
			} else {
				if (this.hasSiblingsBefore) {
					img.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgPlus3 : this.tree.imgBase + this.tree.imgPlus2;
				} else {
					img.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgPlus4 : this.tree.imgBase + this.tree.imgPlus5;
				}
			}
		} catch (err) {
			throw new Error ('_closeChild(base) : ' + err.message);
		}
	},
	
	_openChild : function (img) {
		try {
			img = this.getImgBeforeIcon().img;
			this.struct.open = true;
			if (this.isSelected() && this.getOpenIconSelected()) {
				this.img.src = this.tree.imgBase + this.getOpenIconSelected();
			} else {
				this.img.src = this.tree.imgBase + this.struct.imgopen;
			}
			for (var i = 0; i < this.obj.childNodes.length; i++) {
				if (this.obj.childNodes[i].nodeName.toLowerCase() == 'div') {
					this.obj.childNodes[i].style.display = '';
				}
			}
			if (!this.isRoot) {
				img.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgMinus3 : this.tree.imgBase + this.tree.imgMinus2;
			} else {
				if (this.hasSiblingsBefore) {
					img.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgMinus3 : this.tree.imgBase + this.tree.imgMinus2;
				} else {
					img.src = (this.hasSiblingsAfter) ? this.tree.imgBase + this.tree.imgMinus4 : this.tree.imgBase + this.tree.imgMinus5;
				}
			}
		} catch (err) {
			throw new Error ('_openChild(base) : ' + err.message);
		}
	},
	
	/**
	 * Fonction qui gère les lignes verticales après un drag and drop
	 *
	 * @access	private
	 * @return	void
	 */
	_manageLine : function () {
		try {
			for (var i = 0; i < this.children.length; i++) {
				this.children[i].pos = i;
				// Si on est au dernier enfant et que celui-ci n'était pas le dernier avant le remove
				if (i == this.children.length - 1 && this.children[i].hasSiblingsAfter) {
					this.children[i].hasSiblingsAfter = false;
					this._manageMultiline(this.children[i].beforeIcon, 1, false);
					this._clearLine(this.children[i], this.level);
				}
				// Si on n'est pas au dernier enfant et que celui-ci était le dernier avant le remove
				if (i < this.children.length - 1 && !this.children[i].hasSiblingsAfter) {
					this.children[i].hasSiblingsAfter = true;
					this._manageMultiline(this.children[i].beforeIcon, 1, true);
					this._addLine(this.children[i], this.level);
				}
			}
			this.tree._changeStruct(this);
		} catch (err) {
			throw new Error ('_manageLine(base) : ' + err.message);
		}			
	},
	
	_manageLineForRoot : function (add) {
		for (var i = 0; i < this.children.length; i++) {
			this.children[i]._manageLineForRoot(add);
		}
		var td = this.table.getElementsByTagName('td')[0];
		var img = td.getElementsByTagName('img')[0];
		if (add) {
			img.src = this.tree.imgBase + this.tree.imgLine1;
		} else {
			img.src = this.tree.imgBase + this.tree.imgEmpty;
		}
	},
	
	/**
	 * Fonction qui supprime des lignes au bon endroit*
	 *
	 * @param	TafelTreeBranch		obj						La branche courante
	 * @param	integer				level					Le niveau où supprimer des lignes
	 * @param	boolean				ok						False pour le 1er niveau de branche
	 * @return	void
	 */
	_clearLine : function (obj, level, ok) {
		try {
			for (var i = 0; i < obj.children.length; i++) {
				this._clearLine(obj.children[i], level, true);
			}
			// On récupère la bonne TD et la bonne image
			var img = obj.table.getElementsByTagName('img')[level+1];
			if (ok) {
				img.src = this.tree.imgBase + this.tree.imgEmpty;
				if (this.tree.multiline) {
					this._manageMultiline(img.parentNode, 1, false);
				}
			} else {
				var old = obj.getImgBeforeIcon();
				switch (old.fullName.replace('_over', '')) {
					case this.tree.imgLine1 :
					case this.tree.imgLine3 : newImg = this.tree.imgLine2; break;
					case this.tree.imgPlus1 :
					case this.tree.imgPlus3 : newImg = this.tree.imgPlus2; break;
					case this.tree.imgMinus1:
					case this.tree.imgMinus3: newImg = this.tree.imgMinus2; break;
					default:
						newImg = obj.fullName;
				}
				img.src = this.tree.imgBase + newImg;
			}
		} catch (err) {
			throw new Error ('_clearLine(base) : ' + err.message);
		}			
	},
	
	/**
	 * Fonction qui ajoute des lignes au bon endroit*
	 *
	 * @param	TafelTreeBranch		obj						La branche courante
	 * @param	integer				level					Le niveau où ajouter des lignes
	 * @param	boolean				ok						False pour le 1er niveau de branche
	 * @return	void
	 */
	_addLine : function (obj, level, ok) {
		try {
			for (var i = 0; i < obj.children.length; i++) {
				this._addLine(obj.children[i], level, true);
			}
			// On récupère la bonne TD et la bonne image
			var img = obj.table.getElementsByTagName('img')[level+1];
			if (ok) {
				img.src = this.tree.imgBase + this.tree.imgLine1;
				if (this.tree.multiline) {
					this._manageMultiline(img.parentNode, 1, true);
				}
			} else {
				var old = obj.getImgBeforeIcon();
				switch (old.fullName.replace('_over', '')) {
					case this.tree.imgLine1 :
					case this.tree.imgLine2 : newImg = this.tree.imgLine3; break;
					case this.tree.imgPlus1 :
					case this.tree.imgPlus2 : newImg = this.tree.imgPlus3; break;
					case this.tree.imgMinus1:
					case this.tree.imgMinus2: newImg = this.tree.imgMinus3; break;
					default:
						newImg = obj.fullName;
				}
				img.src = this.tree.imgBase + newImg;
			}
		} catch (err) {
			throw new Error ('_addLine(base) : ' + err.message);
		}			
	},
	
	_isChild : function (child, parent) {
		try {
			if (parent.idObj == child.idObj) return true;
			if (child.parent) {
				return this._isChild(child.parent, parent);
			}
			return false;
		} catch (err) {
			throw new Error ('_isChild(base) : ' + err.message);
		}	
	},

	/**
	 * Set les propriétés utilisateur de la branche, ou celles par défaut
	 *
	 * @access	private
	 * @return	void
	 */
	_setProperties : function () {
		// Images
		if ((typeof(this.struct.img) == 'undefined')) {
			this.struct.img = (this.tree.icons[0]) ? this.tree.icons[0] : this.tree.imgLine0;
		}
		if ((typeof(this.struct.imgopen) == 'undefined')) {
			this.struct.imgopen = (this.tree.icons[1]) ? this.tree.icons[1] : this.struct.img;
		}
		if ((typeof(this.struct.imgclose) == 'undefined')) {
			this.struct.imgclose = (this.tree.icons[2]) ? this.tree.icons[2] : this.struct.img;
		}
		if ((typeof(this.struct.imgselected) == 'undefined')) {
			this.struct.imgselected = (this.tree.iconsSelected[0]) ? this.tree.iconsSelected[0] : null;
		}
		if ((typeof(this.struct.imgopenselected) == 'undefined')) {
			this.struct.imgopenselected = (this.tree.iconsSelected[1]) ? this.tree.iconsSelected[1] : null;
		}
		if ((typeof(this.struct.imgcloseselected) == 'undefined')) {
			this.struct.imgcloseselected = (this.tree.iconsSelected[2]) ? this.tree.iconsSelected[2] : null;
		}
		// Fonctions
		if (typeof(this.struct.open) == 'undefined') {
			this.struct.open = (this.tree.useCookie && this.tree.cookieOpened) ? false : this.tree.openAll;
		} else if (this.tree.useCookie && this.tree.cookieOpened) {
			this.struct.open = false;
		}
		
		if (typeof(this.struct.check) == 'undefined' || (this.tree.useCookie && this.tree.cookieChecked)) this.struct.check = 0;

		if (typeof(this.struct.items) == 'undefined') {
			this.struct.items = [];
		}
		if (typeof(this.struct.canhavechildren) == 'undefined') this.struct.canhavechildren = false;
		if (typeof(this.struct.id) == 'undefined') this.struct.id = this.idObj;
		if (typeof(this.struct.acceptdrop) == 'undefined') this.struct.acceptdrop = true;
		if (typeof(this.struct.last) == 'undefined') this.struct.last = false;
		if (typeof(this.struct.editable) == 'undefined') this.struct.editable = this.tree.editableBranches;
		if (typeof(this.struct.checkbox) == 'undefined') this.struct.checkbox = true;
	},

	/**
	 * Set les fonctions utilisateur et les fonctions par défaut, s'il y en a
	 *
	 * @access	private
	 * @return	void
	 */
	_setFunctions : function () {
		if (typeof(this.struct.ondragstarteffect) == 'undefined') {
			if (typeof(this.tree.onDragStartEffect) == 'function') {
				this.struct.ondragstarteffect = this.tree.onDragStartEffect;
				this.ondragstarteffectDefault = true;
			}
		} else {this.struct.ondragstarteffect = eval(this.struct.ondragstarteffect);}
		if (typeof(this.struct.ondragendeffect) == 'undefined') {
			if (typeof(this.tree.onDragEndEffect) == 'function') {
				this.struct.ondragendeffect = this.tree.onDragEndEffect;
				this.ondragendeffectDefault = true;
			}
		} else {this.struct.ondragendeffect = eval(this.struct.ondragendeffect);}
		if (typeof(this.struct.onerrorajax) == 'undefined') {
			if (typeof(this.tree.onErrorAjax) == 'function') {
				this.struct.onerrorajax = this.tree.onErrorAjax;
				this.onerrorajaxDefault = true;
			}
		} else {this.struct.onerrorajax = eval(this.struct.onerrorajax);}
		if (typeof(this.struct.oneditajax) == 'undefined') {
			if (this.tree.onEditAjax && typeof(this.tree.onEditAjax.func) == 'function') {
				this.struct.oneditajax = this.tree.onEditAjax.func;
				this.struct.editlink = this.tree.onEditAjax.link;
				this.oneditajaxDefault = true;
			}
		} else {this.struct.oneditajax = eval(this.struct.oneditajax);}
		if (typeof(this.struct.onopenpopulate) == 'undefined') {
			if (this.tree.onOpenPopulate && typeof(this.tree.onOpenPopulate.func) == 'function') {
				this.struct.onopenpopulate = this.tree.onOpenPopulate.func;
				this.struct.openlink = this.tree.onOpenPopulate.link;
				this.onopenpopulateDefault = true;
			}
		} else {this.struct.onopenpopulate = eval(this.struct.onopenpopulate);}
		if (typeof(this.struct.onedit) == 'undefined') {
			if (typeof(this.tree.onEdit) == 'function') {
				this.struct.onedit = this.tree.onEdit;
				this.oneditDefault = true;
			}
		} else {this.struct.onedit = eval(this.struct.onedit);}
		if (typeof(this.struct.oncheck) == 'undefined') {
			if (typeof(this.tree.onCheck) == 'function') {
				this.struct.oncheck = this.tree.onCheck;
				this.oncheckDefault = true;
			}
		} else {this.struct.oncheck = eval(this.struct.oncheck);}
		if (typeof(this.struct.onbeforecheck) == 'undefined') {
			if (typeof(this.tree.onBeforeCheck) == 'function') {
				this.struct.onbeforecheck = this.tree.onBeforeCheck;
				this.onbeforecheckDefault = true;
			}
		} else {this.struct.onbeforecheck = eval(this.struct.onbeforecheck);}
		if (typeof(this.struct.onopen) == 'undefined') {
			if (typeof(this.tree.onOpen) == 'function') {
				this.struct.onopen = this.tree.onOpen;
				this.onopenDefault = true;
			}
		} else {this.struct.onopen = eval(this.struct.onopen);}
		if (typeof(this.struct.onbeforeopen) == 'undefined') {
			if (typeof(this.tree.onBeforeOpen) == 'function') {
				this.struct.onbeforeopen = this.tree.onBeforeOpen;
				this.onbeforeopenDefault = true;
			}
		} else {this.struct.onbeforeopen = eval(this.struct.onbeforeopen);}
		if (typeof(this.struct.onmouseover) == 'undefined') {
			if (typeof(this.tree.onMouseOver) == 'function') {
				this.struct.onmouseover = this.tree.onMouseOver;
				this.onmouseoverDefault = true;
			}
		} else {this.struct.onmouseover = eval(this.struct.onmouseover);}
		if (typeof(this.struct.onmouseout) == 'undefined') {
			if (typeof(this.tree.onMouseOut) == 'function') {
				this.struct.onmouseout = this.tree.onMouseOut;
				this.onmouseoutDefault = true;
			}
		} else {this.struct.onmouseout = eval(this.struct.onmouseout);}
		if (typeof(this.struct.onmousedown) == 'undefined') {
			if (typeof(this.tree.onMouseDown) == 'function') {
				this.struct.onmousedown = this.tree.onMouseDown;
				this.onmousedownDefault = true;
			}
		} else {this.struct.onmousedown = eval(this.struct.onmousedown);}
		if (typeof(this.struct.onmouseup) == 'undefined') {
			if (typeof(this.tree.onMouseUp) == 'function') {
				this.struct.onmouseup = this.tree.onMouseUp;
				this.onmouseupDefault = true;
			}
		} else {this.struct.onmouseup = eval(this.struct.onmouseup);}
		if (typeof(this.struct.onclick) == 'undefined') {
			if (typeof(this.tree.onClick) == 'function') {
				this.struct.onclick = this.tree.onClick;
				this.onclickDefault = true;
			}
		} else {this.struct.onclick = eval(this.struct.onclick);}
		if (typeof(this.struct.ondblclick) == 'undefined') {
			if (typeof(this.tree.onDblClick) == 'function') {
				this.struct.ondblclick = this.tree.onDblClick;
				this.ondblclickDefault = true;
			}
		} else {this.struct.ondblclick = eval(this.struct.ondblclick);}
	},
	
	/**
	 * Set actions like selecting node
	 *
	 * @access private
	 * @return void
	 */
	_setActions : function () {
		if (this.struct.select) {
			this.select();
		}
	},
	
	/**
	 * Fonction qui set les divers événements en fonction des données utilisateur
	 *
	 * @access	private
	 * @param	HTMLTdElement		event					La cellule qui contient le texte
	 * @param	HTMLTdElement		tdImg					La cellule qui contient l'icône
	 * @return	void
	 */
	_setEvents : function (event, tdImg) {
		// Le onclick se fait de toutes façon
		Event.observe(this.txt, 'mousedown', this.setMouseDown.bindAsEventListener(this), false);
		Event.observe(this.txt, 'mouseup', this.setMouseUp.bindAsEventListener(this), false);
		// On set les événements
		if (typeof(this.struct.onclick) == 'function') {
			Event.observe(event, 'click', this.setClick.bindAsEventListener(this), false);
		}
		if (typeof(this.struct.ondblclick) == 'function' || this.struct.editable) {
			Event.observe(event, 'dblclick', this.setDblClick.bindAsEventListener(this), false);
		}
		if (typeof(this.struct.onmouseover) == 'function') {
			Event.observe(event, 'mouseover', this.setMouseOver.bindAsEventListener(this), false);
		}
		if (typeof(this.struct.onmouseout) == 'function') {
			Event.observe(event, 'mouseout', this.setMouseOut.bindAsEventListener(this), false);
		}
		if (this.struct.editable && (typeof(this.struct.onedit) == 'function' || typeof(this.struct.oneditajax) == 'function')) {
			this.editableInput = document.createElement('input');
			this.editableInput.setAttribute('type', 'text');
			this.editableInput.setAttribute('autocomplete', 'off');
			this.editableInput.className = this.tree.classEditable;
			event.appendChild(this.editableInput);
			Event.observe(this.editableInput, 'blur', this.hideEditable.bindAsEventListener(this), false);
		}
		// On set l'option drag and drop
		if (!this.isRoot) {
			if (this.struct.draggable && (typeof(this.struct.ondrop) == 'function' || typeof(this.struct.ondropajax) == 'function')) {
				//this.objDrag = new Draggable(this.txt, {revert: this.tree.dragRevert, scroll: this.tree.div, ghosting: this.tree.dragGhosting});
				this.objDrag = new Draggable(this.txt, {
					revert: this.tree.dragRevert,
					starteffect:this.ondragstarteffect.bindAsEventListener(this),
					endeffect:this.ondragendeffect.bindAsEventListener(this)
				}); 
				Element.addClassName(this.txt, this.tree.classDrag);
			}
		}
		if (this.struct.acceptdrop) {
			Droppables.add(this.txt, {hoverclass: this.tree.classDragOver, onDrop: this.setDrop.bindAsEventListener(this)});
		}
		if (this.struct.tooltip) {
			Event.observe(event, 'mouseover', this.evt_showTooltip.bindAsEventListener(this), false);
			Event.observe(event, 'mouseout', this.evt_hideTooltip.bindAsEventListener(this), false);
		}
		// On s'occupe des checkboxes, le cas échéant
		if (this.tree.checkboxes && this.struct.checkbox) {
			if (this.struct.check == 1) imgc = this.tree.imgCheck2;
			else if (this.struct.check == -1) imgc = this.tree.imgCheck3;
			else imgc = this.tree.imgCheck1;
			this.checkbox = document.createElement('img');
			this.checkbox.src = this.tree.imgBase + imgc;
			tdImg.appendChild(this.checkbox);
			Event.observe(this.checkbox, 'click', this.checkOnClick.bindAsEventListener(this), false);
			Event.observe(this.checkbox, 'mouseover', this.evt_openMouseOver.bindAsEventListener(this), false);
			Event.observe(this.checkbox, 'mouseout', this.evt_openMouseOut.bindAsEventListener(this), false);
		} else if (this.tree.checkboxes) {
			// On met éventuellement une image vide au lieu de la checkbox
			var vide = document.createElement('img');
			vide.src = this.tree.imgBase + this.tree.imgEmpty;
			tdImg.appendChild(vide);
		}
	},
	
	_getImgBeforeIcon : function () {
		try {
			var td = document.createElement('td');
			var img = document.createElement('img');
			Element.addClassName(img, this.tree.classOpenable);
			// On détermine s'il y a des frères
			if (this.hasSiblingsAfter) {
				// On détermine s'il y a des enfants
				if (!this.hasChildren()) {
					if (this.isRoot) {
						img.src = this.tree.imgBase + ((this.hasSiblingsBefore) ? this.tree.imgLine3 : this.tree.imgLine4);
					} else {
						img.src = this.tree.imgBase + this.tree.imgLine3;
					}
				} else {
					Event.observe(img, 'click', this.setOpen.bindAsEventListener(this), false);
					Event.observe(img, 'mouseover', this.evt_openMouseOver.bindAsEventListener(this), false);
					Event.observe(img, 'mouseout', this.evt_openMouseOut.bindAsEventListener(this), false);
					if (this.isRoot) {
						img.src = this.tree.imgBase + ((this.hasSiblingsBefore) ? this.tree.imgMinus3 : this.tree.imgMinus4);
					} else {
						img.src = this.tree.imgBase + this.tree.imgMinus3;
					}
				}
				if (this.tree.multiline) {
					this._manageMultiline(td, (this.isRoot ? 2 : 1), true);
				}
			} else {
				// On détermine s'il y a des enfants
				if (!this.hasChildren()) {
					if (this.isRoot) {
						img.src = this.tree.imgBase + ((this.hasSiblingsBefore) ? this.tree.imgLine2 : this.tree.imgEmpty);
					} else {
						img.src = this.tree.imgBase + this.tree.imgLine2;
					}
				} else {
					Event.observe(img, 'click', this.setOpen.bindAsEventListener(this), false);
					Event.observe(img, 'mouseover', this.evt_openMouseOver.bindAsEventListener(this), false);
					Event.observe(img, 'mouseout', this.evt_openMouseOut.bindAsEventListener(this), false);
					if (this.isRoot) {
						img.src = this.tree.imgBase + ((this.hasSiblingsBefore) ? this.tree.imgMinus2 : this.tree.imgMinus5);
					} else {
						img.src = this.tree.imgBase + this.tree.imgMinus2;
					}
				}
			}
			td.appendChild(img);
			return td;
		} catch (err) {
			throw new Error ('_getImgBeforeIcon(base) : ' + err.message);
		}			
	},

	/**
	 * Insère les enfants de la branche
	 *
	 * @access	private
	 * @param	TafelTreeRoot	root					L'élément racine parent
	 * @return	void
	 */
	_setChildren : function (root) {
		if (this.hasChildren()) {
			if (this.tree.bigTreeLoading >= 0) {
				this.loaded = false;
				this.bigTreeLoading = 0;
				setTimeout(this._generate.bind(this), 10);
			} else {
				for (var i = 0; i < this.struct.items.length; i++) {
					if (this.tree.checkboxesThreeState && this.struct.check && typeof(this.struct.items[i].check) == 'undefined') {
						this.struct.items[i].check = 1;
					}
					isNotFirst = (i > 0) ? true : false;
					isNotLast = (i < this.struct.items.length - 1) ? true : false;
					this.children[i] = new TafelTreeBranch(root, this, this.struct.items[i], this.level + 1, isNotFirst, isNotLast, i);
					this.obj.appendChild(this.children[i].obj);
				}
				this.openIt(this.struct.open);
			}
		}
	},
	
	/**
	 * Set l'image de la branche à wait ainsi que ses enfants
	 *
	 * @access	private
	 * @param	TafelTreeBranch		branch					La branche courante
	 * @param	boolean				wait					True pour afficher l'image d'attente
	 * @param	boolean				localPropagationStop	True pour ne pas avoir de propagation, false par défaut
	 * @return	void
	 */
	_setWaitImg : function (branch, wait, localPropagationStop) {
		try {
			this.inProcess = wait;
			if (wait) {
				branch.oldImgSrc = branch.img.src;
				branch.img.src = branch.tree.imgBase + branch.tree.imgWait;
				branch.eventable = false;
			} else {
				branch.eventable = true;
				branch.img.src = branch.oldImgSrc;
			}
			if (this.tree.propagation && !localPropagationStop) {
				for (var i = 0; i < branch.children.length; i++) {
					this._setWaitImg(branch.children[i], wait);
				}
			}
		} catch (err) {
			throw new Error ('_setWaitImg(base) : ' + err.message);
		}
	},
	
	/**
	 * Envoi d'une requête Ajax suite à une ouverture de branche
	 *
	 * @access	private
	 * @return	void
	 */
	_openPopulate : function (ev) {
		try {
			this._setWaitImg(this, true);
			var params = 'branch=' + this.serialize() + '&branch_id=' + this.getId() + '&tree_id=' + this.tree.id;
			var otherParams = this.tree.getURLParams(this.struct.openlink);
			for (var i = 0; i < otherParams.length; i++) {
				params += '&' + otherParams[i].name + '=' + otherParams[i].value;
			}
			new Ajax.Updater (
				this.tree.ajaxObj,
				this.struct.openlink,
				{
					'method'     : 'post',
					'parameters' : params,
					'evalScripts': true,
					'onComplete' : function(event){this._completeOpenPopulate(event);}.bind(this),
					'onFailure' : function(event){this._failureOpenPopulate(event);}.bind(this)
				}
			);
		} catch (err) {
			this._setWaitImg(this, false);
			throw ('_openPopulate(base) : ' + err.message);
		}
	},
	
	_failureOpenPopulate : function () {
		this._setWaitImg(this, false);
		if (typeof(this.struct.onerrorajax) == 'function') {
			this.struct.onerrorajax('open', 'failure request', this);
		}
	},
	
	/**
	 * Méthode appelée lorsque le retour ajax est effectué
	 *
	 * Pour pailler aux éventualités : str.match(/(?:\(\[)((\n|\r|.)*?)(?:\]\))/)[0]
	 *
	 * @access	private
	 * @param	XMLhttpResquest		response				L'objet Ajax
	 * @return	void
	 */
	_completeOpenPopulate : function (response) {
		try {
			this._setWaitImg(this, false);
			var rep = this.struct.onopenpopulate(this, response.responseText);
			if (rep) {
				rep = (rep === true) ? response.responseText : rep;
				var items = eval(rep);
				if (items) {
					var ok = [];
					for (var i = 0 ; i < items.length; i++) {
                        // unicity test
                        if (this.tree.getBranchById(items[i].id)) continue; 
						if (typeof(items[i].id) == 'undefined' || typeof(items[i].txt) == 'undefined') {
							throw new Error (TAFELTREE_WRONG_BRANCH_STRUCTURE);
						}
						ok.push(this.insertIntoLast(items[i]));
					}
					// Permet d'ouvrir les branches qui viennent du serveur au load de la page
					if (this.tree.useCookie && this.tree.cookieOpened && this.tree.reopenFromServer) {
						var okay = false;
						for (var o = 0; o < ok.length; o++) {
							okay = false;
							for (var i = 0; i < this.tree.cookieOpened.length; i++) {
								if (this.tree.cookieOpened[i] == ok[o].getId()) {
									okay = true;
									break;
								}
							}
							if (okay) {
								if (typeof(ok[o].struct.onopenpopulate) == 'function' && ok[o].eventable) {
									ok[o]._openPopulate();
									ok[o].openIt(true);
								}
							}
						}
					}
				}
			}
		} catch (err) {
			this._setWaitImg(this, false);
			if (typeof(this.struct.onerrorajax) == 'function') {
				this.struct.onerrorajax('open', response.responseText, this);
			} else {
				alert ('_completeOpenPopulate(' + response.responseText + ') : ' + err.message);
			}
		}
	},
	
	/**
	 * Envoi d'une requête Ajax suite à un drop
	 *
	 * @access	private
	 * @param	TafelTreeBranch		newParentObj			Le nouveau parent
	 * @param	boolean				asSibling				True pour dropper l'élément comme frère
	 * @param	boolean				copydrag				True si on fait un copy-drag
	 * @return	void
	 */
	_setDropAjax : function (newParentObj, asSibling, copydrag, ev) {
		try {
			this._setWaitImg(this, true);
			var sibling = (asSibling) ? 1 : 0;
			var cdrag = (copydrag) ? 1 : 0;
			var params = 'drag=' + this.serialize() + '&drag_id=' + this.getId() + '&drop=' + newParentObj.serialize() + '&drop_id=' + newParentObj.getId();
			params += '&treedrag_id=' + this.tree.id + '&treedrop_id=' + newParentObj.tree.id + '&sibling=' + sibling + '&copydrag=' + cdrag;
			// On passe le futur id de l'élément copié s'il s'agit d'une copie
			if (cdrag) {
				var cdragId = this.id + this.tree.copyNameBreak + this.tree.idTree;
				params += '&copydrag_id=' + cdragId;
			}
			var otherParams = this.tree.getURLParams(this.struct.droplink);
			for (var i = 0; i < otherParams.length; i++) {
				params += '&' + otherParams[i].name + '=' + otherParams[i].value;
			}
			this.newParent = newParentObj;
			this.asSibling = asSibling;
			this.copyDrag = cdrag;
			new Ajax.Updater (
				this.tree.ajaxObj,
				this.struct.droplink,
				{
					'method'     : 'post',
					'parameters' : params,
					'evalScripts': true,
					'onComplete' : function(event){this._completeDropAjax(event);}.bind(this),
					'onFailure' : function(event){this._failureDropAjax(event);}.bind(this)
				}
			);
		} catch (err) {
			this._setWaitImg(this, false);
			throw ('_setDropAjax(base) : ' + err.message);
		}
	},
	
	_failureDropAjax : function () {
		this._setWaitImg(this, false);
		if (typeof(this.struct.onerrorajax) == 'function') {
			this.struct.onerrorajax('drop', 'failure request', this, this.newParent);
		}
	},
	
	/**
	 * Méthode appelée lorsque le retour ajax est effectué
	 *
	 * @access	private
	 * @param	XMLhttpResquest		response				L'objet Ajax
	 * @return	void
	 */
	_completeDropAjax : function (response) {
		try {
			if (this.struct.ondropajax(this, this.newParent, response.responseText, false, null)) {
				var newBranch = null;
				if (!this.asSibling) {
					if (!this.copyDrag) {
						this.move(this.newParent);
					} else {
						newBranch = this.newParent.insertIntoLast(this.clone());
					}
				} else {
					if (!this.copyDrag) {
						this.moveBefore(this.newParent);
					} else {
						newBranch = this.newParent.insertBefore(this.clone());
					}
				}
				this.struct.ondropajax(this, this.newParent, response.responseText, true, newBranch);
			}
			this._setWaitImg(this, false);
		} catch (err) {
			if (typeof(this.struct.onerrorajax) == 'function') {
				this.struct.onerrorajax('drop', response.responseText, this, this.newParent);
			} else {
				alert ('_completeDropAjax(base) : ' + err.message);
			}
		}
	},
	
	/**
	 * Envoi d'une requête Ajax suite à une édition de branche
	 *
	 * @access	private
	 * @return	void
	 */
	_editAjax : function (newValue, oldValue, ev) {
		try {
			this._setWaitImg(this, true, true);
			var params = 'branch=' + this.serialize() + '&branch_id=' + this.getId() + '&tree_id=' + this.tree.id;
			params += '&new_value=' + newValue + '&old_value=' + oldValue;
			var otherParams = this.tree.getURLParams(this.struct.editlink);
			for (var i = 0; i < otherParams.length; i++) {
				params += '&' + otherParams[i].name + '=' + otherParams[i].value;
			}
			new Ajax.Updater (
				this.tree.ajaxObj,
				this.struct.editlink,
				{
					'method'     : 'post',
					'parameters' : params,
					'evalScripts': true,
					'onComplete' : function(event){this._completeEditAjax(event);}.bind(this),
					'onFailure' : function(event){this._failureEditAjax(event);}.bind(this)
				}
			);
		} catch (err) {
			this._setWaitImg(this, false, true);
			throw ('_editAjax(base) : ' + err.message);
		}
	},
	
	_failureEditAjax : function () {
		this._setWaitImg(this, false);
		if (typeof(this.struct.onerrorajax) == 'function') {
			this.struct.onerrorajax('edit', 'failure request', this);
		}
	},
	
	/**
	 * Méthode appelée lorsque le retour ajax est effectué
	 *
	 * @access	private
	 * @param	XMLhttpResquest		response				L'objet Ajax
	 * @return	void
	 */
	_completeEditAjax : function (response) {
		try {
			this._setWaitImg(this, false, true);
			var rep = this.struct.oneditajax(this, response.responseText, this.txt.innerHTML);
			if (rep) {
				this.setText((rep === true ? response.responseText : rep));
			}
			this.hideEditableElement();
		} catch (err) {
			this._setWaitImg(this, false, true);
			if (typeof(this.struct.onerrorajax) == 'function') {
				this.struct.onerrorajax('edit', response.responseText, this);
			} else {
				alert ('_completeOpenPopulate(' + response.responseText + ') : ' + err.message);
			}
		}
	},
	
	
	/**
	 *------------------------------------------------------------------------------
	 *							TafelTreeBaseBranch Events Management
	 *------------------------------------------------------------------------------
	 */
	
	evt_openMouseOver : function (ev) {
		if (Event.element) {
			var obj = Event.element(ev);
			var img = this._getImgInfo(obj);
			obj.src = this.tree.imgBase + img.type + '_over' + img.number + '.gif';
		}
	},
	
	evt_openMouseOut : function (ev) {
		if (Event.element) {
			var obj = Event.element(ev);
			var img = this._getImgInfo(obj);
			obj.src = this.tree.imgBase + img.type.replace(/_over/g, '') + img.number + '.gif';
		}
	},
	
	evt_showTooltip : function (ev) {
		this.displayTooltip = true;
		setTimeout(this.showTooltip.bind(this), this.tree.durationTooltipShow);
	},
	
	evt_hideTooltip : function (ev) {
		this.displayTooltip = false;
		setTimeout(this.hideTooltip.bind(this), this.tree.durationTooltipHide);
	},
	
	/**
	 * Méthode appelée lorsque la souris passe sur le noeud
	 *
	 * @access	public
	 * @param	Element				ev						L'élément déclencheur
	 * @return	boolean										True si le changement s'est fait, false sinon
	 */
	setMouseOver : function (ev) {
		if (typeof(this.struct.onmouseover) == 'function') {
			return this.struct.onmouseover(this, ev);
		}
	},
	
	/**
	 * Méthode appelée lorsqu'on clic sur le noeud
	 *
	 * @access	public
	 * @param	Element				ev						L'élément déclencheur
	 * @return	boolean										True si le changement s'est fait, false sinon
	 */
	setMouseOut : function (ev) {
		if (typeof(this.struct.onmouseout) == 'function') {
			return this.struct.onmouseout(this, ev);
		}
	},
	
	/**
	 * Méthode appelée lorsqu'on clique sur le noeud (mousedown)
	 *
	 * @access	public
	 * @param	Element				ev						L'élément déclencheur
	 * @return	void
	 */
	setMouseDown : function (ev) {
		// Pour une raison ou une autre, le mousedown du div principal n'est pas appelé...
		this.tree.evt_setAsCurrent(ev);
		if (this.tree.selectedBranchShowed) {
			if (!this.isSelected()) {
				this.select(ev);
				this.okayForUnselect = false;
			} else {
				this.okayForUnselect = true;
			}
		}
		if (this.tooltip) {
			this.displayTooltip = false;
			this.hideTooltip();
		}
		if (typeof(this.struct.onmousedown) == 'function') {
			this.struct.onmousedown(this, ev);
		}
	},
	
	/**
	 * Méthode appelée lorsqu'on "déclique"
	 *
	 * @access	public
	 * @param	Element				ev						L'élément déclencheur
	 * @return	void
	 */
	setMouseUp : function (ev) {
		if (this.tree.lastEdited) {
			this.tree.lastEdited.hideEditable(ev);
		}
		// Si la branche est déjà sélectionnée, on la déselectionne
		if (this.isSelected() && this.okayForUnselect) {
			//this.unselect();
			return true;
		}
		this.okayForUnselect = true;
		if (typeof(this.struct.onmouseup) == 'function') {
			this.struct.onmouseup(this, ev);
		}
	},
	
	/**
	 * Méthode appelée lorsqu'on clique sur le noeud
	 *
	 * @access	public
	 * @param	Element				ev						L'élément déclencheur
	 * @return	void
	 */
	setClick : function (ev) {
		if (this.tree.lastEdited) return false;
		if (typeof(this.struct.onclick) == 'function') {
			return this.struct.onclick(this, ev);
		}
	},
	
	/**
	 * Fonction appelée lorsqu'on clique sur une checkbox
	 *
	 * @access	public
	 * @param	HTMLimgElement		ev						L'élément déclencheur
	 * @return	boolean										True si le changement s'est fait, false sinon
	 */
	checkOnClick : function (ev) {
		if (this.tree.checkboxes && this.checkbox) {
			var checked = (this.isChecked() > 0) ? 0 : 1;
			var ok = true;
			if (typeof(this.struct.onbeforecheck) == 'function') {
				ok = this.struct.onbeforecheck(this, checked, ev);
			}
			if (ok) {
				this.check(checked);
				if (this.tree.checkboxesThreeState) {
					this._manageCheckThreeState(this, checked);
					this._adjustParentCheck();
				}
				if (typeof(this.struct.oncheck) == 'function') {
					this.struct.oncheck(this, checked, ev);
				}
			}
		}
	},
	
	/**
	 * Méthode appelée lors de l'ouverture ou fermeture d'un noeud
	 *
	 * @access	public
	 * @param	HTMLimgElement		ev						L'élément déclencheur
	 * @return	boolean										True si le changement s'est fait, false sinon
	 */
	setOpen : function (ev) {
		if (!this.hasChildren()) return false;
		var ok = true;
		if (typeof(this.struct.onbeforeopen) == 'function') {
			ok = this.struct.onbeforeopen(this, this.struct.open, ev);
		}
		if (!ok) return false;
		// On ne peut pas fermer la branche si elle subit un événement d'ouverture
		if (typeof(this.struct.onopenpopulate) == 'function' && !this.eventable) return false;
		this.openIt((this.isOpened()) ? false : true);
		if (typeof(this.struct.onopen) == 'function') {
			return this.struct.onopen(this, this.struct.open, ev);
		} else if (typeof(this.struct.onopenpopulate) == 'function' && this.isOpened() && this.children.length == 0) {
			if (!this.eventable) return false;
			return this._openPopulate(ev);
		}
		return true;
	},
	
	/**
	 * Ajoute une fonction utilisateur au start du drag
	 *
	 * @access public
	 * @author coucoudom
	 * @param HTMLObject drag l'objet draggé
	 * @param HTMLObject dragbis
	 */
	ondragstarteffect : function (drag, dragbis) {
		var dragObj = this.tree.getBranchByIdObj(drag.id);
		if (!dragObj) {
			for (var i = 0; i < this.tree.otherTrees.length; i++) {
				dragObj = this.tree.otherTrees[i].getBranchByIdObj(drag.id);
				if (dragObj) break;
			}
			if (!dragObj) return false;
		}
		// appel de la function user
		if (typeof(dragObj.struct.ondragstarteffect) == 'function') {
			var ok = dragObj.struct.ondragstarteffect(dragObj);
		}
	},
	
	/**
	 * Ajoute une fonction utilisateur au end du drag
	 *
	 * @access public
	 * @author coucoudom
	 * @param HTMLObject drag l'objet draggé
	 * @param HTMLObject dragbis
	 */
	ondragendeffect : function (drag, dragbis) {
		var dragObj = this.tree.getBranchByIdObj(drag.id);
		if (!dragObj) {
			for (var i = 0; i < this.tree.otherTrees.length; i++) {
				dragObj = this.tree.otherTrees[i].getBranchByIdObj(drag.id);
				if (dragObj) break;
			}
			if (!dragObj) return false;
		}
		// appel de la function user
		if (typeof(dragObj.struct.ondragendeffect) == 'function') {
			var ok = dragObj.struct.ondragendeffect(dragObj);
		}
	},
	
	/**
	 * Méthode appelée lorsqu'on drop sur le noeud
	 *
	 * Ici, le this correspond à l'objet qui réceptionne le drag
	 *
	 * @access	public
	 * @param	HTMLElement			drag					L'élément draggué
	 * @return	boolean										True si le changement s'est fait, false sinon
	 */
	setDrop : function (drag, html, html2, ev) {
		var dragObj = this.tree.getBranchByIdObj(drag.id);
		// Si l'objet n'est pas dans l'arbre courant, on va chercher dans les autres liés
		if (!dragObj) {
			for (var i = 0; i < this.tree.otherTrees.length; i++) {
				dragObj = this.tree.otherTrees[i].getBranchByIdObj(drag.id);
				if (dragObj) break;
			}
			if (!dragObj) return false;
		}
		var alt = (dragObj.tree.dropALT) ? TafelTreeManager.altOn(ev) : false;
		var ctrl = (dragObj.tree.dropCTRL) ? TafelTreeManager.ctrlOn(ev) || TafelTreeManager.metaOn(ev) : false;
		var ok = true;
		if ((this.tree.id == dragObj.tree.id && this.isChild(dragObj)) || !dragObj.eventable || !this.eventable) return false;
		// Fonction utilisateur avant le drop
		if (typeof(dragObj.struct.ondrop) == 'function') {
			ok = dragObj.struct.ondrop(dragObj, this, false, null, ev);
		}
		if (ok) {
			var asSibling = ((dragObj.tree.behaviourDrop == 1 || dragObj.tree.behaviourDrop == 3) && !alt || (dragObj.tree.behaviourDrop == 0 || dragObj.tree.behaviourDrop == 2) && alt) ? true : false;
			var copyDrag = ((dragObj.tree.behaviourDrop == 2 || dragObj.tree.behaviourDrop == 3) && !ctrl || (dragObj.tree.behaviourDrop == 0 || dragObj.tree.behaviourDrop == 1) && ctrl) ? true : false;
			// On va chercher les noeuds sur le serveur s'il y en a
			if (!asSibling && typeof(this.struct.onopenpopulate) == 'function' && !this.isOpened() && this.children.length == 0) {
				this._openPopulate(ev);
			}
			if (typeof(dragObj.struct.ondropajax) == 'function') {
				dragObj._setDropAjax(this, asSibling, copyDrag, ev);
			} else {
				// Drop normal
				var newBranch = null;
				if (!asSibling) {
					if (!copyDrag) {
						dragObj.move(this);
					} else {
						newBranch = this.insertIntoLast(dragObj.clone());
					}
				} else {
					if (!copyDrag) {
						dragObj.moveBefore(this);
					} else {
						newBranch = this.insertBefore(dragObj.clone());
					}
				}
				// Fonction utilisateur après le drop
				if (typeof(dragObj.struct.ondrop) == 'function') {
					ok = dragObj.struct.ondrop(dragObj, this, true, newBranch, ev);
				}				
			}
		}
	},
	
	/**
	 * Méthode appelée lorsqu'on double-clic sur le noeud
	 *
	 * @access	public
	 * @param	Element				ev						L'élément déclencheur
	 * @return	boolean										True si le changement s'est fait, false sinon
	 */
	setDblClick : function (ev) {
		if (this.tree.lastEdited) return false;
		if (typeof(this.struct.ondblclick) == 'function') {
			this.struct.ondblclick(this, ev);
		}
		if (this.struct.editable && this.editableInput) {
			if (!this.tree.lastEdited || this.tree.lastEdited.getId() != this.getId()) {
				this.editableInput.style.width = (this.txt.offsetWidth + 20) + 'px';
			}
			Element.hide(this.txt);
			this.editableInput.value = this.txt.innerHTML;
			this.editableInput.style.display = 'block';
			this.editableInput.focus();
			this.tree.lastEdited = this;
		}
	},
	
	/**
	 * Enlève l'édition de la branche
	 *
	 * @access	public
	 * @param	Event			ev						L'événement déclencheur
	 * @return	boolean									True si l'élément a été caché, false sinon
	 */
	hideEditable : function (ev) {
		if (this.editableInput && this.struct.editable) {
			var obj = this.editableInput;
			var value = obj.value;
			if (this.struct.oneditajax) {
				if (!this.eventable) return false;
				this._editAjax(obj.value, this.txt.innerHTML, ev);
			} else {
				if (typeof(this.struct.onedit) == 'function') {
					value = this.struct.onedit(this, obj.value, this.txt.innerHTML, ev);
				}
				this.setText(value);
				this.hideEditableElement();
			}
			return true;
		}
		return false;
	},
	
	hideEditableElement : function () {
		Element.hide(this.editableInput);
		this.editableInput.value = this.getText();
		this.txt.style.display = 'block';
		this.tree.lastEdited = null;
	}
};


















































/**
 *------------------------------------------------------------------------------
 *							TafelTreeRoot Class
 *------------------------------------------------------------------------------
 */

var TafelTreeRoot = Class.create();

TafelTreeRoot.prototype = Object.extend(new TafelTreeBaseBranch, {
	/**
	 * Constructeur d'un élément racine
	 *
	 * @access	public
	 * @param	TafelTree			tree					L'objet TafelTree courant
	 * @param	object				struct					Les infos concernant la racine est ses enfants
	 * @param	integer				level					Le niveau du noeud (0 pour la racine)
	 * @param	boolean				before					True s'il y a des noeuds avant
	 * @param	boolean				after					True s'il y a des noeuds après
	 */
	initialize : function (tree, struct, level, before, after, pos) {
		this.isRoot = true;
		this.tree = tree;
		this.pos = pos;
		this.level = level;
		this.struct = struct;
		this.tree.idTree++;
		this.idObj = this.tree.idTreeBranch + this.tree.idTree;
		this.hasSiblingsBefore = before;
		this.hasSiblingsAfter = after;
		this.eventable = true;
		this.loaded = true;
		this.children = [];
		this.copiedTimes = 0;

		this._setProperties();
		this._setFunctions();
		
		this.obj = this._addRoot();
		this.content = this._addContent();
		this.obj.appendChild(this.table);
		this._setChildren(this);
		this._setActions();
	},

	/**
	 * Méthode qui insère une branche avant celle courante
	 *
	 * @access	public
	 * @param	object				item					Un objet au format TafelTreeBranch
	 * @return	TafelTreeRoot								La nouvelle racine insérée
	 */
	insertBefore : function (item) {
		if (this.parent) return false;
		var pos = this.pos;
		var posBefore = pos + 1;
		var isNotFirst = (pos == 0) ? false : true;
		this._movePartStructRoot(pos);
		this.tree.roots[pos] = new TafelTreeRoot(this.tree, item, this.level, isNotFirst, true, pos);
		this.tree.div.insertBefore(this.tree.roots[pos].obj, this.obj);
		this._manageAfterRootInsert(pos);
		return this.tree.roots[pos];
	},

	/**
	 * Méthode qui insère une branche après celle courante
	 *
	 * @access	public
	 * @param	object				item					Un objet au format TafelTreeBranch
	 * @return	TafelTreeRoot								La nouvelle racine insérée
	 */
	insertAfter : function (item) {
		if (this.parent) return false;
		var pos = this.pos + 1;
		var posBefore = pos + 1;
		var isNotLast = (pos == this.tree.roots.length) ? false : true;
		this._movePartStructRoot(pos);
		this.tree.roots[pos] = new TafelTreeRoot(this.tree, item, this.level, true, isNotLast, pos);
		try {
			this.tree.div.insertBefore(this.tree.roots[pos].obj, this.tree.roots[posBefore].obj);
		} catch (err) {
			this.tree.div.appendChild(this.tree.roots[pos].obj);
		}
		this._manageAfterRootInsert(pos);
		return this.tree.roots[pos];
	},


	/**
	 *------------------------------------------------------------------------------
	 *							TafelTreeRoot private methods
	 *------------------------------------------------------------------------------
	 */
	
	_manageAfterRootInsert : function (pos) {
		for (var i = 0; i < this.tree.roots.length; i++) {
			if (i < this.tree.roots.length - 1) {
				this.tree.roots[i].hasSiblingsAfter = true;
			}
			if (i > 0) {
				this.tree.roots[i].hasSiblingsBefore = true;
			}
		}
		for (var i = 0; i < this.children.length; i++) {
			this.children[i]._manageLineForRoot(this.hasSiblingsAfter);
		}
	},
	
	_movePartStructRoot : function (pos) {
		var nb = this.tree.roots.length - 1;
		var newPos = 0;
		for (var i = nb; i >= pos; i--) {
			newPos = i + 1;
			this.tree.roots[newPos] = this.tree.roots[i];
			this.tree.roots[newPos].pos = newPos;
		}
	},
	
	/**
	 * Méthode pour ajouter l'élément principal
	 *
	 * @access	private
	 * @return	HTMLDivElement								L'élément DIV créé
	 */
	_addRoot : function () {
		var div = document.createElement('div');
		div.className = this.tree.classTreeRoot;
		return div;
	},
	
	/**
	 * Méthode pour ajouter le contenu de l'élément (images + textes)
	 *
	 * Créé une structure comme suit :
	 *	<table><tbody><tr>
	 *		<td><img /></td>
	 *		<td><![-- CDATA --]></td>
	 *	</tr></tbody></table>
	 *
	 * @access	private
	 * @return	HTMLTbodyElement							L'élément TBODY créé
	 */
	_addContent : function () {
		var table = document.createElement('table');
		var tbody = document.createElement('tbody');
		var tr = document.createElement('tr');
		var tdImg = document.createElement('td');
		var tdTxt = document.createElement('td');
		var img = document.createElement('img');
		var span = document.createElement('div');
		var txt = document.createTextNode(txt);
		img.src = this.tree.imgBase + this.struct.img;
		span.innerHTML = this.struct.txt;
		// Ajout du title (de NoisetteProd)
		if (this.struct.title) {
			span.setAttribute('title', this.struct.title);
		}
		// Fin ajout du title
		span.setAttribute('id', this.idObj);
		Element.addClassName(span, this.tree.classContent);
		Element.addClassName(tdTxt, this.tree.classCanevas);
		tdTxt.appendChild(span);
		tdImg.appendChild(img);
		// Insertion du tooltip, s'il existe
		if (this.struct.tooltip) {
			this.tooltip = this._createTooltip();
			tdTxt.appendChild(this.tooltip);
		}
		// Insertion de l'image avant l'icône
		this.tdImg = tdImg;
		this.beforeIcon = this._getImgBeforeIcon();
		tr.appendChild(this.beforeIcon);
		tr.appendChild(tdImg);
		tr.appendChild(tdTxt);
		tbody.appendChild(tr);
		table.appendChild(tbody);
		if (this.tree.multiline) {
			tdTxt.style.whiteSpace = 'normal';
			if (this.hasChildren()) this._manageMultiline(this.tdImg, 2, true);
		}
		if (this.struct.style) {
			Element.addClassName(tdTxt, this.struct.style);
		}
		this.txt = span;
		this.img = img;
		this.table = table;
		this._setEvents(tdTxt, tdImg);
		return tbody;
	}
});












































/**
 *------------------------------------------------------------------------------
 *							TafelTreeBranch Class
 *------------------------------------------------------------------------------
 */

/**
Properties description

this.tree     : l'arbre de la branche
this.root     : la racine de la branche
this.parent   : le parent de la branche (peut être this.root)
this.level    : le niveau de la branche. Le 1er niveau sous la racine est le 1
this.pos      : la position de la branche au sein des enfants du parent
this.idObj    : l'id attribué automatiquement. Ne pas se baser dessus pour les developpements externes
this.children : les enfants de la branche
this.objDrag  : L'objet Draggable

this.struct           : la structure de la branche avec toutes les infos utilisateur

this.eventable :
Détermine si la branche peut être drag n' droppée ou non.
Utilisé uniquement lors du dragndrop ajax et open ajax.

this.obj        : HTMLDivElement qui symbolise la branche
this.content    : HTMLTBodyElement qui symbolise le contenu de la branche
this.beforeIcon : HTMLTdElement qui symbolise la TD contenant le picto avant l'icône
this.img        : HTMLImgElement qui représente l'icône avant le texte
this.txt        : HTMLTextNodeElement qui représente le texte de la branche
this.table      : HTMLTableElement qui est le parent du Tbody (this.content)
*/

var TafelTreeBranch = Class.create();

TafelTreeBranch.prototype = Object.extend(new TafelTreeBaseBranch, {
	/**
	 * Constructeur d'une branche de l'arbre
	 *
	 * @access	public
	 * @param	TafelRoot			root					L'objet racine parent
	 * @param	TafelBranch			parent					L'objet directement parent
	 * @param	object				struct					Les infos concernant la branche est ses enfants
	 * @param	integer				level					Le niveau du noeud
	 * @param	boolean				before					True s'il y a des noeuds avant
	 * @param	boolean				after					True s'il y a des noeuds après
	 * @param	integer				pos						La position dans le tableau children[] du parent
	 */
	initialize : function (root, parent, struct, level, before, after, pos) {
		this.tree = root.tree;
		this.root = root;
		this.level = level;
		this.pos = pos;
		this.parent = parent;
		this.tree.idTree++;
		this.idObj = this.tree.idTreeBranch + this.tree.idTree;
		this.hasSiblingsBefore = before;
		this.hasSiblingsAfter = after;
		this.struct = struct;
		this.eventable = true;
		this.loaded = true;
		this.inProcess = false;
		this.children = [];
		this.copiedTimes = 0;

		if (typeof(this.struct.draggable) == 'undefined') this.struct.draggable = 1;
		this._setProperties();

		// Fonctions utilisateurs
		if (typeof(this.struct.ondrop) == 'undefined') {
			if (typeof(this.tree.onDrop) == 'function') {
				this.struct.ondrop = this.tree.onDrop;
				this.ondropDefault = true;
			}
		} else {this.struct.ondrop = eval(this.struct.ondrop);}
		if (typeof(this.struct.ondropajax) == 'undefined') {
			if (this.tree.onDropAjax && typeof(this.tree.onDropAjax.func) == 'function') {
				this.struct.ondropajax = this.tree.onDropAjax.func;
				this.struct.droplink = this.tree.onDropAjax.link;
				this.ondropajaxDefault = true;
			}
		} else {this.struct.ondropajax = eval(this.struct.ondropajax);}
		this._setFunctions();

		// Initialisation de la branche
		this.obj = this._addBranch();
		this.content = this._addContent();
		this.obj.appendChild(this.table);
		this._setChildren(root);
		// set actions like select node
		this._setActions();
	},

	insertBefore : function (item) {
		if (!this.parent) return false;
		var pos = this.pos;
		var posBefore = pos + 1;
		var isNotFirst = (pos == 0) ? false : true;
		this.parent._movePartStruct(pos);
		this.parent.struct.items[pos] = item;
		this.parent.children[pos] = new TafelTreeBranch(this.root, this.parent, item, this.level, isNotFirst, true, pos);
		this.parent.obj.insertBefore(this.parent.children[pos].obj, this.obj);
		this.parent._manageAfterInsert(pos);
		return this.parent.children[pos];
	},

	insertAfter : function (item) {
		if (!this.parent) return false;
		var pos = this.pos + 1;
		var posBefore = pos + 1;
		var isNotLast = (pos == this.parent.children.length) ? false : true;
		this.parent._movePartStruct(pos);
		this.parent.struct.items[pos] = item;
		this.parent.children[pos] = new TafelTreeBranch(this.root, this.parent, item, this.level, true, isNotLast, pos);
		try {
			this.parent.obj.insertBefore(this.parent.children[pos].obj, this.parent.children[posBefore].obj);
		} catch (err) {
			this.parent.obj.appendChild(this.parent.children[pos].obj);
		}
		this.parent._manageAfterInsert(pos);
		return this.parent.children[pos];
	},
	
	/**
	 * Méthode pour déplacer une branche dans l'arbre comme fille
	 *
	 * @access	public
	 * @param	string				hereb					L'id de la nouvelle branche parente
	 * @return	TafelTreeBranch								La branche bougée
	 */
	move : function (hereb) {
		return this.moveIntoLast(hereb);
	},
	moveIntoLast : function (hereb) {
		// On récupère l'objet "here"
		var here = this.tree.getBranchById(hereb);
		if (!here) return false

		var pos = here._getPos();
		var id = this.getId();
		var txt = this.getText();
		if (pos == here.children.length) {
			obj = here.insertIntoLast(this.struct);
		} else {
			obj = here.children[pos].insertBefore(this.struct);
		}
		this.tree.removeBranch(this);
		return obj;
	},
	
	moveIntoFirst : function (hereb) {
		// On récupère l'objet "here"
		var here = this.tree.getBranchById(hereb);
		if (!here) return false

		var id = this.getId();
		var txt = this.getText();
		var obj = here.insertIntoFirst(this.struct);
		this.tree.removeBranch(this);
		return obj;
	},
	
	/**
	 * Méthode pour déplacer une branche dans l'arbre comme soeur
	 *
	 * @access	public
	 * @param	string				hereb					L'id de la nouvelle branche soeur
	 * @return	void
	 */
	moveBefore : function (hereb) {
		// On récupère l'objet "here"
		var here = this.tree.getBranchById(hereb);
		if (!here) return false;

		var id = this.getId();
		var txt = this.getText();
		var obj = here.insertBefore(this.struct);
		this.tree.removeBranch(this);
		return obj;
	},

	moveAfter : function (hereb) {
		// On récupère l'objet "here"
		var here = this.tree.getBranchById(hereb);
		if (!here) return false;

		var id = this.getId();
		var txt = this.getText();
		var obj = here.insertAfter(this.struct);
		this.tree.removeBranch(this);
		return obj;
	},


	/**
	 *------------------------------------------------------------------------------
	 *							TafelTreeBranch private methods
	 *------------------------------------------------------------------------------
	 */
	
	/**
	 * Méthode pour ajouter l'élément principal
	 *
	 * @access	private
	 * @return	HTMLDivElement								L'élément DIV créé
	 */
	_addBranch : function () {
		var div = document.createElement('div');
		div.className = this.tree.classTreeBranch;
		return div;
	},
	
	/**
	 * Méthode pour ajouter le contenu de l'élément (images + textes)
	 *
	 * Créé une structure comme suit :
	 *	<table><tbody><tr>
	 *		<td><img /></td>
	 *		<td><img /></td>
	 *		<td>etc. (relatif au niveau de l'élément courant)</td>
	 *		<td><![-- CDATA --]></td>
	 *	</tr></tbody></table>
	 *
	 * @access	private
	 * @return	HTMLTbodyElement							L'élément TBODY créé
	 */
	_addContent : function () {
		var table = document.createElement('table');
		var tbody = document.createElement('tbody');
		var tr = document.createElement('tr');
		var img = document.createElement('img');
		// Toutes les images jusqu'à celle avant l'icône
		var imgs = this._addImgs();
		var nbImgs = imgs.length;
		for (var i = nbImgs - 1; i >= 0; i--) {
			tr.appendChild(imgs[i]);	
		}
		// On récupère l'image avant l'icône
		this.beforeIcon = this._getImgBeforeIcon();
		tr.appendChild(this.beforeIcon);
		
		// On créé l'icone et le texte
		var tdImg = document.createElement('td');
		var tdTxt = document.createElement('td');
		var img = document.createElement('img');
		var span = document.createElement('div');
		span.innerHTML = this.struct.txt;
		// Ajout du title (de NoisetteProd)
		if (this.struct.title) {
			span.setAttribute('title', this.struct.title);
		}
		// Fin ajout du title
		span.setAttribute('id', this.idObj);
		Element.addClassName(span, this.tree.classContent);
		Element.addClassName(tdTxt, this.tree.classCanevas);
		img.src = this.tree.imgBase + this.struct.img;
		this.tdImg = tdImg;
		if (this.tree.multiline) {
			tdTxt.style.whiteSpace = 'normal';
			if (this.hasChildren()) this._manageMultiline(this.tdImg, 2, true);
		}
		if (this.struct.style) {
			Element.addClassName(tdTxt, this.struct.style);
		}
		// On append l'ensemble à la table HTML
		tdTxt.appendChild(span);
		// Insertion du tooltip, s'il existe
		if (this.struct.tooltip) {
			this.tooltip = this._createTooltip();
			tdTxt.appendChild(this.tooltip);
		}
		tdImg.appendChild(img);
		tr.appendChild(tdImg);
		tr.appendChild(tdTxt);
		tbody.appendChild(tr);
		table.appendChild(tbody);
		this.tdImg = tdImg;
		this.txt = span;
		this.img = img;
		this.table = table;
		this._setEvents(tdTxt, tdImg);
		return tbody;
	},
	
	/**
	 * Fonction qui permet de gérer toutes les lignes verticales qui précèdent l'icone
	 *
	 * @access	private
	 * @return	array										Les images à mettre avant l'icône
	 */
	_addImgs : function () {
		var obj = this.parent;
		var cpt = 0;
		var imgs = [];
		var img = null;
		// On détermine s'il y a des lignes verticales avant l'icone et le texte
		var td = null;
		while (obj.parent) {
			td = document.createElement('td');
			img = document.createElement('img');
			if (!obj.hasSiblingsAfter) {
				img.src = this.tree.imgBase + this.tree.imgEmpty;
			} else {
				img.src = this.tree.imgBase + this.tree.imgLine1;
				if (this.tree.multiline) {
					this._manageMultiline(td, 1, true);
				}
			}
			td.appendChild(img);
			imgs[cpt] = td;
			cpt++;
			obj = obj.parent;
		}
		// On teste si le root à des soeurs. Si oui, on ajoute encore une ligne
		td = document.createElement('td');
		img = document.createElement('img');
		if (!this.root.hasSiblingsAfter) {
			img.src = this.tree.imgBase + this.tree.imgEmpty;
		} else {
			img.src = this.tree.imgBase + this.tree.imgLine1;
			if (this.tree.multiline) {
				this._manageMultiline(td, 1, true);
			}
		}
		td.appendChild(img);
		imgs[cpt] = td;
		return imgs;
	}
});



























/**
 *------------------------------------------------------------------------------
 *							TafelTrees Management
 *------------------------------------------------------------------------------
 */

var TafelTreeManager = {
	/**
	 *------------------------------------------------------------------------------
	 *							TafelTreeManager properties
	 *------------------------------------------------------------------------------
	 */
	
	/**
	 * @var		boolean			stopEvent				Stoppe la propagation de l'événement
	 */
	stopEvent : true,
	
	/**
	 * @var		boolean			keyboardEvents			True pour activer la gestion clavier
	 */
	keyboardEvents : true,
	
	/**
	 * @var		boolean			keyboardStructEvents	True pour activer la gestion clavier relative à la structure
	 */
	keyboardStructuralEvents : true,
	
	/**
	 * @var		array			trees					Les arbres actuellement loadés
	 */
	trees : [],
	
	/**
	 * @var		TafelTree		currentTree				L'arbre actuellement actif
	 */
	currentTree : null,
	
	/**
	 * @var		array			userKeys				Les touches utilisateur
	 */
	userKeys : [],
	
	
	
	/**
	 *------------------------------------------------------------------------------
	 *							TafelTreeManager public methods
	 *------------------------------------------------------------------------------
	 */
	
	/**
	 * Permet de setter des fonctions utilisateur pour les touches voulues
	 *
	 * L'objet keys est formé comme ceci :
	 *	- keys[0].key = code de la touche
	 *	- keys[0].func = fonction utilisateur
	 *
	 * @access	public
	 * @param	array			keys					Les touchces et leur fonction
	 * @return	void
	 */
	setKeys : function (keys) {
		this.userKeys = keys;
	},
	
	/**
	 * Ajoute un arbre dans le manager
	 *
	 * @access	public
	 * @param	TafelTree		tree					L'arbre à ajouter
	 * @return	void
	 */
	add : function (tree) {
		this.trees.push(tree);
	},

	disableKeyboardEvents : function () {
		this.keyboardEvents = false;
	},

	disableKeyboardStructuralEvents : function () {
		this.keyboardStructuralEvents = false;
	},
	
	/**
	 * Retourne l'arbre actuellement actif
	 *
	 * @access	public
	 * @return	TafelTree								L'arbre actuellement actif
	 */
	getCurrentTree : function () {
		return this.currentTree;
	},
	
	/**
	 * Set l'arbre actuellement actif
	 *
	 * @access	public
	 * @param	TafelTree								L'arbre actuellement actif
	 * @return	void
	 */
	setCurrentTree : function (tree) {
		this.currentTree = tree;
	},
	
	/**
	 * Retourne true si la touche POMME est appuyée (sur Mac Safari)
	 *
	 * @access	public
	 * @return	boolean									True si POMME est appuyé
	 */
	metaOn : function (ev) {
		var ok = false;
		if (ev && (ev.metaKey)) {
			ok = true;
		}
		return ok;
	},
	
	/**
	 * Retourne true si la touche CTRL est appuyée
	 *
	 * @access	public
	 * @return	boolean									True si CTRL est appuyé
	 */
	ctrlOn : function (ev) {
		var ok = false;
		if (ev && (ev.ctrlKey || ev.modifier == 2)) {
			ok = true;
		}
		return ok;
	},
	
	/**
	 * Retourne true si la touche ALT est appuyée
	 *
	 * @access	public
	 * @return	boolean									True si ALT est appuyé
	 */
	altOn : function (ev) {
		var ok = false;
		if (ev && (ev.altKey || ev.modifier == 1)) {
			ok = true;
		}
		return ok;
	},
	
	/**
	 * Retourne true si la touche SHIFT est appuyée
	 *
	 * @access	public
	 * @return	boolean									True si ALT est appuyé
	 */
	shiftOn : function (ev) {
		var ok = false;
		if (ev && (ev.shiftKey || ev.modifier == 3)) {
			ok = true;
		}
		return ok;
	},
	
	/**
	 * Retourne le code clavier
	 *
	 * @access	public
	 * @param	Event			ev						L'événement déclencheur
	 * @return	void
	 */
	getCode : function (ev) {
		return (ev.which) ? ev.which : ev.keyCode;
	},
	
	/**
	 * Assigne tous les événements nécessaires
	 *
	 * @access	public
	 * @return	void
	 */
	setControlEvents : function () {
		Event.observe(document, 'keypress', this.evt_keyPress.bindAsEventListener(this), false);
		var body = document.getElementsByTagName('body');
		if (!body || !body[0]) {
			throw new Error(TAFELTREE_NO_BODY_TAG);
		} else {
			Event.observe(body[0], 'mouseup', this.evt_unselect.bindAsEventListener(this), false);
		}
	},
	
	
	/**
	 *------------------------------------------------------------------------------
	 *							TafelTreeManager events management
	 *------------------------------------------------------------------------------
	 */

	/**
	 * Déselectionne l'arbre courant
	 *
	 * @access	public
	 * @param	Event			ev						L'événement déclencheur
	 * @return	void
	 */
	evt_unselect : function (ev) {
		var obj = Event.element(ev);
		var current = this.getCurrentTree();
		if (current) {
			if (!Element.hasClassName(obj, current.classSelected) && !Element.hasClassName(obj, current.classOpenable)) {
				current.unselect();
				this.setCurrentTree(null);
			}
		}
	},
	
	/**
	 * Appel lors de la touche ENTER
	 *
	 * @access	public
	 * @param	TafelTree		tree					L'arbre incriminé
	 * @param	integer			code					Le code de la touche
	 * @param	Object			keys					Les infos des "metakeys" ctrl, shift, alt et meta
	 * @param	Event			ev						L'événement déclencheur
	 * @return	void
	 */
	enter : function (tree, code, keys, ev) {
		if (tree.lastEdited) {
			tree.lastEdited.editableInput.blur();
			if (this.stopEvent) Event.stop(ev);
		}
	},
	
	/**
	 * Appel lors de la touche ESCAPE
	 *
	 * @access	public
	 */
	escape : function (tree, code, keys, ev) {
		var selected = tree.getSelectedBranches();
		var lastPos = selected.length - 1;
		var nounselect = false;
		if (lastPos == 0 && tree.lastEdited) {
			if (tree.lastEdited.hideEditable(ev)) {
				nounselect = true;
			}
		}
		if (!nounselect) {
			tree.unselect();
		}
		tree.unsetCut();
		tree.unsetCopy();
		if (this.stopEvent) Event.stop(ev);
	},
	
	/**
	 * Appel lors de la touche HOME
	 *
	 * @access	public
	 */
	moveStart : function (tree, code, keys, ev) {
		if (!tree.lastEdited) {
			tree.unselect();
			if (tree.roots.length > 0) {
				var branch = tree.roots[0];
				branch.select();
			}
			if (this.stopEvent) Event.stop(ev);
		}
	},
	
	/**
	 * Appel lors de la touche END
	 *
	 * @access	public
	 */
	moveEnd : function (tree, code, keys, ev) {
		if (!tree.lastEdited) {
			tree.unselect();
			if (tree.roots.length > 0) {
				var last = tree.roots.length - 1;
				var branch = tree.roots[last];
				while (branch.hasChildren()) {
					branch = branch.getLastBranch();
				}
				branch.select();
			}
			if (this.stopEvent) Event.stop(ev);
		}
	},
	
	/**
	 * Appel lors de la touche Fleche haut
	 *
	 * @access	public
	 */
	moveUp : function (tree, code, keys, ev) {
		var selected = tree.getSelectedBranches();
		var lastPos = selected.length - 1;
		if (!tree.lastEdited) {
			if (lastPos >= 0) {
				var branch = selected[lastPos].getPreviousOpenedBranch();
				if (branch) branch.select(ev);
			} else {
				// On sélectionne automatiquement le 1er élément de l'arbre
				if (typeof(tree.roots[0]) != 'undefined') tree.roots[0].select();
			}
			if (this.stopEvent) Event.stop(ev);
		}
	},
	
	/**
	 * Appel lors de la touche Fleche bas
	 *
	 * @access	public
	 */
	moveDown : function (tree, code, keys, ev) {
		var selected = tree.getSelectedBranches();
		var lastPos = selected.length - 1;
		if (!tree.lastEdited) {
			if (lastPos >= 0) {
				var branch = selected[lastPos].getNextOpenedBranch();
				if (branch) branch.select(ev);
			} else {
				// On sélectionne automatiquement le 1er élément de l'arbre
				if (typeof(tree.roots[0]) != 'undefined') tree.roots[0].select();
			}
			if (this.stopEvent) Event.stop(ev);
		}
	},
	
	/**
	 * Appel lors de la touche Fleche droite
	 *
	 * @access	public
	 */
	moveRight : function (tree, code, keys, ev) {
		var selected = tree.getSelectedBranches();
		var lastPos = selected.length - 1;
		if (!tree.lastEdited) {
			if (lastPos >= 0) {
				var branch = selected[lastPos];
				if (branch.hasChildren() && !branch.isOpened()) {
					branch.setOpen(ev);
				} else {
					if (branch.hasChildren()) {
						var sel = branch.getFirstBranch();
						var sel = sel.select(ev);
					}
				}
			} else {
				// On sélectionne automatiquement le 1er élément de l'arbre
				if (typeof(tree.roots[0]) != 'undefined') tree.roots[0].select();
			}
			if (this.stopEvent) Event.stop(ev);
		}	
	},
	
	/**
	 * Appel lors de la touche Fleche gauche
	 *
	 * @access	public
	 */
	moveLeft : function (tree, code, keys, ev) {
		var selected = tree.getSelectedBranches();
		var lastPos = selected.length - 1;
		if (!tree.lastEdited) {
			if (lastPos >= 0) {
				var branch = selected[lastPos];
				if (lastPos == 0 && branch.hasChildren() && branch.isOpened()) {
					branch.openIt(false);
				} else {
					if (!branch.isRoot) branch.parent.select(ev);
				}
			} else {
				// On sélectionne automatiquement le 1er élément de l'arbre
				if (typeof(tree.roots[0]) != 'undefined') tree.roots[0].select();
			}
			if (this.stopEvent) Event.stop(ev);
		}		
	},
	
	/**
	 * Appel lors de la touche F2
	 *
	 * @access	public
	 */
	edit : function (tree, code, keys, ev) {
		var selected = tree.getSelectedBranches();
		var lastPos = selected.length - 1;
		if (lastPos == 0) {
			selected[lastPos].setDblClick(ev);
		}
		if (this.stopEvent) Event.stop(ev);
	},
	
	/**
	 * Appel lors de la touche DELETE
	 *
	 * @access	public
	 */
	remove : function (tree, code, keys, ev) {
		if (!tree.lastEdited) {
			var selected = tree.getSelectedBranches();
			for (var i = 0; i < selected.length; i++) {
				tree.removeBranch(selected[i]);
			}
			if (this.stopEvent) Event.stop(ev);
		}
	},
	
	/**
	 * Appel lors de la touche x ou X
	 *
	 * @access	public
	 */
	cut : function (tree, code, keys, ev) {
		if (keys.ctrlKey || keys.metaKey) {
			tree.cut();
			if (this.stopEvent) Event.stop(ev);
		}
	},
	
	/**
	 * Appel lors de la touche c ou C
	 *
	 * @access	public
	 */
	copy : function (tree, code, keys, ev) {
		if (keys.ctrlKey || keys.metaKey) {
			tree.copy();
			if (this.stopEvent) Event.stop(ev);
		}
	},
	
	/**
	 * Appel lors de la touche v ou V
	 *
	 * @access	public
	 */
	paste : function (tree, code, keys, ev) {
		if (keys.ctrlKey || keys.metaKey) {
			tree.paste();
			if (this.stopEvent) Event.stop(ev);
		}
	},
	
	/**
	 * Appel lors de la touche z ou Z
	 *
	 * @access	public
	 */
	undo : function (tree, code, keys, ev) {
		if (keys.ctrlKey || keys.metaKey) {
			tree.undo();
			if (this.stopEvent) Event.stop(ev);
		}
	},
	
	/**
	 * Gestion du clavier
	 *
	 * @access	private
	 * @param	Event					ev							L'événement déclencheur
	 * @return	void
	 */
	evt_keyPress : function (ev) {
		var current = this.getCurrentTree();
		if (current && this.keyboardEvents) {
			// Check Control Ctrl
			var keys = {
				'ctrlKey'  : this.ctrlOn(ev),
				'metaKey'  : this.metaOn(ev),
				'altKey'   : this.altOn(ev),
				'shiftKey' : this.shiftOn(ev)
			};
			// Check de la touche appuyée
			var code = this.getCode(ev);
			// Check si l'utilisateur a fourni une fonction particulière
			for (var i = 0; i < this.userKeys.length; i++) {
				if (code == this.userKeys[i].key && typeof(this.userKeys[i].func) == 'function') {
					if (!this.userKeys[i].func(current, code, keys, ev)) {
						return false;
					}
					break;
				}
			}
			switch (code) {
				// Retour au début (Home) et fin (End)
				case Event.KEY_HOME : this.moveStart(current, code, keys, ev); break;
				case Event.KEY_END : this.moveEnd(current, code, keys, ev); break;
				// Mouvements haut, bas, gauche et droite
				case Event.KEY_UP : this.moveUp(current, code, keys, ev); break;
				case Event.KEY_DOWN : this.moveDown(current, code, keys, ev); break;
				case Event.KEY_RIGHT : this.moveRight(current, code, keys, ev); break;
				case Event.KEY_LEFT : this.moveLeft(current, code, keys, ev); break;
			}
			if (this.keyboardStructuralEvents) {
				switch (code) {
					// Fin de l'édition d'une branche
					case Event.KEY_RETURN : this.enter(current, code, keys, ev); break;
					// Déselection
					case Event.KEY_ESC : this.escape(current, code, keys, ev); break;
					// Effacer (Del)
					case Event.KEY_DELETE : this.remove(current, code, keys, ev); break;
					// Editer (F2)
					case 113: this.edit(current, code, keys, ev); break;
					// Couper (x-X)
					case 120: case 88: this.cut(current, code, keys, ev); break;
					// Copier (c-C)
					case 99 : case 67: this.copy(current, code, keys, ev); break;
					// Coller (v-V)
					case 118: case 86: this.paste(current, code, keys, ev); break;
					// Annuler (z-Z)
					case 122: case 90: this.undo(current, code, keys, ev); break;
				}
			}
		}
	}
};


/**
 *------------------------------------------------------------------------------
 *							TafelTree pre-instanciation
 *------------------------------------------------------------------------------
 */

function TafelTreeInitBase (ev) {
	TafelTreeManager.setControlEvents();
	if (typeof(TafelTreeInit) == 'function') {
		TafelTreeInit();
	}
};

Event.observe(window, 'load', TafelTreeInitBase, false);