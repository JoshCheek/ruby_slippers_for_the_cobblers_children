
# line 1 "f.rl"

# line 15 "f.rl"

# %

def parse(data)
  headers = []
  stack   = []
  eof     = data.length
  
# line 14 "f.rb"
class << self
	attr_accessor :_foo_actions
	private :_foo_actions, :_foo_actions=
end
self._foo_actions = [
	0, 1, 1, 1, 2, 1, 3, 1, 
	4, 1, 5, 1, 6, 2, 0, 7
]

class << self
	attr_accessor :_foo_key_offsets
	private :_foo_key_offsets, :_foo_key_offsets=
end
self._foo_key_offsets = [
	0, 0, 1, 2, 3, 4, 5, 6, 
	10, 11, 15
]

class << self
	attr_accessor :_foo_trans_keys
	private :_foo_trans_keys, :_foo_trans_keys=
end
self._foo_trans_keys = [
	101, 97, 100, 101, 114, 58, 33, 63, 
	97, 122, 72, 10, 32, 97, 122, 0
]

class << self
	attr_accessor :_foo_single_lengths
	private :_foo_single_lengths, :_foo_single_lengths=
end
self._foo_single_lengths = [
	0, 1, 1, 1, 1, 1, 1, 2, 
	1, 2, 0
]

class << self
	attr_accessor :_foo_range_lengths
	private :_foo_range_lengths, :_foo_range_lengths=
end
self._foo_range_lengths = [
	0, 0, 0, 0, 0, 0, 0, 1, 
	0, 1, 0
]

class << self
	attr_accessor :_foo_index_offsets
	private :_foo_index_offsets, :_foo_index_offsets=
end
self._foo_index_offsets = [
	0, 0, 2, 4, 6, 8, 10, 12, 
	16, 18, 22
]

class << self
	attr_accessor :_foo_trans_targs
	private :_foo_trans_targs, :_foo_trans_targs=
end
self._foo_trans_targs = [
	2, 0, 3, 0, 4, 0, 5, 0, 
	6, 0, 8, 0, 10, 9, 7, 0, 
	1, 0, 9, 9, 7, 0, 9, 9, 
	0
]

class << self
	attr_accessor :_foo_trans_actions
	private :_foo_trans_actions, :_foo_trans_actions=
end
self._foo_trans_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 7, 0, 0, 
	0, 0, 11, 9, 0, 0, 13, 13, 
	0
]

class << self
	attr_accessor :_foo_to_state_actions
	private :_foo_to_state_actions, :_foo_to_state_actions=
end
self._foo_to_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	3, 3, 0
]

class << self
	attr_accessor :_foo_from_state_actions
	private :_foo_from_state_actions, :_foo_from_state_actions=
end
self._foo_from_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 5, 0
]

class << self
	attr_accessor :_foo_eof_trans
	private :_foo_eof_trans, :_foo_eof_trans=
end
self._foo_eof_trans = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 24
]

class << self
	attr_accessor :foo_start
end
self.foo_start = 8;
class << self
	attr_accessor :foo_first_final
end
self.foo_first_final = 8;
class << self
	attr_accessor :foo_error
end
self.foo_error = 0;

class << self
	attr_accessor :foo_en_header
end
self.foo_en_header = 9;
class << self
	attr_accessor :foo_en_main
end
self.foo_en_main = 8;


# line 23 "f.rl"
  # %
  
# line 144 "f.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = foo_start
	top = 0
	ts = nil
	te = nil
	act = 0
end

# line 25 "f.rl"
  # %
  
# line 158 "f.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_acts = _foo_from_state_actions[cs]
	_nacts = _foo_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _foo_actions[_acts - 1]
			when 3 then
# line 1 "NONE"
		begin
ts = p
		end
# line 192 "f.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _foo_key_offsets[cs]
	_trans = _foo_index_offsets[cs]
	_klen = _foo_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _foo_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _foo_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _foo_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _foo_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _foo_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	end
	if _goto_level <= _eof_trans
	cs = _foo_trans_targs[_trans]
	if _foo_trans_actions[_trans] != 0
		_acts = _foo_trans_actions[_trans]
		_nacts = _foo_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _foo_actions[_acts - 1]
when 0 then
# line 7 "f.rl"
		begin
 puts "BANG!" 		end
when 1 then
# line 11 "f.rl"
		begin

    headers << []
    	begin
		stack[top] = cs
		top+= 1
		cs = 9
		_trigger_goto = true
		_goto_level = _again
		break
	end

  		end
when 4 then
# line 7 "f.rl"
		begin
te = p+1
 begin  headers.last << data[ts...te]  end
		end
when 5 then
# line 8 "f.rl"
		begin
te = p+1
		end
when 6 then
# line 9 "f.rl"
		begin
te = p+1
 begin  	begin
		top -= 1
		cs = stack[top]
		_trigger_goto = true
		_goto_level = _again
		break
	end
  end
		end
when 7 then
# line 7 "f.rl"
		begin
te = p
p = p - 1; begin  headers.last << data[ts...te]  end
		end
# line 307 "f.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _foo_to_state_actions[cs]
	_nacts = _foo_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _foo_actions[_acts - 1]
when 2 then
# line 1 "NONE"
		begin
ts = nil;		end
# line 327 "f.rb"
		end # to state action switch
	end
	if _trigger_goto
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	if _foo_eof_trans[cs] > 0
		_trans = _foo_eof_trans[cs] - 1;
		_goto_level = _eof_trans
		next;
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 27 "f.rl"
  # %
  headers
end


result = parse <<-HEADERS
Header: abc! def?
Header: ghi? jkl!
HEADERS

p result
