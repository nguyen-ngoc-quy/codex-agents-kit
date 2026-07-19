/**
 * Benchmark page — run benchmark, display results + history chart.
 */
const PageBenchmark = (() => {
  let chartInstance = null;

  async function render(renderFn) {
    const html = `
      <div style="margin-bottom:16px;display:flex;align-items:center;gap:12px;flex-wrap:wrap">
        <button class="btn btn-primary" onclick="PageBenchmark.run()">⚡ Run Benchmark</button>
        <span style="color:var(--text-muted);font-size:0.9rem">
          Measures latency and tokens/second of the configured model
        </span>
      </div>
      <div id="benchmark-results">
        <div class="card">
          <div class="card-header"><h3>Latest Result</h3></div>
          <div class="card-body">
            <p style="color:var(--text-secondary)">Click "Run Benchmark" to start.</p>
          </div>
        </div>
      </div>
      <div class="card" style="margin-top:16px">
        <div class="card-header"><h3>📈 History</h3></div>
        <div class="card-body">
          <p style="color:var(--text-secondary)">Results will appear here after running benchmarks.</p>
        </div>
      </div>
    `;
    renderFn(html);

    // Load history if exists
    try {
      const history = await API.getBenchmarkHistory();
      renderHistory(history);
    } catch { /* ignore */ }
  }

  async function run() {
    const resultsEl = document.getElementById('benchmark-results');
    resultsEl.innerHTML = `
      <div class="card">
        <div class="card-header"><h3>⚡ Running Benchmark...</h3></div>
        <div class="card-body">
          <div class="loading-spinner">
            <div class="spinner"></div>
            <p>This may take up to 60 seconds...</p>
          </div>
        </div>
      </div>
    `;

    try {
      const result = await API.runBenchmark();

      resultsEl.innerHTML = `
        <div class="card" style="margin-bottom:16px">
          <div class="card-header"><h3>📊 Benchmark Results</h3></div>
          <div class="card-body">
            <div class="grid grid-3">
              <div style="text-align:center;padding:20px">
                <div style="font-size:0.85rem;color:var(--text-secondary);margin-bottom:4px">Latency</div>
                <div style="font-size:1.8rem;font-weight:700;color:var(--accent-cyan)">
                  ${result.latencyMs !== null ? `${result.latencyMs.toFixed(1)} <span style="font-size:1rem">ms</span>` : 'N/A'}
                </div>
              </div>
              <div style="text-align:center;padding:20px">
                <div style="font-size:0.85rem;color:var(--text-secondary);margin-bottom:4px">Speed</div>
                <div style="font-size:1.8rem;font-weight:700;color:var(--accent-green)">
                  ${result.tokensPerSec !== null ? `${result.tokensPerSec.toFixed(1)} <span style="font-size:1rem">tok/s</span>` : 'N/A'}
                </div>
              </div>
              <div style="text-align:center;padding:20px">
                <div style="font-size:0.85rem;color:var(--text-secondary);margin-bottom:4px">Provider / Model</div>
                <div style="font-size:1rem;font-weight:600">
                  ${result.provider || '?'}<br>
                  <code style="font-size:0.85rem">${result.model || '?'}</code>
                </div>
              </div>
            </div>
            ${result.responseText ? `
              <div style="margin-top:12px;padding-top:12px;border-top:1px solid var(--border-light)">
                <div style="font-size:0.85rem;color:var(--text-secondary);margin-bottom:4px">Response Preview</div>
                <pre class="code-block">${escapeHtml(result.responseText)}</pre>
              </div>
            ` : ''}
          </div>
        </div>
      `;

      // Reload history
      const history = await API.getBenchmarkHistory();
      renderHistory(history);
      API.showToast('Benchmark complete', 'success');
    } catch (err) {
      resultsEl.innerHTML = `
        <div class="card" style="border-color:var(--accent-red)">
          <div class="card-header"><h3>❌ Benchmark Failed</h3></div>
          <div class="card-body">
            <p>${escapeHtml(err.message)}</p>
            <button class="btn btn-primary" style="margin-top:12px" onclick="PageBenchmark.run()">Retry</button>
          </div>
        </div>
      `;
    }
  }

  function renderHistory(history) {
    const container = document.querySelector('.card:last-child');
    if (!container || history.length === 0) return;

    const body = container.querySelector('.card-body');
    if (!body) return;

    // Table
    let tableHtml = `
      <div style="overflow-x:auto">
        <table style="width:100%;border-collapse:collapse">
          <thead>
            <tr style="text-align:left;border-bottom:2px solid var(--border-color)">
              <th style="padding:8px">Date</th>
              <th style="padding:8px">Latency</th>
              <th style="padding:8px">Speed</th>
              <th style="padding:8px">Provider</th>
              <th style="padding:8px">Model</th>
            </tr>
          </thead>
          <tbody>
            ${history.slice(-10).reverse().map(h => `
              <tr style="border-bottom:1px solid var(--border-light)">
                <td style="padding:8px;font-size:0.85rem">${new Date(h.timestamp).toLocaleString()}</td>
                <td style="padding:8px">${h.latencyMs !== null ? `${h.latencyMs.toFixed(0)} ms` : '-'}</td>
                <td style="padding:8px">${h.tokensPerSec !== null ? `${h.tokensPerSec.toFixed(1)} t/s` : '-'}</td>
                <td style="padding:8px;font-size:0.85rem">${h.provider || '-'}</td>
                <td style="padding:8px"><code style="font-size:0.85rem">${h.model || '-'}</code></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    `;
    body.innerHTML = tableHtml;

    // Chart
    renderChart(history);
  }

  function renderChart(history) {
    const canvasId = 'benchmark-chart';
    let canvas = document.getElementById(canvasId);

    if (!canvas) {
      // Add chart after table
      const table = document.querySelector('.card:last-child table');
      if (!table) return;

      const chartContainer = document.createElement('div');
      chartContainer.style.marginTop = '20px';
      chartContainer.innerHTML = `<canvas id="${canvasId}" height="200"></canvas>`;
      table.parentElement.appendChild(chartContainer);
      canvas = document.getElementById(canvasId);
    }

    if (!canvas) return;

    // Destroy old chart
    if (chartInstance) { chartInstance.destroy(); chartInstance = null; }

    const labels = history.map(h => new Date(h.timestamp).toLocaleTimeString());
    const latencyData = history.map(h => h.latencyMs || 0);
    const speedData = history.map(h => h.tokensPerSec || 0);

    const ctx = canvas.getContext('2d');
    chartInstance = new Chart(ctx, {
      type: 'line',
      data: {
        labels,
        datasets: [
          {
            label: 'Latency (ms)',
            data: latencyData,
            borderColor: '#39d2c0',
            backgroundColor: 'rgba(57,210,192,0.1)',
            tension: 0.3,
            yAxisID: 'y',
          },
          {
            label: 'Speed (tok/s)',
            data: speedData,
            borderColor: '#58a6ff',
            backgroundColor: 'rgba(88,166,255,0.1)',
            tension: 0.3,
            yAxisID: 'y1',
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: 'index', intersect: false },
        plugins: {
          legend: { labels: { color: '#8b949e' } },
        },
        scales: {
          x: {
            ticks: { color: '#8b949e', maxRotation: 45 },
            grid: { color: '#21262d' },
          },
          y: {
            type: 'linear',
            display: true,
            position: 'left',
            title: { display: true, text: 'Latency (ms)', color: '#39d2c0' },
            ticks: { color: '#8b949e' },
            grid: { color: '#21262d' },
          },
          y1: {
            type: 'linear',
            display: true,
            position: 'right',
            title: { display: true, text: 'Speed (tok/s)', color: '#58a6ff' },
            ticks: { color: '#8b949e' },
            grid: { drawOnChartArea: false },
          },
        },
      },
    });
  }

  function escapeHtml(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  return { render, run };
})();
