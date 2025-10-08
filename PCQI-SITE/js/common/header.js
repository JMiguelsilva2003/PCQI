async function initializeHeader() {
    const perfilDisplay = document.getElementById("perfil-display");
    const logoutButton = document.getElementById("logout-button");

    if (!perfilDisplay || !logoutButton) {
        console.error("Elementos do header não encontrados!");
        return null;
    }

    const accessToken = localStorage.getItem("accessToken");
    if (!accessToken) {
        window.location.href = "/PCQI-SITE/screens/index.html";
        return null;
    }

    logoutButton.addEventListener("click", () => {
        localStorage.clear();
        window.location.href = "/PCQI-SITE/screens/index.html";
    });

    try {
        const userData = await getUserData(accessToken);
        
        perfilDisplay.textContent = userData.name;
        perfilDisplay.style.cursor = "pointer";
        perfilDisplay.addEventListener("click", () => {
            window.location.href = "/PCQI-SITE/screens/user-profile.html";
        });
        
        return userData;

    } catch (error) {
        console.error("Sessão inválida ou expirada:", error.message);
        alert("Sua sessão expirou. Por favor, faça login novamente.");
        localStorage.clear();
        window.location.href = "/PCQI-SITE/screens/index.html";
        return null;
    }
}