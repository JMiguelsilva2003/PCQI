async function registerUser(name, email, password) {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, email, password })
    });
    const data = await response.json();
    if (!response.ok) {
        throw new Error(data.detail || 'Erro no cadastro.');
    }
    return data;
}

async function loginUser(email, password) {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            'username': email,
            'password': password
        })
    });
    const data = await response.json();
    if (!response.ok) {
        throw new Error(data.detail || 'Erro no login.');
    }
    return data;
}

async function verifyEmailToken(token) {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/verify-email?token=${token}`, {
        method: 'GET',
    });
    
    const data = await response.json();

    if (!response.ok) {
        throw new Error(data.detail || 'Erro na verificação do token.');
    }
    return data;
}

async function requestPasswordReset(email) {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/forgot-password`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email })
    });
    const data = await response.json();
    if (!response.ok) {
        throw new Error(data.detail || 'Erro ao solicitar redefinição.');
    }
    return data;
}

async function resetPassword(token, newPassword) {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/reset-password`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token, new_password: newPassword })
    });
    const data = await response.json();
    if (!response.ok) {
        throw new Error(data.detail || 'Erro ao redefinir a senha.');
    }
    return data;
}