Node = Struct.new :type, :properties

def filename
  "/Users/josh/code/ruby_slippers_for_the_cobblers_children/experiments/node_modules/babel/node_modules/acorn-babel/acorn.js"
end

def fndef?(line)
  line && line =~ /function\s+parse/
end

def lengths(properties)
  keys, values = properties.transpose
  [ (keys   || ['']).map(&:length).max,
    (values || ['']).map(&:length).max,
  ]
end

def nodes
  @nodes ||= 
    File.read(filename)
        .lines
        .slice_before { |line| fndef? line }
        .select { |line, *|    fndef? line }
        .map { |defn, *body|
          Node.new defn.strip.split(/[^a-z]+/i)[1]['parse'.length..-1].downcase,
                   body.grep(/node\.\w+\s*=/)
                       .map { |line| line.strip
                                         .gsub(/^.*?node\./, "")
                                         .chomp(";")
                                         .split(/\s*=\s*/, 2)
                                         .map(&:strip)
                       }
        }
        .sort_by(&:type)
end

puts "=====  TYPES  ====="
nodes.each_slice 8 do |nodes|
  puts nodes.map(&:type).join(" ")
end
puts

puts "=====  WITH ATTRIBUTES  ====="
nodes.each do |node|
  klen, vlen = lengths node.properties
  format     = "  %-#{klen}s | %-#{vlen}s\n"
  puts node.type, node.properties.map { |key, value| format % [key, value] }
end

