// ===============================
// 🔧 Cargar Variables de Entorno
// ===============================
require('dotenv').config();

// ===============================
// 🔍 Azure Application Insights
// ===============================
const appInsights = require("applicationinsights");

appInsights
  .setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING || "InstrumentationKey=dd2c0206-4c52-43e9-a88f-77e18c1a6915")
  .setAutoDependencyCorrelation(true)
  .setAutoCollectRequests(true)
  .setAutoCollectPerformance(true)
  .setAutoCollectExceptions(true)
  .setAutoCollectDependencies(true)
  .setAutoCollectConsole(true, true)
  .setUseDiskRetryCaching(true)
  .start();

console.log("✅ Application Insights conectado correctamente");

const client = appInsights.defaultClient;
client.context.tags[client.context.keys.cloudRole] = "vise-node-api";
client.trackEvent({
  name: "server_started",
  properties: { environment: process.env.NODE_ENV || "local" }
});

// ===============================
// 📊 Axiom Logger Integration
// ===============================
const axiomLogger = require('./axiom-logger');

// ===============================
// 🚀 Configuración Express
// ===============================
const express = require('express');
const path = require('path');
const app = express();
const PORT = 3000;
// Middleware para parsear JSON
app.use(express.json());

// Sistema de logging profesional
const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m'
};

class APILogger {
    constructor() {
        this.requestHistory = [];
        this.startTime = Date.now();
    }

    log(level, message, data = null) {
        const timestamp = new Date().toISOString();
        const colorMap = {
            INFO: colors.blue,
            SUCCESS: colors.green,
            ERROR: colors.red,
            WARNING: colors.yellow,
            API: colors.cyan
        };
        
        const color = colorMap[level] || colors.reset;
        console.log(`${color}[${level}]${colors.reset} ${timestamp} - ${message}`);
        
        if (data) {
            console.log(`${color}Data:${colors.reset}`, JSON.stringify(data, null, 2));
        }
    }

    logRequest(req, res, requestData = null, responseData = null, executionTime = 0) {
        const timestamp = new Date().toISOString();
        const method = req.method;
        const url = req.originalUrl;
        const statusCode = res.statusCode;
        const userAgent = req.get('User-Agent') || 'Unknown';
        const ip = req.ip || req.connection.remoteAddress || 'Unknown';

        // Crear entrada del historial
        const requestEntry = {
            id: this.requestHistory.length + 1,
            timestamp,
            method,
            url,
            statusCode,
            executionTime: `${executionTime}ms`,
            ip,
            userAgent: userAgent.substring(0, 50) + '...',
            requestData,
            responseData
        };

        // Agregar al historial
        this.requestHistory.push(requestEntry);

        // Mantener solo los últimos 100 registros
        if (this.requestHistory.length > 100) {
            this.requestHistory.shift();
        }

        // Log en consola con colores
        const statusColor = statusCode >= 400 ? colors.red : 
                           statusCode >= 300 ? colors.yellow : colors.green;
        
        console.log(`\n${colors.cyan}=== API REQUEST ===${colors.reset}`);
        console.log(`${colors.bright}${method}${colors.reset} ${url}`);
        console.log(`Status: ${statusColor}${statusCode}${colors.reset}`);
        console.log(`Time: ${colors.magenta}${executionTime}ms${colors.reset}`);
        console.log(`IP: ${ip}`);
        
        if (requestData) {
            console.log(`${colors.yellow}📤 Request Body:${colors.reset}`);
            console.log(JSON.stringify(requestData, null, 2));
        }
        
        if (responseData) {
            console.log(`${colors.yellow}📥 Response Body:${colors.reset}`);
            console.log(JSON.stringify(responseData, null, 2));
        }
        
        console.log(`${colors.cyan}===================${colors.reset}\n`);
    }

