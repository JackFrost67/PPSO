#include "main.h"
#include "omp.h"

// ./particle_swarm_optimization n_iterations n_particles
int main(int argc, char *argv[])
{   
    int n_proc = omp_get_num_procs();
    // For benchmarking purposes
    if(argc != 1)
    {
        n_iterations = atoi(argv[1]);
        n_particles = atoi(argv[2]);
        
        if(argc == 4)
            n_proc = atoi(argv[3]);
    }
    Particle* swarm = new Particle[n_particles]; 

    // measure time of execution of the algorithm
    auto start = std::chrono::high_resolution_clock::now();

    // update each particle in the swarm for n_iterations times
    for(int it = 0; it < n_iterations; it++)
    {   
        // adaptive parameter 
        inertia = (0.4f / (n_iterations * n_iterations)) * ((it - n_iterations) * (it - n_iterations))  + 0.4f;
        cognitive = (-3.f * ((float) it / (float) n_iterations)) + 3.5f;
        social = (3.f * ((float) it / (float) n_iterations)) + 0.5f;
        
        #pragma omp parallel for schedule(static) num_threads(n_proc)
        for(int i = 0; i < n_particles; i++)
        {   
            swarm[i].update(gbest, gbest_fitness, inertia, cognitive, social);
        }
        
    }
    auto stop = std::chrono::high_resolution_clock::now();
    // duration as float
    std::chrono::duration<float, std::milli> duration = stop - start;

    // print the best position and fitness
    #ifdef CSV
        printf("OpenMP;%.2f;%.2f;%.2f;%.2f\n", gbest.x, gbest.y, gbest_fitness, duration.count());
        //std::cout << "OpenMP;" << gbest.x << ";" << gbest.y << ";" << gbest_fitness << ";" << duration.count() << std::endl;
    #else
        std::cout << "Best position: (" << gbest.x << " , " << gbest.y << ") | Best fitness: " << gbest_fitness << " | Time: " << duration.count() << " ms" << std::endl;
    #endif
    
    delete[] swarm;
    return 0;
}
