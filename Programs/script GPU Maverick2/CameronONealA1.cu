// Cameron O'Neal

#include <stdio.h>

const int N = 4096;
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
	
	
		
	int Sum = 0;	//add all integer in c array
	int *ad;		//pointer to a array
 	int *bd;		//pointer to b array
	int *cd;		//pointer to c array
	
	// intializing array a & b to correct values
	for(int i = 0; i < 4096; i++)
	{
		a[i] = i;
		b[i] = 4095 + i;
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

	
 	dim3 dimGrid( 4, 1 ); 	
	dim3 dimBlock( blocksize, 1 );

	// calls addition function -> sending pointer to arrays
 	Addition<<<dimGrid, dimBlock>>>(ad, bd, cd);

	//retreaving data from host
 	cudaMemcpy( c, cd, isize ,cudaMemcpyDeviceToHost );

	// frees poiters
 	cudaFree( ad );
	cudaFree( bd );
	cudaFree( cd );
	
	// adding the sum in array c
	for(int i = 0; i < 4096; i++)
	{
		Sum += c[i];
	}	

	// print out values in c[0] , c[4095] , and sum of all values.
 	printf("%d\n%d\n%d", c[0], c[4095], Sum);
	 
 	return EXIT_SUCCESS;
}
