import { supabase } from './supabase.js';

export async function checkAuth(requiredRole = null) {
    let email = localStorage.getItem('fake_session_email');
    
    if (!email) {
        const { data: { session }, error } = await supabase.auth.getSession();

        if (error || !session) {
            // No está logueado
            window.location.href = '/index.html';
            return null;
        }
        email = session.user.email;
    }

    let userRole = 'alumno';
    
    // Nuestro administrador maestro
    if (email === 'admin@fiis.unfv.edu.pe') {
        userRole = 'admin';
    }

    // Proteger las rutas
    if (requiredRole && userRole !== requiredRole) {
        console.warn(`Acceso denegado. Rol requerido: ${requiredRole}, Rol actual: ${userRole}`);
        // Redirigir al panel correspondiente si intenta acceder a un lugar prohibido
        if (userRole === 'admin') {
            window.location.href = '/dashboard-admin.html';
        } else {
            window.location.href = '/dashboard-alumno.html';
        }
        return null;
    }

    // Obtener datos del alumno si no es admin
    let userData = {
        role: userRole,
        codigo: email.split('@')[0],
        alumnoInfo: null
    };

    if (userRole === 'alumno') {
        // Buscar al alumno en la base de datos usando el código extraído del correo
        const { data: alumnoData, error: alumnoError } = await supabase
            .from('alumno')
            .select('*, escuela(nom_escuela), plan_estudio(nombre_plan)')
            .eq('cod_alumno', userData.codigo)
            .single();
            
        if (alumnoError && alumnoError.code !== 'PGRST116') {
            console.error("Error obteniendo datos del alumno:", alumnoError);
            alert("Error DB (Alumno): " + JSON.stringify(alumnoError));
        } else if (!alumnoData) {
            // Test if it's a join issue or RLS issue
            const { data: testData, error: testError } = await supabase.from('alumno').select('*').eq('cod_alumno', userData.codigo);
            if (testError || !testData || testData.length === 0) {
                alert("Error DB (Test Alumno vacio o RLS): " + JSON.stringify(testError || "No data"));
            } else {
                alert("Error DB: El alumno existe pero falló el join con escuela/plan_estudio. Verifica la consola.");
            }
        }
        
        userData.alumnoInfo = alumnoData;
    }

    return userData;
}

export async function logout() {
    localStorage.removeItem('fake_session_email');
    const { error } = await supabase.auth.signOut();
    if (error) {
        console.error("Error al cerrar sesión:", error);
    }
    window.location.href = '/index.html';
}


