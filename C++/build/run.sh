#!/bin/bash

filename=results/results.txt

for exe in {0..3..1}
do
    for it in {1000..10000..1000}
    do
        case $exe in
                #SEQUENTIAL
            0)
                echo "Sequential: $it $it"
                echo -e "Sequential: $it $it" >> $filename
                ./../exe/pso $it $it | grep Best >> $filename
                ;;

                #OPENMP
            1)  
                echo "OPENMP: $it $it"
                echo -e "OPENMP: $it $it" >> $filename
                ./../exe/pso_omp $it $it | grep Best >> $filename
                ;;

                #MPI
            2)
                echo "MPI: $it $it"
                echo -e "MPI: $it $it" >> $filename
                mpirun.openmpi ../exe/pso_mpi $it $it | grep Best >> $filename
                ;;

                #CUDA
            3)
                echo "CUDA: $it $it"
                echo -e "CUDA: $it $it" >> $filename
                ./../exe/pso_cuda $it $it | grep Best >> $filename
                ;;
        esac
    done
    echo "" >> $filename
done
