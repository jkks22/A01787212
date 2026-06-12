#Josue Gomez Artaga A01787212
#python syntax highlighter version 2
#tc2037 - implementation of computational methods

defmodule PythonHighlighter2 do

  #python reserved words
  @keywords ["False", "None", "True", "and", "as", "assert", "async",
    "await", "break", "class", "continue", "def", "del", "elif", "else",
    "except", "finally", "for", "from", "global", "if", "import", "in",
    "is", "lambda", "nonlocal", "not", "or", "pass", "raise", "return",
    "try", "while", "with", "yield", "match", "case"]

  #python builtin functions
  @builtins ["abs", "all", "any", "ascii", "bin", "bool", "bytearray",
    "bytes", "callable", "chr", "classmethod", "compile", "complex",
    "delattr", "dict", "dir", "divmod", "enumerate", "eval", "exec",
    "filter", "float", "format", "frozenset", "getattr", "globals",
    "hasattr", "hash", "help", "hex", "id", "input", "int", "isinstance",
    "issubclass", "iter", "len", "list", "locals", "map", "max",
    "memoryview", "min", "next", "object", "oct", "open", "ord", "pow",
    "print", "property", "range", "repr", "reversed", "round", "set",
    "setattr", "slice", "sorted", "staticmethod", "str", "sum", "super",
    "tuple", "type", "vars", "zip"]

  #special values that look like identifiers
  @constants ["True", "False", "None", "self", "cls"]

  #maps a character to a class so we know what kind of token we're starting
  defp classify_char(char) do
    cond do
      char == "#" -> :hash
      char == "\"" -> :dquote
      char == "'" -> :squote
      char == "\n" -> :newline
      char == " " or char == "\t" -> :space
      char >= "0" and char <= "9" -> :digit
      char == "." -> :dot
      char == "_" -> :underscore
      (char >= "a" and char <= "z") or (char >= "A" and char <= "Z") -> :letter
      char in ["+", "-", "*", "/", "%", "=", "<", ">", "!", "&", "|", "^", "~"] -> :op_char
      char == "@" -> :at
      char in ["(", ")", "[", "]", "{", "}", ",", ":", ";"] -> :punct
      true -> :other
    end
  end

  #once we have a full word, check if it's a keyword/builtin/constant or just a name
  #the previous token is used to tell function names and class names apart
  #from regular variables, since in python that depends on context
  #(a name right after "def" is a function, right after "class" is a class)
  defp classify_word(word, prev_token) do
    cond do
      word in @keywords -> :keyword
      word in @builtins -> :builtin
      word in @constants -> :constant
      prev_token == {:keyword, "def"} -> :function_name
      prev_token == {:keyword, "class"} -> :class_name
      all_uppercase?(word) -> :constant_name
      starts_with_uppercase?(word) -> :class_name
      true -> :identifier
    end
  end

  #returns true if every letter in the word is uppercase, used to spot
  #module-level constants written in SCREAMING_SNAKE_CASE
  defp all_uppercase?(word) do
    letters = String.replace(word, ~r/[^a-zA-Z]/, "")
    letters != "" and letters == String.upcase(letters)
  end

  #returns true if the word starts with an uppercase letter, the usual
  #convention for class names in python (PascalCase)
  defp starts_with_uppercase?(word) do
    first = String.first(word)
    first >= "A" and first <= "Z"
  end

  #escapes html-unsafe characters in a piece of text
  defp escape_html(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end

  #turns a token tuple into an html span with the right css class
  defp wrap_token({type, text}) do
    cond do
      type == :whitespace -> escape_html(text)
      type == :newline -> "\n"
      true -> "<span class=\"tok-#{type}\">#{escape_html(text)}</span>"
    end
  end

  #reads a comment from # to the end of the line
  defp read_comment([], acc), do: {acc, []}
  defp read_comment(["\n" | rest], acc), do: {acc, ["\n" | rest]}
  defp read_comment([char | rest], acc), do: read_comment(rest, acc <> char)

  #reads a regular string, handling backslash escapes along the way
  defp read_simple_string([], _quote, _acc), do: {"", [], false}
  defp read_simple_string(["\\", next | rest], quote, acc) do
    read_simple_string(rest, quote, acc <> "\\" <> next)
  end
  defp read_simple_string([quote | rest], quote, acc) do
    {acc <> quote, rest, true}
  end
  defp read_simple_string(["\n" | _rest], _quote, _acc), do: {"", [], false}
  defp read_simple_string([char | rest], quote, acc) do
    read_simple_string(rest, quote, acc <> char)
  end

  #reads a triple-quoted string until the matching triple quote
  defp read_triple_string([], _quote, _acc), do: {"", [], false}
  defp read_triple_string([q, q, q | rest], q, acc), do: {acc <> q <> q <> q, rest, true}
  defp read_triple_string([char | rest], quote, acc) do
    read_triple_string(rest, quote, acc <> char)
  end

  #checks if we have triple quotes or single quotes and calls the right reader
  defp read_string([q, q, q | rest], q), do: read_triple_string(rest, q, q <> q <> q)
  defp read_string([q | rest], q), do: read_simple_string(rest, q, q)
  defp read_string(_, _), do: {"", [], false}

  #reads a python identifier: letters, digits, underscores
  defp read_identifier([], acc), do: {acc, []}
  defp read_identifier([char | rest] = chars, acc) do
    class = classify_char(char)
    if class == :letter or class == :digit or class == :underscore do
      read_identifier(rest, acc <> char)
    else
      {acc, chars}
    end
  end

  #helper to check if the next char is a digit (needed for floats like .5)
  defp digit_next?([next | _]) when next >= "0" and next <= "9", do: true
  defp digit_next?(_), do: false

  #reads a number: int, float, scientific, hex, binary, octal, complex
  defp read_number([], acc), do: {acc, []}
  defp read_number([char | rest] = chars, acc) do
    cond do
      char >= "0" and char <= "9" ->
        read_number(rest, acc <> char)
      char == "." and not String.contains?(acc, ".") and digit_next?(rest) ->
        read_number(rest, acc <> char)
      char in ["e", "E"] and acc != "" ->
        case rest do
          [sign | rest2] when sign in ["+", "-"] -> read_number(rest2, acc <> char <> sign)
          _ -> read_number(rest, acc <> char)
        end
      char in ["x", "X", "b", "B", "o", "O"] and acc == "0" ->
        read_number(rest, acc <> char)
      ((char >= "a" and char <= "f") or (char >= "A" and char <= "F"))
        and (String.starts_with?(acc, "0x") or String.starts_with?(acc, "0X")) ->
        read_number(rest, acc <> char)
      char == "_" and acc != "" ->
        read_number(rest, acc <> char)
      char in ["j", "J"] and acc != "" ->
        {acc <> char, rest}
      true ->
        {acc, chars}
    end
  end

  #reads a decorator: @name or @module.name
  defp read_decorator(["@" | rest]) do
    {name, after_name} = read_identifier(rest, "")
    case after_name do
      ["." | rest2] ->
        {sub, after_sub} = read_identifier(rest2, "")
        {"@" <> name <> "." <> sub, after_sub}
      _ ->
        {"@" <> name, after_name}
    end
  end

  #reads operators greedily: tries 3 chars first, then 2, then falls back to 1
  defp read_operator([a, b, c | rest]) do
    three = a <> b <> c
    two = a <> b
    cond do
      three in ["**=", "//=", ">>=", "<<="] -> {three, rest}
      two in ["**", "//", ">>", "<<", "<=", ">=", "==", "!=", "+=", "-=",
              "*=", "/=", "%=", "&=", "|=", "^=", "->", ":="] -> {two, [c | rest]}
      true -> {a, [b, c | rest]}
    end
  end
  defp read_operator([a, b | rest]) do
    two = a <> b
    if two in ["**", "//", ">>", "<<", "<=", ">=", "==", "!=", "+=", "-=",
               "*=", "/=", "%=", "&=", "|=", "^=", "->", ":="] do
      {two, rest}
    else
      {a, [b | rest]}
    end
  end
  defp read_operator([a | rest]), do: {a, rest}

  #reads a run of spaces and tabs
  defp read_whitespace([], acc), do: {acc, []}
  defp read_whitespace([char | rest] = chars, acc) do
    if char == " " or char == "\t" do
      read_whitespace(rest, acc <> char)
    else
      {acc, chars}
    end
  end

  #returns the most recent token that is not whitespace, used to look
  #at what came right before the current word (e.g. "def" or "class")
  defp last_meaningful_token([]), do: nil
  defp last_meaningful_token([{:whitespace, _} | rest]), do: last_meaningful_token(rest)
  defp last_meaningful_token([token | _]), do: token

  #main loop: processes one character at a time and builds the token list in reverse
  defp tokenize([], tokens), do: Enum.reverse(tokens)
  defp tokenize([char | rest] = chars, tokens) do
    class = classify_char(char)
    cond do

      class == :hash ->
        {comment, after_comment} = read_comment(chars, "")
        tokenize(after_comment, [{:comment, comment} | tokens])

      class == :dquote or class == :squote ->
        {string, after_string, ok} = read_string(chars, char)
        if ok do
          tokenize(after_string, [{:string, string} | tokens])
        else
          tokenize(rest, [{:other, char} | tokens])
        end

      class == :letter or class == :underscore ->
        {word, after_word} = read_identifier(chars, "")
        prev_token = last_meaningful_token(tokens)
        type = classify_word(word, prev_token)
        tokenize(after_word, [{type, word} | tokens])

      class == :digit ->
        {number, after_number} = read_number(chars, "")
        tokenize(after_number, [{:number, number} | tokens])

      class == :dot and digit_next?(rest) ->
        {number, after_number} = read_number(chars, "")
        tokenize(after_number, [{:number, number} | tokens])

      class == :at ->
        {decorator, after_decorator} = read_decorator(chars)
        tokenize(after_decorator, [{:decorator, decorator} | tokens])

      class == :op_char ->
        {op, after_op} = read_operator(chars)
        tokenize(after_op, [{:operator, op} | tokens])

      class == :punct or class == :dot ->
        tokenize(rest, [{:punctuation, char} | tokens])

      class == :space ->
        {ws, after_ws} = read_whitespace(chars, "")
        tokenize(after_ws, [{:whitespace, ws} | tokens])

      class == :newline ->
        tokenize(rest, [{:newline, char} | tokens])

      true ->
        tokenize(rest, [{:other, char} | tokens])
    end
  end

  #wraps the highlighted code in a full html page with head and body tags
  defp build_html(body, title) do
    "<!DOCTYPE html>\n" <>
    "<html lang=\"en\">\n" <>
    "<head>\n" <>
    "  <meta charset=\"UTF-8\">\n" <>
    "  <title>#{escape_html(title)}</title>\n" <>
    "  <link rel=\"stylesheet\" href=\"style.css\">\n" <>
    "</head>\n" <>
    "<body>\n" <>
    "<pre><code>" <> body <> "</code></pre>\n" <>
    "</body>\n" <>
    "</html>\n"
  end

  #inline css styles for each token type - dark theme inspired by catppuccin
  defp default_css do
    "body {background: #000000; color: #cdd6f4} " <>
    ".tok-keyword {color: #cba6f7;font-weight: bold; }\n" <>
    ".tok-builtin {color: #89dceb;}\n" <>
    ".tok-constant {color: #fab387;font-style: italic;}\n" <>
    ".tok-constant_name {color: #fab387;font-weight: bold;}\n" <>
    ".tok-class_name {color: #f9e2af;font-weight: bold;}\n" <>
    ".tok-function_name {color: #89b4fa;font-weight: bold;}\n" <>
    ".tok-string {color: #a6e3a1;}\n" <>
    ".tok-number {color: #f9e2af;}\n" <>
    ".tok-comment {color: #6c7086;font-style: italic;}\n" <>
    ".tok-operator {color: #f38ba8;}\n" <>
    ".tok-decorator {color: #f5c2e7;font-weight: bold;}\n" <>
    ".tok-identifier {color: #cdd6f4;}\n" <>
    ".tok-punctuation {color: #94e2d5;}\n" <>
    ".tok-other {color: #f38ba8;}\n"
  end

  #returns true if the line contains an odd number of triple-quote
  #delimiters ("\"\"\"" or '''), which means it flips whether we are
  #currently inside a triple-quoted string or not
  defp flips_triple_string?(line) do
    double_count = line |> String.split("\"\"\"") |> length() |> Kernel.-(1)
    single_count = line |> String.split("'''") |> length() |> Kernel.-(1)
    rem(double_count + single_count, 2) == 1
  end

  #splits a list of lines into `parts` chunks of consecutive lines,
  #making sure no chunk boundary falls inside a triple-quoted string.
  #this keeps each chunk independently tokenizable, since the only
  #token that can span multiple lines is a triple-quoted string
  defp split_lines_safely(lines, parts) do
    total = length(lines)
    target_size = max(div(total, parts), 1)

    {chunks, current, _inside} =
      Enum.reduce(lines, {[], [], false}, fn line, {chunks, current, inside} ->
        new_inside = if flips_triple_string?(line), do: not inside, else: inside
        new_current = [line | current]

        at_boundary = length(new_current) >= target_size and not new_inside
        if at_boundary and length(chunks) < parts - 1 do
          {[Enum.reverse(new_current) | chunks], [], false}
        else
          {chunks, new_current, new_inside}
        end
      end)

    final_chunks = Enum.reverse([Enum.reverse(current) | chunks])
    Enum.reject(final_chunks, &(&1 == []))
  end

  #tokenizes a single chunk of source code (a list of lines), joining
  #them back with newlines. the chunk does not get an extra trailing
  #newline here; a newline separator between chunks is added when the
  #tokenized chunks are joined together in highlight_par/1
  defp tokenize_chunk(lines) do
    lines
    |> Enum.join("\n")
    |> String.graphemes()
    |> tokenize([])
  end

  #sequential: read the whole file, tokenize it in a single pass,
  #and write the highlighted html. this is the same approach as a
  #single-file run, kept here as the baseline for the benchmark
  def highlight_seq(filename) do
    output = Path.rootname(filename) <> ".html"

    body = filename
      |> File.stream!()
      |> Enum.join("")
      |> String.graphemes()
      |> tokenize([])
      |> Enum.map(&wrap_token/1)
      |> Enum.join("")

    html = build_html(body, Path.basename(filename))
    File.write!(output, html)
    ensure_stylesheet(Path.dirname(filename))

    output
  end

  #parallel: split the file into one chunk of lines per core, tokenize
  #each chunk in its own Task, then join the resulting tokens back
  #together in order before writing the html. splitting respects
  #triple-quoted strings so no chunk boundary breaks a token
  def highlight_par(filename) do
    output = Path.rootname(filename) <> ".html"
    cores = System.schedulers_online()

    lines = filename |> File.read!() |> String.split("\n")
    chunks = split_lines_safely(lines, cores)

    #tokenize each chunk in parallel, then re-insert the newline that
    #was consumed by String.split/2 between consecutive chunks
    token_lists = chunks
      |> Task.async_stream(&tokenize_chunk/1, max_concurrency: cores)
      |> Enum.map(fn {:ok, tokens} -> tokens end)

    body = token_lists
      |> Enum.intersperse([{:newline, "\n"}])
      |> List.flatten()
      |> Enum.map(&wrap_token/1)
      |> Enum.join("")

    html = build_html(body, Path.basename(filename))
    File.write!(output, html)
    ensure_stylesheet(Path.dirname(filename))

    output
  end

  #public function: takes a .py filename, tokenizes it, and writes the
  #html output. uses the sequential path, kept for backwards
  #compatibility with highlight/1 from the first version
  def highlight(filename), do: highlight_seq(filename)

  #makes sure style.css exists in the given directory before highlighting
  defp ensure_stylesheet(dir) do
    css_path = Path.join(dir, "style.css")
    if not File.exists?(css_path), do: File.write!(css_path, default_css())
  end

  #runs a function and returns {elapsed_milliseconds, result}
  defp timed(fun) do
    start = System.monotonic_time(:millisecond)
    result = fun.()
    elapsed = System.monotonic_time(:millisecond) - start
    {elapsed, result}
  end

  #runs both versions of highlight on the same file several times,
  #prints the average time of each version and the resulting speedup.
  #works on a single file, no directory of files is needed
  def benchmark(filename, runs \\ 5) do
    seq_times = for _ <- 1..runs, do: elem(timed(fn -> highlight_seq(filename) end), 0)
    par_times = for _ <- 1..runs, do: elem(timed(fn -> highlight_par(filename) end), 0)

    seq_avg = Enum.sum(seq_times) / runs
    par_avg = Enum.sum(par_times) / runs
    speedup = seq_avg / par_avg

    lines_count = filename |> File.read!() |> String.split("\n") |> length()
    IO.puts("File: #{filename}")
    IO.puts("Lines: #{lines_count}")
    IO.puts("Cores available: #{System.schedulers_online()}")
    IO.puts("Sequential average: #{Float.round(seq_avg, 2)} ms")
    IO.puts("Parallel average: #{Float.round(par_avg, 2)} ms")
    IO.puts("Speedup: #{Float.round(speedup, 2)}x")

    %{sequential_avg: seq_avg, parallel_avg: par_avg, speedup: speedup}
  end
end
