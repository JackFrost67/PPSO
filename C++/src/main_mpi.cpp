#include "main.h"
#include "mpi.h"

int main(int argc, char** argv)
{   
    std::chrono::time_point<std::chrono::high_resolution_clock> start;
    MPI_Init(NULL, NULL);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int distributed_particles = n_particles / size;
    Particle *swarm = new Particle[distributed_particles];

    float *m_gbest_fitnes = new float[size];
    Position *m_gbest = new Position[size];

    if(argc != 1)
    {
        n_iterations = atoi(argv[1]);
        n_particles = atoi(argv[2]);
    }

    if(rank == 0)
    {   
        std::cout << "Iterations: " << n_iterations << "\tParticles: " << n_particles << std::endl;

        // measure time of execution of the algorithm
        start = std::chrono::high_resolution_clock::now();
    }

    // update each particle in the swarm for n_iterations times
    for (int it = 0; it < n_iterations; it++)
    {
        // adaptive parameter 
        inertia = (0.4f / (n_iterations * n_iterations)) * ((it - n_iterations) * (it - n_iterations))  + 0.4f;
        cognitive = (-3.f * ((float) it / (float) n_iterations)) + 3.5f;
        social = (3.f * ((float) it / (float) n_iterations)) + 0.5f;
        
        for(int i = 0; i < distributed_particles; i++)
        {   
            swarm[i].update(gbest, gbest_fitness, inertia, cognitive, social);
        }
    }
    
    if(rank == 0) 
    {
        // receive the best particle from each process
        for(int i = 1; i < size; i++)
        {
            MPI_Recv(&m_gbest[i].x, 1, MPI_FLOAT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            MPI_Recv(&m_gbest[i].y, 1, MPI_FLOAT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            MPI_Recv(&m_gbest_fitnes[i], 1, MPI_FLOAT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }
        m_gbest[0] = gbest;
        m_gbest_fitnes[0] = gbest_fitness;

        // get the index of the maximum gbest_fitness value
        int index = 0;
        for(int i = 1; i < size; i++)
        {
            if(m_gbest_fitnes[i] < m_gbest_fitnes[index])
            {
                index = i;
            }
        }

        gbest = m_gbest[index];
        gbest_fitness = m_gbest_fitnes[index];

        auto stop = std::chrono::high_resolution_clock::now();
        std::chrono::duration<float, std::milli> duration = stop - start;

        // print the best position and fitness
        #ifdef CSV
            printf("MPI;%.2f;%.2f;%.2f;%.2f\n", gbest.x, gbest.y, gbest_fitness, duration.count());
            //std::cout << "MPI;" << gbest.x << ";" << gbest.y << ";" << gbest_fitness << ";" << duration.count() << std::endl;
        #else
            std::cout << "Best position: (" << gbest.x << " , " << gbest.y << ") | Best fitness: " << gbest_fitness << " | Time: " << duration.count() << " ms" << std::endl;
        #endif

    }
    else
    {
        // send gbest to rank 0
        MPI_Send(&gbest.x, 1, MPI_FLOAT, 0, 0, MPI_COMM_WORLD);
        MPI_Send(&gbest.y, 1, MPI_FLOAT, 0, 0, MPI_COMM_WORLD);
        MPI_Send(&gbest_fitness, 1, MPI_FLOAT, 0, 0, MPI_COMM_WORLD);
    }
    
    delete[] swarm;
    MPI_Finalize();

    return 0;
}