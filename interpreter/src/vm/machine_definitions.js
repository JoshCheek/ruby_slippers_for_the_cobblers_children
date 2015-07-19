export default () => {
  return {
    "name": "root",
    "description": "Machine /",
    "namespace": [],
    "arg_names": [],
    "labels": {},
    "instructions": [],
    "children": {
      "main": {
        "name": "main",
        "description": "The main machine, kicks everything else off",
        "namespace": [],
        "arg_names": [],
        "labels": {},
        "instructions": [
          ["globalToRegister", "$rTOPLEVEL_BINDING", "@_1"],
          ["registerToRegister", "@_1", "@bindingStack"],
          ["registerToGlobal", "@bindingStack", "$bindingStack"],
          ["globalToRegister", "$rObject", "@_2"],
          ["runMachine", ["pushDeftarget"],
            ["@_2"]
          ],
          ["globalToRegister", "$ast", "@_3"],
          ["runMachine", ["ast"],
            ["@_3"]
          ],
          ["runMachine", ["ast", "nil"],
            []
          ],
          ["runMachine", ["popBinding"],
            []
          ]
        ],
        "children": {},
      },
      "emit": {
        "name": "emit",
        "description": "Machine: /emit",
        "namespace": [],
        "arg_names": ["@value"],
        "labels": {},
        "instructions": [
          ["globalToRegister", "$bindingStack", "@_1"],
          ["setKey", "@_1", "returnValue", "@value"],
          ["globalToRegister", "$rTrue", "@_2"],
          ["registerToGlobal", "@_2", "$foundExpression"]
        ],
        "children": {},
      },
      "reemit": {
        "name": "reemit",
        "description": "Machine: /reemit",
        "namespace": [],
        "arg_names": [],
        "labels": {},
        "instructions": [
          ["globalToRegister", "$rTrue", "@_1"],
          ["registerToGlobal", "@_1", "$foundExpression"]
        ],
        "children": {},
      },
      "newPrimitive": {
        "name": "newPrimitive",
        "description": "helper for builtin types with fancy data",
        "namespace": [],
        "arg_names": ["@class", "@data"],
        "labels": {},
        "instructions": [
          ["newHash", "@object"],
          ["setKey", "@object", "class", "@class"],
          ["newHash", "@_1"],
          ["setKey", "@object", "instanceVariables", "@_1"],
          ["setKey", "@object", "primitiveData", "@data"],
          ["runMachine", ["emit"],
            ["@object"]
          ]
        ],
        "children": {},
      },
      "pushDeftarget": {
        "name": "pushDeftarget",
        "description": "Machine: /pushDeftarget",
        "namespace": [],
        "arg_names": ["@toPush"],
        "labels": {},
        "instructions": [
          ["globalToRegister", "$deftargetStack", "@_1"],
          ["registerToRegister", "@_1", "@stack"],
          ["newHash", "@deftargetNode"],
          ["setKey", "@deftargetNode", "parent", "@stack"],
          ["setKey", "@deftargetNode", "target", "@toPush"],
          ["registerToGlobal", "@deftargetNode", "$deftargetStack"]
        ],
        "children": {},
      },
      "popBinding": {
        "name": "popBinding",
        "description": "Machine: /popBinding",
        "namespace": [],
        "arg_names": [],
        "labels": {},
        "instructions": [
          ["globalToRegister", "$deftargetStack", "@_1"],
          ["registerToRegister", "@_1", "@stack"],
          ["getKey", "@_2", "@stack", "parent"],
          ["registerToRegister", "@_2", "@deftargetNode"],
          ["registerToGlobal", "@deftargetNode", "$deftargetStack"]
        ],
        "children": {},
      },
      "openClass": {
        "name": "openClass",
        "description": "Machine: /openClass",
        "namespace": [],
        "arg_names": ["@name_lookup", "@superclass"],
        "labels": {
          "end_if": 21
        },
        "instructions": [
          ["getKey", "@_1", "@name_lookup", "name"],
          ["registerToRegister", "@_1", "@name"],
          ["globalToRegister", "$toplevelNamespace", "@_2"],
          ["registerToRegister", "@_2", "@namespace"],
          ["getKey", "@_3", "@namespace", "constants"],
          ["registerToRegister", "@_3", "@constants"],
          ["to_bool", "@_4", "@constants[@name]"],
          ["not", "@_5", "@_4"],
          ["jumpToIf", "end_if", "@_5"],
          ["newHash", "@class"],
          ["globalToRegister", "$rClass", "@_6"],
          ["setKey", "@class", "class", "@_6"],
          ["newHash", "@_7"],
          ["setKey", "@class", "instanceVariables", "@_7"],
          ["newHash", "@_8"],
          ["setKey", "@class", "constants", "@_8"],
          ["newHash", "@_9"],
          ["setKey", "@class", "instanceMethods", "@_9"],
          ["globalToRegister", "$rObject", "@_10"],
          ["setKey", "@class", "superclass", "@_10"],
          ["setKey", "@constants", "@name", "@class"],
          ["label", "end_if"],
          ["getKey", "@class", "@constants", "name"],
          ["runMachine", ["pushDeftarget"],
            ["@class"]
          ]
        ],
        "children": {},
      },
      "ast": {
        "name": "ast",
        "description": "Interpreters for language constructs",
        "namespace": [],
        "arg_names": ["@ast"],
        "labels": {},
        "instructions": [
          ["getKey", "@_1", "@ast", "type"],
          ["becomeMachine", ["ast", "@_1"]]
        ],
        "children": {
          "nil": {
            "name": "nil",
            "description": "Machine: /ast/nil",
            "namespace": ["ast"],
            "arg_names": [],
            "labels": {},
            "instructions": [
              ["globalToRegister", "$rNil", "@_1"],
              ["runMachine", ["emit"],
                ["@_1"]
              ]
            ],
            "children": {},
          },
          "false": {
            "name": "false",
            "description": "Machine: /ast/false",
            "namespace": ["ast"],
            "arg_names": [],
            "labels": {},
            "instructions": [
              ["globalToRegister", "$rFalse", "@_1"],
              ["runMachine", ["emit"],
                ["@_1"]
              ]
            ],
            "children": {},
          },
          "true": {
            "name": "true",
            "description": "Machine: /ast/true",
            "namespace": ["ast"],
            "arg_names": [],
            "labels": {},
            "instructions": [
              ["globalToRegister", "$rTrue", "@_1"],
              ["runMachine", ["emit"],
                ["@_1"]
              ]
            ],
            "children": {},
          },
          "self": {
            "name": "self",
            "description": "Machine: /ast/self",
            "namespace": ["ast"],
            "arg_names": [],
            "labels": {},
            "instructions": [
              ["globalToRegister", "$bindingStack", "@_1"],
              ["getKey", "@_2", "@_1", "self"],
              ["runMachine", ["emit"],
                ["@_2"]
              ]
            ],
            "children": {},
          },
          "string": {
            "name": "string",
            "description": "Machine: /ast/string",
            "namespace": ["ast"],
            "arg_names": ["@ast"],
            "labels": {},
            "instructions": [
              ["globalToRegister", "$rString", "@_1"],
              ["getKey", "@_2", "@ast", "value"],
              ["runMachine", ["newPrimitive"],
                ["@_1", "@_2"]
              ]
            ],
            "children": {},
          },
          "expressions": {
            "name": "expressions",
            "description": "Machine: /ast/expressions",
            "namespace": ["ast"],
            "arg_names": ["@ast"],
            "labels": {
              "forloop": 3,
              "forloop_end": 10
            },
            "instructions": [
              ["setInt", "@_1", 0],
              ["getKey", "@_2", "@ast", "expressions"],
              ["getKey", "@_3", "@_2", "length"],
              ["label", "forloop"],
              ["eq", "@_4", "@_1", "@_3"],
              ["jumpToIf", "forloop_end", "@_4"],
              ["getKey", "@expression", "@_2", "@_1"],
              ["runMachine", ["ast"],
                ["@expression"]
              ],
              ["add", "@_1", 1],
              ["jumpTo", "forloop"],
              ["label", "forloop_end"],
              ["runMachine", ["reemit"],
                []
              ]
            ],
            "children": {},
          },
          "get_local_variable": {
            "name": "get_local_variable",
            "description": "Machine: /ast/get_local_variable",
            "namespace": ["ast"],
            "arg_names": ["@ast"],
            "labels": {},
            "instructions": [
              ["globalToRegister", "$bindingStack", "@_1"],
              ["getKey", "@_2", "@_1", "localVariables"],
              ["registerToRegister", "@_2", "@locals"],
              ["getKey", "@_3", "@ast", "name"],
              ["registerToRegister", "@_3", "@varName"],
              ["getKey", "@value", "@locals", "@varName"],
              ["runMachine", ["emit"],
                ["@value"]
              ]
            ],
            "children": {},
          },
          "set_local_variable": {
            "name": "set_local_variable",
            "description": "Machine: /ast/set_local_variable",
            "namespace": ["ast"],
            "arg_names": ["@ast"],
            "labels": {},
            "instructions": [
              ["getKey", "@_1", "@ast", "name"],
              ["registerToRegister", "@_1", "@varName"],
              ["globalToRegister", "$bindingStack", "@_2"],
              ["registerToRegister", "@_2", "@binding"],
              ["getKey", "@_3", "@binding", "localVariables"],
              ["registerToRegister", "@_3", "@locals"],
              ["globalToRegister", "$rNil", "@_4"],
              ["setKey", "@locals", "@varName", "@_4"],
              ["getKey", "@_5", "@ast", "value"],
              ["runMachine", ["ast"],
                ["@_5"]
              ],
              ["getKey", "@_6", "@binding", "returnValue"],
              ["registerToRegister", "@_6", "@value"],
              ["setKey", "@locals", "@varName", "@value"],
              ["runMachine", ["reemit"],
                []
              ]
            ],
            "children": {},
          },
          "constant": {
            "name": "constant",
            "description": "Machine: /ast/constant",
            "namespace": ["ast"],
            "arg_names": ["@ast"],
            "labels": {},
            "instructions": [
              ["getKey", "@_1", "@ast", "name"],
              ["registerToRegister", "@_1", "@name"],
              ["globalToRegister", "$toplevelNamespace", "@_2"],
              ["getKey", "@_3", "@_2", "constants"],
              ["registerToRegister", "@_3", "@constants"],
              ["getKey", "@constant", "@constants", "@name"],
              ["runMachine", ["emit"],
                ["@constant"]
              ]
            ],
            "children": {},
          },
          "method_definition": {
            "name": "method_definition",
            "description": "Machine: /ast/method_definition",
            "namespace": ["ast"],
            "arg_names": ["@ast"],
            "labels": {},
            "instructions": [
              ["globalToRegister", "$rTrue", "@_1"],
              ["runMachine", ["emit"],
                ["@_1"]
              ]
            ],
            "children": {},
          },
          "class": {
            "name": "class",
            "description": "Machine: /ast/class",
            "namespace": ["ast"],
            "arg_names": ["@ast"],
            "labels": {},
            "instructions": [
              ["getKey", "@_1", "@ast", "superclass"],
              ["registerToRegister", "@_1", "@superclass"],
              ["getKey", "@_2", "@ast", "name_lookup"],
              ["registerToRegister", "@_2", "@name_lookup"],
              ["runMachine", ["openClass"],
                ["@name_lookup", "@superclass"]
              ],
              ["globalToRegister", "$deftargetStack", "@_3"],
              ["registerToRegister", "@_3", "@deftargetStack"],
              ["getKey", "@_4", "@deftargetStack", "target"],
              ["registerToRegister", "@_4", "@class"],
              ["newHash", "@binding"],
              ["newHash", "@locals"],
              ["setKey", "@binding", "localVariables", "@locals"],
              ["setKey", "@binding", "self", "@class"],
              ["globalToRegister", "$rNil", "@_5"],
              ["setKey", "@binding", "returnValue", "@_5"],
              ["globalToRegister", "$bindingStack", "@_6"],
              ["setKey", "@binding", "caller", "@_6"],
              ["getKey", "@_7", "@ast", "body"],
              ["runMachine", ["ast"],
                ["@_7"]
              ],
              ["runMachine", ["popDeftarget"],
                []
              ],
              ["runMachine", ["popBinding"],
                []
              ],
              ["runMachine", ["reemit"],
                []
              ]
            ],
            "children": {},
          },
        },
      },
    },

  }
}
