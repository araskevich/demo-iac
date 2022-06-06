let activeSessionData = {
  "url_element": "",
  "list_url": [],
  "test_started": "no",
  "green_counter": 0,
  "blue_counter": 0,
  "error_counter": 0
}; // Global activeSessionData variable

function main() {

  console.log("main(): global_web_configuration:", `${global_web_configuration.api_server_ip}:${global_web_configuration.api_server_port}`);
  activeSessionData.url_element = "http://" + `${global_web_configuration.api_server_ip}:${global_web_configuration.api_server_port}` + "/whatColor";
  console.log("activeSessionData:", activeSessionData);

  updateFieldForRequestRateInfo();
  updateActiveSessionCounterData();  
}
