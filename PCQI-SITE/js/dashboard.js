async function setupDashboard() {
    await loadHTML('/PCQI-SITE/components/header.html', 'header-container');
    const user = await initializeHeader();
    if (!user) return;

    await Promise.all([
        loadHTML("/PCQI-SITE/components/dashboardList.html", "list-dashboard"),
        loadHTML("/PCQI-SITE/components/dashboardComponent.html", "component-dashboard"),
    ]);

    const screen = document.querySelector(".screen");
    const tabsContainer = document.querySelector(".tabs");
    const newTabBtn = document.getElementById("newtab");
    
    let loadedSectors = [];

    const renderMachineList = (sector) => {
        let machineHTML = `<h3>Máquinas no Setor: ${sector.name}</h3>`;
        
        if (sector.machines.length === 0) {
            machineHTML += '<p>Nenhuma máquina cadastrada neste setor.</p>';
        } else {
            machineHTML += '<div class="machine-grid">';
            sector.machines.forEach(machine => {
                machineHTML += `
                    <div class="machine-card">
                        <h4>${machine.name}</h4>
                        <p><strong>ID da Máquina:</strong> ${machine.id}</p>
                        <p><strong>ID do Criador:</strong> ${machine.creator_id}</p>
                    </div>
                `;
            });
            machineHTML += '</div>';
        }
        screen.innerHTML = machineHTML;
    };
    
    const createTab = (sector) => {
        const tab = document.createElement("div");
        tab.classList.add("tab");
        tab.textContent = sector.name;

        tabsContainer.insertBefore(tab, newTabBtn);

        tab.addEventListener("click", () => {
            document.querySelectorAll(".tab").forEach(t => t.classList.remove("active"));
            tab.classList.add("active");
            renderMachineList(sector);
        });
    };

    const loadSectorsAsTabs = async () => {
        screen.innerHTML = '<p>Carregando seus setores...</p>';
        try {
            const accessToken = localStorage.getItem('accessToken');
            loadedSectors = await getSectors(accessToken);

            document.querySelectorAll(".tab").forEach(t => t.remove());

            if (loadedSectors.length === 0) {
                screen.innerHTML = '<p>Nenhum setor encontrado. Crie um novo para começar.</p>';
                return;
            }
            
            loadedSectors.forEach(sector => createTab(sector));
            
            const firstTab = tabsContainer.querySelector(".tab");
            if(firstTab) {
                firstTab.classList.add("active");
                renderMachineList(loadedSectors[0]);
            }

        } catch (error) {
            screen.innerHTML = `<p style="color:red;">Erro ao carregar setores: ${error.message}</p>`;
        }
    };
    
    if (newTabBtn && user.role === 'admin') {
        newTabBtn.classList.add('admin-visible');
        newTabBtn.addEventListener("click", async () => {
            const newSectorName = prompt("Digite o nome do novo setor:");
            if (newSectorName) {
                try {
                    const accessToken = localStorage.getItem('accessToken');
                    await createSector(accessToken, newSectorName, "");
                    await loadSectorsAsTabs();
                } catch(error) {
                    alert(`Erro ao criar setor: ${error.message}`);
                }
            }
        });
    }

    await loadSectorsAsTabs();
}

document.addEventListener("DOMContentLoaded", setupDashboard);