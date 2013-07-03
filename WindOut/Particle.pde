class Particle extends VerletParticle2D {
  
  PShape shape;
  int pixel;
  float age;
  float lifetime;
  
  public Particle(float _x, float _y) {
    super(_x, _y);
    age = 0f;
  }
  
}

