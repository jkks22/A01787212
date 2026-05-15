#Josue Gomez Artaga A01787212
#python syntax highlighter
#tc2037 - implementation of computational methods

defmodule PythonHighlighter do

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
  defp classify_word(word) do
    cond do
      word in @constants -> :constant
      word in @keywords -> :keyword
      word in @builtins -> :builtin
      true -> :identifier
    end
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
        type = classify_word(word)
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
    ".tok-constant { color: #fab387;font-style: italic;}\n" <>
    ".tok-string {color: #a6e3a1;}\n" <>
    ".tok-number {color: #f9e2af;}\n" <>
    ".tok-comment {color: #6c7086;font-style: italic;}\n" <>
    ".tok-operator {color: #f38ba8;}\n" <>
    ".tok-decorator {color: #f5c2e7;font-weight: bold;}\n" <>
    ".tok-identifier {color: #cdd6f4;}\n" <>
    ".tok-punctuation {color: #94e2d5;}\n" <>
    ".tok-other {color: #f38ba8;}\n"
  end

  #public function: takes a .py filename, tokenizes it, and writes the html output
  def highlight(filename) do
    #output file gets the same name but with .html extension
    output = Path.rootname(filename) <> ".html"

    #pipeline: read file -> split into chars -> tokenize -> wrap in spans -> join
    body = filename
      |> File.stream!()
      |> Enum.join("")
      |> String.graphemes()
      |> tokenize([])
      |> Enum.map(&wrap_token/1)
      |> Enum.join("")

    #put everything inside a full html page
    html = build_html(body, Path.basename(filename))

    #write the html file
    File.write(output, html)

    #generate the css file only if it doesn't exist yet
    css_path = Path.join(Path.dirname(output), "style.css")
    if not File.exists?(css_path), do: File.write(css_path, default_css())

    output
  end

end
