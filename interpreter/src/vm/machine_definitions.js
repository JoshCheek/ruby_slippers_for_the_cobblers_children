export default () => {
  return {
    "name": "root",
    "description": "Machine /",
    "namespace": [],
    "arg_names": [],
    "instructions": [],
    "children": {
      "main": {
        "name": "main",
        "description": "The main machine, kicks everything else off",
        "namespace": [],
        "arg_names": [],
        "instructions": [
          ["globalToRegister", "ast", "@_1"],
          ["runMachine", ["ast"],
            ["@_1"]
          ],
          ["runMachine", ["ast", "nil"],
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
        "instructions": [
          ["globalToRegister", "currentBinding", "@_1"],
          ["setKey", "@_1", "returnValue", "@value"],
          ["globalToRegister", "rTrue", "@_2"],
          ["registerToGlobal", "@_2", "foundExpression"]
        ],
        "children": {},
      },
      "reemit": {
        "name": "reemit",
        "description": "Machine: /reemit",
        "namespace": [],
        "arg_names": [],
        "instructions": [
          ["globalToRegister", "rTrue", "@_1"],
          ["registerToGlobal", "@_1", "foundExpression"]
        ],
        "children": {},
      },
      "newPrimitive": {
        "name": "newPrimitive",
        "description": "helper for builtin types with fancy data",
        "namespace": [],
        "arg_names": ["@class", "@data"],
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
      "ast": {
        "name": "ast",
        "description": "Interpreters for language constructs",
        "namespace": [],
        "arg_names": ["@ast"],
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
            "instructions": [
              ["globalToRegister", "rNil", "@_1"],
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
            "instructions": [
              ["globalToRegister", "rFalse", "@_1"],
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
            "instructions": [
              ["globalToRegister", "rTrue", "@_1"],
              ["runMachine", ["emit"],
                ["@_1"]
              ]
            ],
            "children": {},
          },
          "string": {
            "name": "string",
            "description": "Machine: /ast/string",
            "namespace": ["ast"],
            "arg_names": ["@ast"],
            "instructions": [
              ["globalToRegister", "rString", "@_1"],
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
        },
      },
    },

  }
}
