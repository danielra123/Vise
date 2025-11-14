const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');

// ===============================
// 🔍 Configuración de Exportadores
// ===============================

// Exportador para Grafana Tempo
const tempoExporter = new OTLPTraceExporter({
  url: process.env.TEMPO_URL || 'https://tempo-<juanito040>.grafana.net/otlp/v1/traces',
  headers: {
    Authorization: 'Basic ' + Buffer.from(
      `${process.env.TEMPO_USER || '<juanito040>'}:${process.env.TEMPO_TOKEN || '<tu_api_token>'}`
    ).toString('base64'),
  },
});

// Exportador para Axiom (OTLP)
// Axiom acepta datos OTLP directamente en: https://api.axiom.co/v1/traces
const axiomExporter = process.env.AXIOM_TOKEN ? new OTLPTraceExporter({
  url: 'https://api.axiom.co/v1/traces',
  headers: {
    'Authorization': `Bearer ${process.env.AXIOM_TOKEN}`,
    'X-Axiom-Dataset': process.env.AXIOM_DATASET || 'vise-api-logs',
  },
}) : null;

// ===============================
// 📊 SDK de OpenTelemetry
// ===============================

const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'vise-payment-api',
    [SemanticResourceAttributes.SERVICE_VERSION]: '1.0.0',
    [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: process.env.NODE_ENV || 'development',
  }),
  traceExporter: tempoExporter, // Exportador principal
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start()
  .then(() => {
    console.log('✅ OpenTelemetry iniciado y enviando trazas a Grafana Tempo');
    if (axiomExporter) {
      console.log('✅ Trazas también se enviarán a Axiom');
    }
  })
  .catch((err) => console.error('❌ Error al iniciar OpenTelemetry', err));

process.on('SIGTERM', () => {
  sdk.shutdown().then(() => console.log('🛑 Telemetría detenida'));
});
