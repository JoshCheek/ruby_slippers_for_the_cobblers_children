import {request} from 'http';

export default function parse(rawCode, cb) {
  // HTTP code largely lifted from https://nodejs.org/api/http.html#http_http_request_options_callback
  const options = {
    hostname: 'localhost',
    port:     3003,
    path:     '/',
    method:   'POST',
    headers: { 'Content-Length': rawCode.length }
  }

  // append cunks to the response, parse them as JSON at the end of the request
  let responseBody = ''
  const req = request(options, (res) => {
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
