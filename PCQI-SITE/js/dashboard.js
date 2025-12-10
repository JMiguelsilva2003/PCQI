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
  const btnCriarMaquina = container.querySelector("#btn-criar-maquina");
  const newTabBtn = container.querySelector("#newtab");

  if (!tabsContainer || !screen || !btnCriarMaquina || !newTabBtn) {
    console.error("Estrutura do component 'viewMachines.html' não encontrada.");
    if (screen) {
      screen.innerHTML =
        "<p style='color:red;'>Erro ao carregar o componente.</p>";
    }
    return;
  }

  try {
    screen.innerHTML = "<p>Carregando seus setores...</p>";
    const sectors = await getSectors(currentAccessToken);
    allSectorsCache = sectors; 

    tabsContainer.querySelectorAll(".tab").forEach((tab) => tab.remove());

    if (sectors.length === 0) {
      screen.innerHTML =
        "<p>Nenhum setor encontrado. Crie um novo para começar.</p>";
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
            deleteSectorBtn.textContent = "X";
            deleteSectorBtn.classList.add("delete-sector-btn");
            deleteSectorBtn.title = `Deletar setor ${sector.name}`;
            
            deleteSectorBtn.addEventListener("click", async (e) => {
                e.stopPropagation(); 
                
                if (confirm(`Tem certeza que deseja deletar o setor "${sector.name}"? \n\nAVISO: Setores com máquinas não podem ser deletados.`)) {
                    try {
                        await deleteSector(currentAccessToken, sector.id);
                        alert("Setor deletado com sucesso!");
                        tab.remove();
                        
                        const firstTab = tabsContainer.querySelector(".tab");
                        if (firstTab) firstTab.click();
                        else screen.innerHTML = "<p>Nenhum setor encontrado.</p>";

                    } catch (error) {
                        alert(`Erro ao deletar setor: ${error.message}`);
                    }
                }
            });
            tab.appendChild(deleteSectorBtn);
        }

        tabsContainer.insertBefore(tab, newTabBtn);

        tab.addEventListener("click", (e) => {
          if (e.target.classList.contains("delete-sector-btn")) return;

          tabsContainer
            .querySelectorAll(".tab")
            .forEach((t) => t.classList.remove("active"));
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
    screen.innerHTML = `<p style='color:red;'>Erro ao carregar setores: ${error.message}</p>`;
  }

  if (user.role === "admin") {
    newTabBtn.classList.add("admin-visible");

    if (!newTabBtn.dataset.listenerAttached) {
      newTabBtn.dataset.listenerAttached = "true";

      newTabBtn.addEventListener("click", async () => {
        const newSectorName = prompt(
          "Digite o nome do novo setor (obrigatório):"
        );

        if (newSectorName) {
          const newSectorDesc = prompt(
            "Digite a descrição do setor (opcional):"
          );

          try {
            await createSector(
              currentAccessToken,
              newSectorName,
              newSectorDesc || ""
            );
            renderMachinesView(container, user); 
          } catch (error) {
            alert(`Erro ao criar setor: ${error.message}`);
          }
        }
      });
    }
  }

  btnCriarMaquina.addEventListener("click", async () => {
    await loadHTML(
      "/components/formCreateMachine.html",
      "machines-screen-content"
    );
    await new Promise((resolve) => setTimeout(resolve, 0));
    renderCreateMachineForm(container, user);
  });
}

function renderMachineList(screenElement, sector, user) {
  let machineHTML = `<h3>Máquinas no Setor: ${sector.name}</h3>`;

  if (sector.description) {
    machineHTML += `<p class="sector-description">${sector.description}</p>`;
  }
  machineHTML += `<h4 style="margin-top: 1rem;">Máquinas:</h4>`;

  if (!sector.machines || sector.machines.length === 0) {
    machineHTML += "<p>Nenhuma máquina cadastrada neste setor.</p>";
  } else {
    machineHTML += '<div class="machine-grid">';
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

    sector.machines.forEach((machine) => {
      const isOnline = machine.last_heartbeat && new Date(machine.last_heartbeat) > fiveMinutesAgo;
      const statusClass = isOnline ? "online" : "offline";
      const statusText = isOnline ? "Online" : "Offline";

      machineHTML += `
        <div class="machine-card">
            <div class="status-indicator ${statusClass}" title="Status: ${statusText}"></div>
            
            <h4>${machine.name}</h4>
            <p style="font-size: 1.2rem; color: #555;">ID: ${machine.id}</p>
            
            <div class="card-actions">
                <button class="edit-machine action-btn" 
                    data-machine-id="${machine.id}"
                    data-machine-name="${machine.name}">
                    Editar
                </button>
                <button class="delete-machine" 
                    data-machine-id="${machine.id}"
                    data-machine-name="${machine.name}">
                    Excluir 
                </button>
            </div>
        </div>
      `;
    });
    machineHTML += "</div>";
  }

  screenElement.innerHTML = machineHTML;
  screenElement.querySelectorAll(".delete-machine").forEach((button) => {
    button.addEventListener("click", async (e) => {
      const machineId = e.target.dataset.machineId;
      const machineName = e.target.dataset.machineName;
      const machineCard = e.target.closest(".machine-card");

      if (confirm(`Tem certeza que deseja deletar a máquina "${machineName}" (ID: ${machineId})?`)) {
        try {
          await deleteMachine(currentAccessToken, machineId);
          alert("Máquina removida com sucesso!");
          machineCard.remove(); 
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

      const newName = prompt(`Digite o novo nome para a máquina "${oldName}":`, oldName);

      if (newName && newName.trim() !== "" && newName !== oldName) {
        try {
          await updateMachineName(currentAccessToken, machineId, newName.trim());
          alert("Nome atualizado com sucesso!");
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
    console.error(
      "Erro: Contêiner de perfis '#profiles-container' não encontrado."
    );
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
      card.className = "profile-card";

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
                        X
                    </button>
                </li>`;
        });
        userSectorsHTML += '</ul>';
      } else {
        userSectorsHTML += "<span>Nenhum</span>";
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
                <span>${user.role}</span>
            </div>
            
            ${userSectorsHTML} 

            <div class="info-item">
                <span>Adicionar ao Setor</span>
                <select class="add-to-sector-select" data-user-id="${user.id}" style="padding: 0.8rem; border-radius: 6px;">
                    ${sectorOptions}
                </select>
            </div>

            <div class="info-item">
                <span>Ações de Admin</span>
                <div style="display: flex; flex-wrap: wrap; gap: 1rem; align-items: center;">
                    <button class="promote-btn" 
                        data-user-id="${user.id}" 
                        ${user.role === "admin" ? "disabled" : ""}>
                        ${user.role === "admin" ? "Já é Admin" : "Promover"}
                    </button>
                    
                    <button class="delete-btn logout-btn" 
                        data-user-id="${user.id}" 
                        data-user-name="${user.name}"
                        ${user.role === "admin" ? "disabled" : ""}>
                        Excluir Usuário
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
            e.target.closest(".profile-card").remove();
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
          alert(`Usuário ${userId} adicionado ao setor ${sectorId}!`);
          renderProfilesView(container);
        } catch (error) {
          alert(`Erro ao adicionar ao setor: ${error.message}`);
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
                    e.target.closest("li").remove();
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