#!/bin/bash

filename=results/results1.csv

echo "Type;x;y;Best Fitness;Time" >> $filename

for exe in {0..3..1}
do
    for it in {1000..10000..1000}
    do
        case $exe in
                #SEQUENTIAL
            0)
                ./../exe/pso $it $it | grep Sequential >> $filename
                ;;

                #OPENMP
            1)  
                ./../exe/pso_omp $it $it | grep OpenMP >> $filename
                ;;

                #MPI
            2)
                mpirun ../exe/pso_mpi $it $it | grep MPI >> $filename
                ;;

                #CUDA
            3)
                ./../exe/pso_cuda $it $it | grep CUDA >> $filename
                ;;
        esac
    done
    #echo "" >> $filename
done
