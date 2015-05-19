/*=====================================
 Each individual contains an array of genes that code for
 particular traits to be visually represented as a
 regular polygon.
 Instance variables:
 chromosome
 An array of genes, each entry corresponds to a
 specific trait in the following order:
 sides: number of sides
 rad: the distance from the center of the regulargon to any vertex
 red_color: red value
 green_color: green value
 blue_color: blue value
 x_factor: "wobble" factor for x values
 y_factos: "wobbly" factor for y values
 phenotype
 A regularGon object with traits the correspond to
 the values found in chromosome.
 fitness
 how "close" the Individual is to the desired state
 ====================================*/

class Individual {

  /*=====================================
   Number of genes in each chromosome and the
   unique indentifier for each gene type
   ====================================*/
  int CHROMOSOME_LENGTH = 7;
  int SIDES = 0;
  int RAD = 1;
  int RED_COLOR = 2;
  int GREEN_COLOR = 3;
  int BLUE_COLOR = 4;
  int X_FACTOR = 5;
  int Y_FACTOR = 6;

  /*=====================================
   Constants defining how long each gene will be.
   For initial developmen set these to lower
   values to make testing easier.
   ====================================*/
  int SIDE_GENE_SIZE = 6;
  int RADIUS_GENE_SIZE = 6;
  int COLOR_GENE_SIZE = 8;
  int FACTOR_GENE_SIZE = 2;

  //Instance variables
  Gene[] chromosome;
  Blob phenotype;
  float fitness;


  /*=====================================
   Create a New Individual by setting each entry in chromosome
   to a new randomly created gene of the appropriate length.
   
   After the array is populated, set phenotype to a new regulargon
   with center cx, cy and properties that align with gene values.
   (i.e. if the sides gene is 4, the regulargon should have 4
   sides...)
   ====================================*/
  Individual(float cx, float cy) {
    chromosome = new Gene[7];
    chromosome[SIDES] = new Gene(SIDE_GENE_SIZE);
    chromosome[RAD] = new Gene(RADIUS_GENE_SIZE);
    chromosome[RED_COLOR] = new Gene(COLOR_GENE_SIZE);
    chromosome[GREEN_COLOR] = new Gene(COLOR_GENE_SIZE);
    chromosome[BLUE_COLOR] = new Gene(COLOR_GENE_SIZE);
    chromosome[X_FACTOR] = new Gene(FACTOR_GENE_SIZE);
    chromosome[Y_FACTOR] = new Gene(FACTOR_GENE_SIZE);
    phenotype = new Blob(cx, cy, chromosome[SIDES].value, chromosome[RAD].value, 
    chromosome[RED_COLOR].value, chromosome[GREEN_COLOR].value,
    chromosome[BLUE_COLOR].value, chromosome[X_FACTOR].value, 
    chromosome[Y_FACTOR].value);
    fitness = 0.0;
  }

  /*=====================================
   Call the display method of the phenotype, make sure to set the fill
   color appropriately
   ====================================*/
  void display() {
    phenotype.display();
  }

  /*=====================================
   Set phenotype to a new regulargon with center cx, cy and 
   properties that align with gene values.
   ====================================*/
  void setPhenotype(int cx, int cy) {
    phenotype = new Blob(cx, cy, chromosome[SIDES].value, chromosome[RAD].value, 
    chromosome[RED_COLOR].value, chromosome[GREEN_COLOR].value,
    chromosome[BLUE_COLOR].value, chromosome[X_FACTOR].value, 
    chromosome[Y_FACTOR].value);
  }

  /*=====================================
   Print the value of each gene in chromosome, useful for
   debugging and development
   ====================================*/
  void printIndividual() {
    for (int i = 0; i < chromosome.length; i++) {
      println( chromosome[i].value );
    }
  }

  /*=====================================
   Return a new Individual based on the genes of the calling
   chromosome and the parameter, "other". A random number of
   genes should be taken from one of the 2 individuals and the
   rest from the other.
   The phenotype of the new Individual must be set, using cs and cy
   as the center
   ====================================*/
  Individual mate(Individual other, int cx, int cy) {
    Individual child = new Individual(cx, cy);
    Gene[] c = other.chromosome;
    Gene[] cc = child.chromosome;
    for (int i = 0; i < c.length; i++) {
      int[] geno = c[i].genotype;
      int rand = int(random(1, geno.length));
      for (int j = 0; j < rand; j++) {
        (cc[i]).genotype[j] = geno[j];
      }
      for (int x = rand; x < geno.length; x++) {
        (cc[i]).genotype[x] = (chromosome[i]).genotype[x];
      }
    }
    child.phenotype = new Blob(cx, cy, cc[SIDES].value, cc[RAD].value, 
    c[RED_COLOR].value, cc[GREEN_COLOR].value,
    cc[BLUE_COLOR].value, cc[X_FACTOR].value, 
    cc[Y_FACTOR].value);
    return child;
  }

  /*=====================================
   Set the fitness value of the calling individual by
   comparing it to the parameter, "goal"
   The closer the two are, the higher the fitness value
   should be
   ====================================*/
  int totalBits() {
    int total = 0;
    for (int i = 0; i < chromosome.length; i++) {
      total += chromosome[i].geneLength;
    }
    return total;
  }
  void setFitness( Individual goal ) {
    int total = totalBits();
    int match = 0;
    for (int i = 0; i < chromosome.length; i++) {
      Gene g = chromosome[i];
      int[] gtype = g.genotype;
      Gene gg = goal.chromosome[i];
      int[] ggtype = gg.genotype;
      for (int j = 0; j < gtype.length; j++) {
        if(gtype[j] ==  ggtype[j]) {
          match++;
        }
      }
    }
    fitness = float(match) / float(total) * 100.0;
  }
  
  boolean mutateHelper(int x, int[] array) {
    for (int i = 0; i < array.length; i++) {
      if (x == array[i]) {
        return true;
      }
    }
    return false;
  }
  
  /*=====================================
   Call the mutate method on a random number
   of genes.
   ====================================*/
  void mutate() {
    int rand = int(random(1, chromosome.length + 1));
    int[] mutated = new int[rand];
    for (int i = 0; i < rand; i++) {
      int r = int(random(1, chromosome.length + 1));
      while (mutateHelper(r, mutated)) {
        r = int(random(1, chromosome.length + 1));
      }
      mutated[i] = r;
      chromosome[i].mutate();
    }
  }
}

