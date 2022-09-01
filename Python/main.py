#!/usr/bin/python3

from matplotlib.animation import FuncAnimation
import Particles
import numpy as np
from numpy import random
import matplotlib.pyplot as plt
from itertools import groupby

max_velocity = 0.1  # maximum velocity of a particle
min_velocity = -max_velocity
max_position_x = 5  # maximum dimension x of the map
min_position_x = -5  # minimum dimension x of the map
max_position_y = 5  # maximum dimension y of the map
min_position_y = -5  # minimum dimension y of the map

n_iterations = 100  # maximum number of iterations
n_particles = 1000  # number of particles in the swarm
n_dimension = 2


def evaluate(position):
    # evaluate the fitness of a particle at a given position for a given objective function
    x = position[0]
    y = position[1]

    # Ackley function [-5, 5] opt(0, 0) = 0
    return -20 * (np.exp(-0.2 * np.sqrt(0.5 * (x**2 + y**2)))) - \
        np.exp(0.5 * (np.cos(2 * np.pi * x) + np.cos(2 * np.pi * y))) + np.e + 20

    # Goldestein-Price function [-2, 2] opt(0, -1) = 3
    '''
    return (1 + (x + y + 1)**2 * (19 - 14 * x + 3 * x**2 - 14 * y + 6 * x * y + 3 * y**2)) * \
        (30 + (2 * x - 3 * y)**2 * (18 - 32 * x + 12 * x**2 + 48 * y - 36 * x * y + 27 * y**2)) \
    '''

    # Booth function [-10, 10] opt(1, 3) = 0
    # return (x + 2 * y - 7)**2 + (2 * x + y - 5)**2

    # Rosenbrock function opt(1, 1) = 0
    # return (1 - x)**2 + 100 * (y - x**2)**2

    # Rastrigin function [-5.12, 5.12] opt(0, 0) = 0
    # return 10 * n_dimension + (x**2 - 10 * np.cos(2 * np.pi * x)) + (y**2 - 10 * np.cos(2 * np.pi * y))

    # Schwefel function [-500, 500] opt(420.97, 420.97) = 0
    # return (418.9829 * n_dimension) - (x * np.sin(np.sqrt(abs(x)))) - (y * np.sin(np.sqrt(abs(y))))


swarm = []
gbest = [random.uniform(min_position_x, max_position_y, 1)[0],
         random.uniform(min_position_y, max_position_y, 1)[0]]
gbest_fitness = evaluate(gbest)


def update(swarm, gbest_fitness, gbest, it):
    inertia = (0.4 / (n_iterations**2)) * (it - n_iterations)**2 + 0.4
    cognitive = -3 * (it / n_iterations) + 3.5
    social = 3 * (it / n_iterations) + 0.5

    # update the position and velocity component of the particles in the swarm
    for i in range(n_particles):
        # update the velocity and position component singularly of the particle
        for j in range(n_dimension):
            # update the velocity component
            r1 = random.random()
            r2 = random.random()

            swarm[i].velocity[j] = (inertia * swarm[i].velocity[j]) + \
                (cognitive * (r1 * (swarm[i].pbest[j] - swarm[i].position[j]))) + \
                (social * (r2 * (gbest[j] - swarm[i].position[j]))) \

            if swarm[i].velocity[j] >= max_velocity:
                swarm[i].velocity[j] = max_velocity
            elif swarm[i].velocity[j] < min_velocity:
                swarm[i].velocity[j] = min_velocity

            # update the position component
            swarm[i].position[j] = swarm[i].position[j] + swarm[i].velocity[j]

        # check if the position component is within the bounds
        if swarm[i].position[0] >= max_position_x:
            swarm[i].position[0] = max_position_x
        elif swarm[i].position[0] < min_position_x:
            swarm[i].position[0] = min_position_x

        if swarm[i].position[1] >= max_position_y:
            swarm[i].position[1] = max_position_y
        elif swarm[i].position[1] < min_position_y:
            swarm[i].position[1] = min_position_y

        # update the fitness component
        swarm[i].fitness = evaluate(swarm[i].position)

        # update the pbest component
        if swarm[i].fitness < swarm[i].pbest_fitness:
            swarm[i].pbest = swarm[i].position
            swarm[i].pbest_fitness = swarm[i].fitness

        # update the gbest component
        if swarm[i].pbest_fitness < gbest_fitness:
            gbest = swarm[i].pbest
            gbest_fitness = swarm[i].pbest_fitness

    return swarm, gbest_fitness, gbest


def main():
    global swarm, gbest_fitness, gbest
    # initialize a swarm of particles randomly
    for _ in range(n_particles):
        position = [random.uniform(min_position_x, max_position_y, 1)[0],
                    random.uniform(min_position_y, max_position_y, 1)[0]]
        velocity = [0, 0]
        fitness = evaluate(position)
        pbest = position
        pbest_fitness = fitness
        swarm.append(Particles.Particles(position, velocity, fitness,
                     pbest, pbest_fitness))

    # prepare the contour plot
    x_, y_ = np.array(np.meshgrid(np.arange(min_position_x, max_position_x, 0.1, dtype=float),
                                  np.arange(min_position_y, max_position_y, 0.1, dtype=float)))
    z_ = evaluate([x_, y_])
    # level = [k for k, _ in groupby(z_.ravel())]

    # set up the plot for the animated plot
    fig, ax = plt.subplots()
    fig.set_tight_layout(True)
    img = ax.imshow(z_, extent=[min_position_x, max_position_x, min_position_y, max_position_y],
                    origin='lower', cmap='viridis', alpha=0.5)
    fig.colorbar(img, ax=ax)
    contours = plt.contour(x_, y_, z_, 10)
    ax.clabel(contours, inline=True, fontsize=8, fmt='%.0f')
    # plot the swarm of particles
    plot = ax.scatter([particle.position[0] for particle in swarm],
                      [particle.position[1] for particle in swarm], c='r', marker='o')
    ax.set_xlim(min_position_x, max_position_x)
    ax.set_ylim(min_position_y, max_position_y)

    # Function for animating the plot
    def animate(i):
        global swarm, gbest_fitness, gbest
        title = 'Iteration: ' + str(i)
        swarm, gbest_fitness, gbest = update(swarm, gbest_fitness, gbest, i)
        ax.set_title(title)
        plot.set_offsets([particle.position for particle in swarm])

    anim = FuncAnimation(fig, func=animate, frames=list(range(n_iterations)),
                         interval=0.5, blit=False, repeat=False, cache_frame_data=False)

    anim.save("Ackley.mp4", fps=30)

    # print the best particle position and fitness
    print("Position best:", gbest, "Fitness:", gbest_fitness)


if __name__ == '__main__':
    main()
