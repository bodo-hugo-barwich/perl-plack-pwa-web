/**
 * @version 2021-07-25
 * @package PhantomJS Tests
 * @subpackage hello_script.js
 */

/**
 * This Library provides Functions to test JavaScript inclusions and executions with PhantomJS
 */



function printHelloMessage(messagebox)
{
	var smessage = 'Hello PhantomJS!';


	console.log("printHelloMessage(): go ...");

	if(typeof messagebox !== 'undefined')
	{
		messagebox.innerHTML = smessage;
	}
	else
	{
		console.log("printHelloMessage(): element 'messagebox' is not set!");
	}
}




//==============================================================================
//Executive Section


console.log("Load Event: hello_script.js loaded.");


document.addEventListener("DOMContentLoaded", function() {
  console.log("Load Event: printHelloMessage() do ...");

  printHelloMessage(bxgreeting);
});


console.log("Load Event: ServiceWorker - Support checking ...");

if ("serviceWorker" in navigator)
{
  console.log("ServiceWorker: Support - OK");
}
else
{
  console.log("ServiceWorker: not supported!");
} //if ("serviceWorker" in navigator)
