import http.server
import logging
import socketserver

HOST = "127.0.0.1"
PORT = 8080

class PollsHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        # Only handle /mock/polls
        logging.info(f"Received {self.command} request for {self.path}")
        # if self.path != "/mock/polls":
        #     self.send_error(404, "Not Found")
        #     return

        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length) if content_length else b""
        logging.info(f"Headers: {self.headers}")
        logging.info(f"Body: {body.decode('utf-8', errors='replace')}")
        logging.info(f"Body_Raw: {body}")

        # always respond 200 OK
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain; charset=utf-8')
        self.end_headers()
        self.wfile.write(b"OK")

    def log_message(self, format, *args):
        # override default to use logging module
        logging.info(format % args)

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s: %(message)s')
    with socketserver.TCPServer((HOST, PORT), PollsHandler) as httpd:
        logging.info(f"Mock server listening on http://{HOST}:{PORT}/mock/polls")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            logging.info("Shutting down server")
            httpd.server_close()
