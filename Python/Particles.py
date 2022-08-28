
# definition of a particle class for the particle swarm optimization
# the particle class has the following attributes:
#   - position: the current position of the particle
#   - velocity: the current velocity of the particle
#   - fitness: the current fitness of the particle
#   - pbest: the best position of the particle
#   - pbest_fitness: the best fitness of the particle
#   - inertia: the inertia weight of the particle
#   - cognitive: the cognitive weight of the particle
#   - social: the social weight of the particle

class Particles:
    def __init__(self, position, velocity, fitness, pbest, pbest_fitness):
        self.position = position
        self.velocity = velocity
        self.fitness = fitness
        self.pbest = pbest
        self.pbest_fitness = pbest_fitness

    def __str__(self):
        return "Particle: position: " + str(self.position) + " velocity: " + str(self.velocity) + " fitness: " + str(self.fitness) + " pbest: " + str(self.pbest) + " pbest_fitness: " + str(self.pbest_fitness)
