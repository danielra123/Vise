const { Axiom } = require('@axiomhq/js');

class AxiomLogger {
    constructor() {
        this.enabled = false;
        this.axiom = null;
        this.dataset = process.env.AXIOM_DATASET || 'vise-api-logs';

        if (process.env.AXIOM_TOKEN) {
            try {
                this.axiom = new Axiom({
                    token: process.env.AXIOM_TOKEN,
                });
                this.enabled = true;
                console.log('✅ Axiom Logger conectado correctamente');
                console.log(`📊 Dataset: ${this.dataset}`);
            } catch (error) {
                console.error('❌ Error al conectar con Axiom:', error.message);
            }
        } else {
            console.log('⚠️  Axiom Logger deshabilitado (no se encontró AXIOM_TOKEN)');
        }
    }

    async log(level, message, metadata = {}) {
        if (!this.enabled || !this.axiom) {
            return;
        }

        try {
            const logEntry = {
                _time: new Date().toISOString(),
                level: level.toUpperCase(),
                message,
                service: 'vise-payment-api',
                environment: process.env.NODE_ENV || 'development',
                ...metadata
            };

            await this.axiom.ingest(this.dataset, [logEntry]);
        } catch (error) {
            console.error('Error enviando log a Axiom:', error.message);
        }
    }

    async info(message, metadata = {}) {
        return this.log('info', message, metadata);
    }

    async success(message, metadata = {}) {
        return this.log('success', message, metadata);
    }

    async warning(message, metadata = {}) {
        return this.log('warning', message, metadata);
    }

    async error(message, metadata = {}) {
        return this.log('error', message, metadata);
    }

    async logRequest(req, res, metadata = {}) {
        if (!this.enabled) return;

        const requestData = {
            _time: new Date().toISOString(),
            level: 'INFO',
            message: `${req.method} ${req.originalUrl}`,
            service: 'vise-payment-api',
            environment: process.env.NODE_ENV || 'development',
            method: req.method,
            url: req.originalUrl,
            path: req.path,
            statusCode: res.statusCode,
            ip: req.ip || req.connection.remoteAddress,
            userAgent: req.get('User-Agent'),
            contentType: req.get('Content-Type'),
            origin: req.get('Origin'),
            ...metadata
        };

        try {
            await this.axiom.ingest(this.dataset, [requestData]);
        } catch (error) {
            console.error('Error enviando request log a Axiom:', error.message);
        }
    }

    async logClientRegistration(client, metadata = {}) {
        return this.log('info', 'Cliente registrado', {
            event_type: 'client_registration',
            client_id: client.clientId,
            card_type: client.cardType,
            country: client.country,
            vise_club: client.viseClub,
            ...metadata
        });
    }

    async logPurchase(purchase, metadata = {}) {
        return this.log('info', 'Compra procesada', {
            event_type: 'purchase',
            client_id: purchase.clientId,
            original_amount: purchase.originalAmount,
            discount_applied: purchase.discountApplied,
            final_amount: purchase.finalAmount,
            benefit: purchase.benefit,
            ...metadata
        });
    }

    async logValidationError(error, metadata = {}) {
        return this.log('warning', 'Error de validación', {
            event_type: 'validation_error',
            error_message: error,
            ...metadata
        });
    }

    async flush() {
        if (this.enabled && this.axiom) {
            try {
                await this.axiom.flush();
                console.log('✅ Logs de Axiom enviados correctamente');
            } catch (error) {
                console.error('❌ Error al enviar logs finales a Axiom:', error.message);
            }
        }
    }
}

const axiomLogger = new AxiomLogger();

process.on('beforeExit', async () => {
    await axiomLogger.flush();
});

process.on('SIGTERM', async () => {
    await axiomLogger.flush();
    process.exit(0);
});

process.on('SIGINT', async () => {
    await axiomLogger.flush();
    process.exit(0);
});

module.exports = axiomLogger;
