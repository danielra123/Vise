const API_BASE = '';

// Configuración de logging
const DEBUG_MODE = true; // Cambiar a false en producción

/**
 * Logger personalizado para debugging
 */
const logger = {
    log: (message, data = null) => {
        if (!DEBUG_MODE) return;
        console.log(`[VISE] ${message}`, data ? data : '');
    },
    
    success: (message, data = null) => {
        if (!DEBUG_MODE) return;
        console.log(`%c[VISE SUCCESS] ${message}`, 'color: #10b981', data ? data : '');
    },
    
    error: (message, error = null) => {
        if (!DEBUG_MODE) return;
        console.error(`[VISE ERROR] ${message}`, error ? error : '');
    },
    
    api: (method, url, requestData = null, responseData = null) => {
        if (!DEBUG_MODE) return;
        console.group(`%c[API ${method.toUpperCase()}] ${url}`, 'color: #3b82f6');
        if (requestData) {
            console.log('📤 Request:', requestData);
        }
        if (responseData) {
            console.log('📥 Response:', responseData);
        }
        console.groupEnd();
    }
};
