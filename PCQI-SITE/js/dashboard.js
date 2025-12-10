let currentAccessToken = null;
let allSectorsCache = [];
let statsInterval = null;

function stopStatsUpdate() {
  if (statsInterval) {
    clearInterval(statsInterval);
    statsInterval = null;
    console.log("Atualização em tempo real parada.");
  }
}

async function authGuardAndGetUserData() {
  const accessToken = localStorage.getItem("accessToken");

  if (!accessToken) {
    console.error(
      "Auth Guard: Nenhum token de acesso encontrado. Redirecionando..."
    );
    window.location.href = "/screens/index.html";
    return null;
  }

  currentAccessToken = accessToken;

  try {
    const userData = await getUserData(accessToken);
    console.log(
      "Auth Guard: Usuário autenticado:",
      userData.name,
      "Role:",
      userData.role
    );
    return userData;
  } catch (error) {
    console.error("Auth Guard: Token inválido ou expirado.", error);
    localStorage.clear();
    window.location.href = "/screens/index.html";
    return null;
  }
}

async function setupDashboard() {
  const userData = await authGuardAndGetUserData();
  if (!userData) return;

  try {
    await Promise.all([
      loadHTML("/components/dashboardHeader.html", "header-dashboard"),
      loadHTML("/components/dashboardList.html", "list-dashboard"),
    ]);

    await new Promise((resolve) => setTimeout(resolve, 0));
  } catch (error) {
    console.error("Erro ao carregar componentes base (Header/List):", error);
    document.body.innerHTML =
      "<h1>Erro ao carregar a página. Tente novamente.</h1>";
    return;
  }

  initializeHeaderComponent(userData);
  setupNavigation(userData);

  const contentContainer = document.getElementById("component-dashboard");
  await loadHTML("/components/viewMachines.html", "component-dashboard");

  await new Promise((resolve) => setTimeout(resolve, 0));

  renderMachinesView(contentContainer, userData);
}

function initializeHeaderComponent(user) {
  const nameElement = document.getElementById("perfil-display");
  if (nameElement) {
      const names = user.name.split(' ');
      const shortName = names[0] + (names.length > 1 ? ' ' + names[names.length - 1] : '');
      nameElement.textContent = shortName;
  }

  const roleElement = document.getElementById("perfil-role");
  if (roleElement) {
      const roleName = user.role === 'admin' ? 'Administrador' : 'Colaborador';
      roleElement.textContent = roleName;
      
      if(user.role === 'admin') {
          const avatar = document.querySelector('.profile-avatar');
          if(avatar) avatar.style.backgroundColor = '#27ae60';
      }
  }

  const profileCard = document.querySelector(".profile-card");
  
  if (profileCard) {
      profileCard.addEventListener("click", () => {
          window.location.href = "/screens/user-profile.html"; 
      });
  }

  const logoutBtn = document.getElementById("logout-button");
  if (logoutBtn) {
      const newBtn = logoutBtn.cloneNode(true);
      logoutBtn.parentNode.replaceChild(newBtn, logoutBtn);
      
      newBtn.addEventListener("click", (e) => {
          e.stopPropagation(); 
          
          if(confirm("Deseja realmente sair do sistema?")) {
              localStorage.clear();
              window.location.href = "/screens/index.html";
          }
      });
  }
}

function setupNavigation(user) {
  const btnVerMaquinas = document.getElementById("btn-ver-maquinas");
  const btnVerPerfis = document.getElementById("btn-ver-perfis");
  const btnVerStats = document.getElementById("btn-ver-estatisticas");
  const contentContainer = document.getElementById("component-dashboard");

  const navButtons = [btnVerMaquinas, btnVerPerfis, btnVerStats].filter(Boolean);

  function setActiveButton(activeBtn) {
    navButtons.forEach(btn => btn.classList.remove("active"));
    if (activeBtn) activeBtn.classList.add("active");
  }

  if (user.role === "admin") {
    btnVerPerfis.style.display = "block";
  }

  //  Botão Ver Máquinas
  btnVerMaquinas.addEventListener("click", async () => {
    stopStatsUpdate();
    setActiveButton(btnVerMaquinas);
    await loadHTML("/components/viewMachines.html", "component-dashboard");
    await new Promise((resolve) => setTimeout(resolve, 0));
    renderMachinesView(contentContainer, user);
  });

  //  Botão Estatísticas
  btnVerStats.addEventListener("click", async () => {
    setActiveButton(btnVerStats);
    await loadHTML("/components/viewStatistics.html", "component-dashboard");
    await new Promise((resolve) => setTimeout(resolve, 0));
    renderStatisticsView(contentContainer, user);
  });

  //  Botão Ver Perfis (Admin) 
  if (user.role === "admin") {
    btnVerPerfis.addEventListener("click", async () => {
      stopStatsUpdate();
      setActiveButton(btnVerPerfis);
      await loadHTML("/components/viewProfiles.html", "component-dashboard");
      await new Promise((resolve) => setTimeout(resolve, 0));
      renderProfilesView(contentContainer);
    });
  }
}

