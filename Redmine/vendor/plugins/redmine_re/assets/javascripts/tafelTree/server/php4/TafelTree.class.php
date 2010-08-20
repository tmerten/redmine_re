<?php

include_once ('JSON.php');
include_once ('TafelTreeBranch.class.php');

/**
 * 
 *
 * @author 	FTafel
 */
class TafelTree {
	
	
	/**
	 *------------------------------------------------------------------------------
	 *							Propriétés
	 *------------------------------------------------------------------------------
	 */
	
	/**
	 * @access 	protected
	 * @var 	string				$id					L'id de l'arbre
	 */
	var $id;
	
	/**
	 * @access 	protected
	 * @var 	string				$id					L'id de l'arbre
	 */
	var $width;
	
	/**
	 * @access 	protected
	 * @var 	string				$id					L'id de l'arbre
	 */
	var $height;
	
	/**
	 * @access 	protected
	 * @var 	string				$id					L'id de l'arbre
	 */
	var $pathImgs;
	
	/**
	 * @access 	protected
	 * @var 	array				$options			Les options de load de l'arbre
	 */
	var $options;
	
	
	/**
	 *------------------------------------------------------------------------------
	 *							Constructeur
	 *------------------------------------------------------------------------------
	 */
	
	/**
	 * Constructeur
	 *
	 * @access	public
	 * @param	string				id					L'id de l'élément HTML conteneur
	 * @param	string				imgBase				Le path vers les images
	 * @param	integer				width				La largeur de l'arbre
	 * @param	integer				height				La hauteur de l'arbre
	 * @param	array				options				Les options de l'arbre
	 */
	function TafelTree ($id, $imgs = 'imgs/', $width = '100%', $height = 'auto', $options = array()){
		$this->id = $id;
		$this->pathImgs = $imgs;
		$this->width = $width;
		$this->height = $height;
		$this->options = array();
		foreach ($options as $property => $value) {
			$this->options[$property] = $value;
		}
	}
	
	/**
	 * Load les infos depuis une string JSON
	 *
	 * @access	public
	 * @param 	string			$json					La string JSON
	 * @return 	TafelTree								Le TafelTree créé
	 */
	function &loadJSON ($json, $id, $imgs = 'imgs/', $width = '100%', $height = 'auto', $options = array()) {
		$tree =& new TafelTree($id, $imgs, $width, $height, $options);
		$service = new Services_JSON();
		$tree->items =& TafelTree::loadServiceJSON($service->decode($json));
		return $tree;
	}
	
	/**
	 * Load les infos depuis un objet Service_JSON
	 *
	 * @access	public
	 * @param 	Service_JSON	$service				L'objet Service_JSON
	 * @return 	array									Les TafelTreeBranch créées
	 */
	function &loadServiceJSON ($service) {
		$branches = array();
		foreach ($service as $branch) {
			$branches[] =& TafelTreeBranch::loadServiceJSON($branch);
		}
		return $branches;
	}
	
	
	
	/**
	 *------------------------------------------------------------------------------
	 *							Fonctions getters et setters
	 *------------------------------------------------------------------------------
	 */
	
	function getId() {
		return $this->id;
	}
	function getPathImgs() {
		return $this->pathImgs;
	}
	function getWidth() {
		return $this->width;
	}
	function getHeight() {
		return $this->height;
	}
	
	
	/**
	 *------------------------------------------------------------------------------
	 *							Fonctions publiques
	 *------------------------------------------------------------------------------
	 */
	
	/**
	 * Ajoute une branche comme enfant
	 *
	 * @access 	public
	 * @param 	TafelTreeBranch		$branch				La branche à ajouter
	 * @return 	void
	 */
	function &add ($branch) {
		if (!isset($this->items)) {
			$this->items = array();
		}
		$this->items[] =& $branch;
	}
	
	/**
	 * Ajoute une sous-branche à l'arbre
	 *
	 * @access 	public
	 * @param 	string			$id						L'id de la sous-branche
	 * @param 	string			$txt					Le texte de la sous-branche
	 * @param 	array			$options				Les informations complémentaires
	 * @return 	TafelTreeBranch							La sous-branche
	 */
	function &addBranch ($id, $txt, $options = array()) {
		$branch =& new TafelTreeBranch ();
		$branch->setId($id);
		$branch->setText($txt);
		foreach ($options as $property => $value) {
			if ($property != 'items') {
				$branch->setParam($property, $value);
			}
		}
		if (isset($options['items'])) {
			foreach ($options['items'] as $opt) {
				$branch->addBranch(null, null, $opt);
			}
		}
		if (!isset($this->items)) {
			$this->items = array();
		}
		$this->items[] =& $branch;
		return $branch;
	}
	
	/**
	 * Affiche la méthode d'initialisation de l'arbre
	 *
	 * @access 	public
	 * @param 	integer			$debug					Mettre 1 ou 2 pour avoir un affichage plus lisible
	 * @return 	string									La string de la méthode JS d'initialisation
	 */
	function display ($debug = 0) {
		if ($debug == 1) {
			$d = '<br />';
		} elseif ($debug == 2) {
			$d = "\n";
		} else {
			$d = '';
		}
		if (count($this->options) > 0) {
			$s = new Services_JSON();
			$options = ','.$s->encode($this->options);
		}
		$str = "var tree_".$this->id." = null;".$d;
		$str .= "function TafelTreeInit() {".$d;
		$str .= "tree_".$this->id." = new TafelTree (".$d;
		$str .= "'".$this->getId()."', ".$d;
		$str .= $this->getJSON().", ".$d;
		$str .= "'".$this->getPathImgs()."', ".$d;
		$str .= "'".$this->getWidth()."', ".$d;
		$str .= "'".$this->getHeight()."'".$options;
		$str .= ");".$d;
		$str .= "};".$d;
		return $str;
	}
	
	/**
	 * Affiche la structure JSON de l'arbre
	 *
	 * @access 	public
	 * @return 	string									La structure JSON de l'arbre
	 */
	function getJSON () {
		$service = new Services_JSON();
		return $service->encode($this->items);
	}
}

?>