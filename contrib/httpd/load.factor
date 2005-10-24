USING: kernel parser sequences io ;
[
    "contrib/httpd/http-common.factor"
    "contrib/httpd/mime.factor"
    "contrib/httpd/html-tags.factor"
    "contrib/httpd/html.factor"
    "contrib/httpd/responder.factor"
    "contrib/httpd/httpd.factor"
    "contrib/httpd/file-responder.factor"
    "contrib/httpd/cont-responder.factor"
    "contrib/httpd/browser-responder.factor"
    "contrib/httpd/default-responders.factor"
    "contrib/httpd/http-client.factor"
    "contrib/httpd/test/html.factor"
    "contrib/httpd/test/http-client.factor"
    "contrib/httpd/test/httpd.factor"
    "contrib/httpd/test/url-encoding.factor"
] [
    dup print run-file
] each
