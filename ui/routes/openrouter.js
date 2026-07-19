/**
 * OpenRouter routes — list free models from OpenRouter API.
 */
const { execSync } = require('child_process');

const CACHE_TTL = 5 * 60 * 1000; // 5 minutes
let cache = { data: null, timestamp: 0 };

function getApiKey() {
  return process.env.OPENROUTER_API_KEY || null;
}

function fetchModels() {
  const key = getApiKey();
  if (!key) return { error: 'OPENROUTER_API_KEY not set', models: [] };

  // Return cached data if fresh
  if (cache.data && (Date.now() - cache.timestamp) < CACHE_TTL) {
    return { models: cache.data, cached: true };
  }

  try {
    const stdout = execSync(
      `curl -s --max-time 15 -H "Authorization: Bearer ${key}" "https://openrouter.ai/api/v1/models"`,
      { timeout: 20000, encoding: 'utf8' }
    );
    const data = JSON.parse(stdout);
    const allModels = data.data || [];

    // Separate free and paid models
    const freeModels = allModels.filter(m => m.id.endsWith(':free'));

    // Sort by context length descending
    freeModels.sort((a, b) => (b.context_length || 0) - (a.context_length || 0));
    allModels.sort((a, b) => (b.context_length || 0) - (a.context_length || 0));

    const result = {
      free: freeModels.map(m => ({
        id: m.id,
        name: m.name,
        context_length: m.context_length,
        pricing: m.pricing,
        description: m.description,
      })),
      all: allModels.map(m => ({
        id: m.id,
        name: m.name,
        context_length: m.context_length,
        pricing: m.pricing,
      })),
      total: allModels.length,
      free_count: freeModels.length,
    };

    cache = { data: result, timestamp: Date.now() };
    return { models: result, cached: false };
  } catch (e) {
    // Return stale cache on error, if available
    if (cache.data) {
      return { models: cache.data, cached: true, stale: true };
    }
    return { error: `API request failed: ${e.message}`, models: null };
  }
}

module.exports = function (app, ctx) {
  // GET /api/openrouter/models — list all models (free first)
  app.get('/api/openrouter/models', (req, res) => {
    const result = fetchModels();
    if (result.error) return res.status(502).json({ error: result.error });
    res.json({
      models: result.models,
      cached: result.cached || false,
      stale: result.stale || false,
      apiKeySet: !!getApiKey(),
    });
  });

  // POST /api/openrouter/models/refresh — force refresh cache
  app.post('/api/openrouter/models/refresh', (req, res) => {
    cache = { data: null, timestamp: 0 };
    const result = fetchModels();
    if (result.error) return res.status(502).json({ error: result.error });
    res.json({ success: true, ...result.models });
  });
};