    getStats() {
        const now = Date.now();
        const uptime = Math.round((now - this.startTime) / 1000);
        const totalRequests = this.requestHistory.length;
        
        const statusCounts = this.requestHistory.reduce((acc, req) => {
            const status = Math.floor(req.statusCode / 100) * 100;
            acc[status] = (acc[status] || 0) + 1;
            return acc;
        }, {});

        const methodCounts = this.requestHistory.reduce((acc, req) => {
            acc[req.method] = (acc[req.method] || 0) + 1;
            return acc;
        }, {});

        return {
            uptime: `${uptime}s`,
            totalRequests,
            statusCounts,
            methodCounts,
            recentRequests: this.requestHistory.slice(-10)
        };
    }
}

const apiLogger = new APILogger();

// Middleware de logging personalizado
app.use((req, res, next) => {
    const startTime = Date.now();
    
    // Capturar datos de la request
    const requestData = req.method !== 'GET' ? req.body : null;
    
    // Interceptar el res.json para capturar la response
    const originalJson = res.json;
    let responseData = null;
    
    res.json = function(body) {
        responseData = body;
        return originalJson.call(this, body);
    };
    
    res.on('finish', () => {
        const executionTime = Date.now() - startTime;
        apiLogger.logRequest(req, res, requestData, responseData, executionTime);

        // Enviar también a Axiom
        axiomLogger.logRequest(req, res, {
            executionTime: `${executionTime}ms`,
            requestBody: requestData,
            responseBody: responseData
        });
    });

    next();
});

// Habilitar CORS
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

// Servir archivos estáticos
app.use(express.static(path.join(__dirname, 'public')));

// Base de datos en memoria para clientes
let clients = [];
let nextClientId = 1;

// Países restringidos para tarjetas Black y White
const RESTRICTED_COUNTRIES = ['China', 'Vietnam', 'India', 'Iran'];

// Configuración de tarjetas
const CARD_CONFIG = {
    Classic: {
        minIncome: 0,
        requiresViseClub: false,
        restrictedCountries: false
    },
    Gold: {
        minIncome: 500,
        requiresViseClub: false,
        restrictedCountries: false
    },
    Platinum: {
        minIncome: 1000,
        requiresViseClub: true,
        restrictedCountries: false
    },
    Black: {
        minIncome: 2000,
        requiresViseClub: true,
        restrictedCountries: true
    },
    White: {
        minIncome: 2000,
        requiresViseClub: true,
        restrictedCountries: true
    }
};

// Función para validar elegibilidad de tarjeta
function validateCardEligibility(client, cardType) {
    const config = CARD_CONFIG[cardType];
    if (!config) {
        return { valid: false, error: `Tipo de tarjeta ${cardType} no válido` };
    }

    if (client.monthlyIncome < config.minIncome) {
        return { 
            valid: false, 
            error: `El cliente no cumple con el ingreso mínimo de ${config.minIncome} USD para ${cardType}` 
        };
    }

    if (config.requiresViseClub && !client.viseClub) {
        return { 
            valid: false, 
            error: `El cliente no cumple con la suscripción VISE CLUB requerida para ${cardType}` 
        };
    }

    if (config.restrictedCountries && RESTRICTED_COUNTRIES.includes(client.country)) {
        return { 
            valid: false, 
            error: `Los clientes de ${client.country} no pueden solicitar tarjeta ${cardType}` 
        };
    }

    return { valid: true };
}

