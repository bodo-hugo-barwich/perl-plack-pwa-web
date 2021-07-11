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


function showCoffees()
{
  let output = "Coffes: showing ...";

  if(typeof coffees !== 'undefined')
  {
	var arrcoffees = Object.values(coffees);


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
  } //if(typeof coffees !== 'undefined')

  container.innerHTML = output;
};


function initPage()
{
  showCoffees();

  console.log("Coffees: fetch do ...");

  fetchCoffees();

  console.log("Coffees: update queued.");
}

