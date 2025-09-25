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

/**
 * Mostrar error en un campo
 */
function showFieldError(field, message) {
    const formGroup = field.closest('.form-group');
    const errorMsg = formGroup.querySelector('.error-message');
    
    if (!formGroup || !errorMsg) return;
    
    formGroup.classList.add('has-error');
    formGroup.classList.remove('has-success');
    field.classList.add('error');
    field.classList.remove('success');
    
    errorMsg.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${message}`;
    errorMsg.style.display = 'flex';
}

/**
 * Mostrar éxito en un campo
 */
function showFieldSuccess(field) {
    const formGroup = field.closest('.form-group');
    
    if (!formGroup) return;
    
    formGroup.classList.add('has-success');
    formGroup.classList.remove('has-error');
    field.classList.add('success');
    field.classList.remove('error');
}

/**
 * Limpiar errores de un campo
 */
function clearFieldError(field) {
    const formGroup = field.closest('.form-group');
    const errorMsg = formGroup ? formGroup.querySelector('.error-message') : null;
    
    if (!formGroup || !errorMsg) return;
    
    formGroup.classList.remove('has-error', 'has-success');
    field.classList.remove('error', 'success');
    errorMsg.style.display = 'none';
}

/**
 * Mostrar alerta al usuario
 */
function showAlert(message, type = 'info', details = null) {
    const alertContainer = document.getElementById('alertContainer');
    if (!alertContainer) return;
    
    const alertId = 'alert_' + Date.now();
    
    let icon = 'fas fa-info-circle';
    if (type === 'success') icon = 'fas fa-check-circle';
    if (type === 'error') icon = 'fas fa-exclamation-triangle';
    
    const alertHtml = `
        <div class="alert alert-${type}" id="${alertId}">
            <i class="${icon}"></i>
            <div>
                <div>${message}</div>
                ${details ? `<pre style="margin-top: 0.5rem; font-size: 0.85rem; opacity: 0.8;">${JSON.stringify(details, null, 2)}</pre>` : ''}
            </div>
        </div>
    `;
    
    alertContainer.insertAdjacentHTML('afterbegin', alertHtml);
    
    // Auto-eliminar después de 10 segundos
    setTimeout(() => {
        const alert = document.getElementById(alertId);
        if (alert) {
            alert.remove();
        }
    }, 10000);
}

/**
 * Manejar envío del formulario de cliente
 */
async function handleClientSubmit(e) {
    e.preventDefault();
    
    const form = e.target;
    
    // Validar todos los campos requeridos
    if (!validateForm(form)) {
        logger.error('Formulario de cliente inválido');
        showAlert('Por favor corrija los errores en el formulario', 'error');
        return;
    }
    
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalText = submitBtn.innerHTML;
    
    // Mostrar estado de carga
    setButtonLoading(submitBtn, 'Procesando...');
    
    try {
        const formData = new FormData(form);
        const clientData = {
            name: formData.get('name'),
            country: formData.get('country'),
            monthlyIncome: parseInt(formData.get('monthlyIncome')),
            viseClub: formData.get('viseClub') === 'on',
            cardType: formData.get('cardType')
        };

        logger.api('POST', '/client', clientData);

        const response = await fetch(`${API_BASE}/client`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(clientData)
        });

        const result = await response.json();
        
        logger.api('POST', '/client', null, {
            status: response.status,
            data: result
        });
        
        if (response.ok) {
            logger.success('Cliente registrado exitosamente', result);
            showAlert('Cliente registrado exitosamente', 'success', result);
            resetForm(form);
            loadClients();
            updateStats();
        } else {
            logger.error('Error del servidor al registrar cliente', result);
            showAlert('Error al registrar cliente', 'error', result);
        }
        
    } catch (error) {
        logger.error('Error de conexión al registrar cliente', error);
        showAlert('Error de conexión con el servidor', 'error', { error: error.message });
    } finally {
        resetButtonLoading(submitBtn, originalText);
    }
}

/**
 * Manejar envío del formulario de compra
 */
async function handlePurchaseSubmit(e) {
    e.preventDefault();
    
    const form = e.target;
    
    // Validar todos los campos requeridos
    if (!validateForm(form)) {
        logger.error('Formulario de compra inválido');
        showAlert('Por favor corrija los errores en el formulario', 'error');
        return;
    }
    
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalText = submitBtn.innerHTML;
    
    // Mostrar estado de carga
    setButtonLoading(submitBtn, 'Procesando...');
    
    try {
        const formData = new FormData(form);
        const purchaseData = {
            clientId: parseInt(formData.get('clientId')),
            amount: parseFloat(formData.get('amount')),
            currency: formData.get('currency'),
            purchaseDate: new Date(formData.get('purchaseDate')).toISOString(),
            purchaseCountry: formData.get('purchaseCountry')
        };

        logger.api('POST', '/purchase', purchaseData);

        const response = await fetch(`${API_BASE}/purchase`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(purchaseData)
        });

        const result = await response.json();
        
        logger.api('POST', '/purchase', null, {
            status: response.status,
            data: result
        });
        
        if (response.ok) {
            logger.success('Pago procesado exitosamente', result);
            showAlert('Pago procesado exitosamente', 'success', result);
            resetForm(form);
            // Restablecer fecha actual
            const purchaseDateField = document.getElementById('purchaseDate');
            if (purchaseDateField) {
                purchaseDateField.value = new Date().toISOString().slice(0, 16);
            }
            updateStats();
            incrementTransactionCount();
        } else {
            logger.error('Error del servidor al procesar pago', result);
            showAlert('Error al procesar el pago', 'error', result);
        }
        
    } catch (error) {
        logger.error('Error de conexión al procesar pago', error);
        showAlert('Error de conexión con el servidor', 'error', { error: error.message });
    } finally {
        resetButtonLoading(submitBtn, originalText);
    }
}

/**
 * Validar todo un formulario
 */
function validateForm(form) {
    const inputs = form.querySelectorAll('.form-control[required]');
    let isValid = true;
    
    inputs.forEach(input => {
        if (!validateField(input)) {
            isValid = false;
        }
    });
    
    return isValid;
}

/**
 * Restablecer formulario a su estado inicial
 */
function resetForm(form) {
    form.reset();
    
    // Limpiar validaciones
    form.querySelectorAll('.form-group').forEach(group => {
        group.classList.remove('has-error', 'has-success');
        const errorMsg = group.querySelector('.error-message');
        if (errorMsg) {
            errorMsg.style.display = 'none';
        }
    });
    
    form.querySelectorAll('.form-control').forEach(input => {
        input.classList.remove('error', 'success');
    });
}
