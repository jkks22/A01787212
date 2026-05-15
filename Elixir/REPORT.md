# Python Syntax Highlighter Report

**Author:** Josue Gomez Artaga A01787212
**Course:** TC2037 Implementation of Computational Methods
**Target language:** Python
**Development language:** Elixir


## 1. Lexical categories of Python

The highlighter recognizes the following lexical categories, each one mapped
to a CSS class in the output HTML:

| Category | Examples | DFA approach |
|---|---|---|
| Keywords | `def`, `if`, `class`, `return`, `import` | read as identifier first, then check the keyword list |
| Built-in functions | `print`, `len`, `range`, `int`, `float` | same as keywords |
| Constants | `True`, `False`, `None`, `self`, `cls` | same as keywords |
| Strings | `"abc"`, `'abc'`, `"""abc"""` | quote-delimited reader with escape handling |
| Numbers | `42`, `3.14`, `1e-5`, `0xFF`, `0b1010`, `1_000_000`, `3.5j` | digit-driven DFA with prefix and suffix support |
| Comments | `# comment` | reads from `#` to end of line |
| Operators | `+`, `**`, `==`, `<<=`, `:=`, `->` | greedy match: try 3 chars, then 2, then 1 |
| Decorators | `@property`, `@app.route` | `@` followed by a dotted identifier |
| Identifiers | `my_var`, `_x`, `Foo123` | letters, digits, underscores |
| Punctuation | `(`, `)`, `[`, `]`, `{`, `}`, `,`, `:`, `;`, `.` | single-character match |
| Whitespace | spaces, tabs, newlines | kept as-is to preserve layout |


## 2. Regular expressions for each category

```
keyword ::= one of the words in the keyword set
identifier ::= [a-zA-Z_] [a-zA-Z0-9_]*
integer ::= [0-9] [0-9_]*
float ::= integer "." [0-9_]* | "." [0-9] [0-9_]*
scientific ::= (integer | float) [eE] [+-]? [0-9]+
hex ::= "0" [xX] [0-9a-fA-F_]+
binary ::= "0" [bB] [01_]+
octal ::= "0" [oO] [0-7_]+
complex ::= (integer | float | scientific) [jJ]
string ::= '"' (char | "\\" char)* '"'  |  "'" (char | "\\" char)* "'"
triple_str ::= '"""' .* '"""'  |  "'''" .* "'''"
comment ::= "#" [^\n]*
decorator ::= "@" identifier ("." identifier)?
operator ::= one of: + - * / % ** // = == != < > <= >= += -= *= /= %= **= //= & | ^ ~ << >> &= |= ^= <<= >>= -> :=
punctuation ::= one of: ( ) [ ] { } , : ; .
```


## 3. How to run

The highlighter is a single Elixir module with no external dependencies.

```bash
iex python_highlighter.ex
```

```elixir
iex(1)> PythonHighlighter.highlight("sample.py")
"sample.html"
```

The function reads the Python file, tokenizes it character by character,
wraps each token in an HTML `<span>` with its CSS class, and writes the
result to a `.html` file. A `style.css` is also written next to it if it
doesn't already exist

## 4. Algorithm and complexity

### Approach

The lexer is a deterministic finite automaton (DFA) that scans the file one
character at a time. For each character it identifies the token type and
calls the right reader (`#` → comment reader, quote → string reader,
digit → number reader, letter → identifier reader, etc.). Each reader
consumes its characters and returns the leftover input

The main processing pipeline is:

```elixir
filename
|> File.stream!()
|> Enum.join("")
|> String.graphemes()
|> tokenize([])
|> Enum.map(&wrap_token/1)
|> Enum.join("")
```

Each character is read exactly once. Tokens are accumulated in a list in
reverse order and flipped at the end, this avoids the O(n²) cost of
repeatedly prepending to a list in Elixir

### Time complexity

Let **n** = number of characters in the input file, **t** = number of tokens
produced. Since every token is at least one character, **t ≤ n**

| Phase | Cost |
|---|---|
| File read + join | **O(n)** |
| Grapheme split | **O(n)** |
| Tokenization | **O(n)** — each character is read at most twice |
| Keyword lookup | **O(t · k) = O(n)** — k is a fixed constant |
| List reversal | **O(t) = O(n)** |
| HTML wrapping + join | **O(n)** |
| File write | **O(n)** |
| **Total** | **O(n)** |

### Space complexity

The token list and the HTML output are both proportional to the input size,
so space complexity is also **O(n)**

## 5. Reflection on ethical implications

Syntax highlighters look like simple tools but there are a few things worth
thinking about from an ethical perspective

**Accessibility.** Highlighting that only uses color is a problem for people
with color blindness, which affects roughly 8% of men. This project uses
color combined with bold and italic styles so that token types can still be
told apart even without color. This should be a minimum requirement for any
tool that displays code

**Trust and security.** A highlighting tool could be misused to make code
look different from what it actually does — for example, coloring a dangerous
function call to look like a comment. People who copy code from websites
should be aware that the visual style might not match what actually ends up
in the clipboard. Pasting into a plain text editor first is a good habit

**Tooling bias.** Well-known languages like Python or JavaScript have great
tools, while less popular languages often have very little support. This
creates a cycle where languages with better tooling stay popular. As
developers, choosing to contribute tools for underrepresented languages is
a small way to push back against that

**Automation and impact.** The same DFA ideas behind this project are what
power compilers, linters, and AI coding assistants. Each layer up automates
more of what developers do. It's worth thinking about what that means for
the people doing that work, not just about how to build the tools correctly