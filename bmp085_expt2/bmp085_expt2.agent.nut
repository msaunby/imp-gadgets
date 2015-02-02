// When Device sends new readings, Run this!
local tokens = {
       temperature = "mytoken01",
       pressure = "mytoken02",
    }

device.on("init" function(msg) {

    
    //Plotly Data Object
    local data = [{
        x = [], // Time Stamp from Device
        y = [],
        type = "scatter",
        stream = {
          token = tokens.temperature,
          maxpoints = 500,
        }
    },{
        x =  [], // Time Stamp from Device
        y = [],
        yaxis = "y2",
        type = "scatter",
        stream = {
          token = tokens.pressure,
          maxpoints = 500,
        }
    }];

    // Plotly Layout Object
    local layout = {
        fileopt = "extend",
        filename = "BMP085 temp and pressure stream - 1",
        layout = {
        xaxis = {
          autorange = true,
        },
        yaxis = {
          autorange = true,
        },
        yaxis2 = {
            autorange = true,
            overlaying = "y",
            side = "right",
        },
        }
    };

    // Setting up Data to be POSTed
    local payload = {
    un = "ms.....",
    key = ".......",
    origin = "plot",
    platform = "electricimp",
    args = http.jsonencode(data),
    kwargs = http.jsonencode(layout),
    version = "0.0.1"
    };
    // encode data and log
    local headers = { "Content-Type" : "application/json" };
    local body = http.urlencode(payload);
    local url = "https://plot.ly/clientresp";
    HttpPostWrapper(url, headers, body, true);
});


device.on("new_readings", function(sensordata) {
    local headers = {"plotly-streamtoken" : tokens.temperature };
    local body = {
        x = sensordata.time_stamp,
        y = sensordata.temperature_reading
    }
    local data = http.jsonencode(body);

    // your middleware stream server
    // you can also roll your own with the provided server.js script
    // and simply change this URL to your server's URL
    local url  = "http://54.201.244.104:9999/"
    // Post data to streamserver
    HttpPostWrapper(url, headers, data, false);
});


// Http Request Handler
function HttpPostWrapper (url, headers, string, log) {
  local request = http.post(url, headers, string);
  local response = request.sendsync();
  if (log)
    server.log(http.jsonencode(response));
  return response;

}
