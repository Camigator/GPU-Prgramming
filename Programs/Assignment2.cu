// Cameron O'Neal

#include <stdio.h>
#include <math.h>


const double PI = 3.14159265;

//const int Samples = 8192;
const int N = 8;
const int Threadcount = 4;

// initalize Array's 

	
__global__
void FFT(double * R, double * img, double * XR, double * XI, double *c , double * s)
{	
	int i = blockIdx.x * blockDim.x + threadIdx.x;	
	

	
	XR[2*i] = (R[2*i] * c[2*i] - img[2*i] * s[2*i]*-1);
	XI[2*i] = (c[2*i]*img[2*i] - R[2*i] * s[2*i]);

	XR[2*i+1] = (R[2*i+1] * c[2*i+1] - img[2*i+1] * s[2*i+1]*-1);	
	XI[2*i+1] = (c[2*i+1]*img[2*i+1] - R[2*i+1] * s[2*i+1]);
	
	
}



int main()
{	
		
	
	double * ad;		//pointer to REAL array
 	double * bd;		//pointer to IMAGINARY array
	double * cd;		//pointer to XR array
	double * dd; 		//pointer to IR array
	double * c;
	double * s;
	
	
	// intializing array REAL & IMAGINARY to correct values
	double REAL[N];
	double IMAGINARY[N];
	double Cosine[N];
	double Sine[N];
	double XR[N];
	double XI[N];
	
	REAL[0] = 3.6; IMAGINARY[0] = 2.6;
	REAL[1] = 2.9; IMAGINARY[1] = 6.3;
	REAL[2] = 5.6; IMAGINARY[2] = 4.0;
	REAL[3] = 4.8; IMAGINARY[3] = 9.1;
	REAL[4] = 3.3; IMAGINARY[4] = 0.4;
	REAL[5] = 5.9; IMAGINARY[5] = 4.8;
	REAL[6] = 5.0; IMAGINARY[6] = 2.6;
	REAL[7] = 4.3; IMAGINARY[7] = 4.1;
	
		for(int i = 8; i < N; i++)
    	{  
			REAL[i] = 0;
		   IMAGINARY[i] = 0;
    	}
		
	for(int i = 0; i < N; i++)
		{  
			XR[i] = 0;
		   XI[i] = 0;
		}	
		
	double b;
	
	for (int i = 0; i < N/2 ; i++)
	{
		b= (2*PI*2*i)/N;
		Cosine[2*i] = cos(b);
		Sine[2*i] = sin(b);
		
		b= (2*PI*((2*i)+1))/N;
		Cosine[2*i + 1] = cos(b);
		Sine[2*i + 1] = sin(b);

	}
	
	

	const double isize = N*sizeof(double);
	
	//allocate pointers to global mem with size = Isize
 	cudaMalloc( (void**)&ad, isize );
 	cudaMalloc( (void**)&bd, isize );
 	cudaMalloc( (void**)&cd, isize );
	cudaMalloc( (void**)&dd, isize );
	cudaMalloc( (void**)&c, isize );
	cudaMalloc( (void**)&s, isize );
	

	// memory Data Transfer
 	cudaMemcpy( ad, REAL, isize, cudaMemcpyHostToDevice );
 	cudaMemcpy( bd, IMAGINARY, isize, cudaMemcpyHostToDevice );
	cudaMemcpy( cd, XR, isize, cudaMemcpyHostToDevice );
	cudaMemcpy( dd, XI, isize, cudaMemcpyHostToDevice );
	cudaMemcpy( c, Cosine, isize, cudaMemcpyHostToDevice );
	cudaMemcpy( s, Sine, isize, cudaMemcpyHostToDevice );
	

	
 	dim3 dimGrid( 4, 1 ); 		
	dim3 dimBlock( Threadcount, 1 );
	
	
	FFT<<<dimGrid, dimBlock>>>(ad, bd, cd, dd, c, s);
	cudaMemcpy( XR, cd, isize, cudaMemcpyDeviceToHost );
	cudaMemcpy( XI, dd, isize, cudaMemcpyDeviceToHost );
	
	printf("================================== \n" );
	for( int i = 0; i < N ; i++)
	{
			
			printf("XR[%d] : %f         XI[%d] : %f \n", i, XR[i], i, XI[i]);
			printf("================================== \n" );
	}
	
	
	

	// frees poiters
 	cudaFree( ad );
	cudaFree( bd );
	cudaFree( cd );
	cudaFree( dd ) ;
	cudaFree( c ) ;
	cudaFree( s ) ;
	
	
	 
 	return EXIT_SUCCESS;
}






