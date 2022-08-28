#!/bin/bash

if [ "$#" -eq 2 ];
then
    CSV=\-D$2
else
    CSV=""
fi

if [ "$1" == "EGGHOLDER" ] || [ "$1" == "EASOM" ];
then
    echo "Compiling with objective function: $1"
    #SEQUENTIAL
    echo "Compiling sequential ..."
    g++ ../src/main.cpp -Ofast -I../include -Wall -D$1 $CSV -std=c++11 -o ../exe/pso

    #OPENMP
    echo "Compiling OpenMP ..."
    g++ ../src/main_omp.cpp -Ofast -fopenmp -I../include -Wall -D$1 $CSV -std=c++11 -o ../exe/pso_omp

    #MPI
    echo "Compiling MPI ..."
    mpic++ -Ofast ../src/main_mpi.cpp -I../include -D$1 $CSV -std=c++11 -o ../exe/pso_mpi

    #CUDA
    echo "Compiling CUDA ..."
    nvcc ../src/main.cu -O3 -I../include -D$1 $CSV -std=c++11 -arch=sm_20 -o ../exe/pso_cuda
else
    echo "Invalid argument"
fi
