// Set URL of your WebSocketMain.swf here:
WEB_SOCKET_SWF_LOCATION = "/javascripts/socky/WebSocketMain.swf";
// Set this to dump debug message from Flash to console.log:
WEB_SOCKET_DEBUG = false;

Socky = function(host, port, params) {
  instance = this;

  var ws = new WebSocket(host + ':' + port + '/?' + params);
  ws.onopen = function() { instance.onopen(); };
  ws.onmessage = function(evt) { instance.onmessage(evt); };
  ws.onclose = function() { instance.onclose(); };
  ws.onerror = function() { instance.onerror(); };
};

Socky.prototype.onopen = function() {};

Socky.prototype.onmessage = function(evt) {
  var request = JSON.parse(evt.data);
  switch (request.type) {
    case "message":
      this.respond_to_message(request.body);
      break;
  }
};

Socky.prototype.onclose = function() {};

Socky.prototype.onerror = function() {};

Socky.prototype.respond_to_message = function(msg) {
  eval(msg);
};