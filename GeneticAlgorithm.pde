//"Constants"
int POPULATION_SIZE = 25;

//Global Variables
int selectedX;
int selectedY;
int bestX;
int bestY;
boolean continuous = false;
float totalFitness;
int speed;
int generation;
float mutationRate = 0.05;
int rad;
int row;
int col;

//The actual individuals
Individual[] population;
Individual selected;
Individual best;


/*=====================================
 Create an initial population of randomly
 generated individuals.
 Setup the basic window properties
 ====================================*/
void setup() {
  speed = 30;
  generation = 0;
  frameRate(speed);
  int temp = round(sqrt(POPULATION_SIZE));
  int temp2 = temp;
  while (POPULATION_SIZE % temp != 0 && POPULATION_SIZE % temp2 !=0) {
    temp--;
    temp2++;
  }
  if (POPULATION_SIZE % temp == 0) {
    row = temp;
    col = POPULATION_SIZE / row;
  } else {
    row = temp2;
    col = POPULATION_SIZE / row;
  }
  population = new Individual[POPULATION_SIZE];
  population[0] = new Individual(0.0, 0.0);
  rad = 5 + int(pow(population[0].RADIUS_GENE_SIZE, 2));
  populate();
  size(row * rad * 2, col * rad * 2);
}

/*=====================================
 Redraw very Individual in the population
 each frame. Make sure they are drawn in a grid without
 overlaping each other.
 If an individual has been slected (by the mouse), draw a box
 around it and draw a box around the individual with the
 highest fitness value.
 If mating mode is set to continuous, call mating season
 ====================================*/
void draw() {
  background(255, 255, 255);
  for (int i = 0; i < population.length; i++) {
    stroke(0, 0, 0);
    population[i].display();
  }
  if (continuous) {
    matingSeason();
  }
  if (selected != null) {
    noFill();
    stroke(255, 0, 0);
    rect(selectedX - rad, selectedY -rad, rad*2, rad*2);
    stroke(0, 0, 255);
    rect(bestX - rad, bestY - rad, rad*2, rad*2);
  }  
}

/*=====================================
 When the mouse is clicked, set selected to
 the individual clicked on, and set 
 selectedX and selectedY so that a box can be
 drawn around it.
 ====================================*/
void mouseClicked() {
  int beginX = 0;
  int beginY = 0;
  int endX = 0;
  int endY = 0;
  if (mouseX > rad) {
    beginX = mouseX - rad;
  }
  else {
    beginX = 0;
  }
  if (mouseY > rad) {
    beginY = mouseY - rad;
  }
  else {
    beginY = 0;
  }
  if (mouseX + rad < width) {
    endX = mouseX + rad;
  }
  else {
    endX = width;
  }
  if (mouseY + rad < height) {
    endY = mouseY + rad;
  }
  else {
    endY = height;
  }
  for (int i = 0; i < population.length; i++) {
    if ( (population[i].phenotype).x > beginX && (population[i].phenotype).x < endX
    && (population[i].phenotype).y > beginY && (population[i].phenotype).y < endY) {
      Individual temp = population[0];
      int tempx = int((population[i].phenotype).x);
      int tempy = int((population[i].phenotype).y);
      population[0] = population[i];
      (population[0].phenotype).x = rad;
      (population[0].phenotype).y = rad;
      population[i] = temp;
      (population[i].phenotype).x = tempx;
      (population[i].phenotype).y = tempy;
    }
  }
  selected = population[0];
  totalFitness();
  selectedX = int((selected.phenotype).x);
  selectedY = int((selected.phenotype).y);
}

/*====================================
 The following keys are mapped to actions:
 
 Right Arrow: move forard one generation
 Up Arrow: speed up when in continuous mode
 Down Arrow: slow down when in continuous mode
 Shift: toggle continuous mode
 Space: reset the population
 f: toggle fitness value display
 s: toggle smiley display
 m: increase mutation rate
 n: decrease mutation rate
 ==================================*/
