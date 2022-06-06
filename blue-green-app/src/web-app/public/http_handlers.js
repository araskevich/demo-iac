function httpGetHandler(url) {

    // loadingScreen("on");
  
    return new Promise(function(resolve, reject) {
  
      let httpClient = new XMLHttpRequest();
      httpClient.open('GET', url, true);
  
      httpClient.onload = function() {
        if (this.status == 200 && this.responseText != null) {
          // loadingScreen("off");
          resolve(this.responseText);
        } else {
          let error = new Error(this.statusText);
          error.code = this.status;
          // loadingScreen("off");
          reject(error);
        }
      };
  
      httpClient.onerror = function() {
        // loadingScreen("off");
        reject(new Error("Network Error"));
      };
  
      httpClient.send();
    });
  
}


// function httpPostHandler(url, data) {

//   let json_data = JSON.stringify(data);

//   // loadingScreen("on");

//   return new Promise(function(resolve, reject) {

//     let httpClient = new XMLHttpRequest();
//     httpClient.open('POST', url, true);
//     httpClient.setRequestHeader('Content-type', 'application/json; charset=utf-8');

//     httpClient.onload = function() {
//       if (this.status == 200 && this.responseText != null) {
//         // loadingScreen("off");
//         resolve(this.responseText);
//       } else {
//         let error = new Error(this.statusText);
//         error.code = this.status;
//         // loadingScreen("off");
//         reject(error);
//       }
//     };

//     httpClient.onerror = function() {
//       // loadingScreen("off");
//       reject(new Error("Network Error"));
//     };

//     httpClient.send(json_data);
//   });

// }


function httpGetForCheckServerInfo(url_get) {
  httpGetHandler(url_get)
  .then(
    response => {
        //loadingScreen("off");
        try {
          response = JSON.parse(response);
        } catch(error) {
          console.log("httpGetForCheckServerInfo response error:", error);
          response = {"status": "error", "message": "JSON.parse error"};
        }

        if (response.status === "ok") {
          console.log("httpGetForCheckServerInfo response:", response);
          //console.log("httpGetForCheckServerInfo color:", response.server_color);
          workWithServerInfo(response);

        } else if (response.status === "error") {
          console.log("httpGetForCheckServerInfo response error:", response.message);
          activeSessionData.error_counter += 1

        } else {
          console.log("httpGetForCheckServerInfo unexpected error:", response);
          activeSessionData.error_counter += 1
        }
        
        updateActiveSessionCounterData();

      },
    error => {
      //loadingScreen("off");
      console.log("httpGetForCheckServerInfo unexpected error:", error);
      activeSessionData.error_counter += 1
      updateActiveSessionCounterData();
   });
}

function doPauseForCurrentActiveWindow() {
  return new Promise(function(resolve, reject) {
    setTimeout(() => {
	  resolve("pause 1000");
	}, 1000);
  });
}
	

function testRunCheckServerInfoWithParallelRequests() {

  let urls = activeSessionData.list_url;
  console.log("testRunCheckServerInfoWithParallelRequests(): urls", urls);
  
  if (urls.length <= 0) {
    console.log("testRunCheckServerInfoWithParallelRequests(): thereis no urls in activeSessionData.list_url:", activeSessionData.list_url);
    activeSessionData.test_started = "no";
    return 1;
  }  

  //loadingScreen("on");
  
  document.getElementById('fieldForCheckServerInfo').innerHTML = "";

  Promise.all(urls.map(httpGetForCheckServerInfo))
  .then(  
    result =>  {
        //loadingScreen("off");
        
        let timeNowUtcString = new Date().toJSON().slice(0, 19).replace("T", " ");
        document.getElementById("fieldForUpdateDateUtcString").innerHTML = `Data updated at: ${timeNowUtcString} UTC`;
        
        console.log("testRunCheckServerInfoWithParallelRequests(): completed:", `Data updated at: ${timeNowUtcString} UTC`);

        console.log("doPauseForCurrentActiveWindow() and doCallback: testRunCheckServerInfoWithParallelRequests()");

        doPauseForCurrentActiveWindow()
        .then(
          response => {
            console.log("doPauseForCurrentActiveWindow():", response);
            
            testRunCheckServerInfoWithParallelRequests();
          },
          error => {
            console.log("doPauseForCurrentActiveWindow(): error:", error);
          });

      },
    error => {
      
      //loadingScreen("off");
      console.log("testRunCheckServerInfoWithParallelRequests(): error:", error);
  });
}