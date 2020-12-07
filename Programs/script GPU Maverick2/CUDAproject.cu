//sbatch Project_Script_Par
#include <stdio.h>
#include "timer.h"

const int N = 1000;
const int blocksize = 38;

__global__ void wordSearchSimple(char *Data, int dataLength, char *Target, int targetLen, int *count)
{
	int startIndex = threadIdx.x;
	int fMatch = 1;
    
    for (int i=0; i < targetLen; i++)
    {	
        if (Data[startIndex] != Target[i])
            fMatch = 0;
		
		printf( " Thread : %d , fMatch %d , Target : %c , Data [%d] : %c \n " , threadIdx.x, fMatch , Target[i] , threadIdx.x, Data[threadIdx.x]);
    }
	
    if (fMatch == 1)
        count[0]++;
}
int main()
{
    char *CharacterArray;
    char *SuckMyAss;
    int *IntArray;		
    int count[1] = {0};
    FILE *infile;
    char *BookData;
	char WORD[3] = {'h','e','y'};
    int numbytes;
	double start, finish, elapsed;
	
    const int booksize = N*sizeof(char);
    const int intsize = sizeof(int);
    infile = fopen("input.txt", "r");
    fseek(infile, 0L, SEEK_END);
    numbytes = ftell(infile);
    fseek(infile, 0L, SEEK_SET);
    BookData = (char*)calloc(numbytes, sizeof(char));
    fread(BookData, sizeof(char), numbytes, infile);
    fclose(infile);
    cudaMalloc( (void**)&CharacterArray, booksize );
    cudaMalloc( (void**)&SuckMyAss, booksize );
    cudaMalloc( (void**)&IntArray, intsize );
    cudaMemcpy( CharacterArray, BookData, booksize, cudaMemcpyHostToDevice ); 
    cudaMemcpy( SuckMyAss, WORD, booksize, cudaMemcpyHostToDevice ); 		
    cudaMemcpy( IntArray, count, intsize, cudaMemcpyHostToDevice );
    dim3 dimGrid(1, 1, 1 ); 	
	dim3 dimBlock( blocksize, 1, 1 );
	GET_TIME(start);
    wordSearchSimple<<<dimGrid, dimBlock>>>(CharacterArray, numbytes, SuckMyAss, 3, IntArray);
    cudaMemcpy( count, IntArray, intsize, cudaMemcpyDeviceToHost );
	GET_TIME(finish);
	
	elapsed = finish - start;
    cudaFree( CharacterArray );
	free(BookData);
	printf( "time is : %f \n number of occurances : %d " , elapsed, count[0] ); 
	 
 	return EXIT_SUCCESS;
}
