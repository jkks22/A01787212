# Context-free grammars

### Yuhaoo Liu A01787782
### Josue Gomez Artaga A01787212

## Grammar definitions

Describe the basic grammar necessary to write a valid *construction* in the language indicated.

The contents of the *construction* do not need to be specified.

Consider all the requirements for the construction according to the language. For example, the rules for the names of the constructions

### BNF C / C++ functions

```xml
<function> ::= <return-type> <identifier> "(" <parameters> ")" <body>

<return-type> ::= "void" | "int" | "char" | "float" | "double" | "short"
                | "long" | "signed" | "unsigned" | "bool" "auto"
                | <identifier>
                | <return-type> "*"
                | <return-type> "&"
                | "const" <return-type>
                | "static" <return-type>
                | "inline" <return-type>

<parameters> ::= "" | "void" | <parameter-list>
<parameter-list>::= <parameter> | <parameter> "," <parameter-list>
<parameter> ::= <return-type> <identifier>
            | <return-type> <identifier> "[" "]"
            | <return-type> <identifier> "=" <code>
            | "..."

<body> ::= "{" <code> "}"
<code> ::= "" | <any-valid-C-code> <code>

<identifier> ::= <letter-or-underscore> <id-rest>
<id-rest> ::= "" | <letter-digit-underscore> <id-rest>
<letter-or-underscore> ::= <letter> | "_"
<letter-digit-underscore> ::= <letter> | <digit> | "_"
<letter> ::= "a" | "b" | ... | "z" | "A" | "B" | ... | "Z"
<digit> ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
```

### EBNF C / C++ functions

```bash
FUNCTION ::= RETURN_TYPE IDENTIFIER "(" PARAMETERS ")" BODY

RETURN_TYPE ::= [ "const" | "static" | "inline" ]
                ( "void" | "int" | "char" | "float" | "double"
                | "short" | "long" | "signed" | "unsigned"
                | "bool" | "auto" | IDENTIFIER )
                { "*" | "&" }

PARAMETERS ::= [ "void" | PARAMETER { "," PARAMETER } [ "," "..." ] ]
PARAMETER  ::= RETURN_TYPE IDENTIFIER [ "[" "]" ] [ "=" CODE ]

BODY ::= "{" CODE "}"
CODE ::= { ANY_VALID_C_CODE }

IDENTIFIER ::= ( LETTER | "_" ) { LETTER | DIGIT | "_" }
LETTER ::= "a" .. "z" | "A" .. "Z"
DIGIT ::= "0" .. "9"
```

### BNF Elixir modules

```xml
<module> ::= "defmodule" <module-name> "do" <module-body> "end"

<module-name> ::= <capital-identifier>
                  | <module-name> "." <capital-identifier>

<module-body> ::= "" | <module-element> <module-body>

<module-element> ::= <function>
                   | <private-function>
                   | <module-attribute>
                   | <use-directive>
                   | <import-directive>
                   | <alias-directive>
                   | <require-directive>
                   | <module>

<module-attribute> ::= "@" <identifier> <code>
<use-directive> ::= "use" <module-name>
                     | "use" <module-name> "," <options>
<import-directive> ::= "import" <module-name>
                     | "import" <module-name> "," <options>
<alias-directive> ::= "alias" <module-name>
                     | "alias" <module-name> "," "as:" <capital-identifier>
<require-directive> ::= "require" <module-name>

<options> ::= <option> | <option> "," <options>
<option> ::= <atom> ":" <code>

<code> ::= <any-valid-elixir-code>

<capital-identifier> ::= <uppercase-letter> <id-rest>
<uppercase-letter> ::= "A" | "B" | "C" | ... | "Z"
<identifier>         ::= <lowercase-letter-or-underscore> <id-rest>
<lowercase-letter-or-underscore> ::= <lowercase-letter> | "_"
<lowercase-letter> ::= "a" | "b" | "c" | ... | "z"
<id-rest> ::= "" | <letter-digit-underscore> <id-rest>
                       | <letter-digit-underscore> <id-rest> <ending>
<ending> ::= "?" | "!"
<letter-digit-underscore> ::= <letter> | <digit> | "_"
<letter> ::= <lowercase-letter> | <uppercase-letter>
<digit> ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
```

### EBNF Elixir modules

```bash
MODULE ::= "defmodule" MODULE_NAME "do" MODULE_BODY "end"

MODULE_NAME ::= CAPITAL_IDENTIFIER { "." CAPITAL_IDENTIFIER }

MODULE_BODY ::= { MODULE_ELEMENT }

MODULE_ELEMENT ::= FUNCTION
                 | PRIVATE_FUNCTION
                 | MODULE_ATTRIBUTE
                 | DIRECTIVE
                 | MODULE

MODULE_ATTRIBUTE ::= "@" IDENTIFIER CODE

DIRECTIVE ::= ( "use" | "import" | "require" ) MODULE_NAME [ "," OPTIONS ]
                 | "alias" MODULE_NAME [ "," "as:" CAPITAL_IDENTIFIER ]

OPTIONS ::= OPTION { "," OPTION }
OPTION ::= ATOM ":" CODE

CODE ::= ANY_VALID_ELIXIR_CODE

CAPITAL_IDENTIFIER ::= UPPERCASE { LETTER | DIGIT | "_" }
IDENTIFIER ::= ( LOWERCASE | "_" ) { LETTER | DIGIT | "_" } [ "?" | "!" ]

LETTER ::= LOWERCASE | UPPERCASE
LOWERCASE ::= "a" .. "z"
UPPERCASE ::= "A" .. "Z"
DIGIT ::= "0" .. "9"
```

