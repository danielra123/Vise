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

// Inicialización cuando el DOM está listo
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

/**
 * Inicializar la aplicación
 */
function initializeApp() {
    logger.log('Inicializando aplicación VISE...');
    
    // Establecer fecha actual en el campo de fecha
    const purchaseDateField = document.getElementById('purchaseDate');
    if (purchaseDateField) {
        purchaseDateField.value = new Date().toISOString().slice(0, 16);
        logger.log('Fecha de compra establecida:', purchaseDateField.value);
    }
    
    // Cargar datos iniciales
    loadClients();
    updateStats();
    
    // Configurar validación de formularios
    setupFormValidation();
    
    // Configurar event listeners
    setupEventListeners();
    
    logger.success('Aplicación inicializada correctamente');
}

/**
 * Configurar event listeners para la aplicación
 */
function setupEventListeners() {
    // Navegación por pestañas
    const navTabs = document.querySelectorAll('.nav-tab');
    navTabs.forEach(tab => {
        tab.addEventListener('click', handleTabClick);
    });
    
    // Formulario de registro de cliente
    const clientForm = document.getElementById('clientForm');
    if (clientForm) {
        clientForm.addEventListener('submit', handleClientSubmit);
    }
    
    // Formulario de procesamiento de pagos
    const purchaseForm = document.getElementById('purchaseForm');
    if (purchaseForm) {
        purchaseForm.addEventListener('submit', handlePurchaseSubmit);
    }
    
    // Botón de actualizar clientes
    const refreshBtn = document.getElementById('refreshClients');
    if (refreshBtn) {
        refreshBtn.addEventListener('click', loadClients);
    }
}

/**
 * Configurar validación de formularios en tiempo real
 */
function setupFormValidation() {
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        const inputs = form.querySelectorAll('.form-control');
        inputs.forEach(input => {
            // Validar cuando pierde el foco
            input.addEventListener('blur', function() {
                validateField(this);
            });
            
            // Limpiar errores cuando empieza a escribir
            input.addEventListener('input', function() {
                clearFieldError(this);
            });
        });
    });
}

/**
 * Manejar clic en pestañas de navegación
 */
function handleTabClick(event) {
    const tabName = event.currentTarget.getAttribute('data-tab');
    switchTab(tabName);
}

/**
 * Cambiar pestaña activa
 */
function switchTab(tabName) {
    // Ocultar todas las pestañas
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // Desactivar todos los botones
    document.querySelectorAll('.nav-tab').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // Activar la pestaña seleccionada
    const targetTab = document.getElementById(tabName);
    const targetBtn = document.querySelector(`[data-tab="${tabName}"]`);
    
    if (targetTab && targetBtn) {
        targetTab.classList.add('active');
        targetBtn.classList.add('active');
    }
}

/**
 * Validar un campo individual
 */
function validateField(field) {
    const formGroup = field.closest('.form-group');
    if (!formGroup) return true;
    
    // Limpiar estado anterior
    clearFieldError(field);
    
    // Verificar campos requeridos
    if (field.hasAttribute('required') && !field.value.trim()) {
        showFieldError(field, 'Este campo es requerido');
        return false;
    }
    
    // Validar campos numéricos
    if (field.type === 'number' && field.value) {
        const value = parseFloat(field.value);
        const min = field.getAttribute('min');
        const max = field.getAttribute('max');
        
        if (isNaN(value)) {
            showFieldError(field, 'Ingrese un número válido');
            return false;
        }
        
        if (min && value < parseFloat(min)) {
            showFieldError(field, `El valor mínimo es ${min}`);
            return false;
        }
        
        if (max && value > parseFloat(max)) {
            showFieldError(field, `El valor máximo es ${max}`);
            return false;
        }
    }
    
    // Mostrar éxito si todo está bien
    if (field.value.trim()) {
        showFieldSuccess(field);
    }
    
    return true;
}