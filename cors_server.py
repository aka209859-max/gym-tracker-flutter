import http.server
import socketserver

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('X-Frame-Options', 'ALLOWALL')
        self.send_header('Content-Security-Policy', 'frame-ancestors *')
        super().end_headers()

if __name__ == '__main__':
    with socketserver.TCPServer(('0.0.0.0', 5060), CORSRequestHandler) as httpd:
        print("✅ Server running on http://0.0.0.0:5060")
        httpd.serve_forever()
