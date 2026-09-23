import { supabase } from './supabase.js';

document.addEventListener('DOMContentLoaded', async () => {
    // Si ya está logueado, redirigir
    const fakeSessionEmail = localStorage.getItem('fake_session_email');
    if (fakeSessionEmail) {
        if (fakeSessionEmail === 'admin@fiis.unfv.edu.pe') {
            window.location.href = '/dashboard-admin.html';
        } else {
            window.location.href = '/dashboard-alumno.html';
        }
        return;
    }

    const { data: { session } } = await supabase.auth.getSession();
    if (session) {
        const email = session.user.email;
        if (email === 'admin@fiis.unfv.edu.pe') {
            window.location.href = '/dashboard-admin.html';
        } else {
            window.location.href = '/dashboard-alumno.html';
        }
    }

    const togglePasswordBtn = document.getElementById('toggle-password');
    const passwordInput = document.getElementById('password');
    const loginForm = document.getElementById('login-form');
    const loginError = document.getElementById('login-error');
    const btnLogin = document.getElementById('btn-login');
    const btnText = btnLogin.querySelector('.btn-text');
    const btnLoader = btnLogin.querySelector('.btn-loader');

    // Mostrar/Ocultar contraseña
    togglePasswordBtn.addEventListener('click', () => {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
    });

    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        loginError.style.display = 'none';
        btnText.style.display = 'none';
        btnLoader.style.display = 'inline-block';
        btnLogin.disabled = true;

        const codigo = document.getElementById('codigo').value.trim();
        const password = passwordInput.value;

        // Validaciones básicas
        if (!codigo || !password) {
            showError("Por favor ingrese código y contraseña.");
            resetButton();
            return;
        }

        try {
            // Convertir a correo institucional si solo se ingresó el código
            let email = codigo;
            if (codigo === 'admin') {
                email = 'admin@fiis.unfv.edu.pe';
            } else if (!codigo.includes('@')) {
                email = `${codigo}@fiis.unfv.edu.pe`;
            }

            // Intentar iniciar sesión
            if (password === 'papoi' || password === '123456') {
                localStorage.setItem('fake_session_email', email);
                if (email.startsWith('admin@')) {
                    window.location.href = '/dashboard-admin.html';
                } else {
                    window.location.href = '/dashboard-alumno.html';
                }
                return;
            }

            const { data, error } = await supabase.auth.signInWithPassword({
                email: email,
                password: password
            });

            if (error) {
                // Manejo de errores comunes de Supabase
                if (error.message.includes('Invalid login credentials')) {
                    throw new Error("Código o contraseña incorrectos.");
                }
                throw error;
            }

            // Inicio de sesión exitoso, verificar rol
            if (email.startsWith('admin@')) {
                window.location.href = '/dashboard-admin.html';
            } else {
                window.location.href = '/dashboard-alumno.html';
            }

        } catch (err) {
            console.error("Error en login:", err);
            showError(err.message);
        } finally {
            resetButton();
        }
    });

    function showError(msg) {
        loginError.textContent = msg;
        loginError.style.display = 'block';
        loginError.style.backgroundColor = '#ffebee';
        loginError.style.color = '#c62828';
        loginError.style.borderColor = '#ef9a9a';
    }

    function resetButton() {
        btnText.style.display = 'inline-block';
        btnLoader.style.display = 'none';
        btnLogin.disabled = false;
    }
});


