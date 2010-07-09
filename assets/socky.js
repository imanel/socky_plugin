// Set URL of your WebSocketMain.swf here:
WEB_SOCKET_SWF_LOCATION = "/javascripts/socky/WebSocketMain.swf";
// Set this to dump debug message from Flash to console.log:
WEB_SOCKET_DEBUG = false;

Socky = function(host, port, params) {
  this.host = host;
  this.port = port;
  this.params = params;
  this.connect();
};

// Socky states
Socky.CONNECTING = 0;
Socky.AUTHENTICATING = 1;
Socky.OPEN = 2;
Socky.CLOSED = 3;
Socky.UNAUTHENTICATED = 4;

Socky.prototype.connect = function() {
  var instance = this;
  instance.state = Socky.CONNECTING;

  var ws = new WebSocket(this.host + ':' + this.port + '/?' + this.params);
  ws.onopen = function() { instance.onopen(); };
  ws.onmessage = function(evt) { instance.onmessage(evt); };
  ws.onclose = function() { instance.onclose(); };
  ws.onerror = function() { instance.onerror(); };
};

Socky.prototype.onopen = function() {
  this.state = Socky.AUTHENTICATING;
};

Socky.prototype.onmessage = function(evt) {
  try {
    var request = JSON.parse(evt.data);
    switch (request.type) {
      case "message":
        this.respond_to_message(request.body);
        break;
      case "authentication":
        if(request.body == "success") {
          this.respond_to_authentication_success();
        } else {
          this.respond_to_authentication_failure();
        }
        break;
    }
  } catch (e) {
    console.error(e.toString());
  }
};

Socky.prototype.onclose = function() {
  if(this.state != Socky.CLOSED && this.state != Socky.UNAUTHENTICATED) {
    setTimeout(function(instance) { instance.connect(); }, 1000, this);
  }
};

Socky.prototype.onerror = function() {};

Socky.prototype.respond_to_message = function(msg) {
  eval(msg);
};

Socky.prototype.respond_to_authentication_success = function() {
  this.state = Socky.OPEN;
};

Socky.prototype.respond_to_authentication_failure = function() {
  this.state = Socky.UNAUTHENTICATED;
};