// Test script to verify JSONBin connection
const https = require('https');

const JSONBIN_API_KEY = process.env.JSONBIN_API_KEY || '$2a$10$bHE2iH7WlxTIMY1tqo/T..kc9UqGDzF8kIbv3WRzz/1AuZZsIk9uS';
const JSONBIN_BIN_ID = process.env.JSONBIN_BIN_ID || '6a10c8ac6877513b27b87c94';

console.log('🧪 Testing JSONBin Connection...');
console.log('API Key:', JSONBIN_API_KEY ? '✅ Present' : '❌ Missing');
console.log('Bin ID:', JSONBIN_BIN_ID ? '✅ Present' : '❌ Missing');
console.log('');

const url = `https://api.jsonbin.io/v3/b/${JSONBIN_BIN_ID}/latest`;

https.get(url, {
  headers: {
    'X-Master-Key': JSONBIN_API_KEY
  }
}, (response) => {
  let data = '';
  
  response.on('data', (chunk) => {
    data += chunk;
  });
  
  response.on('end', () => {
    console.log('📦 Response Status:', response.statusCode);
    console.log('📦 Response Data:');
    
    try {
      const parsed = JSON.parse(data);
      console.log(JSON.stringify(parsed.record || parsed, null, 2));
      
      if (response.statusCode === 200 || response.statusCode === 202) {
        console.log('\n✅ JSONBin connection SUCCESSFUL!');
      } else {
        console.log('\n❌ JSONBin connection FAILED!');
        console.log('Error:', data);
      }
    } catch (error) {
      console.log('❌ Parse error:', error.message);
      console.log('Raw data:', data);
    }
  });
}).on('error', (error) => {
  console.log('❌ Connection error:', error.message);
});
