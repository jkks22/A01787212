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


defmodule Parallel do

#exercise 2
#prime_sum/1: parallel version - each Task sums the primes in one slice of 2..n
#partial sums are added together after all tasks complete
  def prime_sum(n) do
    num_tasks = System.schedulers_online()
    chunk = div(n - 1, num_tasks)
    tasks =
      for i <- 0..(num_tasks - 1) do
        first = 2 + i * chunk
        last  = if i == num_tasks - 1, do: n, else: first + chunk - 1
        Task.async(fn ->
          first..last
          |> Enum.filter(&is_prime?/1)
          |> Enum.sum()
        end)
      end
    tasks
    |> Enum.map(&Task.await(&1, :infinity))
    |> Enum.sum()
  end

#exercise 3
#compute_pi/1: parallel version - each Task sums the rectangle heights of one slice
#partial sums are combined and multiplied by the rectangle width
  def compute_pi(n) do
    num_tasks = System.schedulers_online()
    width = 1.0 / n
    chunk = div(n, num_tasks)
    tasks =
      for i <- 0..(num_tasks - 1) do
        first = i * chunk
        last  = if i == num_tasks - 1, do: n - 1, else: first + chunk - 1
        Task.async(fn ->
          first..last
          |> Enum.reduce(0.0, fn j, acc ->
            mid = (j + 0.5) * width
            acc + 4.0 / (1.0 + mid * mid)
          end)
        end)
      end
    sum =
      tasks
      |> Enum.map(&Task.await(&1, :infinity))
      |> Enum.sum()
    width * sum
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

end


num_tasks = System.schedulers_online()
IO.puts("Running on #{num_tasks} schedulers\n")

#exercise 2 - prime sum (n = 1000000)
IO.puts("=== Exercise 2 - prime sum (n = 1000000) ===")
{t1, s2} = :timer.tc(fn -> Sequential.prime_sum(1_000_000) end)
{tp, p2} = :timer.tc(fn -> Parallel.prime_sum(1_000_000) end)
IO.puts("Sequential: #{Float.round(t1 / 1_000_000, 4)} s")
IO.puts("Parallel:   #{Float.round(tp / 1_000_000, 4)} s")
IO.puts("Speedup:    #{Float.round(t1 / tp, 2)}x")
IO.puts("Results match: #{s2 == p2}\n")

#exercise 3 - compute pi (n = 50000000)
IO.puts("=== Exercise 3 - compute pi (n = 50000000) ===")
{t1, s3} = :timer.tc(fn -> Sequential.compute_pi(50_000_000) end)
{tp, p3} = :timer.tc(fn -> Parallel.compute_pi(50_000_000) end)
IO.puts("Sequential: #{Float.round(t1 / 1_000_000, 4)} s")
IO.puts("Parallel:   #{Float.round(tp / 1_000_000, 4)} s")
IO.puts("Speedup:    #{Float.round(t1 / tp, 2)}x")
IO.puts("Results match: #{Float.round(s3, 10) == Float.round(p3, 10)}\n")
