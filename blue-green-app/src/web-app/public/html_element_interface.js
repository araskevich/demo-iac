function createHtmlTableWithServerInfo(serverInfo) { 
  let serverInfoTr = document.createElement('tr');

  let appVersion = serverInfo[2];
  let serverHostname = serverInfo[3];
  let clientAddr = serverInfo[1];
  let serverColor = serverInfo[4];
  // let status = response.status;
  // let statusMessage = response.message;
  let timestampUtc = serverInfo[0]; 

  let serverInfoTdContent = ""

  serverInfoTdContent += `<td style="border: 1px solid; width: 400px;">${timestampUtc}</td>`;
  serverInfoTdContent += `<td style="border: 1px solid; width: 200px;">${clientAddr}</td>`;
  serverInfoTdContent += `<td style="border: 1px solid; width: 125px;">${appVersion}</td>`;
  serverInfoTdContent += `<td style="border: 1px solid; width: 400px;">${serverHostname}</td>`;
  serverInfoTdContent += `<td style="border: 1px solid; width: 120px;">${serverColor}</td>`;

  serverInfoTr.innerHTML = serverInfoTdContent;

  if (serverColor === "green"){
    serverInfoTr.style.color = "green"
    activeSessionData.green_counter += 1

  } else if (serverColor === "blue") {
    serverInfoTr.style.color = "blue"
    activeSessionData.blue_counter += 1

  } else {
    activeSessionData.error_counter += 1
  }

  updateActiveSessionCounterData();
  document.getElementById('fieldForCheckServerInfo').appendChild(serverInfoTr);
}

function pushUrlElementkToListUrl() {
  activeSessionData.list_url.push(activeSessionData.url_element);
  console.log("pushUrlElementkToListUrl(): activeSessionData.list_url:", activeSessionData.list_url);
  updateFieldForRequestRateInfo();
}

function popUrlElementFromListUrl() {
  activeSessionData.list_url.pop();
  console.log("popUrlElementFromListUrl(): activeSessionData.list_url:", activeSessionData.list_url);
  updateFieldForRequestRateInfo();
}

function updateFieldForRequestRateInfo() {fieldForRequestRate
  document.getElementById('fieldForRequestRate').innerHTML = `Request rate: ${activeSessionData.list_url.length}`;
}

function stopTestCheckServerInfo() {
  activeSessionData.list_url = [];
  updateFieldForRequestRateInfo();
  activeSessionData.test_started = "no";
  console.log("stopTestCheckServerInfo(): activeSessionData.list_url", activeSessionData.list_url);
}