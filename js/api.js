/**
 * @version 2021-07-25
 * @package PWA Content Loader
 * @subpackage api.js
 */

/**
 * This Library provides Functions to load the Content from the API
 */


function fetchProductList(bxdisplay, lstcontents)
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
    if (xhr.status != 200) { // analyze HTTP status of the response
      console.log("Coffees: Fetch failed with Error [" + xhr.status + "]: '" + xhr.statusText + "'"); // e.g. 404: Not Found

			showFetchError(bxdisplay, "Coffees: Product List cannot be loaded!");
    } else { // show the result
      console.log("Coffees: fetched, got '" + xhr.response.length + "' Entries."); // response is the server response

      lstcontents = xhr.response;

			console.log("Coffees: Type: '" + typeof lstcontents + "'");

			if(typeof lstcontents == 'string')
			{
				lstcontents = JSON.parse(lstcontents);
			}

      console.log("Coffees: updating ..."); // response is the server response

      showProductList(bxdisplay, lstcontents);

      console.log("Coffees: update done.");
    }
  };	//xhr.onload
}

function fetchCoffee(bxdisplay, link_name)
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
    if (xhr.status != 200) { // analyze HTTP status of the response
      console.log("Coffee: Fetch failed with Error [" + xhr.status + "]: '" + xhr.statusText + "'"); // e.g. 404: Not Found
    } else { // show the result
      console.log("Coffee: fetched, got '" + xhr.response.length + "' Entries."); // response is the server response

      coffee = xhr.response;

      console.log("Coffee: updating ..."); // response is the server response

      showCoffee(bxdisplay, coffee);

      console.log("Coffee: update done.");
    }
  };	//xhr.onload
}



//==============================================================================
//Executive Section


console.log("Load Event: api.js loaded.");

