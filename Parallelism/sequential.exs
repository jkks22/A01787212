#Josue Gomez Arteaga A01787212

defmodule Sequential do

#exercise 2
#prime_sum/1: sums all prime numbers in 2..n using trial division
#filters the full range keeping only primes, then sums them
  def prime_sum(n) do
    2..n
    |> Enum.filter(&is_prime?/1)
    |> Enum.sum()
  end

#is_prime?/1: returns true if x is prime using trial division up to sqrt(x)
#only checks odd divisors starting at 3 to halve the number of divisions
  defp is_prime?(x) when x < 2, do: false
  defp is_prime?(2), do: true
  defp is_prime?(x) when rem(x, 2) == 0, do: false
  defp is_prime?(x) do
    limit = trunc(:math.sqrt(x))
    not Enum.any?(3..limit//2, fn i -> rem(x, i) == 0 end)
  end

#exercise 3
#compute_pi/1: approximates pi by the rectangle (midpoint) rule over n intervals
#for each rectangle of width 1/n, evaluates 4/(1+x^2) at the midpoint and sums
  def compute_pi(n) do
    width = 1.0 / n
    sum =
      0..(n - 1)
      |> Enum.reduce(0.0, fn i, acc ->
        mid = (i + 0.5) * width
        acc + 4.0 / (1.0 + mid * mid)
      end)
    width * sum
  end

end


#exercise 2 - prime sum (n = 1000000)
IO.puts("=== Exercise 2 - prime sum (n = 1000000) ===")
{us2, result2} = :timer.tc(fn -> Sequential.prime_sum(1_000_000) end)
IO.puts("Result:    #{result2}")
IO.puts("Time:      #{Float.round(us2 / 1_000_000, 4)} s\n")

#exercise 3 - compute pi (n = 50000000)
IO.puts("=== Exercise 3 - compute pi (n = 50000000) ===")
{us3, result3} = :timer.tc(fn -> Sequential.compute_pi(50_000_000) end)
IO.puts("Result:    #{result3}")
IO.puts("Time:      #{Float.round(us3 / 1_000_000, 4)} s\n")