async function renderMachinesView(container, user) {
  const tabsContainer = container.querySelector(".tabs");
  const screen = container.querySelector("#machines-screen-content");
  const newTabBtn = container.querySelector("#newtab");

  if (!tabsContainer || !screen || !newTabBtn) {
    console.error("Estrutura do component 'viewMachines.html' não encontrada.");
    return;
  }

  try {
    screen.innerHTML = `
        <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 200px; color: #7f8c8d;">
            <div class="spinner" style="border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; width: 30px; height: 30px; animation: spin 1s linear infinite; margin-bottom: 10px;"></div>
            <p>Carregando setores...</p>
        </div>
        <style>@keyframes spin {0% {transform: rotate(0deg);} 100% {transform: rotate(360deg);}}</style>
    `;

    const sectors = await getSectors(currentAccessToken);
    allSectorsCache = sectors; 

    tabsContainer.innerHTML = "";

    if (sectors.length === 0) {
      screen.innerHTML = `
        <div style="text-align: center; padding: 3rem; color: #95a5a6;">
            <p>Nenhum setor encontrado.</p>
            <p style="font-size: 0.9rem;">Clique no "+" acima para criar o primeiro setor.</p>
        </div>
      `;
    } else {
      sectors.forEach((sector, index) => {
        const tab = document.createElement("div");
        tab.classList.add("tab");
        tab.dataset.sectorId = sector.id;

        const tabName = document.createElement("span");
        tabName.textContent = sector.name;
        tab.appendChild(tabName);

        if (user.role === "admin") {
            const deleteSectorBtn = document.createElement("button");
            deleteSectorBtn.textContent = "✕";
            deleteSectorBtn.classList.add("delete-sector-btn");
            deleteSectorBtn.title = `Deletar setor ${sector.name}`;
            
            deleteSectorBtn.addEventListener("click", async (e) => {
                e.stopPropagation();
                if (confirm(`Tem certeza que deseja deletar o setor "${sector.name}"?`)) {
                    try {
                        await deleteSector(currentAccessToken, sector.id);
                        alert("Setor deletado com sucesso!");
                        renderMachinesView(container, user);
                    } catch (error) {
                        alert(`Erro ao deletar setor: ${error.message}`);
                    }
                }
            });
            tab.appendChild(deleteSectorBtn);
        }

        tabsContainer.appendChild(tab);

        tab.addEventListener("click", (e) => {
          if (e.target.classList.contains("delete-sector-btn")) return;
          tabsContainer.querySelectorAll(".tab").forEach((t) => t.classList.remove("active"));
          tab.classList.add("active");
          
          renderMachineList(screen, sector, user);
        });

        if (index === 0) {
          tab.click();
        }
      });
    }
  } catch (error) {
    console.error("Erro ao carregar setores:", error);
    screen.innerHTML = `<p style='color:red; padding: 1rem;'>Erro de conexão: ${error.message}</p>`;
  }

  if (user.role === "admin") {
    newTabBtn.style.display = "flex"; 
    const newBtnClone = newTabBtn.cloneNode(true);
    newTabBtn.parentNode.replaceChild(newBtnClone, newTabBtn);

    newBtnClone.addEventListener("click", async () => {
        const newSectorName = prompt("Nome do novo setor:");
        if (newSectorName && newSectorName.trim()) {
            const newSectorDesc = prompt("Descrição (opcional):");
            try {
                await createSector(currentAccessToken, newSectorName, newSectorDesc || "");
                renderMachinesView(container, user); 
            } catch (error) {
                alert(`Erro ao criar setor: ${error.message}`);
            }
        }
    });
  } else {
      newTabBtn.style.display = "none";
  }

  const btnCriarMaquina = container.querySelector("#btn-criar-maquina");
  if(btnCriarMaquina) {
      const btnClone = btnCriarMaquina.cloneNode(true);
      btnCriarMaquina.parentNode.replaceChild(btnClone, btnCriarMaquina);
      
      btnClone.addEventListener("click", async () => {
        await loadHTML("/components/formCreateMachine.html", "machines-screen-content");
        await new Promise((resolve) => setTimeout(resolve, 0));
        renderCreateMachineForm(container, user);
      });
  }
}

