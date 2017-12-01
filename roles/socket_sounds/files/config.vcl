backend webroot {
  .host = "172.17.0.1";
  .port = "9000";
  .connect_timeout = 1s;
  .first_byte_timeout = 30s;
  .between_bytes_timeout = 10s;
  .max_connections = 10;
#  .probe = health_check;
}

backend sounds_client {
  .host = "172.17.0.1";
  .port = "9001";
  .connect_timeout = 1s;
  .first_byte_timeout = 30s;
  .between_bytes_timeout = 10s;
  .max_connections = 10;
#  .probe = health_check;
}

backend sounds_server {
  .host = "172.17.0.1";
  .port = "5000";
  .connect_timeout = 1s;
  .first_byte_timeout = 30s;
  .between_bytes_timeout = 10s;
  .max_connections = 10;
#  .probe = health_check;
}

sub vcl_recv {
  if (req.http.host ~ "^sounds\.") {
    if (req.url ~ "^/sounds/") {
      # Actual sound files go to webroot container.
      set req.backend_hint = webroot;
    } else if (req.http.Upgrade ~ "(?i)websocket") {
      # If connection is a websocket, send to server container.
      set req.backend_hint = sounds_server;
      return(pipe);
    } else {
      # Otherwise, send traffic to the soundboard client container.
      set req.backend_hint = sounds_client;
    }
  } else {
    set req.backend_hint = webroot;
  }
  return(pass);
}

sub vcl_deliver {
  set resp.http.Access-Control-Allow-Origin = "*";
}

sub vcl_pipe {
  if (req.http.upgrade) {
    set bereq.http.upgrade = req.http.upgrade;
  }
}
