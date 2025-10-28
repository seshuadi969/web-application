from flask import Flask, jsonify, send_from_directory
import os

app = Flask(__name__)

# Serve frontend files
@app.route('/')
def serve_frontend():
    return send_from_directory('../frontend', 'index.html')

@app.route('/<path:path>')
def serve_static_files(path):
    return send_from_directory('../frontend', path)

# API routes
@app.route('/api/')
def home():
    return jsonify({
        "message": "Welcome to Sample Web App!",
        "status": "success",
        "version": "1.0.0"
    })

@app.route('/api/health')
def health():
    return jsonify({"status": "healthy"})

@app.route('/api/info')
def info():
    return jsonify({
        "environment": os.getenv('ENVIRONMENT', 'development'),
        "host": os.getenv('WEBSITE_HOSTNAME', 'localhost'),
        "deployment": "Azure App Service via GitHub Actions"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
