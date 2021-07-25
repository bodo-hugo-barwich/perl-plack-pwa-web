/**
 * @version 2021-05-23
 * @package PWA ServiceWorker Initialization
 * @subpackage app.js
 */

/*
 * This Script registers the Service Worker
 *
 *---------------------------------
 * Requirements:
 * - The Navigator must support ServiceWorker Functionality
 * - The JavaScript Module "service-worker_utils.js" must be installed
 *
 *---------------------------------
 * Extensions:
 * - The JavaScript Module "home.js" must be installed
 * - The JavaScript Module "product.js" must be installed
 *
 */



//==============================================================================
//Auxiliary Functions


function registeredServiceWorker(registration)
{
  console.log('ServiceWorker registration succeeded:', registration);

  //Successful Registration
  if(registration)
  {
    //Listen on Updates of the Service Worker
    registration.addEventListener('updatefound', event => updatedServiceWorker(event));
  }

  //Listen on Messages from the Service Worker
  navigator.serviceWorker.addEventListener('message', event => showWorkerMessage(event));

  console.log('ServiceWorker installed 1:', registration);


  return registration;
}

function doSkipWaiting(registration)
{
  console.log('doSkipWaiting - go ...');

  if(registration)
  {
    console.log('ServiceWorkerRegistration found:', registration);


    var worker = registration.installing;


    if(worker == null)
    {
      worker = registration.waiting;
    }

    if(worker != null)
    {
      worker.postMessage('SKIP_WAITING');

    	window.location.reload();
    }
    else
    {
      console.log('ServiceWorkerRegistration: No Update waiting.');
    }
  } //if(registration)
}

function doCheckVersion(registration)
{
  var worker = null;


  console.log('doCheckVersion - go ...');
  console.log('doCheckVersion - ServiceWorkerRegistration: ', registration);

	workerstatus.version = '';

  if(registration)
  {
    console.log('doCheckVersion - registration.active (' + typeof registration.active + '): ', (registration.active));
    console.log('doCheckVersion - registration.installing (' + typeof registration.installing + '): ', (registration.installing));

    worker = registration.active;

    if(worker == null)
    {
      worker = registration.installing;
    }
  } //if(registration)

  if(worker != null)
  {
    console.log('doCheckVersion - Request posting ...');

    //Send the message to the service worker.
    worker.postMessage('VERSION');
  }
  else  //No Service Worker Reference found
  {
    //There isn't always a service worker to send a message to.
    //This can happen when the page is force reloaded.
    if(navigator.serviceWorker.controller)
    {
      console.log('doCheckVersion - Request posting ...');

      //Send the message to the service worker.
      navigator.serviceWorker.controller.postMessage('VERSION');
    }
    else
    {
      console.log('doCheckVersion - error: no controller');
    } //if(navigator.serviceWorker.controller)
  } //if(worker != null)


  return registration;
}

function doCheckUpdate(registration)
{
  var bregok = false;
  var bupdok = false;


  console.log('doCheckUpdate - go ...');
  console.log('doCheckUpdate - ServiceWorkerRegistration: ', registration);

	workerstatus.updatewaiting = false;

  if(registration)
  {
    console.log('doCheckUpdate - registration.active (' + typeof registration.active + '): ', (registration.active));

		if(registration.active != null)
		{
		  bregok = true;
		}

    console.log('doCheckUpdate - registration.installing (' + typeof registration.installing + '): ', (registration.installing));
    console.log('doCheckUpdate - registration.waiting (' + typeof registration.waiting + '): ', (registration.waiting));

    if(registration.installing != null
      || registration.waiting != null)
    {
      bupdok = true;
    }
    else
    {
      console.log('Update: No Update waiting.');
    }
  } //if(registration)

  if(bregok
		&& bupdok)
  {
		workerstatus.updatewaiting = true;

    console.log('Service Worker Update detected!');

    if(typeof notification !== 'undefined')
    {
      notification.innerHTML = '<b>Service Worker Update detected!</b>';
      notification.hidden = false;
    }

    if(typeof updatebox !== 'undefined')
    {
      updatebox.hidden = false;
    }
  } //if(bregok && bupdok)


  return registration;
}

