class Instructor
  attr_reader :name
  def initialize(name)
    @name = name
  end

  def teach(student)
    "#{@name} teaches #{student.name}"
  end
end

class LocalInstructor < Instructor
  def teach(student)
    super + ' from Turing'
  end
end

class RemoteInstructor < Instructor
  def teach(student)
    super + ' from afar'
  end
end

class Student
  def initialize(name)
    @name = name
  end

  def name
    # JSON OUTPUT IS TAKEN FROM HERE
    caller.map { |s| s[/[`]<?(.*?)>?[']/, 1] + ':' + s[/:(\d+):/, 1]} # => ["teach:8", "teach:14", "main:40"], ["main:98"], ["main:113"]
    @name
  end
end

carlos = Student.new 'Carlos'
josh   = LocalInstructor.new 'Josh'
sarah  = RemoteInstructor.new 'Sarah'

josh.teach(carlos) # => "Josh teaches Carlos from Turing"

# ==========  Data Structure  ==========
etcetera = 'etcetera'
{stack:[
  {context: 'main',                  line: 39, self: self.object_id,   locals: {carlos: carlos.object_id, josh: josh.object_id, sarah: sarah.object_id}},
  {context: 'LocalInstructor#teach', line: 19, self: josh.object_id,   locals: {student: carlos.object_id}},
  {context: 'Instructor#teach',      line: 18, self: josh.object_id,   locals: {student: carlos.object_id}},
  {context: 'Student#name',          line: 29, self: carlos.object_id, locals: {}},
 ],
 constant_namespace: {
   Object:           Object.object_id,
   Class:            Class.object_id,
   Instructor:       Instructor.object_id,
   RemoteInstructor: RemoteInstructor.object_id,
   LocalInstructor:  LocalInstructor.object_id,
   String:           String.object_id,
 },
 objects: {
   Object.object_id => {
      class:              Class.object_id,
      superclass:         etcetera,
      instance_variables: {},
      methods:            [],
    },
   Class.object_id => {
     class:              Class.object_id,
     superclass:         etcetera,
     instance_variables: {},
     methods:            [:allocate, :new, :superclass],
   },
   Instructor.object_id => {
     class:              Class.object_id,
     superclass:         Object.object_id,
     instance_variables: {},
     methods:            [:initialize, :teach, :name],
   },
   RemoteInstructor.object_id => {
     class:              Class.object_id,
     superclass:         Instructor.object_id,
     instance_variables: {},
     methods:            [:teach],
   },
   LocalInstructor.object_id => {
      class:              Class.object_id,
      superclass:         Instructor.object_id,
      instance_variables: {},
      methods:            [:teach],
    },
   String.object_id => {
     class:              Class.object_id,
     superclass:         Object.object_id,
     instance_variables: {},
     methods:            [etcetera],
   },
   carlos.object_id => {
     class: Student.object_id,
     instance_variables: {
       :@name => carlos.name.object_id,
     },
   },
   josh.object_id => {
     class: RemoteInstructor.object_id,
     instance_variables: {
       :@name => josh.name.object_id,
     },
   },
   sarah.object_id => {
     class: LocalInstructor.object_id,
     instance_variables: {
       :@name => sarah.name.object_id
     },
   },
  carlos.name.object_id => {class: String.object_id, instance_variables: {}},
  josh.name.object_id   => {class: String.object_id, instance_variables: {}},
  sarah.name.object_id  => {class: String.object_id, instance_variables: {}},
 },
}
# => {:stack=>
#      [{:context=>"main",
#        :line=>39,
#        :self=>70222727959040,
#        :locals=>
#         {:carlos=>70222736319760,
#          :josh=>70222736319700,
#          :sarah=>70222736319660}},
#       {:context=>"LocalInstructor#teach",
#        :line=>19,
#        :self=>70222736319700,
#        :locals=>{:student=>70222736319760}},
#       {:context=>"Instructor#teach",
#        :line=>18,
#        :self=>70222736319700,
#        :locals=>{:student=>70222736319760}},
#       {:context=>"Student#name",
#        :line=>29,
#        :self=>70222736319760,
#        :locals=>{}}],
#     :constant_namespace=>
#      {:Object=>70222727961540,
#       :Class=>70222727961460,
#       :Instructor=>70222736320900,
#       :RemoteInstructor=>70222736320340,
#       :LocalInstructor=>70222736320520,
#       :String=>70222727957300},
#     :objects=>
#      {70222727961540=>
#        {:class=>70222727961460,
#         :superclass=>"etcetera",
#         :instance_variables=>{},
#         :methods=>[]},
#       70222727961460=>
#        {:class=>70222727961460,
#         :superclass=>"etcetera",
#         :instance_variables=>{},
#         :methods=>[:allocate, :new, :superclass]},
#       70222736320900=>
#        {:class=>70222727961460,
#         :superclass=>70222727961540,
#         :instance_variables=>{},
#         :methods=>[:initialize, :teach, :name]},
#       70222736320340=>
#        {:class=>70222727961460,
#         :superclass=>70222736320900,
#         :instance_variables=>{},
#         :methods=>[:teach]},
#       70222736320520=>
#        {:class=>70222727961460,
#         :superclass=>70222736320900,
#         :instance_variables=>{},
#         :methods=>[:teach]},
#       70222727957300=>
#        {:class=>70222727961460,
#         :superclass=>70222727961540,
#         :instance_variables=>{},
#         :methods=>["etcetera"]},
#       70222736319760=>
#        {:class=>70222736320040,
#         :instance_variables=>{:@name=>70222736319840}},
#       70222736319700=>
#        {:class=>70222736320340,
#         :instance_variables=>{:@name=>70222736319720}},
#       70222736319660=>
#        {:class=>70222736320520,
#         :instance_variables=>{:@name=>70222736319680}},
#       70222736319840=>{:class=>70222727957300, :instance_variables=>{}},
#       70222736319720=>{:class=>70222727957300, :instance_variables=>{}},
#       70222736319680=>{:class=>70222727957300, :instance_variables=>{}}}}
