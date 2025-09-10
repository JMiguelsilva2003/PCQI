const url = 'CONNECTION-STRING';

function callApi(){
  return fetch(url)
    .then(response => {
      if (response.ok) {
        return response;
      } else {
        throw new Error('API request failed');
      }
    });
}

callApi();