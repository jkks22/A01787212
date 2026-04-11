#Josue Gomez Artaga A01787212

defmodule Hw.Ariel2 do

#exercise 1
#insert/2: inserts element n into a sorted list while maintaining order.
#traverses the list recursively comparing n with the head:
#if n is less than or equal, inserts it at the front; otherwise advances to the next element.
  def insert(list, n) do
    if list == [] do
      [n]
    else
      head = hd(list)
      tail = tl(list)
      if n <= head do
        [n] ++ list
      else
        [head] ++ insert(tail, n)
      end
    end
  end

#exercise 2
#insertion_sort/1: sorts a list using the insertion sort algorithm.
#recursively sorts the tail and then inserts the head in its correct position
#using insert/2 base case is an empty list.
  def insertion_sort(list) do
    if list == [] do
      []
    else
      head = hd(list)
      tail = tl(list)
      insert(insertion_sort(tail), head)
    end
  end

#helper for rotate_left
#rotate_left_once/1: moves the first element to the end of the list
  def rotate_left_once(list) do
    if list == [] do
      []
    else
      head = hd(list)
      tail = tl(list)
      tail ++ [head]
    end
  end

#removes the last element to the front of the list
  def rotate_right_once(list) do
    if list == [] do
      []
    else
      last         = List.last(list)
      without_last = Enum.drop(list, -1)
      [last] ++ without_last
    end
  end

#exercise 3
#rotates the list n positions to the left
#if n is positive, moves elements from the front to the end; if negative, from the end to the front
#uses rem/2 to reduce rotations larger than the list size
  def rotate_left(list, n) do
    if list == [] do
      []
    else
      size      = length(list)
      rotations = rem(n, size)
      if rotations == 0 do
        list
      else
        if rotations > 0 do
          rotate_left(rotate_left_once(list), rotations - 1)
        else
          rotate_left(rotate_right_once(list), rotations + 1)
        end
      end
    end
  end

#helper for prime_factors
#searches for divisors starting from 'divisor'
#if n is divisible, adds the divisor and continues dividing; otherwise increments the divisor
  def prime_factors_aux(n, divisor) do
    if n == 1 do
      []
    else
      if rem(n, divisor) == 0 do
        [divisor] ++ prime_factors_aux(div(n, divisor), divisor)
      else
        prime_factors_aux(n, divisor + 1)
      end
    end
  end

#exercise 4
#returns the list of prime factors of n in ascending order
#delegates to prime_factors_aux/2 starting from divisor 2
  def prime_factors(n) do
    prime_factors_aux(n, 2)
  end

#exercise 5
#calculates the Greatest Common Divisor using Euclid's algorithm
#base case if b == 0, the GCD is a
#recursive gcd(b, a mod b) until b is 0
  def gcd(a, b) do
    if b == 0 do
      a
    else
      gcd(b, rem(a, b))
    end
  end

#exercise 6
#deep_reverse/1: reverses a list deeply (also reverses sublists)
#traverses the list and, if the head is a list, reverses it recursively as well
#the result is built by placing each element at the end of the already-reversed tail
  def deep_reverse(list) do
    if list == [] do
      []
    else
      head          = hd(list)
      tail          = tl(list)
      reversed_tail = deep_reverse(tail)
      if is_list(head) do
        reversed_tail ++ [deep_reverse(head)]
      else
        reversed_tail ++ [head]
      end
    end
  end1

#helper for insert_at
#insert_at_pos/3: inserts x into the list at the given index (base 0)
#traverses the list subtracting 1 from posicion until reaching 0 and inserts the element
  def insert_at_pos(list, pos, x) do
    if pos == 0 do
      [x] ++ list
    else
      if list == [] do
        [x]
      else
        head = hd(list)
        tail = tl(list)
        [head] ++ insert_at_pos(tail, pos - 1, x)
      end
    end
  end

#exercise 7
#insert_at/3: inserts x into the list at the given index (supports negative indices)
#calculates the real position: negative indices count from the end
#if the index is out of range, clamps it to the start or the end
  def insert_at(list, index, x) do
    if list == [] do
      [x]
    else
      size     = length(list)
      real_pos =
        if index < 0 do
          new_pos = size + index + 1
          if new_pos < 0 do
            0
          else
            new_pos
          end
        else
          if index > size do
            size
          else
            index
          end
        end
      insert_at_pos(list, real_pos, x)
    end
  end

#helper for insert_everywhere
#insert_at_all_pos/4: generates all possible lists inserting x
#at each position from current_pos to size (inclusive)
  def insert_at_all_pos(list, x, current_pos, size) do
    if current_pos > size do
      []
    else
      new_list = insert_at_pos(list, current_pos, x)
      [new_list] ++ insert_at_all_pos(list, x, current_pos + 1, size)
    end
  end

