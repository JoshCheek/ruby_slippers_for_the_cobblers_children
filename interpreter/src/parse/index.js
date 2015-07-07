let http = require('http')

module.exports = parse
function parse(rawCode, cb) {
  // HTTP code largely lifted from https://nodejs.org/api/http.html#http_http_request_options_callback
  let responseBody = ''
  let options = {
    hostname: 'localhost',
    port:     3003,
    path:     '/',
    method:   'POST',
    headers: { 'Content-Length': rawCode.length }
  }

  var req = http.request(options, (res) => {
    res.setEncoding('utf8');
    res.on('data', (chunk) => responseBody += chunk)
    res.on('end',  ()      => cb(JSON.parse(responseBody)))
  })

  req.on('error', function(e) {
    console.log('problem with request: ' + e.message);
  })

  // write data to request body
  req.write(rawCode);
  req.end();
}
