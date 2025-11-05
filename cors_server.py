#!/usr/bin/env python3
"""
CORS-enabled HTTP Server for Flutter Web Preview
Serves Flutter web build with proper CORS headers
"""
import http.server
import socketserver

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP Request Handler with CORS support"""
    
    def end_headers(self):
        """Add CORS headers to all responses"""
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('X-Frame-Options', 'ALLOWALL')
        self.send_header('Content-Security-Policy', 'frame-ancestors *')
        super().end_headers()
    
    def do_OPTIONS(self):
        """Handle OPTIONS requests for CORS preflight"""
        self.send_response(200)
        self.end_headers()

if __name__ == '__main__':
    PORT = 5060
    with socketserver.TCPServer(('0.0.0.0', PORT), CORSRequestHandler) as httpd:
        print(f'✅ Flutter Web Server running on http://0.0.0.0:{PORT}')
        print(f'📁 Serving directory: build/web/')
        print(f'🌐 CORS enabled for all origins')
        print(f'Press Ctrl+C to stop')
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print('\n🛑 Server stopped')
