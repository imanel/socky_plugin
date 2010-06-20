WebSocket.__swfLocation = "/javascripts/socky/WebSocketMain.swf";

function socky(host, port, params) {
  var ws = new WebSocket(host + ':' + port + '/?' + params);
  ws.onmessage = function (evt) { parse_socky_request(evt.data) };
}

function parse_socky_request(request) {
  req = JSON.parse(request);
  switch (req["type"]) {
    case "message":
      eval_socky_message(req["body"]);
      break
  }
}

function eval_socky_message(msg) {
  eval(msg);
}