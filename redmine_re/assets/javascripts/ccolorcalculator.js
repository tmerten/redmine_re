function getccolor(element) {
 
  var color = element.getAttribute("style", "false");
  var cColor = '#' + ( parseInt('FFFFFF',16) - parseInt(color.substr(-6),16) ).toString(16);
  
  element.style.color = cColor;
  
}