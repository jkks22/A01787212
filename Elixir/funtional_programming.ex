#Josue Gomez Artaga A01787212

defmodule Hw.Ariel1 do

#exercise 1
#fahrenheit_to_celsius/1: converts a temperature from fahrenheit to celsius.
#applies the formula: celsius = 5 * (fahrenheit - 32) / 9
  def fahrenheit_to_celsius(fahrenheit) do
    5 * (fahrenheit - 32) / 9
  end

#exercise 2
#roots/2: calculates one root of a quadratic equation ax^2 + bx + c = 0
#uses the quadratic formula: (-b + sqrt(b^2 - 4ac)) / 2a, returns only the positive root
  def roots(a, b, c) do
    (-b + :math.sqrt(b * b - 4 * a * c)) / (2 * a)
  end

#exercise 3
#sign/1: returns the sign of a number: -1 if negative, 1 if positive, 0 if zero
#uses cond to evaluate the three cases in order
  def sign(n) do
    cond do
      n < 0 -> -1
      n > 0 ->  1
      true  ->  0
    end
  end

#exercise 4
#bmi/2: calculates the body mass index (weight / height^2) and classifies the result
#returns an atom based on the range: :underweight, :normal, :obese1, :obese2, :obese3
  def bmi(weight, height) do
    val = weight / (height * height)
    cond do
      val < 20 -> :underweight
      val < 25 -> :normal
      val < 30 -> :obese1
      val < 40 -> :obese2
      true -> :obese3
    end
  end

#exercise 5
#factorial/1: calculates the factorial of n recursively
#base case factorial(0) = 1, recursive n * factorial(n - 1)
  def factorial(0), do: 1
  def factorial(n), do: n * factorial(n - 1)

#exercise 6
#pow/2: calculates a raised to the power b recursively.
#base case: any number raised to 0 is 1. recursion: a * pow(a, b - 1)
  def pow(_a, 0), do: 1
  def pow(a, b), do: a * pow(a, b - 1)

#exercise 7
#fib/1: returns the n-th number in the fibonacci sequence
#base cases: fib(0) = 0, fib(1) = 1. recursion: fib(n-1) + fib(n-2)
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n), do: fib(n - 1) + fib(n - 2)

#exercise 8
#duplicate/1: duplicates each element of the list.
#base case: empty list. recursion: inserts the head twice and continues with the tail
  def duplicate([]), do: []
  def duplicate([head | tail]), do: [head, head | duplicate(tail)]

#exercise 9
#enlist/1: wraps each element of the list in its own sublist
#base case: empty list,  recursive: places the head inside a list and continues
  def enlist([]), do: []
  def enlist([head | tail]), do: [[head] | enlist(tail)]

#exercise 10
#positives/1: filters the list and returns only elements greater than zero
#uses pattern matching with guards: includes the head if positive, otherwise discards it
  def positives([]), do: []
  def positives([head | tail]) when head > 0, do: [head | positives(tail)]
  def positives([_head | tail]), do: positives(tail)

#exercise 11
#add_list/1: sums all elements of a number list
#base case empty list returns 0, recursive head + sum of the tail
  def add_list([]), do: 0
  def add_list([head | tail]), do: head + add_list(tail)

#exercise 12
#invert_pairs/1: swaps elements of each tuple {a, b} -> {b, a} in the list
#traverses the list with pattern matching and rebuilds each tuple with inverted values
  def invert_pairs([]), do: []
  def invert_pairs([{a, b} | tail]), do: [{b, a} | invert_pairs(tail)]

#exercise 13
#is_atom_list/1: returns true if all elements of the list are atoms, false otherwise
#base case empty list is true, uses guard is_atom/1 to verify each element
  def is_atom_list([]), do: true
  def is_atom_list([head | tail]) when is_atom(head), do: is_atom_list(tail)
  def is_atom_list([_head | _tail]), do: false

#exercise 14
#swapper/3: swaps all occurrences of a with b and vice versa in the list.
#uses three clauses with pattern matching: if head is a puts b, if b puts a, otherwise keeps it.
  def swapper([], _a, _b), do: []
  def swapper([a | tail], a, b), do: [b | swapper(tail, a, b)]
  def swapper([b | tail], a, b), do: [a | swapper(tail, a, b)]
  def swapper([head | tail], a, b), do: [head | swapper(tail, a, b)]

#exercise 15
#dot_product/2: calculates the dot product of two vectors represented as lists
#base case two empty lists return 0, recursion multiplies the heads and adds the dot product of the rest
  def dot_product([], []), do: 0
  def dot_product([ha | ta], [hb | tb]), do: ha * hb + dot_product(ta, tb)

#exercise 16
#average/1: calculates the average of a list of numbers
#base case empty list returns 0, general case divides the sum of the list by its length
  def average([]), do: 0
  def average(list) do
    add_list(list) / length(list)
  end

#helper for std_dev
#suma_diferencias_cuadradas/2: sums (element - mean)^2 for each element in the list
#traverses the list recursively calculating the squared difference of each element from the mean
  def suma_diferencias_cuadradas([], _mean), do: 0
  def suma_diferencias_cuadradas([head | tail], mean) do
    diff = head - mean
    diff * diff + suma_diferencias_cuadradas(tail, mean)
  end

#exercise 17
#std_dev/1: calculates the standard deviation of a list of numbers
#base case: empty list returns 0. calculates the mean, then the variance (sum of squared differences / n)
#and returns its square root
  def std_dev([]), do: 0
  def std_dev(list) do
    mean     = average(list)
    variance = suma_diferencias_cuadradas(list, mean) / length(list)
    :math.sqrt(variance)
  end

#helper for replic
#repetir_elemento/2: generates a list with n repetitions of the given element
#base case n == 0 returns empty list, recursive adds the element and reduces n by 1
  def repetir_elemento(_element, 0), do: []
  def repetir_elemento(element, n),  do: [element | repetir_elemento(element, n - 1)]

#exercise 18
#replic/2: repeats each element of the list n times
#base cases empty list or n == 0 return empty list
#recursive repeats the head n times and concatenates with the rest replicated
  def replic(_n, []), do: []
  def replic(0, _list), do: []
  def replic(n, [head | tail]) do
    repetir_elemento(head, n) ++ replic(n, tail)
  end

#helper for expand
#expand_aux/2: traverses the list and repeats each element as many times as its index (base 1)
#increments the index on each recursive call
  def expand_aux([], _index), do: []
  def expand_aux([head | tail], index) do
    repetir_elemento(head, index) ++ expand_aux(tail, index + 1)
  end

#exercise 19
#expand/1: repeats each element according to its position in the list (first 1 time, second 2, etc.)
#delegates to expand_aux/2 starting with index 1
  def expand(list), do: expand_aux(list, 1)

#exercise 20
#binary/1: converts an integer to its binary representation as a list of bits
#base case 0 returns empty list, recursive divides by 2 and appends the remainder at the end
  def binary(0), do: []
  def binary(n), do: binary(div(n, 2)) ++ [rem(n, 2)]

end
