<?php

if (isset($_POST['branch_id'])) {
	switch ($_POST['branch_id']) {
		case 'child1' :
			// Création du tableau de branches enfant pour child1
			echo "[";
			echo "{id:'server1', txt:'Du serveur 1'},";
			echo "{id:'server2', txt:'Du serveur 2'}";
			echo ",{id:'server2d', txt:'Du serveur 2d'}";
			echo "]";
			break;
		case 'child3' :
			// Création du tableau de branches enfant pour child3
			echo "[";
			echo "{id:'server3', txt:'Du serveur 3'}";
			echo "]";
			break;
		case 'child4' :
			// Création du tableau de branches enfant pour child4
			echo "[";
			echo "{id:'server4', txt:'Du serveur 4'},";
			echo "{id:'server5', txt:'Du serveur 5', canhavechildren:true},";
			echo "{id:'server6', txt:'Du serveur 6'}";
			echo "]";
			break;
		case 'server5' :
			// Création du tableau de branches enfant pour server5
			echo "[";
			echo "{id:'server7', txt:'Du serveur 7'}";
			echo "]";
			break;
		default :
			// Ne fait rien
	}
}

?>