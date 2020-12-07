// Cameron O'Neal

#include <stdio.h>

const int N = 10240;
const int blocksize = 1024;

// initalize Array's 

	int a[N];
 	int b[N];
	int c[N];



__global__
void Addition(int *a, int * b, int *c)
{
	//threads 0 - 1023 are doing computation in 4 different blocks
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	c[i] = a[i] * b[i];		
	
		
} 
int main()
{	
		
	
	int *ad;		//pointer to a array
 	int *bd;		//pointer to b array
	int *cd;		//pointer to c array
	
	// intializing array a & b to correct values
	for(int i = 0; i < N; i++)
	{
		a[i] = 2 * i;
		b[i] = 2*i + 1;
	}
	
	
 	const int isize = N*sizeof(int);
	
	//allocate pointers to global mem with size = Isize
 	cudaMalloc( (void**)&ad, isize );
 	cudaMalloc( (void**)&bd, isize );
 	cudaMalloc( (void**)&cd, isize );

	// memory Data Transfer
 	cudaMemcpy( ad, a, isize, cudaMemcpyHostToDevice );
 	cudaMemcpy( bd, b, isize, cudaMemcpyHostToDevice );
	cudaMemcpy( cd, b, isize, cudaMemcpyHostToDevice );

	
 	dim3 dimGrid( 2, 1 ); 		
	dim3 dimBlock( blocksize, 1 );

	// calls addition function -> sending pointer to arrays
	for(int i = 0; i < 5 ; i++)
	{	
		
		Addition<<<dimGrid, dimBlock>>>(ad, bd, cd);
	}
	
	
	cudaMemcpy( c, cd, isize, cudaMemcpyDeviceToHost );
	printf("%d\n%d\n", c[0], c[N-1]);

	dim3 dimGrid2( 10, 1 ); 	
	Addition<<<dimGrid2, dimBlock>>>(ad, bd, cd);
	cudaMemcpy( c, cd, isize, cudaMemcpyDeviceToHost );
	
	

	// frees poiters
 	cudaFree( ad );
	cudaFree( bd );
	cudaFree( cd );
	
	
	

	// print out values in c[0] , c[N-1]
 	printf("%d\n%d", c[0], c[N-1]);
	
	
	 
 	return EXIT_SUCCESS;
}
