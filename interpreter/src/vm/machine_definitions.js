export default () => { return {
  "name": "root",
  "namespace": [],
  "arg_names": [],
  "description": "Machine /",
  "instructions": [],
  "children": {
    "main": {
      "name": "main",
      "namespace": [],
      "arg_names": [],
      "description": "The main machine, kicks everything else off",
      "instructions": [
        [
          "globalToRegister",
          "ast",
          "@_1"
        ],
        [
          "runMachine",
          [
            "ast"
          ],
          [
            "@_1"
          ]
        ]
      ],
      "children": {}
    },
    "emit": {
      "name": "emit",
      "namespace": [],
      "arg_names": [
        "@value"
      ],
      "description": "Machine: /emit",
      "instructions": [
        [
          "globalToRegister",
          "currentBinding",
          "@_1"
        ],
        [
          "setKey",
          "@_1",
          "returnValue",
          "@value"
        ]
      ],
      "children": {}
    },
    "reemit": {
      "name": "reemit",
      "namespace": [],
      "arg_names": [],
      "description": "Machine: /reemit",
      "instructions": [
        [
          "globalToRegister",
          "rTrue",
          "@_1"
        ],
        [
          "registerToGlobal",
          "@_1",
          "foundExpression"
        ]
      ],
      "children": {}
    },
    "ast": {
      "name": "ast",
      "namespace": [],
      "arg_names": [
        "@ast"
      ],
      "description": "Interpreters for language constructs",
      "instructions": [
        [
          "becomeMachine",
          [
            "ast",
            "*[@ast.type]"
          ]
        ]
      ],
      "children": {
        "nil": {
          "name": "nil",
          "namespace": [
            "ast"
          ],
          "arg_names": [],
          "description": "Machine: /ast/nil",
          "instructions": [
            [
              "globalToRegister",
              "rNil",
              "@_1"
            ],
            [
              "runMachine",
              [
                "emit"
              ],
              [
                "@_1"
              ]
            ]
          ],
          "children": {}
        },
        "false": {
          "name": "false",
          "namespace": [
            "ast"
          ],
          "arg_names": [],
          "description": "Machine: /ast/false",
          "instructions": [
            [
              "globalToRegister",
              "rFalse",
              "@_1"
            ],
            [
              "runMachine",
              [
                "emit"
              ],
              [
                "@_1"
              ]
            ]
          ],
          "children": {}
        },
        "true": {
          "name": "true",
          "namespace": [
            "ast"
          ],
          "arg_names": [],
          "description": "Machine: /ast/true",
          "instructions": [
            [
              "globalToRegister",
              "rTrue",
              "@_1"
            ],
            [
              "runMachine",
              [
                "emit"
              ],
              [
                "@_1"
              ]
            ]
          ],
          "children": {}
        },
        "expressions": {
          "name": "expressions",
          "namespace": [
            "ast"
          ],
          "arg_names": [
            "@ast"
          ],
          "description": "Machine: /ast/expressions",
          "instructions": [
            [
              "setInt",
              "@_1",
              0
            ],
            [
              "getKey",
              "@_2",
              "@ast",
              "expressions"
            ],
            [
              "getKey",
              "@_3",
              "@_2",
              "length"
            ],
            [
              "label",
              "forloop"
            ],
            [
              "eq",
              "@_4",
              "@_1",
              "@_3"
            ],
            [
              "jumpToIf",
              "forloop_end",
              "@_4"
            ],
            [
              "getKey",
              "@expression",
              "@_2",
              "@_1"
            ],
            [
              "runMachine",
              [
                "ast"
              ],
              [
                "@expression"
              ]
            ],
            [
              "add",
              "@_1",
              1
            ],
            [
              "jumpTo",
              "forloop"
            ],
            [
              "label",
              "forloop_end"
            ],
            [
              "runMachine",
              [
                "reemit"
              ],
              []
            ]
          ],
          "children": {}
        }
      }
    }
  }
}
 }
