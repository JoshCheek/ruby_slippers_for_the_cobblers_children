class User
  def initialize(name)
    self.name = name
  end

  def name
    @name
  end

  def name=(name)
    @name = name
  end
end

user = User.new("Josh")
puts user.name
------------------------------

# vm tracks
#   rObject, rClass, rString, rNil, rTrue, rFalse
#   currentBinding, toplevelBinding
#
# Things you can do:
#   declare a "register machine" (hash of key/value pairs, values may be symbols, arrays, hashes)
#   load from World into registers:
#   load register into target

start
running
  expressions ->
    class :User ->
      find the class ->
        find namespace (none exists, so Object)
        find superclass (none exists, so Object)
        within namespace, look at constants for :User
        :User dne ->
          create a new Class
          set superclass to Object since it is not provided
          set its name to cref::name
        return User
      open User ->
        push binding (self: User, deftarget: User, returnValue: nil)
        push User onto crefs
      eval body ->
        def (3x) ->
          in deftarget (User), look at the instance methods
          set the method name as the key
          set the code as the body
        set bindings return value to method name
      close User ->
        pop the binding
        set next bindings return value
    set local :user ->
      get locals
      initialize variable ->
        look up :user in locals
        it dne -> set it to nil
      eval rhs ->
        send User.new("Josh") ->
          lookup constant ->
            no namespace, so start in Object
            look at its constants
            we find :User
            set returnValue
          receiver = returnValue
          eval args ->
            "Josh" ->
              create new string
              set return value
          lookup method ->
            follow receivers class pointer to get Class
            set methods to Users instance methods
            lookup :new
            find it
            create binding
              match arg names to values
              set these as locals on the binding
              set self to be User
              set returnValue to be nil
            push binding
            eval code -> ...
            pop binding, copy return value
      set local :user to equal current return value
    send :puts
     true literal
     string literal
     send
       eval target
         ->

teardown
  -> at_exit hooks
     report errors
     close streams and things
     set exit status

finish
