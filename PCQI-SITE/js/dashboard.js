document.addEventListener("DOMContentLoaded", async () => {
    await Promise.all([
        loadHTML("../components/dashboardHeader.html", "header-dashboard"),
        loadHTML("../components/dashboardList.html", "list-dashboard"),
        loadHTML("../components/dashboardComponent.html", "component-dashboard")
    ]);
});
