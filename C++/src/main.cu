#include <cuda_runtime.h>
#include <cuda.h>
#include <curand_kernel.h>

#include "main.h"

#define N_DIMENSION 2 //for the sake of clarity in the code

// Initialize state for random numbers 
__global__ void init_kernel(curandState *state, long seed) 
{
    int idx = threadIdx.x + blockIdx.x * blockDim.x; 
    curand_init(seed, idx, 0, state);
}

__device__ float d_evaluate(Position pos)
{
    #if defined(EGGHOLDER)
        // Eggholder function [-512, 404.2319] -959.6407
        return (-(pos.y + 47)) * sin(sqrt(abs(pos.y + (pos.x / 2) + 47))) - (pos.x * sin(sqrt(abs(pos.x - (pos.y + 47)))));
    #elif defined(EASOM)
        // Easom function [pi, pi] -1
        return -cos(pos.x) * cos(pos.y) * exp(-(pow(pos.x - M_PI, 2) + pow(pos.y - M_PI, 2)));
    #endif
}

__global__ void pso_kernel(Particle* swarm, Position* gbest, float &gbest_fitness, float inertia, float cognitive, float social, int n_particles, curandState* state)
{
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    
    if(id < n_particles)
    {
        float r1 = curand_uniform(state);
        float r2 = curand_uniform(state);

        //update position and velocity
        swarm[id].velocity.x = swarm[id].velocity.x * inertia + cognitive * r1 * (swarm[id].pbest.x - swarm[id].position.x) + social * r2 * (gbest->x - swarm[id].position.x);
        swarm[id].velocity.y = swarm[id].velocity.y * inertia + cognitive * r1 * (swarm[id].pbest.y - swarm[id].position.y) + social * r2 * (gbest->y - swarm[id].position.y);

        //check constraints
        if (swarm[id].velocity.x > MAX_V)
            swarm[id].velocity.x = MAX_V;
        else if (swarm[id].velocity.x < MIN_V)
            swarm[id].velocity.x = MIN_V;
        
        if (swarm[id].velocity.y > MAX_V)
            swarm[id].velocity.y = MAX_V;
        else if (swarm[id].velocity.y < MIN_V)
            swarm[id].velocity.y = MIN_V;

        //update position
        swarm[id].position.x += swarm[id].velocity.x;
        swarm[id].position.y += swarm[id].velocity.y;

        //check constraints
        if (swarm[id].position.x > MAX_D)
            swarm[id].position.x = MAX_D;
        else if (swarm[id].position.x < MIN_D)
            swarm[id].position.x = MIN_D;
        
        if (swarm[id].position.y > MAX_D)
            swarm[id].position.y = MAX_D;
        else if (swarm[id].position.y < MIN_D)
            swarm[id].position.y = MIN_D;

        //update fitness
        float fitness = d_evaluate(swarm[id].position);

        //update pbest
        if (fitness < swarm[id].pbest_fitness)
        {
            swarm[id].pbest_fitness = fitness;
            swarm[id].pbest.x = swarm[id].position.x;
            swarm[id].pbest.y = swarm[id].position.y;
        }

        if (swarm[id].pbest_fitness < gbest_fitness)
        {
            gbest_fitness = swarm[id].pbest_fitness;
            gbest->x = swarm[id].position.x;
            gbest->y = swarm[id].position.y;
        }
    }
}

int main(int argc, char** argv){
    if(argc != 1)
    {
        n_iterations = atoi(argv[1]);
        n_particles = atoi(argv[2]);
    }

    //std::cout << "Iterations: " << n_iterations << "\tParticles: " << n_particles << std::endl;

    // Thread and block dimensions
    int threadsNum = 1024;
    int blocksNum = (n_particles + threadsNum - 1) / threadsNum;

    curandState* state;
    cudaMalloc(&state, n_particles * sizeof(curandState));
    init_kernel<<<1, 1>>>(state, time(NULL));

    // initialize the particles 
    Particle *particles = new Particle[n_particles];

    // define dev pointers to particles and gbest gbest_fitness
    Particle *d_particles;
    float *d_gbest_fitness;
    Position *d_gbest;

    // meausre time of execution of the algorithm
    auto start = std::chrono::high_resolution_clock::now();

    cudaMalloc((void **)&d_particles, n_particles * sizeof(Particle));
    cudaMalloc((void **)&d_gbest_fitness, sizeof(float));
    cudaMalloc((void **)&d_gbest, sizeof(Position));

    // Copy particles to device
    cudaMemcpy(d_particles, particles, n_particles * sizeof(Particle), cudaMemcpyHostToDevice);
    cudaMemcpy(d_gbest_fitness, &gbest_fitness, sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_gbest, &gbest, sizeof(Position), cudaMemcpyHostToDevice);

    // Launch the kernel for each iteration
    for(int it = 0; it < n_iterations; it++)
    {
        // adaptive parameter 
        inertia = (0.4f / (n_iterations * n_iterations)) * ((it - n_iterations) * (it - n_iterations))  + 0.4f;
        cognitive = (-3.f * ((float) it / (float) n_iterations)) + 3.5f;
        social = (3.f * ((float) it / (float) n_iterations)) + 0.5f;
        
        pso_kernel<<<blocksNum, threadsNum>>>(d_particles, d_gbest, *d_gbest_fitness, inertia, cognitive, social, n_particles, state);
    }

    // Copy gbest fitness and gbest to host
    cudaMemcpy(&gbest_fitness, d_gbest_fitness, sizeof(float), cudaMemcpyDeviceToHost);
    cudaMemcpy(&gbest, d_gbest, N_DIMENSION * sizeof(float), cudaMemcpyDeviceToHost);

    auto stop = std::chrono::high_resolution_clock::now();
    // duration as float
    std::chrono::duration<float, std::milli> duration = stop - start;
    
    // print the best position and fitness
    #ifdef CSV
        printf("CUDA;%.2f;%.2f;%.2f;%.2f\n", gbest.x, gbest.y, gbest_fitness, duration.count());
        //std::cout << "CUDA;" << gbest.x << ";" << gbest.y << ";" << gbest_fitness << ";" << duration.count() << std::endl;
    #else
        std::cout << "Best position: (" << gbest.x << " , " << gbest.y << ") | Best fitness: " << gbest_fitness << " | Time: " << duration.count() << " ms" << std::endl;
    #endif

    // Free memory
    cudaFree(d_particles);
    cudaFree(d_gbest_fitness);
    cudaFree(d_gbest);
    cudaFree(state);

    delete[] particles;

    return 0;
}
