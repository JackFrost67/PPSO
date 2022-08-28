#ifndef MAIN_H
#define MAIN_H

#include "utils.h"
#include "particle.h"

#include <chrono> 
#include <iostream>

float inertia = 0.0f;
float cognitive = 0.0f;
float social = 0.0f;

int n_iterations = 1000;
int n_particles = 1000;

Position gbest = {rand_uniform(MIN_D, MAX_D), rand_uniform(MIN_D, MAX_D)};
float gbest_fitness = evaluate(gbest);

#endif // MAIN_H