function renderMachineList(screenElement, sector, user) {
  let contentHTML = "";

  contentHTML += `<div style="margin-bottom: 1.5rem;">
      <h3 style="color: #2c3e50; font-size: 1.4rem;">${sector.name}</h3>
      <p style="color: #7f8c8d; font-size: 0.95rem;">${sector.description || 'Sem descrição definida.'}</p>
  </div>`;

  if (!sector.machines || sector.machines.length === 0) {
    contentHTML += `
        <div style="text-align: center; padding: 3rem; color: #95a5a6; background: #fdfdfd; border: 2px dashed #eee; border-radius: 12px;">
            <p style="font-size: 1.1rem; margin-bottom: 1rem;">Este setor ainda não possui máquinas.</p>
            <p style="font-size: 0.9rem;">Clique em "Criar Nova Máquina" abaixo para começar.</p>
        </div>
    `;
  } else {
    contentHTML += '<div class="machine-grid">';
    
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

    sector.machines.forEach((machine) => {
      const isOnline = machine.last_heartbeat && new Date(machine.last_heartbeat) > fiveMinutesAgo;
      const statusClass = isOnline ? "online" : "offline";
      const statusText = isOnline ? "ONLINE" : "OFFLINE";

      contentHTML += `
        <div class="machine-card ${statusClass}">
            <div class="machine-header">
                <div class="machine-info">
                    <h4>${machine.name}</h4>
                    <p class="machine-id">ID: #${machine.id}</p>
                </div>
                <div class="status-badge ${statusClass}">
                    <span class="status-dot"></span>
                    ${statusText}
                </div>
            </div>
            
            <div style="flex-grow: 1;">
                 <p style="font-size: 0.8rem; color: #aaa;">
                    Último sinal: ${machine.last_heartbeat ? new Date(machine.last_heartbeat).toLocaleTimeString() : 'Nunca'}
                 </p>
            </div>

            <div class="card-actions">
                <button class="action-btn btn-edit edit-machine" 
                    data-machine-id="${machine.id}"
                    data-machine-name="${machine.name}">
                    Editar
                </button>
                <button class="action-btn btn-delete delete-machine" 
                    data-machine-id="${machine.id}"
                    data-machine-name="${machine.name}">
                    Excluir
                </button>
            </div>
        </div>
      `;
    });
    contentHTML += "</div>";
  }

  screenElement.innerHTML = contentHTML;

  screenElement.querySelectorAll(".delete-machine").forEach((button) => {
    button.addEventListener("click", async (e) => {
      const machineId = e.target.dataset.machineId;
      const machineName = e.target.dataset.machineName;
      const machineCard = e.target.closest(".machine-card");

      if (confirm(`Tem certeza que deseja deletar a máquina "${machineName}"?`)) {
        try {
          await deleteMachine(currentAccessToken, machineId);
          machineCard.style.opacity = "0";
          setTimeout(() => machineCard.remove(), 300);
        } catch (error) {
          alert(`Erro ao deletar: ${error.message}`);
        }
      }
    });
  });

  screenElement.querySelectorAll(".edit-machine").forEach((button) => {
    button.addEventListener("click", async (e) => {
      const machineId = e.target.dataset.machineId;
      const oldName = e.target.dataset.machineName;
      const machineCard = e.target.closest(".machine-card");

      const newName = prompt(`Novo nome para "${oldName}":`, oldName);

      if (newName && newName.trim() !== "" && newName !== oldName) {
        try {
          await updateMachineName(currentAccessToken, machineId, newName.trim());
          machineCard.querySelector("h4").textContent = newName;
          e.target.dataset.machineName = newName;
        } catch (error) {
          alert(`Erro ao atualizar: ${error.message}`);
        }
      }
    });
  });
}

