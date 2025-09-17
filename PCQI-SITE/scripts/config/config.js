const url = 'https://pcqi-api.onrender.com/';

function callApi(){
  return fetch(url)
    .then(response => {
      if (response.ok) {
        return response.json();
      } else {
        throw new Error('API request failed');
      }
    });
}

callApi();