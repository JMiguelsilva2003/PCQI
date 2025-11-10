const API_BASE_URL = 'https://pcqi-api.onrender.com';


function callApi(){
  return fetch(API_BASE_URL)
    .then(response => {
      if (response.ok) {
        return response.json();
      } else {
        throw new Error('API request failed');
      }
    });
}

callApi();