//*****************************************************************
// Assignment #2
// Name: Alex Trampert and Cameron O'Neal
// GPU Programming Date: Date of Submission (10/16/2020)
//*****************************************************************
// The purpose of this progam is to solve for complex numbers
// using the Fast Fourier Transform(FFT). The FFT paired with blocks
// and thread partitions allows for the gpu to divide the data to increase 
// processing speed. We input a set of 8 complex and Imaginary numbers 
// filling the rest of our array values with 0. The program is to take 
// complex numbers, partition specific threads to solve the FFT odds and evens.
// The solving of the FFT odds and evens provides us with a Fourier Coeificient
// as the final result.
//*****************************************************************

#include <stdio.h>
#include <math.h>
#include <complex.h>

//initializing basics values
const int N = 8192;
const int blocksize = 1024;

//******************************************************************
// function Name::computeEven()
// Parameters: 
// *xr  - initial reals array pointer 
// *xi  - initial imaginaries array pointer
// *fr  - final reals array pointer 
// *fi  - final imaginaries array pointer
// computes the even portion of the FFT
// using the various threads and dimensions
//********************************************************************
__global__
void computeEven(double *xr, double *xi, double *fr, double *fi)
{	int i = (blockIdx.x * blockDim.x + threadIdx.x) * 2;
	/*
	//loop 4 times using j
	double _Complex z1 = xr[j] + xi[j] * I;
	double temp1 = cos(2 * 3.1415 * (j/8));
	double temp2 = (sin(2 * 3.1415 * (j/8)) * -1);
	double _Complex z2 = temp1 + temp2 * I;
	double _Complex product = z1 * z2;
	*/
	//Trying to use complex library so the computer can keep track
	//of real and imaginary but it will not recognize any form of
	//I we use (_I, _Complex_I, i)
	//j is the iteration we are on (evens - 0-2-4-6)
	//would store calculated real portion in fr[j] and imag portion in fi[j]
}
//******************************************************************
// function Name::computeOdd()
// Parameters: 
// *xr  - initial reals array pointer 
// *xi  - initial imaginaries array pointer
// *fr  - final reals array pointer 
// *fi  - final imaginaries array pointer
// computes the odd portion of the FFT
// using the various threads and dimensions
//********************************************************************
__global__
void computeOdd(double *xr, double *xi, double *fr, double *fi)
{	int i = ((blockIdx.x * blockDim.x + threadIdx.x) * 2) + 1;
	/*
	//loop 4 times using j
	double _Complex z1 = xr[j] + xi[j] * I;
	double temp1 = cos(2 * 3.1415 * (j/8));
	double temp2 = (sin(2 * 3.1415 * (j/8)) * -1);
	double _Complex z2 = temp1 + temp2 * I;
	double _Complex product = z1 * z2;
	*/
	
	//Trying to use complex library so the computer can keep track
	//of real and imaginary but it will not recognize any form of
	//I we use (_I, _Complex_I, i)
	//j is the iteration we are on (odds - 1-3-5-7)
	//would store calculated real portion in fr[j] and imag portion in fi[j]
}

int main()
{	//initializing arrays and sum integer
	double xr[N];
	double xi[N];
	double fr[N];
	double fi[N];
	double totalr = 0, totali = 0;

	//pointers for passing arrays
	double *xrd;
	double *xid;
	double *frd;
	double *fid;
	
	//hard coding the first 8 samples
	xr[0] = 3.6; xi[0] = 2.6;
	xr[1] = 2.9; xi[1] = 6.3;
	xr[2] = 5.6; xi[2] = 4.0;
	xr[3] = 4.8; xi[3] = 9.1;
	xr[4] = 3.3; xi[4] = 0.4;
	xr[5] = 5.9; xi[5] = 4.8;
	xr[6] = 5.0; xi[6] = 2.6;
	xr[7] = 4.3; xi[7] = 4.1;

	//filling arrays with the rest of samples
	for(int i = 8; i < N; i++)
    	{  xr[i] = 0;
		   xi[i] = 0;
    	}
	for(int i = 0; i < N; i++)
		{  fr[i] = 0;
		   fi[i] = 0;
		}

 	//value for data size
 	const double isize = N*sizeof(double);
	
	//allocating pointers with isize
 	cudaMalloc( (void**)&xrd, isize );
	cudaMalloc( (void**)&xid, isize );
	cudaMalloc( (void**)&frd, isize );
	cudaMalloc( (void**)&fid, isize );
 	
	//data transfers to function
 	cudaMemcpy( xrd, xr, isize, cudaMemcpyHostToDevice );
	cudaMemcpy( xid, xi, isize, cudaMemcpyHostToDevice );
	cudaMemcpy( frd, fr, isize, cudaMemcpyHostToDevice );
	cudaMemcpy( fid, fi, isize, cudaMemcpyHostToDevice );

	//4 blocks each consisting of 1024 threads
 	dim3 dimGrid( 4, 1 ); 	
	dim3 dimBlock( blocksize, 1 );

	//calling function with 4096 threads to work on evens
 	computeEven<<<dimGrid, dimBlock>>>(xrd, xid, frd, fid);

	//calling function with 4096 threads to work on odds
 	computeOdd<<<dimGrid, dimBlock>>>(xrd, xid, frd, fid);

	//data transfer to get new information in arrays from functions
 	cudaMemcpy( fr, frd, isize, cudaMemcpyDeviceToHost );
	cudaMemcpy( fi, fid, isize, cudaMemcpyDeviceToHost );
 	cudaFree( xrd );
	cudaFree( xid );
	cudaFree( frd );
	cudaFree( fid );

	//formatting output and summing totals of samples
	printf("TOTAL PROCESSED SAMPLES: %d\n", N);
	for(int i = 0; i < N/8; i++)
    	{  	totalr = 0; totali = 0;
			for(int j = 0; j < 8; j++)
			{ totalr += fr[j * i];
			  totali += fi[j * i];
			}
			printf("========================================\n");
			printf("XR[%d]: %f   XI[%d]: %f\n", i, totalr, i, totali);
    	}
	//sums up total for calculated real and imaginary arrays
	//groups them into samples of 8 numbers as in Table 1.Data of Time-Domain
	
 	return EXIT_SUCCESS;
}