async function renderCreateMachineForm(viewContainer, user) {
  const form = document.getElementById("form-create-machine");
  const selectSector = document.getElementById("machine-sector");
  const btnCancelar = document.getElementById("btn-cancelar-criacao");

  if (!form || !selectSector || !btnCancelar) {
    console.error(
      "Erro: Elementos do formulário de criação de máquina não encontrados."
    );
    return;
  }

  if (allSectorsCache.length > 0) {
    selectSector.innerHTML = '<option value="">Selecione um setor</option>';
    allSectorsCache.forEach((sector) => {
      selectSector.innerHTML += `<option value="${sector.id}">${sector.name}</option>`;
    });
  } else {
    selectSector.innerHTML =
      '<option value="">Nenhum setor encontrado</option>';
  }

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const machineName = document.getElementById("machine-name").value;
    const sectorId = selectSector.value;

    if (!machineName || !sectorId) {
      alert("Por favor, preencha todos os campos.");
      return;
    }

    try {
      await createMachine(currentAccessToken, machineName, parseInt(sectorId));
      alert("Máquina criada com sucesso!");
      document.getElementById("btn-ver-maquinas").click();
    } catch (error) {
      console.error("Erro ao criar máquina:", error);
      alert(`Erro ao criar máquina: ${error.message}`);
    }
  });

  btnCancelar.addEventListener("click", () => {
    document.getElementById("btn-ver-maquinas").click();
  });
}

