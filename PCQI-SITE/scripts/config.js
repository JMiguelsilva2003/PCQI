const url = 'CONNECTION-STRING';

function callApi(){
    fetch(url)
        .then(response => {
        if (response.ok) {
        return response.json();
        } else {
        throw new Error('API request failed');
        }
    })
    .then(data => {
        // faça o que quiser com o response aqui
        console.log('DADOS DA API', data);
    })
    .catch(error => {
        // crie o handler de error aqui
        console.log('ERRO NA CHAMADA', error);
    });
}

callApi();