void keyPressed() {
  if (keyCode == RIGHT) {
    matingSeason();
  }
  if (keyCode == UP) {
    System.out.print("Speed: ");
    speed += 5;
    frameRate(speed);
    System.out.println(speed);
  }
  if (keyCode == DOWN) {
    System.out.print("Speed: ");
    speed -= 5;
    frameRate(speed);
    System.out.println(speed);
  }
  if (keyCode == SHIFT) {
    continuous = !(continuous);
    if(continuous) {
      System.out.println("continuous");
    }
    else {
      System.out.println("non-continuous");
    }
  }
  if (keyCode == ' ') {
    generation = 0;
    populate();
  }
  if (keyCode == 'm' || keyCode == 'M') {
    System.out.print("Mutation Rate: ");
    if (mutationRate >= 100) {
      System.out.println("Maxed");
    }
    else {
      mutationRate += 0.01;
      System.out.println(mutationRate);
    }
  }
  if (keyCode == 'n' || keyCode == 'N') {
    System.out.print("Mutation Rate: ");
    if (mutationRate < 0) {
      System.out.println("Minimum");
    }
    mutationRate -= 0.01;
    System.out.println(mutationRate);
  } 
}


/*====================================
 select will return a pseudo-random chromosome from the population
 Uses roulette wheel selection:
 A random number is generated between 0 and the total fitness 
 Go through the population and add each member's fitness until you exceed the random 
 number that was generated.
 Return the individual that the algorithm stopped on
 Do not include the "selected" Blob as a possible return value
 ==================================*/
Individual select() {
  totalFitness();
  float sum = 0;
  int fin = 0;
  float rand = random(totalFitness);
  Individual[] temp = new Individual[population.length];
  arrayCopy(population, temp);
  int pos = 0;
  while (sum < rand) {
    pos = int(random(1, population.length));
    while (temp[pos] == null) {
      pos = int(random(1, population.length));
    }
    sum += temp[pos].fitness;
    if (sum < rand) {
      temp[pos] = null;
    }
  }
  return population[pos];
}

/*====================================
 
 Replaces the current population with a totally new one by
 selecting pairs of Individuals and "mating" them.
 Make sure that totalFitness is set before you use select().
 The goal shape (selected) should always be rist Individulation, unmodified.
 ==================================*/
void matingSeason() {
  int x = 0;
  int y = 0;
  Individual[] pop = new Individual[population.length];
  pop[0] = population[0];
  for (int i = 1; i < population.length; i++) {
    Individual parent1 = select();
    Individual parent2 = select();
    x = int((population[i].phenotype).x);
    y = int((population[i].phenotype).y);
    pop[i] = parent1.mate(parent2, x, y);
  }
  arrayCopy(pop, population);
  mutate();
  generation++;
  System.out.println("Generation: " + generation);
  totalFitness();
  System.out.println("Total Fitness: " + totalFitness);
  System.out.println("Best Fitness: " + best.fitness);
}

/*====================================
 
 Randomly call the mutate method an Individual (or Individuals)
 in the population.
 ==================================*/
void mutate() {
  for (int i = 1; i < population.length; i++) {
    float rand = random(1);
    if ( rand < mutationRate ) {
      population[i].mutate();
    }
  }
}

/*====================================
 
 Set the totalFitness to the sum of the fitness values
 of each individual.
 Make sure that each individual has an accurate fitness value
 ==================================*/
void totalFitness() {
  totalFitness = 0.0;
  for (int i = 1; i < population.length; i++) {
    population[i].setFitness(selected);
    totalFitness += population[i].fitness;
  }
  findBest();
}

/*====================================
 Fill the population with randomly generated Individuals
 Make sure to set the location of each individual such that
 they display nicely in a grid.
 ==================================*/
void populate() {
  int cRow = 1;
  int cCol = 1;
  for (int i = 0; i < population.length; i++) {
    population[i] = new Individual(cRow * rad, cCol * rad);
    cCol+=2;
    if (cCol > 2 * col) {
      cCol = 1;
      cRow += 2;
    }
  }
}

/*====================================
 Go through the population and find the Individual with the 
 highest fitness value.
 Set bestX and bestY so that the best Individual can have a 
 square border drawn around it.
 ==================================*/
void findBest() {
  best = population[1];
  for (int i = 2; i < population.length; i++) {
    if (best.fitness < population[i].fitness) {
      best = population[i];
    }
  }
  bestX = int((best.phenotype).x);
  bestY = int((best.phenotype).y);
}


