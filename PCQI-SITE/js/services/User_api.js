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

async function getUserData(token) {
    const response = await fetch(`${API_BASE_URL}/api/v1/users/me`, {
        method: 'GET',
        headers: {'Authorization': `Bearer ${token}`}
    });
    const data= await response.json();
    if (!response.ok){
        throw new Error(data.detail || 'Erro ao redefinir a senha.');
    }
    return data
}

async function getSectors(token) {
    const response = await fetch(`${API_BASE_URL}/api/v1/sectors/`, {
        method: 'GET',
        headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await response.json();
    if (!response.ok) {
        throw new Error(data.detail || 'Erro ao buscar setores.');
    }
    return data;
}

async function createSector(token, sectorName, sectorDescription) {
    const response = await fetch(`${API_BASE_URL}/api/v1/sectors/`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ name: sectorName, description: sectorDescription })
    });
    const data = await response.json();
    if (!response.ok) {
        throw new Error(data.detail || 'Erro ao criar setor.');
    }
    return data;
}

async function getAllUsers(token) {
    const response = await fetch(`${API_BASE_URL}/api/v1/admin/users`, {
        headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.detail || 'Erro ao buscar usuários.');
    return data;
}

async function promoteUser(token, userId) {
    const response = await fetch(`${API_BASE_URL}/api/v1/admin/users/${userId}/promote`, {
        method: 'PUT',
        headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.detail || 'Erro ao promover usuário.');
    return data;
}

async function addUserToSector(token, sectorId, userId) {
    const response = await fetch(`${API_BASE_URL}/api/v1/sectors/${sectorId}/members`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ user_id: userId })
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.detail || 'Erro ao adicionar membro ao setor.');
    return data;
}

async function createMachine(token, machineName, sectorId) {
    const response = await fetch(`${API_BASE_URL}/api/v1/machines/`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ name: machineName, sector_id: sectorId })
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.detail || 'Erro ao criar máquina.');
    return data;
}