// Función para calcular beneficios
function calculateBenefits(client, purchase) {
    const { cardType } = client;
    const { amount, purchaseDate, purchaseCountry } = purchase;
    
    const date = new Date(purchaseDate);
    const dayOfWeek = date.getDay();
    const isAbroad = purchaseCountry !== client.country;
    
    let discount = 0;
    let benefit = '';

    switch (cardType) {
        case 'Classic':
            break;

        case 'Gold':
            if ([1, 2, 3].includes(dayOfWeek) && amount > 100) {
                discount = 0.15;
                benefit = 'Lunes/Martes/Miércoles - Descuento 15%';
            }
            break;

        case 'Platinum':
            if ([1, 2, 3].includes(dayOfWeek) && amount > 100) {
                discount = 0.20;
                benefit = 'Lunes/Martes/Miércoles - Descuento 20%';
            }
            else if (dayOfWeek === 6 && amount > 200) {
                discount = 0.30;
                benefit = 'Sábado - Descuento 30%';
            }
            else if (isAbroad) {
                discount = 0.05;
                benefit = 'Compra en el exterior - Descuento 5%';
            }
            break;

        case 'Black':
            if ([1, 2, 3].includes(dayOfWeek) && amount > 100) {
                discount = 0.25;
                benefit = 'Lunes/Martes/Miércoles - Descuento 25%';
            }
            else if (dayOfWeek === 6 && amount > 200) {
                discount = 0.35;
                benefit = 'Sábado - Descuento 35%';
            }
            else if (isAbroad) {
                discount = 0.05;
                benefit = 'Compra en el exterior - Descuento 5%';
            }
            break;

        case 'White':
            if ([1, 2, 3, 4, 5].includes(dayOfWeek) && amount > 100) {
                discount = 0.25;
                benefit = 'Lunes a Viernes - Descuento 25%';
            }
            else if ([6, 0].includes(dayOfWeek) && amount > 200) {
                discount = 0.35;
                benefit = 'Fin de semana - Descuento 35%';
            }
            else if (isAbroad) {
                discount = 0.05;
                benefit = 'Compra en el exterior - Descuento 5%';
            }
            break;
    }

    const discountAmount = amount * discount;
    const finalAmount = amount - discountAmount;

    return {
        discountApplied: Math.round(discountAmount * 100) / 100,
        finalAmount: Math.round(finalAmount * 100) / 100,
        benefit: benefit || 'Sin beneficios aplicables'
    };
}

// POST /client - Registrar cliente
app.post('/client', (req, res) => {
    apiLogger.log('INFO', 'Procesando registro de cliente...');
    
    try {
        const { name, country, monthlyIncome, viseClub, cardType } = req.body;

        if (!name || !country || monthlyIncome === undefined || viseClub === undefined || !cardType) {
            apiLogger.log('ERROR', 'Campos requeridos faltantes en registro de cliente');
            return res.status(400).json({
                status: 'Rejected',
                error: 'Todos los campos son requeridos'
            });
        }

        const validation = validateCardEligibility({
            name, country, monthlyIncome, viseClub
        }, cardType);

        if (!validation.valid) {
            apiLogger.log('WARNING', `Cliente no elegible: ${validation.error}`);

            // Log error a Axiom
            axiomLogger.logValidationError(validation.error, {
                name, country, monthlyIncome, viseClub, cardType
            });

            return res.status(400).json({
                status: 'Rejected',
                error: validation.error
            });
        }

        const client = {
            clientId: nextClientId++,
            name,
            country,
            monthlyIncome,
            viseClub,
            cardType
        };

        clients.push(client);

        const response = {
            clientId: client.clientId,
            name: client.name,
            cardType: client.cardType,
            status: 'Registered',
            message: `Cliente apto para tarjeta ${cardType}`
        };

        apiLogger.log('SUCCESS', `Cliente registrado: ID ${client.clientId}, Tarjeta ${cardType}`);

        // Log a Axiom
        axiomLogger.logClientRegistration(client);

        res.status(201).json(response);

    } catch (error) {
        apiLogger.log('ERROR', 'Error interno en registro de cliente', { error: error.message });
        res.status(500).json({
            status: 'Error',
            error: 'Error interno del servidor'
        });
    }
});