async function renderProfilesView(container) {
  const screen = container.querySelector("#profiles-container");

  if (!screen) {
    console.error("Erro: Contêiner de perfis '#profiles-container' não encontrado.");
    return;
  }
  screen.innerHTML = "<p>Carregando usuários e setores...</p>";

  try {
    const [users, allSectors] = await Promise.all([
      getAllUsers(currentAccessToken),
      getSectors(currentAccessToken), 
    ]);

    const userSectorMap = {};
    allSectors.forEach((sector) => {
        sector.members.forEach((member) => {
            if (!userSectorMap[member.id]) {
                userSectorMap[member.id] = [];
            }
            userSectorMap[member.id].push({ id: sector.id, name: sector.name });
        });
    });

    screen.innerHTML = "";

    users.forEach((user) => {
      const card = document.createElement("div");
      card.className = "admin-user-card";

      let sectorOptions = '<option value="">Adicionar ao Setor...</option>';
      allSectors.forEach((sector) => {
        sectorOptions += `<option value="${sector.id}">${sector.name}</option>`;
      });

      const userSectors = userSectorMap[user.id] || [];
      let userSectorsHTML = '<div class="info-item"><span>Membro dos Setores</span>';
      
      if (userSectors.length > 0) {
        userSectorsHTML += '<ul class="sector-membership-list">';
        userSectors.forEach(sector => {
            userSectorsHTML += `
                <li>
                    <span>${sector.name}</span>
                    <button class="remove-from-sector-btn" 
                            data-user-id="${user.id}" 
                            data-sector-id="${sector.id}"
                            data-user-name="${user.name}"
                            data-sector-name="${sector.name}"
                            title="Remover ${user.name} do setor ${sector.name}">
                        ✕
                    </button>
                </li>`;
        });
        userSectorsHTML += '</ul>';
      } else {
        userSectorsHTML += "<span>Nenhum setor vinculado</span>";
      }
      userSectorsHTML += '</div>';

      card.innerHTML = `
        <div class="info-grid">
            <div class="info-item">
                <span>Nome</span>
                <span>${user.name}</span>
            </div>
            <div class="info-item">
                <span>Email</span>
                <span>${user.email}</span>
            </div>
            <div class="info-item">
                <span>Permissão</span>
                <span style="color: ${user.role === 'admin' ? '#d35400' : '#2c3e50'}; font-weight: bold;">
                    ${user.role.toUpperCase()}
                </span>
            </div>
            
            ${userSectorsHTML} 

            <div class="info-item">
                <span>Gerenciar</span>
                <select class="add-to-sector-select" data-user-id="${user.id}" style="padding: 0.6rem; border-radius: 6px; border: 1px solid #ccc; width: 100%;">
                    ${sectorOptions}
                </select>
            </div>

            <div class="info-item">
                <span>Ações</span>
                <div style="display: flex; gap: 0.5rem; margin-top: 5px;">
                    <button class="promote-btn" 
                        data-user-id="${user.id}" 
                        style="flex: 1; padding: 8px; background: #3498db; color: white; border: none; border-radius: 4px; cursor: pointer;"
                        ${user.role === "admin" ? "disabled" : ""}>
                        ${user.role === "admin" ? "Admin" : "Promover"}
                    </button>
                    
                    <button class="delete-btn" 
                        data-user-id="${user.id}" 
                        data-user-name="${user.name}"
                        style="flex: 1; padding: 8px; background: #e74c3c; color: white; border: none; border-radius: 4px; cursor: pointer;"
                        ${user.role === "admin" ? "disabled" : ""}>
                        Excluir
                    </button>
                </div>
            </div>
        </div>
      `;
      screen.appendChild(card);
    });

    screen.querySelectorAll(".promote-btn").forEach((button) => {
      button.addEventListener("click", async (e) => {
        const userId = e.target.dataset.userId;
        if (confirm(`Tem certeza que deseja promover o usuário ${userId} a admin?`)) {
          try {
            await promoteUser(currentAccessToken, userId);
            alert("Usuário promovido com sucesso!");
            renderProfilesView(container); 
          } catch (error) {
            alert(`Erro ao promover: ${error.message}`);
          }
        }
      });
    });

    screen.querySelectorAll(".delete-btn").forEach((button) => {
      button.addEventListener("click", async (e) => {
        const userId = e.target.dataset.userId;
        const userName = e.target.dataset.userName;
        
        if (confirm(`Tem certeza que deseja deletar o usuário "${userName}" (ID: ${userId})?`)) {
          try {
            await deleteUser(currentAccessToken, userId);
            alert("Usuário removido com sucesso!");
            e.target.closest(".admin-user-card").remove();
          } catch (error) {
            alert(`Erro ao deletar: ${error.message}`);
          }
        }
      });
    });

    screen.querySelectorAll(".add-to-sector-select").forEach((select) => {
      select.addEventListener("change", async (e) => {
        const sectorId = e.target.value;
        const userId = e.target.dataset.userId;
        if (!sectorId) return;

        try {
          await addUserToSector(currentAccessToken, sectorId, userId);
          alert(`Usuário ${userId} adicionado ao setor com sucesso!`);
          renderProfilesView(container);
        } catch (error) {
          alert(`Erro ao adicionar ao setor: ${error.message}`);
          e.target.value = "";
        }
      });
    });

    screen.querySelectorAll(".remove-from-sector-btn").forEach((button) => {
        button.addEventListener("click", async (e) => {
            const userId = e.target.dataset.userId;
            const sectorId = e.target.dataset.sectorId;
            const userName = e.target.dataset.userName;
            const sectorName = e.target.dataset.sectorName;

            if (confirm(`Tem certeza que deseja remover "${userName}" do setor "${sectorName}"?`)) {
                try {
                    await removeUserFromSector(currentAccessToken, sectorId, userId);
                    alert("Membro removido com sucesso!");
                    renderProfilesView(container); 
                } catch (error) {
                    alert(`Erro ao remover: ${error.message}`);
                }
            }
        });
    });

  } catch (error) {
    console.error("Erro ao carregar dados de admin:", error);
    screen.innerHTML = `<p style='color:red;'>Erro ao carregar dados: ${error.message}</p>`;
  }
}

let historyChartInstance = null;
let performanceChartInstance = null;