#exercise 8
#insert_everywhere/2: returns a list with all ways to insert x into the list
#generates a list of lists, each with x inserted at a different position
  def insert_everywhere(list, x) do
    size = length(list)
    insert_at_all_pos(list, x, 0, size)
  end

#helper for pack
#group_equal/2: extracts all consecutive elements equal to 'value' from the start
  def group_equal(list, value) do
    if list == [] do
      []
    else
      head = hd(list)
      tail = tl(list)
      if head == value do
        [head] ++ group_equal(tail, value)
      else
        []
      end
    end
  end

#exercise 9
#pack/1: groups consecutive equal elements into sublists
#example: [:a,:a,:b,:b] -> [[:a,:a],[:b,:b]]
#uses group_equal/2 to extract each group and continues with the remainder
  def pack(list) do
    if list == [] do []
    else
      head          = hd(list)
      current_group = group_equal(list, head)
      group_size    = length(current_group)
      rest          = Enum.drop(list, group_size)
      [current_group] ++ pack(rest)
    end
  end

#exercise 10
#compress/1: removes consecutive duplicates from a list, keeping only one of each group.
#compares the head with the next element; if equal, discards the head.
  def compress(list) do
    if list == [] do
      []
    else
      head = hd(list)
      tail = tl(list)
      if tail == [] do
        [head]
      else
        next = hd(tail)
        if head == next do
          compress(tail)
        else
          [head] ++ compress(tail)
        end
      end
    end
  end

#helper for encode
#groups_to_tuples/1: converts each group (sublist) into a tuple {count, element}.
  def groups_to_tuples(groups) do
    if groups == [] do
      []
    else
      group   = hd(groups)
      rest    = tl(groups)
      count   = length(group)
      element = hd(group)
      [{count, element}] ++ groups_to_tuples(rest)
    end
  end

#exercise 11
#encode/1: Run-Length Encoding. returns tuples {n, element} for each group.
#uses pack/1 to group and then converts each group to a tuple with its count.
  def encode(list) do
    groups = pack(list)
    groups_to_tuples(groups)
  end

#helper for encode_modified
#groups_to_tuples_modified/1: same as groups_to_tuples, but if the group
#has only one element, leaves it as a standalone element (not as a tuple).
  def groups_to_tuples_mod(groups) do
    if groups == [] do
      []
    else
      group   = hd(groups)
      rest    = tl(groups)
      count   = length(group)
      element = hd(group)
      if count == 1 do
        [element] ++ groups_to_tuples_mod(rest)
      else
        [{count, element}] ++ groups_to_tuples_mod(rest)
      end
    end
  end

#exercise 12
#encode_modified/1: modified Run-Length Encoding.
#if a group has a single element, returns it as-is; if more, returns {n, elem}.
  def encode_modified(list) do
    groups = pack(list)
    groups_to_tuples_mod(groups)
  end

#helper for decode
#repeat_element/2: generates a list with n repetitions of the given element.
  def repeat_element(element, n) do
    if n == 0 do
      []
    else
      [element] ++ repeat_element(element, n - 1)
    end
  end

#exercise 13
#decode/1: decodes a list in encode_modified format.
#if the element is a tuple {n, elem}, expands it to n repetitions; otherwise leaves it as-is.
  def decode(list) do
    if list == [] do
      []
    else
      head = hd(list)
      tail = tl(list)
      if is_tuple(head) do
        count   = elem(head, 0)
        element = elem(head, 1)
        repeat_element(element, count) ++ decode(tail)
      else
        [head] ++ decode(tail)
      end
    end
  end

#exercise 14
#args_swap/1: receives a two-argument function and returns another with the
#arguments swapped. that is, args_swap(f).(a, b) == f.(b, a).
  def args_swap(func) do
    fn a, b -> func.(b, a) end
  end

#helper for there_exists_one?
#count_matching/2: counts how many elements in the list satisfy the predicate pred.
  def count_matching(pred, list) do
    if list == [] do
      0
    else
      head = hd(list)
      tail = tl(list)
      if pred.(head) do
        1 + count_matching(pred, tail)
      else
        count_matching(pred, tail)
      end
    end
  end

#exercise 15
#there_exists_one?/2: returns true if exactly one element of the list satisfies the predicate.
#uses count_matching/2 and verifies that the count is exactly 1.
  def there_exists_one?(pred, list) do
    count = count_matching(pred, list)
    count == 1
  end

end
