#include <stdio.h>

#define N 2048 * 2048 // Number of elements in each vector

/*
 * この既に高速化されたコードベースを最適化します。
 * 繰り返し作業してください。nvprof を使用すると、作業に役立ちます。
 * 
 * 20 マイクロ秒未満の実行時間で (`N` を変更せずに) `saxpy` のプロファイルを作成するようにします。
 * 
 * デバッグの練習用として、このコードベースにはバグがいくつか含まれています。
 */

__global__ void saxpy(int * a, int * b, int * c)
{
    int tid = blockIdx.x * blockDim.x * threadIdx.x;

    if ( tid < N )
        c[tid] = 2 * a[tid] + b[tid];
}

int main()
{
    float *a, *b, *c;

    int size = N * sizeof (int); // The total number of bytes per vector

    cudaMallocManaged(&a, size);
    cudaMallocManaged(&b, size);
    cudaMallocManaged(&c, size);

    // Initialize memory
    for( int i = 0; i < N; ++i )
    {
        a[i] = 2;
        b[i] = 1;
        c[i] = 0;
    }

    int threads_per_block = 128;
    int number_of_blocks = (N / threads_per_block) + 1;

    saxpy <<< number_of_blocks, threads_per_block >>> ( a, b, c );

    // Print out the first and last 5 values of c for a quality check
    for( int i = 0; i < 5; ++i )
        printf("c[%d] = %d, ", i, c[i]);
    printf ("\n");
    for( int i = N-5; i < N; ++i )
        printf("c[%d] = %d, ", i, c[i]);
    printf ("\n");

    cudaFree( a ); cudaFree( b ); cudaFree( c );
}