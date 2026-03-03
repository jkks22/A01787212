#Josue Gomez Artaga A01787212

defmodule Hw.Ariel1 do

  def fahrenheit_to_celsius(fahrenheit) do
    5 * (fahrenheit - 32) / 9
  end

  def roots(a, b, c) do
    (-b + :math.sqrt(b * b - 4 * a * c)) / (2 * a)
  end

  def sign(n) do
    cond do
      n < 0 -> -1
      n > 0 ->  1
      true  ->  0
    end
  end

  def bmi(peso, altura) do
    imc = peso / (altura * altura)
    cond do
      imc < 20 -> :underweight
      imc < 25 -> :normal
      imc < 30 -> :obese1
      imc < 40 -> :obese2
      true -> :obese3
    end
  end

  def factorial(0), do: 1
  def factorial(n), do: n * factorial(n - 1)

  def pow(_a, 0), do: 1
  def pow(a, b), do: a * pow(a, b - 1)

  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n), do: fib(n - 1) + fib(n - 2)

  def duplicate([]), do: []
  def duplicate([head | tail]), do: [head, head | duplicate(tail)]

  def enlist([]), do: []
  def enlist([head | tail]), do: [[head] | enlist(tail)]

  def positives([]), do: []
  def positives([head | tail]) when head > 0, do: [head | positives(tail)]
  def positives([_head | tail]), do: positives(tail)

  def add_list([]), do: 0
  def add_list([head | tail]), do: head + add_list(tail)

  def invert_pairs([]), do: []
  def invert_pairs([{a, b} | tail]), do: [{b, a} | invert_pairs(tail)]

  def is_atom_list([]), do: true
  def is_atom_list([head | tail]) when is_atom(head), do: is_atom_list(tail)
  def is_atom_list([_head | _tail]), do: false

  def swapper([], _a, _b), do: []
  def swapper([a | tail], a, b), do: [b | swapper(tail, a, b)]
  def swapper([b | tail], a, b), do: [a | swapper(tail, a, b)]
  def swapper([head | tail], a, b), do: [head | swapper(tail, a, b)]

  def dot_product([], []), do: 0
  def dot_product([ha | ta], [hb | tb]), do: ha * hb + dot_product(ta, tb)

  def average([]), do: 0
  def average(lista) do
    add_list(lista) / length(lista)
  end

  def suma_diferencias_cuadradas([], _media), do: 0
  def suma_diferencias_cuadradas([head | tail], media) do
    diff = head - media
    diff * diff + suma_diferencias_cuadradas(tail, media)
  end

  def std_dev([]), do: 0
  def std_dev(lista) do
    media = average(lista)
    varianza = suma_diferencias_cuadradas(lista, media) / length(lista)
    :math.sqrt(varianza)
  end

  def repetir_elemento(_elemento, 0), do: []
  def repetir_elemento(elemento, n),  do: [elemento | repetir_elemento(elemento, n - 1)]

  def replic(_n, []), do: []
  def replic(0, _lista), do: []
  def replic(n, [head | tail]) do
    repetir_elemento(head, n) ++ replic(n, tail)
  end

  def expand_aux([], _indice), do: []
  def expand_aux([head | tail], indice) do
    repetir_elemento(head, indice) ++ expand_aux(tail, indice + 1)
  end

  def expand(lista), do: expand_aux(lista, 1)

  def binary(0), do: []
  def binary(n), do: binary(div(n, 2)) ++ [rem(n, 2)]

end