async function renderStatisticsView(container, user) {
    stopStatsUpdate();

    const loadingEl = container.querySelector("#stats-loading");
    const totalEl = container.querySelector("#stats-total");
    const madurasEl = container.querySelector("#stats-maduras");
    const verdesEl = container.querySelector("#stats-verdes");
    const outrasEl = container.querySelector("#stats-outras");

    const sectorSelect = container.querySelector("#stats-filter-sector");
    const machineSelect = container.querySelector("#stats-filter-machine");
    const filterBtn = container.querySelector("#btn-apply-filter");

    if (allSectorsCache.length > 0) {
        sectorSelect.innerHTML = '<option value="all">Todos os Setores</option>';
        allSectorsCache.forEach(sector => {
            sectorSelect.innerHTML += `<option value="${sector.id}">${sector.name}</option>`;
        });
    }

    sectorSelect.addEventListener("change", () => {
        const sectorId = sectorSelect.value;
        machineSelect.innerHTML = '<option value="all">Todas as Máquinas</option>';
        
        if (sectorId !== "all") {
            const selectedSector = allSectorsCache.find(s => s.id == sectorId);
            if (selectedSector && selectedSector.machines) {
                selectedSector.machines.forEach(machine => {
                    machineSelect.innerHTML += `<option value="${machine.id}">${machine.name}</option>`;
                });
            }
        }
    });

    const updateAllData = async (isFirstLoad = false) => {
        const sectorId = sectorSelect.value === "all" ? null : sectorSelect.value;
        const machineId = machineSelect.value === "all" ? null : machineSelect.value;

        if (isFirstLoad) loadingEl.style.display = "block";

        try {
            const stats = await getStats(currentAccessToken, sectorId, machineId);
            totalEl.textContent = stats.total;
            madurasEl.textContent = stats.maduras;
            verdesEl.textContent = stats.verdes;
            outrasEl.textContent = stats.outras;

            const historyData = await getStatsHistory(currentAccessToken, 7);
            renderHistoryChart(historyData);

            const performanceData = await getStatsPerformance(currentAccessToken);
            renderPerformanceChart(performanceData);

        } catch (error) {
            console.error("Erro na atualização automática:", error);
            if (isFirstLoad) {
                totalEl.textContent = "Erro";
                loadingEl.innerHTML = `<p style="color:red">Falha de conexão.</p>`;
            }
        } finally {
            if (isFirstLoad) {
                loadingEl.style.display = "none";
                const histLoad = container.querySelector("#history-loading");
                const perfLoad = container.querySelector("#performance-loading");
                if(histLoad) histLoad.style.display = "none";
                if(perfLoad) perfLoad.style.display = "none";
            }
        }
    };

    filterBtn.addEventListener("click", () => {
        stopStatsUpdate();
        updateAllData(true);
        statsInterval = setInterval(() => updateAllData(false), 3000);
    });

    await updateAllData(true);
    statsInterval = setInterval(() => {
        updateAllData(false);
    }, 3000);
}

function renderHistoryChart(data) {
    const ctx = document.getElementById('historyChart')?.getContext('2d');
    if (!ctx) return;

    if (historyChartInstance) {
        historyChartInstance.destroy();
    }

    const labels = data.map(item => item.date).reverse();
    const madurasData = data.map(item => item.maduras).reverse();
    const verdesData = data.map(item => item.verdes).reverse();

    historyChartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Mangas Maduras',
                    data: madurasData,
                    borderColor: '#28a745',
                    backgroundColor: 'rgba(40, 167, 69, 0.1)',
                    fill: true,
                    tension: 0.1
                },
                {
                    label: 'Mangas Verdes',
                    data: verdesData,
                    borderColor: '#dc3545',
                    backgroundColor: 'rgba(220, 53, 69, 0.1)',
                    fill: true,
                    tension: 0.1
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
        }
    });
}

function renderPerformanceChart(data) {
    const ctx = document.getElementById('performanceChart')?.getContext('2d');
    if (!ctx) return;

    if (performanceChartInstance) {
        performanceChartInstance.destroy();
    }

    const labels = data.map(item => item.machine_name);
    const madurasData = data.map(item => item.maduras);
    const verdesData = data.map(item => item.verdes);

    performanceChartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Maduras (Aceitas)',
                    data: madurasData,
                    backgroundColor: '#28a745',
                },
                {
                    label: 'Verdes (Rejeitadas)',
                    data: verdesData,
                    backgroundColor: '#dc3545',
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: { stacked: true },
                y: { stacked: true, beginAtZero: true }
            }
        }
    });
}


document.addEventListener("DOMContentLoaded", setupDashboard);