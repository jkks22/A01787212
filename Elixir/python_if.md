# Context-Free Grammars

## Python if

```Python
if age >= 18:
    print("You are allowed to go to the party")
elif age < 10:
    print("Is this OK")
else: 
    print("You are under-age")
```

**Backus-Narus Form**
```xml
<conditional> ::= <if> ::= <if> | <if><elifs> | <if><elifs><else> | <if><else>
<if> ::= if <expression> :\n\t <code>
<elifs> ::= <elif> | <elif><elifs>
<elif> ::= elif <expression> :\n\t <code>
<else> ::=else :\n\t <code>
```

**Extended Backus-Narus Form**
```bash
CONDITIONAL ::= IF [{ELIF}] [ELSE]
IF ::= 'if' EXPRESSION  ':\n\t' CODE 
ELIF ::= 'elif' EXPRESSION  ':\n\t' CODE
ELSE ::= 'else :\n\t' CODE
```