# >> =====  TYPES  =====
# >> arrowexpression assignablelistitemtypes await bindfunctionexpression bindingatom bindinglist block breakcontinuestatement
# >> class classimplements comprehension debuggerstatement declare declareclass declarefunction declaremodule
# >> declarevariable dostatement emptystatement export exportspecifiers expratom expression expressionstatement
# >> exprlist exprop exprops exprsubscripts for forin forstatement function
# >> functionbody functionparams functionstatement functiontypeparam functiontypeparams generictype ident ifstatement
# >> import importspecifierdefault importspecifiers interface interfaceextends interfaceish intersectiontype jsxattribute
# >> jsxattributevalue jsxclosingelementat jsxelement jsxelementat jsxelementname jsxemptyexpression jsxexpressioncontainer jsxidentifier
# >> jsxnamespacedname jsxopeningelementat labeledstatement maybeassign maybeconditional maybedefault maybeunary method
# >> new obj objectpropertykey objecttype objecttypecallproperty objecttypeindexer objecttypemethod objecttypemethodish
# >> parenanddistinguishexpression parenexpression postfixtype prefixtype primarytype private propertyname rest
# >> returnstatement spread statement subscripts switchstatement template templateelement throwstatement
# >> toplevel trystatement tupletype type typealias typeannotatableidentifier typeannotation typeoftype
# >> typeparameterdeclaration typeparameterinstantiation uniontype var varstatement voidtype whilestatement withstatement
# >> yield
# >> 
# >> =====  WITH ATTRIBUTES  =====
# >> arrowexpression
# >>   params | toAssignableList(params, true)
# >> assignablelistitemtypes
# >> await
# >>   all      | eat(_star)            
# >>   argument | parseMaybeAssign(true)
# >> bindfunctionexpression
# >>   callee    | parseSubscripts(parseExprAtom(), start, true)
# >>   arguments | parseExprList(_parenR, false)                
# >>   arguments | []                                           
# >> bindingatom
# >>   elements | parseBindingList(_bracketR, true)
# >> bindinglist
# >> block
# >>   body | []
# >> breakcontinuestatement
# >>   label | null                                     
# >>   label | parseIdent()                             
# >>   label | = null || lab.name === node.label.name) {
# >> class
# >>   id                  | tokType === _name ? parseIdent() : isStatement ? unexpected() : null
# >>   typeParameters      | parseTypeParameterDeclaration()                                     
# >>   superClass          | eat(_extends) ? parseExprSubscripts() : null                        
# >>   superTypeParameters | parseTypeParameterInstantiation()                                   
# >>   implements          | parseClassImplements()                                              
# >>   body                | finishNode(classBody, "ClassBody")                                  
# >> classimplements
# >>   id             | parseIdent()                     
# >>   typeParameters | parseTypeParameterInstantiation()
# >>   typeParameters | null                             
# >> comprehension
# >>   blocks    | []                                      
# >>   filter    | eat(_if) ? parseParenExpression() : null
# >>   body      | parseExpression()                       
# >>   generator | isGenerator                             
# >> debuggerstatement
# >> declare
# >> declareclass
# >> declarefunction
# >>   id | parseIdent()
# >> declaremodule
# >>   id   | parseExprAtom()
# >>   id   | parseIdent()   
# >>   body | startNode()    
# >> declarevariable
# >>   id | parseTypeAnnotatableIdentifier()
# >> dostatement
# >>   body | parseStatement(false) 
# >>   test | parseParenExpression()
# >> emptystatement
# >> export
# >>   declaration | parseStatement(true)                                
# >>   specifiers  | null                                                
# >>   source      | null                                                
# >>   declaration | expr                                                
# >>   specifiers  | null                                                
# >>   source      | null                                                
# >>   declaration | null                                                
# >>   specifiers  | parseExportSpecifiers()                             
# >>   source      | tokType === _string ? parseExprAtom() : unexpected()
# >>   source      | null                                                
# >> exportspecifiers
# >>   id   | parseIdent(tokType === _default)             
# >>   name | eatContextual("as") ? parseIdent(true) : null
# >> expratom
# >>   callee    | id                                                          
# >>   arguments | expr.expressions                                            
# >>   arguments | [expr]                                                      
# >>   regex     | {pattern: tokVal.pattern, flags: tokVal.flags}              
# >>   value     | tokVal.value                                                
# >>   raw       | input.slice(tokStart, tokEnd)                               
# >>   value     | tokVal                                                      
# >>   raw       | input.slice(tokStart, tokEnd)                               
# >>   value     | tokType.atomValue                                           
# >>   raw       | tokType.keyword                                             
# >>   elements  | parseExprList(_bracketR, true, true, refShorthandDefaultPos)
# >> expression
# >>   expressions | [expr]
# >> expressionstatement
# >>   expression | expr
# >> exprlist
# >> exprop
# >>   left     | left                                                                                
# >>   operator | tokVal                                                                              
# >>   right    | parseExprOp(parseMaybeUnary(), start, op.rightAssociative ? (prec - 1) : prec, noIn)
# >> exprops
# >> exprsubscripts
# >> for
# >>   init   | init                                          
# >>   test   | tokType === _semi ? null : parseExpression()  
# >>   update | tokType === _parenR ? null : parseExpression()
# >>   body   | parseStatement(false)                         
# >> forin
# >>   left  | init                 
# >>   right | parseExpression()    
# >>   body  | parseStatement(false)
# >> forstatement
# >> function
# >>   generator      | eat(_star)                     
# >>   id             | parseIdent()                   
# >>   typeParameters | parseTypeParameterDeclaration()
# >> functionbody
# >>   body       | parseMaybeAssign()
# >>   expression | true              
# >>   body       | parseBlock(true)  
# >>   expression | false             
# >> functionparams
# >>   params     | parseBindingList(_parenR, false)
# >>   returnType | parseTypeAnnotation()           
# >> functionstatement
# >> functiontypeparam
# >>   name           | parseIdent()
# >>   optional       | optional    
# >>   typeAnnotation | parseType() 
# >> functiontypeparams
# >> generictype
# >>   typeParameters | null                                        
# >>   id             | id                                          
# >>   id             | finishNode(node2, "QualifiedTypeIdentifier")
# >>   typeParameters | parseTypeParameterInstantiation()           
# >> ident
# >>   name | tokVal         
# >>   name | tokType.keyword
# >> ifstatement
# >>   test       | parseParenExpression()                   
# >>   consequent | parseStatement(false)                    
# >>   alternate  | eat(_else) ? parseStatement(false) : null
# >> import
# >>   isType     | false                                               
# >>   specifiers | []                                                  
# >>   isType     | true                                                
# >>   source     | parseExprAtom()                                     
# >>   source     | tokType === _string ? parseExprAtom() : unexpected()
# >> importspecifierdefault
# >>   id   | id  
# >>   name | null
# >> importspecifiers
# >>   name | parseIdent()                             
# >>   id   | parseIdent(true)                         
# >>   name | eatContextual("as") ? parseIdent() : null
# >> interface
# >> interfaceextends
# >>   id             | parseIdent()                     
# >>   typeParameters | parseTypeParameterInstantiation()
# >>   typeParameters | null                             
# >> interfaceish
# >>   id             | parseIdent()                   
# >>   typeParameters | parseTypeParameterDeclaration()
# >>   typeParameters | null                           
# >>   extends        | []                             
# >>   body           | parseObjectType(allowStatic)   
# >> intersectiontype
# >>   types | [type]
# >> jsxattribute
# >>   argument | parseMaybeAssign()                        
# >>   name     | parseJSXNamespacedName()                  
# >>   value    | eat(_eq) ? parseJSXAttributeValue() : null
# >> jsxattributevalue
# >> jsxclosingelementat
# >>   name | parseJSXElementName()
# >> jsxelement
# >> jsxelementat
# >>   openingElement | openingElement
# >>   closingElement | closingElement
# >>   children       | children      
# >> jsxelementname
# >> jsxemptyexpression
# >> jsxexpressioncontainer
# >>   expression | tokType === _braceR ? parseJSXEmptyExpression() : parseExpression()
# >> jsxidentifier
# >>   name | tokVal         
# >>   name | tokType.keyword
# >> jsxnamespacedname
# >>   namespace | name                
# >>   name      | parseJSXIdentifier()
# >> jsxopeningelementat
# >>   attributes  | []                   
# >>   name        | parseJSXElementName()
# >>   selfClosing | eat(_slash)          
# >> labeledstatement
# >>   body  | parseStatement(true)
# >>   label | expr                
# >> maybeassign
# >>   operator | tokVal                                     
# >>   left     | tokType === _eq ? toAssignable(left) : left
# >>   right    | parseMaybeAssign(noIn)                     
# >> maybeconditional
# >>   left       | toAssignable(expr)    
# >>   right      | parseMaybeAssign(noIn)
# >>   operator   | "?="                  
# >>   test       | expr                  
# >>   consequent | parseMaybeAssign()    
# >>   alternate  | parseMaybeAssign(noIn)
# >> maybedefault
# >>   operator | "="               
# >>   left     | left              
# >>   right    | parseMaybeAssign()
# >> maybeunary
# >>   operator | tokVal           
# >>   prefix   | true             
# >>   argument | parseMaybeUnary()
# >>   operator | == "delete" &&   
# >>   operator | tokVal           
# >>   prefix   | false            
# >>   argument | expr             
# >> method
# >>   generator | isGenerator
# >> new
# >>   callee    | parseSubscripts(parseExprAtom(), start, true)
# >>   arguments | parseExprList(_parenR, false)                
# >>   arguments | empty                                        
# >> obj
# >>   properties | []
# >> objectpropertykey
# >> objecttype
# >>   key      | propertyKey
# >>   value    | parseType()
# >>   optional | optional   
# >>   static   | isStatic   
# >> objecttypecallproperty
# >>   static | isStatic                           
# >>   value  | parseObjectTypeMethodish(valueNode)
# >> objecttypeindexer
# >>   static | isStatic                
# >>   id     | parseObjectPropertyKey()
# >>   key    | parseType()             
# >>   value  | parseType()             
# >> objecttypemethod
# >>   value    | parseObjectTypeMethodish(startNodeAt(start))
# >>   static   | isStatic                                    
# >>   key      | key                                         
# >>   optional | false                                       
# >> objecttypemethodish
# >>   params         | []                             
# >>   rest           | null                           
# >>   typeParameters | null                           
# >>   typeParameters | parseTypeParameterDeclaration()
# >>   rest           | parseFunctionTypeParam()       
# >>   returnType     | parseType()                    
# >> parenanddistinguishexpression
# >> parenexpression
# >> postfixtype
# >>   elementType | parsePrimaryType()
# >> prefixtype
# >>   typeAnnotation | parsePrefixType()
# >> primarytype
# >>   typeParameters | parseTypeParameterDeclaration()
# >>   params         | tmp.params                     
# >>   rest           | tmp.rest                       
# >>   returnType     | parseType()                    
# >>   params         | tmp.params                     
# >>   rest           | tmp.rest                       
# >>   returnType     | parseType()                    
# >>   typeParameters | null                           
# >>   value          | tokVal                         
# >>   raw            | input.slice(tokStart, tokEnd)  
# >> private
# >>   declarations | []
# >> propertyname
# >>   id         | null   
# >>   generator  | false  
# >>   expression | false  
# >>   async      | isAsync
# >> rest
# >>   argument | tokType === _name || tokType === _bracketL ? parseBindingAtom() : unexpected()
# >> returnstatement
# >>   argument | null                             
# >>   argument | parseExpression(); semicolon(); }
# >> spread
# >>   argument | parseMaybeAssign(refShorthandDefaultPos)
# >> statement
# >> subscripts
# >>   object    | base                         
# >>   property  | parseIdent(true)             
# >>   arguments | parseExprList(_parenR, false)
# >>   arguments | []                           
# >>   object    | base                         
# >>   property  | parseIdent(true)             
# >>   object    | base                         
# >>   property  | parseIdent(true)             
# >>   computed  | false                        
# >>   object    | base                         
# >>   property  | parseExpression()            
# >>   computed  | true                         
# >>   callee    | base                         
# >>   arguments | parseExprList(_parenR, false)
# >>   tag       | base                         
# >>   quasi     | parseTemplate()              
# >> switchstatement
# >>   discriminant | parseParenExpression()
# >>   cases        | []                    
# >> template
# >>   expressions | []      
# >>   quasis      | [curElt]
# >> templateelement
# >> throwstatement
# >>   argument | parseExpression()
# >> toplevel
# >>   body) node.body | []
# >> trystatement
# >>   block           | parseBlock()                       
# >>   handler         | null                               
# >>   handler         | finishNode(clause, "CatchClause")  
# >>   guardedHandlers | empty                              
# >>   finalizer       | eat(_finally) ? parseBlock() : null
# >> tupletype
# >>   types | []
# >> type
# >> typealias
# >>   id             | parseIdent()                   
# >>   typeParameters | parseTypeParameterDeclaration()
# >>   typeParameters | null                           
# >>   right          | parseType()                    
# >> typeannotatableidentifier
# >> typeannotation
# >>   typeAnnotation | parseType()
# >> typeoftype
# >>   argument | parsePrimaryType()
# >> typeparameterdeclaration
# >>   params | []
# >> typeparameterinstantiation
# >>   params | []
# >> uniontype
# >>   types | [type]
# >> var
# >>   declarations | []  
# >>   kind         | kind
# >> varstatement
# >> voidtype
# >> whilestatement
# >>   test | parseParenExpression()
# >>   body | parseStatement(false) 
# >> withstatement
# >>   object | parseParenExpression()
# >>   body   | parseStatement(false) 
# >> yield
# >>   delegate | false             
# >>   argument | null              
# >>   delegate | eat(_star)        
# >>   argument | parseMaybeAssign()

