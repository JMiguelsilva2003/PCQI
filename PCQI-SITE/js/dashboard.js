let currentAccessToken = null;
let allSectorsCache = [];

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

  btnVerMaquinas.addEventListener("click", async () => {
    setActiveButton(btnVerMaquinas);
    await loadHTML("/components/viewMachines.html", "component-dashboard");
    await new Promise((resolve) => setTimeout(resolve, 0));
    renderMachinesView(contentContainer, user);
  });

  btnVerStats.addEventListener("click", async () => {
    setActiveButton(btnVerStats);
    await loadHTML("/components/viewStatistics.html", "component-dashboard");
    await new Promise((resolve) => setTimeout(resolve, 0));
    renderStatisticsView(contentContainer, user);
  });

  if (user.role === "admin") {
    btnVerPerfis.addEventListener("click", async () => {
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
    machineHTML +=
      '<div class="machine-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1rem;">';
    sector.machines.forEach((machine) => {
      machineHTML += `
                <div class="machine-card" style="background: #fff; border: 1px solid #ccc; border-radius: 4px; padding: 1rem;">
                    <h4>${machine.name}</h4>
                    <p style="font-size: 1.2rem; color: #555;">ID: ${machine.id}</p>
                    <button class="delete-machine" 
                        data-machine-id = "${machine.id}">
                        excluir 
                    </button>
                </div>
            `;
    });
    machineHTML += "</div>";
  }

  let membersHTML = "";

  if (user.role === "admin" && sector.members) {
    membersHTML = `<h3 style="margin-top: 2rem;">Membros no Setor: ${sector.name}</h3>`;

    if (sector.members.length === 0) {
      membersHTML += "<p>Nenhum membro cadastrado neste setor.</p>";
    } else {
      membersHTML +=
        '<div class="member-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1rem;">';
      sector.members.forEach((member) => {
        membersHTML += `
                    <div class="member-card" style="background: #fff; border: 1px solid #ccc; border-radius: 4px; padding: 1rem;">
                        <h4>${member.name || "Nome não disponível"}</h4>
                        <p style="font-size: 1.2rem; color: #555;">${
                          member.email || "Email não disponível"
                        }</p>
                    </div>
                `;
      });
      membersHTML += "</div>";
    }
  }

  screenElement.innerHTML = machineHTML + membersHTML;

    screenElement.querySelectorAll(".delete-machine").forEach((button) => {
      button.addEventListener("click", async (e) => {
        const machineId = e.target.dataset.machineId;
        const machineCard = e.target.closest(".machine-card");
        const machineName = machineCard.querySelector("h4").textContent;

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

    screen.innerHTML = "";

    users.forEach((user) => {
      const card = document.createElement("div");
      card.className = "profile-card";

      let sectorOptions = '<option value="">Adicionar ao Setor...</option>';
      allSectors.forEach((sector) => {
        sectorOptions += `<option value="${sector.id}">${sector.name}</option>`;
      });

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
                    <div class="info-item">
                        <span>Ações</span>
                        <div style="display: flex; flex-wrap: wrap; gap: 1rem; align-items: center;">
                            <button class="promote-btn" 
                                data-user-id="${user.id}" 
                                ${user.role === "admin" ? "disabled" : ""}>
                                ${user.role === "admin" ? "Já é Admin" : "Promover"}
                            </button>
                            <select class="add-to-sector-select" data-user-id="${user.id}" style="padding: 0.8rem; border-radius: 6px;">
                                ${sectorOptions}
                            </select>
                            
                            <button class="delete-btn logout-btn" 
                                data-user-id="${user.id}" 
                                data-user-name="${user.name}"
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
        if (
          confirm(
            `Tem certeza que deseja promover o usuário ${userId} a admin?`
          )
        ) {
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
        
        if (confirm(`Tem certeza que deseja deletar o usuário "${userName}" (ID: ${userId})? \n\nAtenção: esta ação não pode ser desfeita.`)) {
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
          e.target.value = "";
        } catch (error) {
          alert(`Erro ao adicionar ao setor: ${error.message}`);
        }
      });
    });
  } catch (error) {
    console.error("Erro ao carregar dados de admin:", error);
    screen.innerHTML = `<p style='color:red;'>Erro ao carregar dados: ${error.message}</p>`;
  }
}

async function renderStatisticsView(container, user) {
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

    const fetchAndRenderStats = async () => {
        loadingEl.style.display = "block";
        totalEl.textContent = "...";
        madurasEl.textContent = "...";
        verdesEl.textContent = "...";
        outrasEl.textContent = "...";

        const sectorId = sectorSelect.value === "all" ? null : sectorSelect.value;
        const machineId = machineSelect.value === "all" ? null : machineSelect.value;

        try {
            const stats = await getStats(currentAccessToken, sectorId, machineId);
            totalEl.textContent = stats.total;
            madurasEl.textContent = stats.maduras;
            verdesEl.textContent = stats.verdes;
            outrasEl.textContent = stats.outras;
            loadingEl.style.display = "none";
        } catch (error) {
            console.error("Erro ao buscar estatísticas:", error);
            loadingEl.style.display = "none";
            totalEl.textContent = "Erro";
            madurasEl.textContent = "Erro";
            verdesEl.textContent = "Erro";
            outrasEl.textContent = "Erro";
        }
    };

    filterBtn.addEventListener("click", fetchAndRenderStats);

    fetchAndRenderStats();

    function renderHistoryChart(data) {
    const ctx = document.getElementById('historyChart')?.getContext('2d');
    if (!ctx) return;

    // Destrói o gráfico antigo, se existir
    if (historyChartInstance) {
        historyChartInstance.destroy();
    }

    // Inverte os dados (API vem desc, gráfico precisa asc) e formata
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
                    borderColor: '#28a745', // Verde
                    backgroundColor: 'rgba(40, 167, 69, 0.1)',
                    fill: true,
                    tension: 0.1
                },
                {
                    label: 'Mangas Verdes',
                    data: verdesData,
                    borderColor: '#dc3545', // Vermelho
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
}


document.addEventListener("DOMContentLoaded", setupDashboard);