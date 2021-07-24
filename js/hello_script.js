function printHelloMessage(messagebox)
{
  console.log("printHelloMessage(): go ...");

	if(typeof messagebox !== 'undefined')
	{
		messagebox.innerHTML = 'Hello PhantomJS!';
	}
	else
	{
		console.log("printHelloMessage(): element 'messagebox' is not set!");
	}
}




//==============================================================================
//Executive Section



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