// POST /purchase - Procesar compra
app.post('/purchase', (req, res) => {
    apiLogger.log('INFO', 'Procesando compra...');
    
    try {
        const { clientId, amount, currency, purchaseDate, purchaseCountry } = req.body;

        if (!clientId || !amount || !currency || !purchaseDate || !purchaseCountry) {
            apiLogger.log('ERROR', 'Campos requeridos faltantes en procesamiento de compra');
            return res.status(400).json({
                status: 'Rejected',
                error: 'Todos los campos son requeridos'
            });
        }

        const client = clients.find(c => c.clientId === clientId);
        if (!client) {
            apiLogger.log('ERROR', `Cliente no encontrado: ID ${clientId}`);
            return res.status(404).json({
                status: 'Rejected',
                error: 'Cliente no encontrado'
            });
        }

        if ((client.cardType === 'Black' || client.cardType === 'White') && 
            RESTRICTED_COUNTRIES.includes(purchaseCountry)) {
            apiLogger.log('WARNING', `Compra rechazada: Cliente ${clientId} con tarjeta ${client.cardType} desde ${purchaseCountry}`);
            return res.status(400).json({
                status: 'Rejected',
                error: `El cliente con tarjeta ${client.cardType} no puede realizar compras desde ${purchaseCountry}`
            });
        }

        const benefits = calculateBenefits(client, {
            amount, purchaseDate, purchaseCountry
        });

        const response = {
            status: 'Approved',
            purchase: {
                clientId: client.clientId,
                originalAmount: amount,
                discountApplied: benefits.discountApplied,
                finalAmount: benefits.finalAmount,
                benefit: benefits.benefit
            }
        };

        apiLogger.log('SUCCESS', `Compra procesada: Cliente ${clientId}, Monto ${amount} ${currency}, Descuento ${benefits.discountApplied}`);

        // Log a Axiom
        axiomLogger.logPurchase({
            clientId: client.clientId,
            originalAmount: amount,
            discountApplied: benefits.discountApplied,
            finalAmount: benefits.finalAmount,
            benefit: benefits.benefit
        }, {
            currency,
            purchaseDate,
            purchaseCountry,
            cardType: client.cardType
        });

        res.json(response);

    } catch (error) {
        apiLogger.log('ERROR', 'Error interno en procesamiento de compra', { error: error.message });
        res.status(500).json({
            status: 'Error',
            error: 'Error interno del servidor'
        });
    }
});

// GET /clients - Obtener todos los clientes
app.get('/clients', (req, res) => {
    apiLogger.log('INFO', `Consultando lista de clientes. Total: ${clients.length}`);
    res.json(clients);
});

// GET /api/stats - Endpoint para ver estadísticas de la API
app.get('/api/stats', (req, res) => {
    const stats = apiLogger.getStats();
    apiLogger.log('INFO', 'Consultando estadísticas de la API');
    res.json(stats);
});

// GET /api/history - Endpoint para ver historial de peticiones
app.get('/api/history', (req, res) => {
    const { limit = 10 } = req.query;
    const history = apiLogger.requestHistory.slice(-parseInt(limit));
    apiLogger.log('INFO', `Consultando historial de peticiones. Límite: ${limit}`);
    res.json({
        total: apiLogger.requestHistory.length,
        showing: history.length,
        requests: history
    });
});

// Ruta principal
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 404 handler
app.use('*', (req, res) => {
    apiLogger.log('WARNING', `Ruta no encontrada: ${req.method} ${req.originalUrl}`);
    res.status(404).json({
        status: 'Error',
        error: 'Ruta no encontrada'
    });
});

// Iniciar servidor
app.listen(PORT, () => {
    apiLogger.log('SUCCESS', `🚀 Servidor VISE API ejecutándose en http://localhost:${PORT}`);
    console.log(`\n${colors.cyan}📋 Endpoints disponibles:${colors.reset}`);
    console.log(`   ${colors.green}POST${colors.reset} /client         - Registrar cliente`);
    console.log(`   ${colors.green}POST${colors.reset} /purchase       - Procesar compra`);
    console.log(`   ${colors.blue}GET${colors.reset}  /clients        - Ver clientes registrados`);
    console.log(`   ${colors.blue}GET${colors.reset}  /api/stats      - Estadísticas de la API`);
    console.log(`   ${colors.blue}GET${colors.reset}  /api/history    - Historial de peticiones`);
    console.log(`\n${colors.yellow}💳 Tipos de tarjeta: Classic, Gold, Platinum, Black, White${colors.reset}`);
    console.log(`${colors.magenta}🔍 Logs detallados activados${colors.reset}\n`);
});

module.exports = app;