async function initializeHeaderComponent(user) {
    const perfilDisplay = document.getElementById("perfil-display");
    const logoutButton = document.getElementById("logout-button");

    if (!perfilDisplay || !logoutButton) {
        console.error("Elementos do header (perfil-display ou logout-button) não encontrados!");
        return;
    }

    if (user && user.name) {
        perfilDisplay.textContent = user.name;
        perfilDisplay.style.cursor = "pointer";
        perfilDisplay.addEventListener("click", () => {
            window.location.href = "/PCQI-SITE/screens/user-profile.html";
        });
    } else {
        perfilDisplay.textContent = "Usuário";
    }

    logoutButton.addEventListener("click", () => {
        localStorage.clear(); 
        window.location.href = "/PCQI-SITE/screens/index.html";
    });

    console.log("Componente Header inicializado.");
}