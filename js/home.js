/**
 * @version 2021-07-11
 * @package PWA Content Loader
 * @subpackage home.js
 */

/**
 * This Module renders the given Content on the Page
 *
 *---------------------------------
 * Requirements:
 * - The JavaScript Module "api.js" must be installed
 *
 */


function showProductList(bxdisplay, lstcontents)
{
  var output = "Coffes: showing ...";


  if(typeof bxdisplay !== 'undefined')
  {
	  if(typeof lstcontents !== 'undefined')
	  {
			var arrcoffees = Object.values(lstcontents);
			var coffee = undefined;
		  var card = undefined;
		  var title = undefined;
			var img = undefined;
			var link = undefined;
		  var sttltxt = undefined;
			var slnktxt = undefined;
			var scmttxt = undefined;
			var icof = -1;


			//Clear previous Content
			bxdisplay.replaceChildren();

	    output = "";

			//console.log("Coffees: fetched Content List '" + arrcoffees + "'");

	    for(icof in arrcoffees)
			{
				coffee = arrcoffees[icof];

				//console.log("Coffee: Content [" + icof + "]: '" + coffee + "'.");

			  card = document.createElement('div');

				card.className = 'card-list';

				img = document.createElement('img');

				img.src = svmainpath + 'images/' + coffee.image;
				img.className = 'card-image';

				card.appendChild(img);

			  title = document.createElement('h3');

				title.className = 'card--title';

				sttltxt = document.createTextNode(coffee.name);

				title.appendChild(sttltxt);
				card.appendChild(title);

				scmttxt = new Comment(svmainpath + 'coffee/' + coffee.link_name);

				card.appendChild(scmttxt);

				link = document.createElement('a');
				link.className = 'card--link';

				slnktxt = document.createTextNode('See Recipe');

				link.appendChild(slnktxt);
				card.appendChild(link);

				bxdisplay.appendChild(card);

/*
		      output += `<div class="card-list">
		                  <img class="card-image" src="${svmainpath}images/${coffee.image}" />
		                  <h3 class="card--title">${coffee.name}</h3>
						  <!--  -->
		                  <a class="" href="#">See Recipe</a>
		                </div>
		                `;
*/
			}	//for(let coffee of arrcoffees)

	  }
	  else	//Product Data empty
	  {
	    console.log("Coffees: No Data");
	  } //if(typeof lstcontents !== 'undefined')

		if(output !== '')
		{
	  	bxdisplay.innerHTML = output;
		}
  }	//if(typeof bxdisplay !== 'undefined')
};


function initPage(bxdisplay, lstcontents)
{
  console.log("initPage() - go ...");

  showProductList(bxdisplay, lstcontents);

  console.log("Coffees: fetch do ...");

  fetchProductList(bxdisplay, lstcontents);

  console.log("Coffees: update queued.");
}



//==============================================================================
//Executive Section

console.log("Load Event: home.js loaded.");

