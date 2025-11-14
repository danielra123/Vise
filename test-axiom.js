// ===============================
// 🧪 Script de Prueba para Axiom
// ===============================

require('dotenv').config();
const axiomLogger = require('./axiom-logger');

async function testAxiom() {
    console.log('\n🧪 Iniciando pruebas de Axiom...\n');

    try {
        // Test 1: Log básico de información
        console.log('Test 1: Enviando log de información...');
        await axiomLogger.info('Test de información desde script de prueba', {
            test_id: 1,
            timestamp: new Date().toISOString()
        });
        console.log('✅ Log de información enviado\n');

        // Test 2: Log de éxito
        console.log('Test 2: Enviando log de éxito...');
        await axiomLogger.success('Test de éxito completado', {
            test_id: 2,
            success: true
        });
        console.log('✅ Log de éxito enviado\n');

        // Test 3: Log de advertencia
        console.log('Test 3: Enviando log de advertencia...');
        await axiomLogger.warning('Test de advertencia', {
            test_id: 3,
            warning_level: 'medium'
        });
        console.log('✅ Log de advertencia enviado\n');

        // Test 4: Log de error
        console.log('Test 4: Enviando log de error...');
        await axiomLogger.error('Test de error simulado', {
            test_id: 4,
            error_code: 'TEST_ERROR',
            stack: 'Simulated stack trace'
        });
        console.log('✅ Log de error enviado\n');

        // Test 5: Log de registro de cliente
        console.log('Test 5: Enviando log de registro de cliente...');
        await axiomLogger.logClientRegistration({
            clientId: 999,
            name: 'Cliente de Prueba',
            country: 'Colombia',
            cardType: 'Gold',
            viseClub: true
        });
        console.log('✅ Log de registro de cliente enviado\n');

        // Test 6: Log de compra
        console.log('Test 6: Enviando log de compra...');
        await axiomLogger.logPurchase({
            clientId: 999,
            originalAmount: 500,
            discountApplied: 75,
            finalAmount: 425,
            benefit: 'Test Benefit'
        }, {
            currency: 'USD',
            purchaseDate: new Date().toISOString(),
            purchaseCountry: 'USA'
        });
        console.log('✅ Log de compra enviado\n');

        // Test 7: Log de error de validación
        console.log('Test 7: Enviando log de error de validación...');
        await axiomLogger.logValidationError('Error de validación de prueba', {
            field: 'email',
            reason: 'invalid_format'
        });
        console.log('✅ Log de error de validación enviado\n');

        // Flush final
        console.log('⏳ Esperando flush final de logs...');
        await axiomLogger.flush();
        console.log('✅ Todos los logs fueron enviados a Axiom\n');

        console.log('🎉 ¡Todas las pruebas completadas exitosamente!');
        console.log('\n📊 Ve a tu dashboard de Axiom para verificar los logs:');
        console.log('   https://app.axiom.co\n');

    } catch (error) {
        console.error('❌ Error durante las pruebas:', error);
        process.exit(1);
    }
}

// Ejecutar pruebas
testAxiom().then(() => {
    console.log('✨ Script de prueba finalizado');
    process.exit(0);
}).catch((error) => {
    console.error('💥 Error fatal:', error);
    process.exit(1);
});
