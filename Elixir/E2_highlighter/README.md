# Python Syntax Highlighter

**Author:** Josue Gomez Artaga A01787212

A syntax highlighter for Python written in Elixir.
It reads a `.py` file and generates an HTML file that colors keywords,
builtins, strings, numbers, comments, operators, decorators, class names,
function names, constants, and more. The file is tokenized either
sequentially or in parallel, splitting the work across all the cores
available on the machine.

## Requirements

- Elixir 1.14 or newer
- A web browser to see the output

## How to run

The easiest way is to load the module directly into `iex`:

```bash
iex python_highlighter_2.ex
```

### Highlight a file (sequential)

```elixir
iex(1)> PythonHighlighter2.highlight("big_sample.py")
"big_sample.html"
```

`highlight/1` is the same single-pass version from the first version of
this project, kept under that name for backwards compatibility. It is
equivalent to calling `highlight_seq/1`.

This creates two files:

- `big_sample.html` — the highlighted source code
- `style.css` — the stylesheet (only created the first time)

### Highlight a file (parallel)

```elixir
iex(2)> PythonHighlighter2.highlight_par("big_sample.py")
"big_sample.html"
```

`highlight_par/1` produces **exactly the same HTML** as `highlight_seq/1`,
but splits the file into one chunk of lines per core, tokenizes each
chunk concurrently with `Task.async_stream/3`, and joins the results
back together in order. The number of cores used can be checked with:

```elixir
iex(3)> System.schedulers_online()
32
```

### Measure the speedup

```elixir
iex(4)> PythonHighlighter2.benchmark("big_sample.py", 5)
File: big_sample.py
Lines: 2544
Cores available: 32
Sequential average: 410.32 ms
Parallel average:   19.87 ms
Speedup:            20.65x
```

`benchmark/2` runs `highlight_seq/1` and `highlight_par/1` `runs` times
each (default 5) on the **same single file**, and prints the average
time of each version and the resulting speedup. No directory or
multiple files are needed — a single large `.py` file is enough.

To open a result in a browser from inside iex:

```elixir
iex(5)> System.cmd("xdg-open", ["big_sample.html"])
```

Press `Ctrl + C` twice to exit iex.

You can also compile and run it without iex if you prefer:

```bash
elixirc python_highlighter_2.ex -o /tmp/build
elixir -pa /tmp/build -e 'PythonHighlighter2.benchmark("big_sample.py", 5)'
```

## Output format

The HTML file wraps each token in a `<span>` with a class like
`tok-keyword` or `tok-string`. Open it in any browser to see the
highlighted code.

| CSS class | What it highlights |
|---|---|
| `.tok-keyword` | Reserved words (`def`, `if`, `class`, ...) |
| `.tok-builtin` | Built-in functions (`print`, `len`, `range`, ...) |
| `.tok-constant` | `True`, `False`, `None`, `self`, `cls` |
| `.tok-constant_name` | Module-level constants in `SCREAMING_SNAKE_CASE` |
| `.tok-class_name` | Class names (after `class`, or `PascalCase`) |
| `.tok-function_name` | Function and method names (after `def`) |
| `.tok-string` | Regular and triple-quoted strings |
| `.tok-number` | Integers, floats, hex, binary, complex |
| `.tok-comment` | `# ...` to end of line |
| `.tok-operator` | Arithmetic, comparison, bitwise operators |
| `.tok-decorator` | `@name` and `@module.name` |
| `.tok-identifier` | Regular variable names |
| `.tok-punctuation` | `()[]{}` `,:;.` |

You can edit `style.css` to change the colors. The default is a dark
theme based on Catppuccin.

## Files

- `python_highlighter_2.ex` — the main highlighter module
- `big_sample.py` — a 2500+ line Python file for testing and benchmarking
- `big_sample.html` — example generated output
- `REPORT.md` — token recognition process, state diagram, parallelization
  strategy, complexity analysis, and ethical reflection
