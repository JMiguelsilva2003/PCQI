function formatDate(isoString) {
    if (!isoString) return 'N/A';
    const date = new Date(isoString);
    return date.toLocaleString("pt-BR", {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

async function setupProfilePage() {
    const accessToken = localStorage.getItem('accessToken');
    if (!accessToken) {
        console.error("Auth Guard: Nenhum token encontrado. Redirecionando...");
        window.location.href = '/PCQI-SITE/screens/index.html';
        return;
    }

    let user;
    try {
        user = await getUserData(accessToken);
    } catch (error) {
        console.error("Sessão inválida ou expirada:", error.message);
        localStorage.clear();
        window.location.href = "/PCQI-SITE/screens/index.html";
        return;
    }

    await loadHTML('/PCQI-SITE/components/header.html', 'header-container');
    await new Promise(resolve => setTimeout(resolve, 0));

    initializeHeaderComponent(user);
    
    if (user) {
        await loadHTML('/PCQI-SITE/components/userInfo.html', 'user-info-container');
        await new Promise(resolve => setTimeout(resolve, 0));
        
        document.getElementById("user-name").textContent = user.name;
        document.getElementById("user-email").textContent = user.email;
        document.getElementById("user-created").textContent = formatDate(user.created_at);
        document.getElementById("user-role").textContent = user.role;
    }
}

document.addEventListener("DOMContentLoaded", setupProfilePage);