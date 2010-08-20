<?php

include_once ('php4/TafelTree.class.php');


///
 // CASE 1 : load structure from a JSON string
 //
 ///

// Check the JSON string
$json = "[{id:'r1',txt:'root',items:[{id:'b1',txt:'branch 1',myPos:{x:1,y:9}},{id:'b2',txt:'branch 2'}]}]";

// Load the JSON into an object (or array of objects)
$branches = TafelTreeBranch::loadJSON($json);

// Manipulate the object (or array of objects)
$first = $branches[0];
echo '<h3>CASE 1 : load structure from a JSON string</h3>';
echo 'First JSON branch : '.$first->getText().' ('.$first->getId().')';
echo '<ul>';
foreach ($first->items as $next) {
	echo '<li>Next JSON branch : '.$next->getText().' ('.$next->getId().')</li>';
}
echo '</ul>';






///
 // CASE 2 : create a loader TafelTree from an object
 //
 ///

// Create the tree (same options as javascript). In this sample, the file
// drop.php doesn't exist. It's just to show how to manage ajax declarations
$tree = new TafelTree('divTree', '../imgs/', null, null, array(
	'generate' => true,
	'onMouseOver'=>'myMouseover',
	'onMouseOut'=>'myMouseout',
	'defaultImg'=>'page.gif',
	'lineStyle'=>'full',
	'onDropAjax'=>array('funcDrop', 'drop.php')
));

// Add a root branch
$b1 = $tree->addBranch('r1', 'root');

// Add two branches into the root
$b1->addBranch('b1', 'branch 1', array('onclick'=>'testclick','thing' => 1));
$b1->addBranch('b2', 'branch 2');

?>
<html>
<head>
	<title>PHP4 sample</title>
	<link rel="stylesheet" href="../css/tree.css" type="text/css" />
	<script src="../js/prototype.js" type="text/javascript"></script>
	<script src="../js/scriptaculous.js" type="text/javascript"></script>
	<script src="../Tree.js" type="text/javascript"></script>
	<script type="text/javascript">
	function myMouseover (branch) {
		branch.txt.style.color = 'red';
	}
	function myMouseout (branch) {
		branch.txt.style.color = 'black';
	}
	function funcDrop (move, here, response, finished) {
		return false;
	}
	function testclick(branch) {
		
	}
<?php
// Display the function which is called at load
// You can print only the JSON structure with
// the function $tree->getJSON();
echo $tree->display();
?>
	</script>
</head>
<body>

<h3>CASE 2 : create a loader TafelTree from an object</h3>
<div id="divTree"></div>

<h3>CASE 3 : get only the JSON from an object</h3>
<?php echo $tree->getJSON(); ?>

</body>
</html>
