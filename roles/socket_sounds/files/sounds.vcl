backend sounds_client {
  .host = "172.17.0.1";
  .port = "9001";
  .connect_timeout = 1s;
  .first_byte_timeout = 30s;
  .between_bytes_timeout = 10s;
  .max_connections = 10;
}

backend sounds_server {
  .host = "172.17.0.1";
  .port = "5000";
  .connect_timeout = 1s;
  .first_byte_timeout = 30s;
  .between_bytes_timeout = 10s;
  .max_connections = 10;
}

sub vcl_recv {
  if (req.http.host ~ "^sounds\.") {
    if (req.url ~ "^/sounds/") {
      # Requess for actual sound files go to default backend.
    } else if (req.http.Upgrade ~ "(?i)websocket") {
      # If connection is a websocket, send to server container.
      set req.backend_hint = sounds_server;
      return(pipe);
    } else {
      # Otherwise, send traffic to the soundboard client container.
      set req.backend_hint = sounds_client;
    }
  }
}

sub vcl_pipe {
  if (req.http.upgrade) {
    set bereq.http.upgrade = req.http.upgrade;
    set bereq.http.connection = req.http.connection;
  }
}
