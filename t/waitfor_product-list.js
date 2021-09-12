/**
 * Wait until the test condition is true or a timeout occurs. Useful for waiting
 * on a server response or for a ui change (fadeIn, etc.) to occur.
 *
 * @param testFx javascript condition that evaluates to a boolean,
 * it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
 * as a callback function.
 * @param onReady what to do when testFx condition is fulfilled,
 * it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
 * as a callback function.
 * @param timeOutMillis the max amount of time to wait. If not specified, 3 sec is used.
 */

"use strict";

function waitFor(testFx, onReady, timeOutMillis, checkmilliseconds)
{
	var itmtimeout = timeOutMillis ? timeOutMillis : 10000;
	var itmcheck = checkmilliseconds ? checkmilliseconds : 200;

  var maxtimeOutMillis = itmtimeout, //< Default Max Timout is 10s
      start = new Date().getTime(),
      condition = false,
      interval = setInterval(function() {
          if ( (new Date().getTime() - start < maxtimeOutMillis) && !condition ) {
              // If not time-out yet and condition not yet fulfilled
              condition = (typeof(testFx) === "string" ? eval(testFx) : testFx()); //< defensive code
          } else {
              if(!condition) {
                  // If condition still not fulfilled (timeout but condition is 'false')
                  console.log("'waitFor()' timeout");

				page.render('web_home_timeout.jpg', {format: 'jpg', quality: '100'});

                  phantom.exit(4);
              } else {
                  // Condition fulfilled (timeout and/or condition is 'true')
                  console.log("'waitFor()' finished in " + (new Date().getTime() - start) + "ms.");
                  typeof(onReady) === "string" ? eval(onReady) : onReady(); //< Do what it's supposed to do once the condition is fulfilled
                  clearInterval(interval); //< Stop this interval
              }
          }
      }, itmcheck); //< repeat check every 200ms
};

function printSettings(settings)
{
	console.log("settings: '" + settings + "'");


	var arrsets = Object.keys(settings);
	var set = undefined;
	var iset = -1;
	var isetcnt = arrsets.length;

	for(iset = 0; iset < isetcnt; iset++)
	{
		set = arrsets[iset];

	  console.log("setting '" + set + "': '" + settings[set] + "'");
	}
}


var main_url = "http://localhost:3000/"
var page = require('webpage').create();


page.onInitialized = function() {
    console.log("page.onInitialized");
    //printArgs.apply(this, arguments);
};
page.onLoadStarted = function() {
    console.log("page.onLoadStarted");
    //printArgs.apply(this, arguments);
};
page.onLoadFinished = function() {
    console.log("page.onLoadFinished");
    //printArgs.apply(this, arguments);
};
page.onUrlChanged = function() {
    console.log("page.onUrlChanged");
    //printArgs.apply(this, arguments);
};

page.onResourceRequested = function (requestData, request) {
  console.log("Request (#" + requestData.id + ", method: '" + requestData.method + "', url: '" + requestData.url + "'): "
		+ JSON.stringify(requestData));
  console.log('Request Object: ' + JSON.stringify(request));
};

page.onResourceReceived = function(response) {
  console.log("Response (#" + response.id + ", url: '" + response.url + "', stage '" + response.stage + "'): "
		+ JSON.stringify(response));
};

page.onConsoleMessage = function(msg, lineNum, sourceId) {
	if(lineNum !== 'undefined')
	{
	  console.log('Browser: ' + msg + ' (from line #' + lineNum + ' in "' + sourceId + '")');
	}
	else
	{
	  console.log('Browser: ' + msg);
	}
};

page.onResourceError = function(resourceError) {
  console.log('Resource (#' + resourceError.id + ', url: ' + resourceError.url + '): Resource could not be loaded!');
  console.log('Resource Error [code: ' + resourceError.errorCode + '] - Message: ' + resourceError.errorString);
};

