const express = require('express');
const client = require('prom-client');

const app = express();

// ── PROMETHEUS METRICS SETUP ──
// This creates a registry that collects all metrics
const register = new client.Registry();

// Collect default metrics (CPU, memory, event loop etc)
client.collectDefaultMetrics({ register });

// Custom metric — counts how many HTTP requests we receive
const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

// Custom metric — tracks response time
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

// ── MIDDLEWARE ──
app.use(express.json());

// Track every request automatically
app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer();
  res.on('finish', () => {
    httpRequestCounter.inc({
      method: req.method,
      route: req.path,
      status: res.statusCode,
    });
    end({ method: req.method, route: req.path, status: res.statusCode });
  });
  next();
});

// ── ROUTES ──

// Home route — shows app is running
app.get('/', (req, res) => {
  res.json({
    message: '🚀 DevOps Monitor App is running!',
    timestamp: new Date().toISOString(),
    uptime: `${Math.floor(process.uptime())} seconds`,
  });
});

// Health check route — used by monitoring tools
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    memory: process.memoryUsage(),
    uptime: process.uptime(),
  });
});

// Metrics route — Prometheus scrapes this endpoint
// This is the key route that feeds data to Grafana
app.get('/metrics', async (req, res) => {
  res.setHeader('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Simulate a slow endpoint (for testing alerts)
app.get('/slow', async (req, res) => {
  await new Promise(resolve => setTimeout(resolve, 3000));
  res.json({ message: 'This was a slow response!' });
});

// Simulate an error (for testing error alerts)
app.get('/error', (req, res) => {
  res.status(500).json({ error: 'Simulated server error for testing!' });
});

// ── START SERVER ──
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ App running on port ${PORT}`);
  console.log(`📊 Metrics available at http://localhost:${PORT}/metrics`);
  console.log(`❤️  Health check at http://localhost:${PORT}/health`);
});
