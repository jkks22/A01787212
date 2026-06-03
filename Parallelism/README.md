# Parallelism

**Josue Gomez Arteaga A01787212**

Two problems solved in both sequential and parallel versions, implemented in
C (pthreads) and Elixir (Task.async / Task.await).

---

## Files

| File | Language | Description |
|------|----------|-------------|
| `sequential.c` | C | Sequential implementation of exercises 2–3 |
| `parallel.c` | C | Sequential + parallel implementation, shows speedup |
| `sequential.exs` | Elixir | Sequential implementation of exercises 2–3 |
| `parallel.exs` | Elixir | Sequential + parallel implementation, shows speedup |

---

## How to Compile and Run

### C

**Requirements:** `gcc`, `libpthread`, `libm`

```bash
# Compile
gcc -o sequential sequential.c -lm
gcc -o parallel   parallel.c   -lpthread -lm

# Run sequential
./sequential

# Run parallel (optional: pass the number of threads, default = 4)
./parallel
./parallel 8
./parallel 32
```

> **We use `-lm`** because both programs call `sqrt()` and `ceil()` from `<math.h>` (in the
> `is_prime` function). The header only declares those functions; their compiled
> code lives in the separate math library (`libm`), which gcc does not link by
> default. The `-lm` flag links `libm` so the linker can resolve `sqrt`/`ceil`;
> without it compilation fails with `undefined reference to 'sqrt'`. The
> `-lpthread` flag is needed in `parallel.c` for the same reason, to link the
> pthreads library.

### Elixir
```bash
# Run sequential
iex sequential.exs

# Run parallel (uses all available schedulers automatically)
iex parallel.exs
```

> Each script runs as soon as it loads and prints its results, then `iex` drops
> you into the interactive shell. Press **Ctrl+C twice** (or type
> `System.halt()` and Enter) to exit the shell when you are done.

---

## Exercises

### Exercise 2 – Prime Sum

Sum all prime numbers from 2 to n using trial division.

- **C input:** n = 2,000,000
- **Elixir input:** n = 1,000,000

### Exercise 3 – Compute Pi

Approximate π by the rectangle (midpoint) rule over n intervals, integrating
`4 / (1 + x²)` from 0 to 1.

- **C input:** n = 500,000,000
- **Elixir input:** n = 50,000,000

---

## Parallelization Analysis

### Exercise 2 – Prime Sum

**Sequential approach:** iterate from 2 to n; for each candidate, run trial
division up to √x; accumulate primes.

**Parallel approach:** split `2..n` into *T* equal slices. Each thread/task
independently checks primality for its slice and accumulates a partial sum. The
main thread adds the T partial sums at the end. There is no shared mutable
state during computation – each thread writes only to its own slot – so no
locks or mutexes are needed.

**Why speedup is near-linear:** the work per element (O(√x) primality test) is
independent for every integer. The only serial section is the final addition of
T partial sums, which is O(T) and negligible. This is an **embarrassingly
parallel** problem for the computation phase.

### Exercise 3 – Compute Pi

**Sequential approach:** loop over n rectangles of width 1/n, evaluate
`4 / (1 + mid²)` at the midpoint of each, accumulate the sum, multiply by
width.

**Parallel approach:** split the n rectangles into T equal groups. Each
thread/task accumulates the height sum for its group independently. The main
thread sums the T partial results and multiplies by the width. Again, no shared
state during computation.

**Why speedup is near-linear:** each rectangle evaluation is a fixed-cost
arithmetic expression with no dependencies between iterations. The final
reduction is O(T). This is the textbook **embarrassingly parallel** case and
achieves the highest speedup of the two exercises.

---

## Speedup Results

Results measured on an **Intel Core i9-14900HX** (8 P-cores + 16 E-cores, 32
logical processors).

### C – `parallel.c`

Speedup = sequential time / parallel time (both measured in the same run).

| Threads | Ex 2 – Prime Sum | Ex 3 – Compute Pi |
|---------|------------------|-------------------|
| 1       | 0.88×            | 0.80×             |
| 2       | 1.56×            | 1.68×             |
| 4       | 2.77×            | 2.45×             |
| 8       | 4.74×            | 4.34×             |
| 16      | 7.19×            | 4.97×             |
| 32      | 7.09×            | 6.83×             |

> **Exercise 2** scales well up to 16 threads (7.19×). Beyond that, performance
> plateaus because the 16 Efficient cores (E-cores) on this CPU are slower than
> the 8 Performance cores, so adding more threads past 16 yields diminishing
> returns.

> **Exercise 3** scales well throughout (6.83× at 32 threads). The pure
> floating-point workload benefits from both P-cores and E-cores.

### Elixir – `parallel.exs` (32 BEAM schedulers)

Sequential baseline measured in the same run before launching tasks.

| Exercise | Sequential | Parallel  | Speedup |
|----------|-----------|-----------|---------|
| Ex 2 – Prime Sum (n=1 000 000)   | 0.258 s | 0.022 s | 11.98× |
| Ex 3 – Compute Pi (n=50 000 000) | 0.807 s | 0.077 s | 10.52× |

> Elixir achieves higher relative speedup for exercises 2 and 3 than C because
> the BEAM VM pins one OS thread per scheduler and its lightweight process model
> has very low context-switch overhead. The Task.async / Task.await abstraction
> maps directly to OS-level parallelism with minimal bookkeeping cost.

---

## Observations

1. **Embarrassingly parallel problems scale near-linearly** (exercises 2 and
   3) up to the hardware limit. The practical ceiling on this machine is around
   7–12× due to the mix of fast P-cores and slower E-cores.

2. **Thread overhead matters for small workloads.** At 1 thread, both exercises
   2 and 3 show speedup below 1× (0.88× and 0.80×) because `pthread_create` /
   `pthread_join` cost is paid without any parallel benefit.

3. **Elixir vs C:** C is 10–100× faster in absolute time due to compiled native
   code and fine-grained pointer arithmetic for big numbers. Elixir's strength
   is relative speedup: its scheduler is tuned for concurrent workloads and
   achieves excellent scaling with minimal boilerplate.