### BNF Elixir functions

```xml
<function> ::= <public-function> | <private-function>

<public-function> ::= "def" <function-header> <function-tail>
<private-function> ::= "defp" <function-header> <function-tail>

<function-header> ::= <function-name>
                    | <function-name> "(" ")"
                    | <function-name> "(" <parameter-list> ")"
                    | <function-name> <guard>
                    | <function-name> "(" ")" <guard>
                    | <function-name> "(" <parameter-list> ")" <guard>

<function-tail> ::= "do" <body> "end"
                    | "," "do:" <code>

<function-name> ::= <identifier>
                    | <identifier> "?"
                    | <identifier> "!"

<parameter-list> ::= <parameter>
                    | <parameter> "," <parameter-list>

<parameter> ::= <identifier>
                | "_"
                | "_" <identifier>
                | <pattern>
                | <identifier> "\\\\" <code>

<pattern> ::= <literal>
            | <atom>
            | "[" "]"
            | "[" <pattern-list> "]"
            | "[" <pattern> "|" <pattern> "]"
            | "{" <pattern-list> "}"
            | "%{" <map-pattern-list> "}"
            | "%" <module-name> "{" <map-pattern-list> "}"

<pattern-list> ::= <pattern> | <pattern> "," <pattern-list>
<map-pattern-list> ::= <map-entry> | <map-entry> "," <map-pattern-list>
<map-entry> ::= <pattern> "=>" <pattern>
              | <atom> ":" <pattern>

<guard> ::= "when" <guard-expression>
<guard-expression> ::= <code>
                     | <guard-expression> "and" <guard-expression>
                     | <guard-expression> "or" <guard-expression>

<body> ::= <code>

<code> ::= <any-valid-elixir-code>

<literal> ::= <integer> | <float> | <string> | <atom> | "true" | "false" | "nil"
<atom> ::= ":" <identifier> | ":" "\"" <string-content> "\""

<identifier> ::= <lowercase-or-underscore> <id-rest>
<lowercase-or-underscore> ::= <lowercase-letter> | "_"
<id-rest> ::= "" | <letter-digit-underscore> <id-rest>
<letter-digit-underscore> ::= <letter> | <digit> | "_"
<letter> ::= <lowercase-letter> | <uppercase-letter>
<lowercase-letter> ::= "a" | "b" | "c" | ... | "z"
<uppercase-letter> ::= "A" | "B" | "C" | ... | "Z"
<digit> ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
```

### EBNF Elixir functions

```bash
FUNCTION ::= ( "def" | "defp" ) FUNCTION_HEADER FUNCTION_TAIL

FUNCTION_HEADER ::= FUNCTION_NAME [ "(" [ PARAMETER_LIST ] ")" ] [ GUARD ]

FUNCTION_TAIL ::= "do" BODY "end"
                 | "," "do:" CODE

FUNCTION_NAME ::= IDENTIFIER [ "?" | "!" ]

PARAMETER_LIST ::= PARAMETER { "," PARAMETER }

PARAMETER ::= IDENTIFIER [ "\\\\" CODE ]
              | "_" [ IDENTIFIER ]
              | PATTERN

PATTERN ::= LITERAL
            | ATOM
            | "[" [ PATTERN { "," PATTERN } [ "|" PATTERN ] ] "]"
            | "{" PATTERN { "," PATTERN } "}"
            | "%{" MAP_ENTRY { "," MAP_ENTRY } "}"
            | "%" MODULE_NAME "{" MAP_ENTRY { "," MAP_ENTRY } "}"

MAP_ENTRY ::= PATTERN "=>" PATTERN
              | ATOM ":" PATTERN

GUARD ::= "when" GUARD_EXPRESSION { ( "and" | "or" ) GUARD_EXPRESSION }
GUARD_EXPRESSION ::= CODE

BODY ::= CODE

CODE ::= ANY_VALID_ELIXIR_CODE

LITERAL ::= INTEGER | FLOAT | STRING | "true" | "false" | "nil"
ATOM ::= ":" IDENTIFIER | ":\"" STRING_CONTENT "\""

IDENTIFIER ::= ( LOWERCASE | "_" ) { LETTER | DIGIT | "_" }
LETTER ::= LOWERCASE | UPPERCASE
LOWERCASE ::= "a" .. "z"
UPPERCASE ::= "A" .. "Z"
DIGIT ::= "0" .. "9"
```