#!/bin/bash

# Run with static dimension of 1000 it 1000 particles and changing n of processors
# sh csv1.sh $NAMEOFTHEFILE.csv

filename=results/$1
it=1000

echo "Type;x;y;Best Fitness;Time" >> $filename
for name in {EGGHOLDER,EASOM}
do
    echo "Compiling for $name"
    sh compile.sh $name CSV

    for i in {1..5}
    do
        ./../exe/pso $it $it | grep Sequential >> $filename
    done
    echo "" >> $filename               
    for exe in {1..3..1}
    do
        for np in {1,8,16,24,32}
        do
            echo "" >> $filename
            for i in {1..5}
            do
                case $exe in
                        #OPENMP
                    1)  
                        ./../exe/pso_omp $it $it $np | grep OpenMP >> $filename
                        ;;

                        #MPI
                    2)
                        mpirun -np $np ../exe/pso_mpi $it $it | grep MPI >> $filename
                        ;;

                        #CUDA
                    3)  
                        case $np in
                        1)
                            ./../exe/pso_cuda $it $it 1 | grep CUDA >> $filename
                            ;;
                        8)
                            ./../exe/pso_cuda $it $it 128 | grep CUDA >> $filename
                            ;;
                        16)
                            ./../exe/pso_cuda $it $it 256 | grep CUDA >> $filename
                            ;;
                        24)
                            ./../exe/pso_cuda $it $it 512 | grep CUDA >> $filename
                            ;;
                        32)
                            ./../exe/pso_cuda $it $it 1024 | grep CUDA >> $filename
                            ;;
                        esac
                esac
            done
        done
    done
done

sed -i 's/\./,/g' $filename
