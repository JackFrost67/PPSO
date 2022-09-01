#ifndef PARTICLE_STRUCT_H
#define PARTICLE_STRUCT_H

#if defined(EGGHOLDER)
    #define MAX_D 512
    #define MIN_D -512
#elif defined(EASOM)
    #define MAX_D 100
    #define MIN_D -100
#endif

#define MAX_V 10
#define MIN_V -10

#include "utils.h"

class Particle 
{
    public:
        Position pbest; // best position of the particle
        Position position; // current position
        Position velocity; // velocity of the particle
        float pbest_fitness; // personal best fitness

        // Constructor
        Particle() 
        {
            position = {rand_uniform(MIN_D, MAX_D), rand_uniform(MIN_D, MAX_D)};
            velocity = {0.0f, 0.0f};
            pbest = position;
            pbest_fitness = evaluate(position);
        }

        // Update the particle's position based on its velocity
        void update(Position &gbest, float &gbest_fitness, float inertia, float cognitive, float social) 
        {
            float r1 = rand_uniform(0.0f, 1.0f);
            float r2 = rand_uniform(0.0f, 1.0f);
            
            // update velocity
            this->velocity.x = inertia * this->velocity.x + cognitive * r1 * (this->pbest.x - this->position.x) + social * r2 * (gbest.x - this->position.x);
            this->velocity.y = inertia * this->velocity.y + cognitive * r1 * (this->pbest.y - this->position.y) + social * r2 * (gbest.y - this->position.y);
            
            //check costraints on velocity
            if(this->velocity.x > MAX_V) 
            {
                this->velocity.x = MAX_V;
            }
            else if(this->velocity.x < MIN_V) 
            {
                this->velocity.x = MIN_V;
            }
            
            if(this->velocity.y > MAX_V)
            {
                this->velocity.y = MAX_V;
            }
            else if(this->velocity.y < MIN_V) 
            {
                this->velocity.y = MIN_V;
            }
            
            // update position
            this->position.x = this->position.x + this->velocity.x;
            this->position.y = this->position.y + this->velocity.y;

            //check costraints on position
            if(this->position.x > MAX_D)
            {
                this->position.x = MAX_D;
            }
            else if(this->position.x < MIN_D) 
            {
                this->position.x = MIN_D;
            }

            if(this->position.y > MAX_D) 
            {
                this->position.y = MAX_D;
            }
            else if(this->position.y < MIN_D) 
            {
                this->position.y = MIN_D;
            }

            // update pbest
            float fitness = evaluate(this->position);

            if(fitness < this->pbest_fitness) 
            {
                this->pbest = this->position;
                this->pbest_fitness = fitness;
            }

            //update gbest
            if(fitness < gbest_fitness) 
            {
                gbest = this->position;
                gbest_fitness = fitness;
            }
        }
};

#endif // PARTICLE_STRUCT_H