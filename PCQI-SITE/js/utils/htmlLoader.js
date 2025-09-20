async function loadHTML(url, elementId) {
    try {
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`Não foi possível carregar o componente: ${url}`);
        }
        const text = await response.text();
        document.getElementById(elementId).innerHTML = text;
    } catch (error) {
        console.error('Erro ao carregar HTML:', error);
    }
}