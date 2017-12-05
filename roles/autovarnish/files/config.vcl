sub vcl_deliver {
  set resp.http.Access-Control-Allow-Origin = "*";
}
