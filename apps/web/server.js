'use strict';

const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  const http = require('http');
  
  const body = JSON.stringify({
    userName: 'fred'
  })
  const options = {
    port: 8080, 
    host: 'user-service.k8s-quickstart',
    method: 'GET',
    path: '/',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': body.length
    }
  }
  const request = http.request(options, response =>    {
    if (response.statusCode !== 200) {
      console.error(`Did not get an OK from the server. Code: ${response.statusCode}`);
      response.resume();
      return;
    }
    let data = '';
    response.on('data', (chunk) => {
      data += chunk;
    });
    response.on('close', ()=>{
      const greeting = JSON.parse(data)
      res.write('Greetings ' + greeting.Greeting)
      res.end()
    })
  });
  request.write(body)
  request.end()
  
  request.on('error', (err) => {
    console.error(`Encountered an error trying to make a request: ${err.message}`);
  });
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);