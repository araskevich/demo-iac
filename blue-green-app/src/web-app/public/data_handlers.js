function workWithServerInfo(response) {    
  let appVersion = response.app_version;
  let serverHostname = response.server_hostname;
  let clientAddr = response.client_addr;
  let serverColor = response.server_color;
  // let status = response.status;
  // let statusMessage = response.message;
  let timestampUtc = response.timestamp;

  createHtmlTableWithServerInfo([timestampUtc, clientAddr, appVersion, serverHostname, serverColor])
}

function updateActiveSessionCounterData() {
  let greenCounter = activeSessionData.green_counter;
  let blueCounter = activeSessionData.blue_counter;
  let errorCounter = activeSessionData.error_counter;

  let activeSessionCounterContent = "<table>";
  activeSessionCounterContent += `<tr><td style="border: 1px solid; width: 150px;"> Green counter:</td><td style="border: 1px solid; width: 150px;"> ${greenCounter} </td></tr>`;
  activeSessionCounterContent += `<tr><td style="border: 1px solid; width: 150px;">  Blue counter:</td><td style="border: 1px solid; width: 150px;"> ${blueCounter} </td></tr>`;
  activeSessionCounterContent += `<tr><td style="border: 1px solid; width: 150px;"> Error counter:</td><td style="border: 1px solid; width: 150px;"> ${errorCounter} </td></tr>`;
  activeSessionCounterContent += "</table>";

  document.getElementById('fieldForActiveSessionCounterData').innerHTML = activeSessionCounterContent;
  console.log("updateActiveSessionCounterData(): activeSessionData:", activeSessionData);
}

function resetActiveSessionCounterData() {
  activeSessionData.green_counter = 0;
  activeSessionData.blue_counter = 0;
  activeSessionData.error_counter = 0;
  updateActiveSessionCounterData();
  console.log("resetActiveSessionCounterData(): activeSessionData:", activeSessionData);
}

function checkIfActiveTestAlreadyRunningAndRunTest() {
  if (activeSessionData.test_started === "yes") {
    alert("Test already started!");
    return 1;
  }

  if (activeSessionData.list_url.length === 0) {
    alert("Please increase rate first!");
    return 1;
  }

  activeSessionData.test_started = "yes";
  testRunCheckServerInfoWithParallelRequests();
}