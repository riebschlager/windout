import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

VerletPhysics2D physics;
PGraphics canvas;
ArrayList<PShape> shapes = new ArrayList<PShape>();
ArrayList<Integer> shapeSrc = new ArrayList<Integer>();
PImage src;
float t = random(10000);

static int NUMBER_OF_ROTATIONS = 6;
static int SHAPES_PER_CLICK = 6;
static int SHAPE_SCATTER = 10;
static int SHAPE_SCALE_MIN = 0;
static int SHAPE_SCALE_MAX = 5;
static int SHAPE_FILL_COLOR = -1;
static int SHAPE_FILL_ALPHA = 0;
static int SHAPE_STROKE_COLOR = -1;
static int SHAPE_STROKE_ALPHA = 255;

void setup() {
  size(1000, 1000);
  // Create a drawing context that matches your targeted print size.
  canvas = createGraphics(3000, 3000);
  canvas.beginDraw();
  canvas.background(255);
  canvas.endDraw();
  loadVectors("flourish");
  physics = new VerletPhysics2D();
  physics.setDrag(0.25f);
  //physics.setWorldBounds(new Rect(0, 0, width, height));
  //physics.addBehavior(new GravityBehavior(new Vec2D(0, 0.25f)));
  src = loadImage("http://24.media.tumblr.com/75d4a32b56db14aa1a2c5a251d368864/tumblr_mozo3rGQiO1qc4s84o1_250.jpg");
  src.loadPixels();
}

void mousePressed() {
  physics.clear();
  shapeSrc.clear();
  for (int i = 0; i < SHAPES_PER_CLICK; i++) {
    float randomX = map(mouseX, 0, width, 0, canvas.width) + random(-SHAPE_SCATTER, SHAPE_SCATTER);
    float randomY = map(mouseY, 0, height, 0, canvas.height) + random(-SHAPE_SCATTER, SHAPE_SCATTER);
    VerletParticle2D p = new VerletParticle2D(randomX, randomY);
    p.addVelocity(new Vec2D(random(2), random(2)));
    physics.addParticle(p);
    physics.addBehavior(new AttractionBehavior(p, 200, -0.2f));
    shapeSrc.add((int) random(shapes.size()));
  }
}



void draw() {
  t += 0.01;
  physics.update();
  canvas.beginDraw();
  for (VerletParticle2D p : physics.particles) {
    for (float i = 0; i < TWO_PI; i+= TWO_PI / NUMBER_OF_ROTATIONS) {
      int pixel = src.get((int) map(p.x, 0, canvas.width, 0, src.width), (int) map(p.y, 0, canvas.height, 0, src.height));
      int fillColor = (SHAPE_FILL_COLOR > 0) ? SHAPE_FILL_COLOR : color(red(pixel), green(pixel), blue(pixel), SHAPE_FILL_ALPHA);
      int strokeColor = (SHAPE_STROKE_COLOR > 0) ? SHAPE_STROKE_COLOR : color(red(pixel), green(pixel), blue(pixel), SHAPE_STROKE_ALPHA);
      if (SHAPE_FILL_ALPHA == 0) {
        canvas.noFill();
      } 
      else {
        canvas.fill(fillColor);
      }
      if (SHAPE_STROKE_ALPHA == 0) {
        canvas.noStroke();
      }
      else {
        canvas.stroke(strokeColor);
      }
      canvas.pushMatrix();
      canvas.translate(canvas.width / 2, canvas.height / 2);
      canvas.rotate(i);

      PShape ss = shapes.get(shapeSrc.get(physics.particles.indexOf(p)));
      ss.resetMatrix();
      ss.scale(map(noise(p.x * 0.01, p.y * 0.01, frameCount * 0.01), 0, 1, SHAPE_SCALE_MIN, SHAPE_SCALE_MAX));
      ss.rotate(p.getVelocity().heading() + PI);
      canvas.shape(ss, p.x-canvas.width/2, p.y-canvas.height/2);
      canvas.popMatrix();
    }
  }
  canvas.endDraw();
  image(canvas, 0, 0, width, height);
}


void keyPressed() {
  if (key == 's') {
    canvas.save("data/output/composition-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + ".tif");
  }
  if (key == 'c') {
    canvas.beginDraw();
    canvas.background(255);
    canvas.endDraw();
  }
  if (key == ' ') {
    physics.clear();
  }
}


void loadVectors(String folderName) {
  // Create an SVG with several shapes, each on its own layer.
  // Make sure they're all crammed into the top-left of the artboard.
  File folder = new File(this.sketchPath + "/data/vector/" + folderName);
  File[] listOfFiles = folder.listFiles();
  for (File file : listOfFiles) {
    if (file.isFile()) {
      PShape shape = loadShape(file.getAbsolutePath());
      for (PShape layer : shape.getChildren()) {
        if (layer!=null) {
          layer.disableStyle();
          shapes.add(layer);
        }
      }
    }
  }
}

