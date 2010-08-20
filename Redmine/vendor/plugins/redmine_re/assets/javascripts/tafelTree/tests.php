<html>
<head>
	<title>OpenOfficeGeneration Documentation</title>
	<link rel="stylesheet" type="text/css" href="css/tree.css" />
	<script type="text/javascript" src="js/prototype.js"></script>
	<script type="text/javascript" src="js/scriptaculous.js"></script>
	<script type="text/javascript" src="Tree.js"></script>
</head>
<body>

			<script type="text/javascript">
			function dstart (branch) {
				var tree = branch.getTree();
				tree.debug('start');
			}
			
			function dend (branch) {
				var tree = branch.getTree();
				tree.debug('end');
			}
			function ondrop (b1, b2) {
				return true;
			}
			var tree = null;
			function TafelTreeInit () {
				var struct = [
				{
				'id':'root1',
				'checkbox':false,
				'txt':'Element racine',
				'items':[
					{
					'id':'child1',
					'txt':'Un enfant'
					},
					{
					'id':'child2',
					'txt':'Un enfant 2',
					'select' : true
					},
					{
					'id':'child3',
					'txt':'Un enfant 3'
					},
					{
					'id':'child4',
					'txt':'Un enfant 4'
					}
				]
				}
				];
				tree = new TafelTree('test', struct, {
					'generate' : true,
					'imgBase' : 'imgs/',
					'onDragStartEffect' : dstart,
					'onDragEndEffect' : dend,
					'onDrop' : ondrop,
					'checkboxes':true
				});
			}
			
			function blu (branch) {
				alert(branch.txt.className);
			}
			</script>
			<div id="test"></div>
			<p><a href="#" onclick="blu()">Effet</a></p>


	
</body>
</html>
