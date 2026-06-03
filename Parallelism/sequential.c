//Josue Gomez Arteaga A01787212

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>

//Return the current time in seconds, used to measure execution time
double now ()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec / 1000000.0;
}


//Exercise 2 - Prime sum
//Return 1 if x is a prime number, 0 otherwise, using trial division
int is_prime (long x)
{
    if (x < 2)
    {
        return 0;
    }
    if (x == 2)
    {
        return 1;
    }
    long limit = (long) ceil(sqrt((double) x));
    for (long i = 2; i <= limit; i++)
    {
        if (x % i == 0)
        {
            return 0;
        }
    }
    return 1;
}

//Sequential: test every number from 2 to n and add the primes
unsigned long prime_sum_seq (long n)
{
    unsigned long sum = 0;
    for (long i = 2; i <= n; i++)
    {
        if (is_prime(i))
        {
            sum += i;
        }
    }
    return sum;
}


//Exercise 3 - Compute pi
//Sequential: rectangle method using a single loop over n rectangles
double compute_pi_seq (long n)
{
    double sum = 0.0;
    double width = 1.0 / n;
    for (long i = 0; i < n; i++)
    {
        double mid = (i + 0.5) * width;
        double height = 4.0 / (1.0 + mid * mid);
        sum += height;
    }
    return width * sum;
}


//Main: time each sequential exercise
int main (int argc, char * argv[])
{
    (void) argc;
    (void) argv;
    double t0, elapsed;

    //Exercise 2 - Prime sum (n = 2000000)
    printf("Exercise 2\n");
    t0 = now();
    unsigned long result2 = prime_sum_seq(2000000);
    elapsed = now() - t0;
    printf("Result:    %lu\n", result2);
    printf("Time:      %.4f s\n\n", elapsed);

    //Exercise 3 - Compute pi (n = 500000000)
    printf("Exercise 3\n");
    t0 = now();
    double result3 = compute_pi_seq(500000000L);
    elapsed = now() - t0;
    printf("Result:    %.15f\n", result3);
    printf("Time:      %.4f s\n\n", elapsed);

    return 0;
}
