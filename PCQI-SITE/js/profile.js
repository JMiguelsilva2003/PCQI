document.addEventListener("DOMContentLoaded", async () => {
    const headerContainer = document.getElementById("header-container");
    if (headerContainer) {
        await loadHTML("/components/dashboardHeader.html", "header-container");
    }

    const token = localStorage.getItem("accessToken");
    if (!token) {
        window.location.href = "/screens/index.html";
        return;
    }

    try {
        await loadUserProfile(token);
    } catch (error) {
        console.error("Erro ao carregar perfil:", error);
        if (!localStorage.getItem("sessionExpiredAlert")) {
            alert("Sessão expirada ou inválida. Faça login novamente.");
            localStorage.setItem("sessionExpiredAlert", "true");
        }
        localStorage.removeItem("accessToken");
        window.location.href = "/screens/index.html";
    }
});

async function loadUserProfile(token) {
    localStorage.removeItem("sessionExpiredAlert");

    const user = await getUserData(token);
    
    let mySectors = [];
    try {
        const allSectors = await getSectors(token);
        
        if (user.role === 'admin') {
            mySectors = allSectors;
        } else {
            mySectors = allSectors.filter(sector => 
                sector.members.some(member => member.id === user.id)
            );
        }
    } catch (e) {
        console.warn("Não foi possível carregar setores (verifique se Machine_api.js está importado)", e);
    }

    const elName = document.getElementById("display-name");
    const elEmail = document.getElementById("display-email");
    const elRole = document.getElementById("display-role");

    if (elName) elName.textContent = user.name;
    if (elEmail) elEmail.textContent = user.email;
    if (elRole) elRole.textContent = user.role === 'admin' ? 'Administrador' : 'Colaborador';
    
    const elSectorCount = document.getElementById("stat-sectors-count");
    const elMachineCount = document.getElementById("stat-machines-count");

    if (elSectorCount) elSectorCount.textContent = mySectors.length;
    
    if (elMachineCount) {
        const totalMachines = mySectors.reduce((acc, sec) => acc + (sec.machines ? sec.machines.length : 0), 0);
        elMachineCount.textContent = totalMachines;
    }

    const sectorsList = document.getElementById("my-sectors-list");
    if (sectorsList) {
        sectorsList.innerHTML = "";

        if (mySectors.length === 0) {
            sectorsList.innerHTML = "<p style='color: #7f8c8d;'>Você não está vinculado a nenhum setor.</p>";
        } else {
            mySectors.forEach(sector => {
                const badge = document.createElement("div");
                badge.className = "sector-badge";
                badge.textContent = sector.name;
                badge.title = sector.description || "Sem descrição";
                sectorsList.appendChild(badge);
            });
        }
    }

    initializeHeaderLocal(user);

    const formPass = document.getElementById("form-change-password");
    if (formPass) {
        formPass.addEventListener("submit", (e) => {
            e.preventDefault();
            const newPass = document.getElementById("new-password").value;
            if(newPass.length < 6) {
                alert("A senha deve ter no mínimo 6 caracteres.");
                return;
            }
            alert("Solicitação enviada! (Funcionalidade simulada para MVP)");
            document.getElementById("new-password").value = "";
        });
    }
}

function initializeHeaderLocal(user) {
    const nameElement = document.getElementById("perfil-display");
    if (nameElement) {
        const names = user.name.split(' ');
        const shortName = names[0] + (names.length > 1 ? ' ' + names[names.length - 1] : '');
        nameElement.textContent = shortName;
    }

    const roleElement = document.getElementById("perfil-role");
    if (roleElement) {
        roleElement.textContent = user.role === 'admin' ? 'Administrador' : 'Colaborador';
        
        if(user.role === 'admin') {
            const avatar = document.querySelector('.profile-avatar');
            if(avatar) avatar.style.backgroundColor = '#27ae60';
        }
    }

    // Configura Botão Sair
    const logoutBtn = document.getElementById("logout-button");
    if (logoutBtn) {
        const newBtn = logoutBtn.cloneNode(true);
        logoutBtn.parentNode.replaceChild(newBtn, logoutBtn);
        
        newBtn.addEventListener("click", (e) => {
            e.stopPropagation();
            if(confirm("Deseja realmente sair?")) {
                localStorage.clear();
                window.location.href = "/screens/index.html";
            }
        });
    }
}