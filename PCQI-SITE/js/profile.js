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
    await loadHTML('/PCQI-SITE/components/header.html', 'header-container');
    
    const user = await initializeHeader();
    
    if (user) {
        await loadHTML('/PCQI-SITE/components/userInfo.html', 'user-info-container');
        
        document.getElementById("user-name").textContent = user.name;
        document.getElementById("user-email").textContent = user.email;
        document.getElementById("user-created").textContent = formatDate(user.created_at);
        document.getElementById("user-role").textContent = user.role;
    }
}

document.addEventListener("DOMContentLoaded", setupProfilePage);