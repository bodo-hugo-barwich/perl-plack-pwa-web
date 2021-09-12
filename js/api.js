/**
 * @version 2021-07-25
 * @package PWA Content Loader
 * @subpackage api.js
 */

/**
 * This Library provides Functions to load the Content from the API
 */


function fetchProductList(fonsuccess, fonerror, arrparameters)
{
  console.log("Coffees: fetching ..."); // response is the server response

  // 1. Create a new XMLHttpRequest object
  var xhr = new XMLHttpRequest();


  // 2. Configure it: GET-request for the URL /article/.../load
  xhr.open('GET', api_host + api_mainpath + 'coffees');

  xhr.responseType = 'json';

  // 3. Send the request over the network
  xhr.send();

  xhr.onprogress = function(event) {
	  console.log('Coffees: Got Progress Event: ', event);

    if (event.lengthComputable) {
      console.log("Coffees: received '" + event.loaded + " / " + event.total + " Bytes");
    } else {
      console.log("Coffees: received '" + event.loaded + "' Bytes"); // no Content-Length
    }
  };	//xhr.onprogress

  // 4. This will be called after the response is received
  xhr.onload = function() {
    if(xhr.status == 200)
		{
			// show the result

			var contents = undefined;


      console.log("Coffees: fetched, got '" + xhr.response.length + "' Entries."); // response is the server response

      contents = xhr.response;

			console.log("Coffees: Type: '" + typeof contents + "'");

			if(typeof contents == 'string')
			{
				contents = JSON.parse(contents);
			}

			arrparameters.push(contents);

      console.log("Coffees: updating ..."); // response is the server response

      fonsuccess(arrparameters);

      console.log("Coffees: update done.");
    }
		else //The Request failed
		{
			// analyze HTTP status of the response

      console.log("Coffees: Fetch failed with Error [" + xhr.status + "]: '" + xhr.statusText + "'"); // e.g. 404: Not Found

			arrparameters.push("Coffees: Product List cannot be loaded!");

			fonerror(arrparameters);
		}	//if(xhr.status == 200)
  };	//xhr.onload
}

function fetchCoffee(fonsuccess, fonerror, arrparameters)
{
  console.log("Coffee: fetching ..."); // response is the server response

  // 1. Create a new XMLHttpRequest object
  var xhr = new XMLHttpRequest();


  // 2. Configure it: GET-request for the URL /article/.../load
  xhr.open('GET', api_host + api_mainpath + 'coffee/' + link_name);

  xhr.responseType = 'json';

  // 3. Send the request over the network
  xhr.send();

  xhr.onprogress = function(event) {
	  console.log('Coffees: Got Progress Event: ', event);

    if (event.lengthComputable) {
      console.log("Coffees: received '" + event.loaded + " / " + event.total + " Bytes");
    } else {
      console.log("Coffees: received '" + event.loaded + "' Bytes"); // no Content-Length
    }
  };	//xhr.onprogress

  // 4. This will be called after the response is received
  xhr.onload = function() {
    if(xhr.status == 200)
		{
			var contents = undefined;


			// show the result
      console.log("Coffee: fetched, got '" + xhr.response.length + "' Entries."); // response is the server response

      contents = xhr.response;

			arrparameters.push(contents);

      console.log("Coffee: updating ..."); // response is the server response

      fonsuccess(arrparameters);

      console.log("Coffee: update done.");
    }
		else	//The Request failed
		{
			// analyze HTTP status of the response

      console.log("Coffee: Fetch failed with Error [" + xhr.status + "]: '" + xhr.statusText + "'"); // e.g. 404: Not Found

			arrparameters.push("Coffee: Product Data cannot be loaded!");

			fonerror(arrparameters);

		}	//if(xhr.status == 200)
  };	//xhr.onload
}



//==============================================================================
//Executive Section


console.log("Load Event: api.js loaded.");