page.onError = function(msg, trace) {

  var msgStack = ['ERROR: ' + msg];

  if (trace && trace.length) {
    msgStack.push('TRACE:');
    trace.forEach(function(t) {
      msgStack.push(' -> ' + t.file + ': ' + t.line + (t.function ? ' (in function "' + t.function +'")' : ''));
    });
  }

  console.error(msgStack.join('\n'));

};


console.log("settings 0 :");

printSettings(page.settings);

page.settings['localToRemoteUrlAccessEnabled'] = true;
page.settings['webSecurityEnabled'] = false;
page.settings['XSSAuditingEnabled'] = true;
page.settings.localToRemoteUrlAccessEnabled = true;
page.settings.ignoreSslErrors = true;

console.log("settings 1 :");

printSettings(page.settings);


// Open the Home Page and wait for the Product List Data
page.open(main_url, function (status) {
	// Check for page load success

	console.log("Page URL '" + page.url + "': finished with Status [" + status + "].");

	if(status == "success")
	{
		console.log("Page URL '" + page.url + "': Page Loading done.");

		page.render('web_home_start.jpg', {format: 'jpg', quality: '100'});

		var lstscrs = page.evaluate(function() {
			var lsttgs = document.getElementsByTagName("script");
			var lstfls = {'count': 0, 'loaded': 0, 'files': []};
			var tg = undefined;


			console.log("Script List: found Tags (count: '" + lsttgs.length + "').");
			console.log("Script List: found Tags '" + lsttgs + "'");

			for(itg in lsttgs)
			{
				tg = lsttgs[itg];

				console.log("Script: tg: '" + tg + "'.");
				console.log("Script: tg HTML: '" + tg.outerHTML + "'.");

				if(typeof tg.src !== 'undefined'
					&& tg.src !== '')
				{
					console.log("Script: src: '" + tg.src + "' add.");
					lstfls.files.push(tg.src);
					lstfls.count++;
				}
			}

			console.log("Script List: found Files (count: '" + lstfls.count + "').");

			return lstfls;
		});

		console.log("Script List: found Scripts  (count: '" + lstscrs.count + "').");
		console.log("Script List: found Scripts '" + lstscrs + "'");


		var scr = undefined;
		var iscr = -1;
		var iscrcnt = lstscrs.count;


		for(iscr = 0; iscr < iscrcnt; iscr++)
		{
			scr = lstscrs.files[iscr];

			console.log("Script List: include Script '" + scr + "'");

			if(page.injectJs(scr))
			{
				lstscrs.loaded++;

				console.log("Script List: Script '" + scr + "' injected");
			}

			console.log("Script List: Count '" + lstscrs.loaded + " / " + lstscrs.count + "' injected");

			if(lstscrs.loaded == lstscrs.count)
			{
				page.evaluateJavaScript(function() {
					console.log("Function 'initPage()': Type '" + typeof initPage + "'");

					if(typeof initPage === 'function')
					{
						console.log("Script List: Function 'initPage()' - do ...");

						initPage(bxproducts, lstproducts);
					}
					else
					{
						console.log("Function 'initPage()': Does Not Exist!");
					}
				});	//page.evaluateJavaScript()
			}	//if(lstscrs.loaded == lstscrs.count)
		}	//for(iscr = 0; iscr < iscrcnt; iscr++)

    // Wait for 'signin-dropdown' to be visible
    waitFor(function() {
			console.log("check page ...");

      // Check in the page if a specific element is now visible
      return page.evaluate(function() {
				var bxlist = document.getElementById('productlistbox');

				console.log("box 'productlistbox' content: '" + bxlist.innerHTML + "'");

				//The List Box must contain Product Cards
				//bxlist.innerHTML !== ''
				return (bxlist.innerHTML.indexOf('View Recipe') !== -1);

      });
    }, function() {
			console.log("The Product List should be visible now.");

			//Exit with Success
      phantom.exit();
    });
	}
	else	//Page Loading failed
	{
  	console.log("Page URL '" + page.url + "': Page Loading failed!");

		//Exit with Error
		phantom.exit(1);

  }	//if(status == "success")
});


