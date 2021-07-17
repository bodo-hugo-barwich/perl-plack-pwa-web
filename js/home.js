/**
 * @version 2021-07-11
 * @package PWA Content Loader
 * @subpackage home.js
 */

/**
 * This Script registers the Service Worker and loads the Content from the API
 *
 *---------------------------------
 * Requirements:
 * - The JavaScript Module "api.js" must be installed
 *
 */


function showProductList(bxdisplay, lstcontents)
{
  let output = "Coffes: showing ...";

  if(typeof bxdisplay !== 'undefined')
  {
	  if(typeof lstcontents !== 'undefined')
	  {
		var arrcoffees = Object.values(lstcontents);


	    output = "";

	    for(let coffee of arrcoffees)
		{
	      output += `<div class="card-list">
	                  <img class="card-image" src="${svmainpath}images/${coffee.image}"" />
	                  <h3 class="card--title">${coffee.name}</h3>
					  <!-- ${svmainpath}coffee/${coffee.link_name} -->
	                  <a class="card--link" href="#">See Recipe</a>
	                </div>
	                `;
		}	//for(let coffee of arrcoffees)
	  }
	  else	//Product Data empty
	  {
	    console.log("Coffees: No Data");
	  } //if(typeof lstcontents !== 'undefined')

	  bxdisplay.innerHTML = output;
  }	//if(typeof bxdisplay !== 'undefined')
};


function initPage(bxdisplay, lstcontents)
{
  showProductList(bxdisplay, lstcontents);

  console.log("Coffees: fetch do ...");

  fetchProductList(bxdisplay, lstcontents);

  console.log("Coffees: update queued.");
}

