//Josue Gomez Arteaga A01787212

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>
#include <pthread.h>

int num_threads = 4;

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

//Declare a structure to send data to the threads for exercise 2
typedef struct {
    int index;
    long first;
    long last;
    //A pointer to the slot where the thread leaves its partial sum
    unsigned long * partial_ptr;
} prime_data_t;

//This function adds all the prime numbers in one slice of the range
void * primeThread (void * data)
{
    prime_data_t * info = data;
    unsigned long sum = 0;
    for (long i = info->first; i <= info->last; i++)
    {
        if (is_prime(i))
        {
            sum += i;
        }
    }
    *(info->partial_ptr) = sum;
    pthread_exit(NULL);
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

//Parallel: each thread sums the primes of one slice of the range
unsigned long prime_sum_par (long n)
{
    long chunk = (n - 1) / num_threads;

    //Create the array of thread id's
    pthread_t * tid = malloc(num_threads * sizeof(pthread_t));
    //Create an array of data structures
    prime_data_t * data = malloc(num_threads * sizeof(prime_data_t));
    //Array to receive the partial sum of every thread
    unsigned long * partials = malloc(num_threads * sizeof(unsigned long));

    //Start all the threads
    for (int i = 0; i < num_threads; i++)
    {
        //Fill the struct for each of the threads
        data[i].index = i;
        data[i].first = 2 + (long) i * chunk;
        data[i].last = (i == num_threads - 1) ? n : data[i].first + chunk - 1;
        data[i].partial_ptr = &partials[i];
        //Create the thread, and pass the pointer to the structure
        pthread_create(&tid[i], NULL, primeThread, &data[i]);
    }

    //Wait for the threads to finish
    for (int i = 0; i < num_threads; i++)
    {
        pthread_join(tid[i], NULL);
    }

    //Add the partial sums returned by the threads
    unsigned long sum = 0;
    for (int i = 0; i < num_threads; i++)
    {
        sum += partials[i];
    }
    free(tid);
    free(data);
    free(partials);
    return sum;
}


//Exercise 3 - Compute pi
//Declare a structure to send data to the threads for exercise 3
typedef struct {
    int index;
    long first;
    long last;
    double width;
    //A pointer to the slot where the thread leaves its partial sum
    double * partial_ptr;
} pi_data_t;

//This function adds the rectangle heights for one slice
void * piThread (void * data)
{
    pi_data_t * info = data;
    double sum = 0.0;
    for (long i = info->first; i <= info->last; i++)
    {
        double mid = (i + 0.5) * info->width;
        double height = 4.0 / (1.0 + mid * mid);
        sum += height;
    }
    *(info->partial_ptr) = sum;
    pthread_exit(NULL);
}

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

//Parallel: each thread sums the heights of one slice of the rectangles
double compute_pi_par (long n)
{
    double width = 1.0 / n;
    long chunk = n / num_threads;

    //Create the array of thread id's
    pthread_t * tid = malloc(num_threads * sizeof(pthread_t));
    //Create an array of data structures
    pi_data_t * data = malloc(num_threads * sizeof(pi_data_t));
    //Array to receive the partial sum of every thread
    double * partials = malloc(num_threads * sizeof(double));

    //Start all the threads
    for (int i = 0; i < num_threads; i++)
    {
        //Fill the struct for each of the threads
        data[i].index = i;
        data[i].first = (long) i * chunk;
        data[i].last = (i == num_threads - 1) ? n - 1 : data[i].first + chunk - 1;
        data[i].width = width;
        data[i].partial_ptr = &partials[i];
        //Create the thread, and pass the pointer to the structure
        pthread_create(&tid[i], NULL, piThread, &data[i]);
    }

    //Wait for the threads to finish
    for (int i = 0; i < num_threads; i++)
    {
        pthread_join(tid[i], NULL);
    }

    //Add the partial sums and multiply by the rectangle width
    double sum = 0.0;
    for (int i = 0; i < num_threads; i++)
    {
        sum += partials[i];
    }
    free(tid);
    free(data);
    free(partials);
    return width * sum;
}


//Main: time sequential vs parallel for each exercise and show speedup
//Usage: ./parallel [num_threads]
int main (int argc, char * argv[])
{
    if (argc > 1)
    {
        num_threads = atoi(argv[1]);
    }
    printf("Running on %d threads\n\n", num_threads);

    double t1, tp, t0;

    //Exercise 2 - Prime sum (n = 2000000)
    printf("Exercise 2\n");
    t0 = now();
    unsigned long s2 = prime_sum_seq(2000000);
    t1 = now() - t0;
    t0 = now();
    unsigned long p2 = prime_sum_par(2000000);
    tp = now() - t0;
    printf("Sequential: %.4f s\n", t1);
    printf("Parallel:   %.4f s\n", tp);
    printf("Speedup:    %.2fx\n", t1 / tp);
    printf("Results match: %s\n\n", (s2 == p2) ? "true" : "false");

    //Exercise 3 - Compute pi (n = 500000000)
    printf("Exercise 3\n");
    t0 = now();
    double s3 = compute_pi_seq(500000000L);
    t1 = now() - t0;
    t0 = now();
    double p3 = compute_pi_par(500000000L);
    tp = now() - t0;
    printf("Sequential: %.4f s  (pi = %.15f)\n", t1, s3);
    printf("Parallel:   %.4f s  (pi = %.15f)\n", tp, p3);
    printf("Speedup:    %.2fx\n\n", t1 / tp);

    //Finish this thread, and wait for any child threads
    pthread_exit(NULL);
}
