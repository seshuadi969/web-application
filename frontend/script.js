async function fetchAppInfo() {
    try {
        const response = await fetch('/api/info');
        const data = await response.json();
        document.getElementById('app-info').innerHTML = `
            <p><strong>Environment:</strong> ${data.environment}</p>
            <p><strong>Host:</strong> ${data.host}</p>
            <p><strong>Deployment:</strong> ${data.deployment}</p>
            <p><strong>Version:</strong> 1.0.0</p>
        `;
    } catch (error) {
        document.getElementById('app-info').innerHTML = 
            '<p class="status-error">Failed to load app information</p>';
    }
}

async function checkHealth() {
    try {
        const response = await fetch('/api/health');
        const data = await response.json();
        document.getElementById('health-status').innerHTML = 
            `<p class="status-healthy">✅ ${data.status}</p>`;
    } catch (error) {
        document.getElementById('health-status').innerHTML = 
            '<p class="status-error">❌ Service unavailable</p>';
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    fetchAppInfo();
    checkHealth();
    
    // Refresh health status every 30 seconds
    setInterval(checkHealth, 30000);
});
