'use strict';

const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  const http = require('http');
  
  const data = JSON.stringify({
    userName: 'fred'
  })
  const options = {
    port: 8080, 
    host: 'http://user-service.k8s-quickstart',
    method: 'GET',
    path: '/',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  }
  const request = http.request(options, res =>    {
    console.log(`statusCode: ${res.statusCode}`)
    if (res.statusCode !== 200) {
      console.error(`Did not get an OK from the server. Code: ${res.statusCode}`);
      res.resume();
      return;
    }
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    res.on('close', ()=>{
      console.log(JSON.parse(response))
    })
  });
  request.on('error', (err) => {
    console.error(`Encountered an error trying to make a request: ${err.message}`);
  });
  request.write(data)
  request.on('response', function (response) {
    res.send(JSON.parse(response));
  });
  request.end()
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);