function updatedServiceWorker(updateevent)
{
  bupdok = false;


  console.log('Got Update: ', updateevent);

  if(updateevent != undefined)
  {
    // get the ServiceWorkerRegistration instance
    navigator.serviceWorker.getRegistration()
      .then(reg => doCheckUpdate(reg))
      .catch(err => failedCheckUpdate(err));

  }
  else  //No Data was passed
  {
    console.log('Update: No Data.');
  } //if(updateevent != undefined)

}

function doUpdateWindow()
{
  console.log('doUpdateWindow() - go ...');

	//Halt Update untill it was confirmed by the ServiceWorker
	if(workerstatus.updatewaiting)
	{
	  // get the ServiceWorkerRegistration instance
	  navigator.serviceWorker.getRegistration()
	    .then(registration => doSkipWaiting(registration))
	    .catch(err => failedSkipWaiting(err));
	}
	else
	{
		console.log('Update: Update not queued.');
	}
}

function showWorkerMessage(messageevent)
{
  console.log('Got Message: ', messageevent);

  if(messageevent != undefined)
  {
    if(typeof messagebox !== 'undefined')
    {
      if(messagebox.innerHTML != '')
      {
        messagebox.innerHTML += "<br />\n";
      }

      messagebox.innerHTML += JSON.stringify(messageevent.data);
    }
    else  //Message Box does not exist
    {
      console.log('Message: Message dropped!');
    } //if(typeof messagebox !== 'undefined')

    if(messageevent.data.version)
    {
			workerstatus.version = messageevent.data.version;

      console.log("Message: Version Number '" + workerstatus.version + "'");

      if(typeof vernobox !== 'undefined')
      {
        vernobox.innerHTML = workerstatus.version;
      }
      else
      {
        console.log('Message: Message dropped!');
      }
    } //if(messageevent.data.version)
  }
  else  //No Data was passed
  {
    console.log('Message: No Data.');
  } //if(messageevent != undefined)
}

function failedCheckUpdate(error)
{
  console.log('CheckWaiting failed!');
  console.log('Registration Error: ', error);
}

function failedSkipWaiting(error)
{
  console.log('SkipWaiting failed!');
  console.log('Registration Error: ', error);
}

function failedCheckVersion(error)
{
  console.log('CheckVersion failed!');
  console.log('Registration Error: ', error);
}



//==============================================================================
//Executive Section


var workerstatus = {'version': '', 'updatewaiting': false};


console.log("Load Event: app.js loaded.");

//------------------------
//Check Visual Output Boxes

if(typeof notification === 'undefined')
{
  console.log("Notification Box Element '#notification' is missing!");
}

if(typeof vernobox === 'undefined')
{
  console.log("Version Box Element '#versionnumber' is missing!");
}

if(typeof messagebox === 'undefined')
{
  console.log("Worker Message Box Element '#workermessage' is missing!");
}


if(typeof updatebox === 'undefined'
  || typeof updatelink === 'undefined')
{
  console.log("Update Box Element '#update' is missing!");
}

if(typeof updatelink !== 'undefined')
{
	workerstatus.updatewaiting = false;


  updatelink.onclick = doUpdateWindow;
}

if(typeof bxproducts === 'undefined')
{
  console.log("Target Box Element '#productlistbox' is missing!");
}

document.addEventListener("DOMContentLoaded", function() {
   console.log("Load Event: initPage() do ...");

	 initPage(bxproducts, lstproducts);



});


//------------------------
//Initialize Service Worker


console.log("Load Event: ServiceWorker Check do ...");

if ("serviceWorker" in navigator)
{

	if(typeof registeredServiceWorker === 'function')
	{
		console.log("Load Event: ServiceWorker Initialize do ...");

			//Register the ServiceWorker Script
		  window.addEventListener("load", function() {
		    navigator.serviceWorker.register(svmainpath + "service-worker")
		      //Pass the ServiceWorkerRegistration instance
		      .then(reg => registeredServiceWorker(reg))
		      .then(reg => doCheckVersion(reg))
		      .then(reg => doCheckUpdate(reg))
		      .catch(err => console.log("service worker not registered", err));

		  });
	}
	else
	{
	  console.log("ServiceWorker: Script Utilities are not loaded!");
	} //if ("serviceWorker" in navigator)
}
else
{
  console.log("ServiceWorker not supported!");
} //if ("serviceWorker" in navigator)

