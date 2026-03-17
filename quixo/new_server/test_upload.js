const http = require('http');
const FormData = require('form-data');
const fs = require('fs');

const form = new FormData();
form.append('token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZGU1NDBlZTk0NmI4OTllYTU2MTdlNyIsImlhdCI6MTc3MzA1MTg1NSwiZXhwIjoxNzczMTM4MjU1fQ.MOCK'); // Mock token
form.append('name', 'Test Debug');
form.append('brand', '');
form.append('shortDescription', '');
form.append('description', '');
form.append('pricePerUnit', '150');
form.append('unit', 'piece');
form.append('discount', '0');
form.append('stock', '50');
form.append('type', 'quick');
form.append('product catagory (link to category id)', 'null');

const req = http.request({
    hostname: 'localhost',
    port: 5000,
    path: '/api/vender/product/add',
    method: 'POST',
    headers: form.getHeaders()
}, res => {
    let data = '';
    res.on('data', d => data += d);
    res.on('end', () => console.log('Response:', data));
});

form.pipe(req);
