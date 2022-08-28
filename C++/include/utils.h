#ifndef UTILS_TEST_H
#define UTILS_TEST_H

#include <math.h>
#include <random>
#include <string>

// Position struct contains x and y coordinates 
struct Position 
{
    float x, y; 

    std::string toString() 
    {
        return "(" + std::to_string(x) + " , " + std::to_string(y) + ")"; 
    }

    void operator+=(const Position& a) 
    {
        x = x + a.x;
        y = y + a.y; 
    }

    void operator=(const Position& a) 
    {
        x = a.x; 
        y = a.y; 
    }
};

float evaluate(Position pos)
{
    #if defined(EGGHOLDER)
        // Eggholder function [-512, 404.2319] -959.6407
        return (-(pos.y + 47)) * sin(sqrt(abs(pos.y + (pos.x / 2) + 47))) - (pos.x * sin(sqrt(abs(pos.x - (pos.y + 47)))));
    #elif defined(EASOM)
        // Easom function [pi, pi] -1
        return -cos(pos.x) * cos(pos.y) * exp(-(pow(pos.x - M_PI, 2) + pow(pos.y - M_PI, 2)));
    #endif
}

// Function to get random values in an interval
float rand_uniform(float min, float max)
{
    std::random_device generator;
    std::uniform_real_distribution<float> distribution(min, max);
    return distribution(generator);
}

#endif // UTILS_TEST_H