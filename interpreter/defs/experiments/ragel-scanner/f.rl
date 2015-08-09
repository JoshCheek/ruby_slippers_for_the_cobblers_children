%%{
  # %
  machine foo;
  word      = [a-z]+;
  head_name = 'Header';
  header := |*
    word ("!" %{ puts "BANG!" } | "?") => { headers.last << data[ts...te] };
    ' ';
    '\n' => { fret; };
  *|;
  main := ( head_name ':' @{
    headers << []
    fcall header;
  } )*;
}%%
# %

def parse(data)
  headers = []
  stack   = []
  eof     = data.length
  %% write data;
  # %
  %% write init;
  # %
  %% write exec;
  # %
  headers
end


result = parse <<-HEADERS
Header: abc! def?
Header: ghi? jkl!
HEADERS

p result
