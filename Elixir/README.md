# Python Syntax Highlighter

A syntax highlighter for Python written in Elixir.
It reads a `.py` file and generates an HTML file that colors keywords, strings,
numbers, comments, operators, decorators, and more

## Requirements

- Elixir 1.14 or newer
- A web browser to see the output

## How to run

The easiest way is to load the module directly into `iex`:

```bash
iex python_highlighter.ex
```

Then call the highlight function with the Python file you want to process:

```elixir
iex(1)> PythonHighlighter.highlight("sample.py")
"sample.html"
```

This creates two files:

- `sample.html` — the highlighted source code
- `style.css` — the stylesheet (only created the first time)

To open the result in a browser from inside iex:

```elixir
iex(2)> System.cmd("xdg-open", ["sample.html"])
```

Press `Ctrl + C` twice to exit iex.

You can also compile and run it without iex if you prefer:

```bash
elixirc python_highlighter.ex -o /tmp/build
elixir -pa /tmp/build -e 'PythonHighlighter.highlight("sample.py")'
```

## Output format

The HTML file wraps each token in a `<span>` with a class like `tok-keyword`
or `tok-string`. Open it in any browser to see the highlighted code

| CSS class | What it highlights |
|---|---|
| `.tok-keyword` | Reserved words (`def`, `if`, `class`, ...) |
| `.tok-builtin` | Built-in functions (`print`, `len`, `range`, ...) |
| `.tok-constant` | `True`, `False`, `None`, `self`, `cls` |
| `.tok-string` | Regular and triple-quoted strings |
| `.tok-number` | Integers, floats, hex, binary, complex |
| `.tok-comment` | `# ...` to end of line |
| `.tok-operator` | Arithmetic, comparison, bitwise operators |
| `.tok-decorator` | `@name` and `@module.name` |
| `.tok-identifier` | User-defined names |
| `.tok-punctuation` | `()[]{}` `,:;.` |

You can edit `style.css` to change the colors. The default is a dark theme

## Files

- `python_highlighter.ex` — the main highlighter module
- `sample.html` — generated output, run the highlighter to create it
- `style.css` — generated stylesheet
- `REPORT.md` — complexity analysis and reflection
