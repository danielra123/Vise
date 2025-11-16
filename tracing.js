const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');

const axiomExporter = process.env.AXIOM_TOKEN ? new OTLPTraceExporter({
  url: 'https://api.axiom.co/v1/traces',
  headers: {
    'Authorization': `Bearer ${process.env.AXIOM_TOKEN}`,
    'X-Axiom-Dataset': process.env.AXIOM_DATASET || 'vise-api-axiom',
  },
}) : null;

const tempoExporter = process.env.TEMPO_URL && process.env.TEMPO_TOKEN ? new OTLPTraceExporter({
  url: process.env.TEMPO_URL,
  headers: {
    Authorization: 'Basic ' + Buffer.from(
      `${process.env.TEMPO_USER}:${process.env.TEMPO_TOKEN}`
    ).toString('base64'),
  },
}) : null;

let traceExporter;
let exporterName;

if (axiomExporter) {
  traceExporter = axiomExporter;
  exporterName = 'Axiom';
} else if (tempoExporter) {
  traceExporter = tempoExporter;
  exporterName = 'Grafana Tempo';
} else {
  console.log('⚠️  OpenTelemetry: No hay exportadores configurados (falta AXIOM_TOKEN o TEMPO_URL)');
  traceExporter = null;
}

if (traceExporter) {
  const sdk = new NodeSDK({
    resource: new Resource({
      [SemanticResourceAttributes.SERVICE_NAME]: 'vise-payment-api',
      [SemanticResourceAttributes.SERVICE_VERSION]: '1.0.0',
      [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: process.env.NODE_ENV || 'development',
    }),
    traceExporter: traceExporter,
    instrumentations: [getNodeAutoInstrumentations()],
  });

  sdk.start()
    .then(() => {
      console.log(`✅ OpenTelemetry iniciado y enviando trazas a ${exporterName}`);
      console.log(`📊 Dataset: ${process.env.AXIOM_DATASET || 'vise-api-axiom'}`);
    })
    .catch((err) => console.error('❌ Error al iniciar OpenTelemetry', err));

  process.on('SIGTERM', () => {
    sdk.shutdown().then(() => console.log('🛑 Telemetría detenida'));
  });
}
