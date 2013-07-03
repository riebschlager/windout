import controlP5.*;
import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

VerletPhysics2D physics;
PGraphics canvas;
ArrayList<PShape> shapes = new ArrayList<PShape>();
ArrayList<Integer> shapeSrc = new ArrayList<Integer>();
ArrayList<Integer> shapeColors = new ArrayList<Integer>();
PImage src;
float t = random(10000);
ControlP5 cp5;
boolean isToolbarVisible = false;

int NUMBER_OF_ROTATIONS = 7;
int SHAPES_PER_CLICK = 5;
int SHAPE_SCATTER = 5;
float SHAPE_SCALE_MIN = 1f;
float SHAPE_SCALE_MAX = 3f;
int SHAPE_FILL_ALPHA = 25;
int SHAPE_STROKE_ALPHA = 0;
int PARTICLE_FORCE_RADIUS = 50;
float PARTICLE_FORCE = -2.5f;

void setup() {
  size(1000, 1000);
  // Create a drawing context that matches your targeted print size.
  canvas = createGraphics(3000, 3000);
  canvas.beginDraw();
  canvas.background(255);
  canvas.endDraw();
  loadVectors("splat");
  loadVectors("flourish");
  loadVectors("scribble");
  loadVectors("retro");
  loadVectors("stain");
  loadVectors("doodads");
  physics = new VerletPhysics2D();
  physics.setDrag(0.5f);
  src = loadImage("http://dribbble.s3.amazonaws.com/users/21071/screenshots/1139794/cran--beer-labels_1x.png");
  src.loadPixels();
  setupCP5();
}

void setupCP5() {
  cp5 = new ControlP5(this);
  cp5.addNumberbox("NUMBER_OF_ROTATIONS").setPosition(10, 100).setSize(100, 14).setMultiplier(1).setMin(1).setMax(50).setValue(NUMBER_OF_ROTATIONS).setCaptionLabel("NUMBER_OF_ROTATIONS");
  cp5.addNumberbox("SHAPES_PER_CLICK").setPosition(10, 140).setSize(100, 14).setMultiplier(1).setMin(1).setMax(50).setValue(SHAPES_PER_CLICK).setCaptionLabel("SHAPES_PER_CLICK");
  cp5.addNumberbox("SHAPE_SCATTER").setPosition(10, 180).setSize(100, 14).setMultiplier(1).setMin(0).setMax(300).setValue(SHAPE_SCATTER).setCaptionLabel("SHAPE_SCATTER");
  cp5.addNumberbox("SHAPE_SCALE_MIN").setPosition(10, 220).setSize(100, 14).setMultiplier(0.1f).setMin(-10f).setMax(10f).setValue(SHAPE_SCALE_MIN).setCaptionLabel("SHAPE_SCALE_MIN");
  cp5.addNumberbox("SHAPE_SCALE_MAX").setPosition(10, 260).setSize(100, 14).setMultiplier(0.1f).setMin(0f).setMax(20f).setValue(SHAPE_SCALE_MAX).setCaptionLabel("SHAPE_SCALE_MAX");
  cp5.addNumberbox("SHAPE_FILL_ALPHA").setPosition(10, 300).setSize(100, 14).setMultiplier(1).setMin(0).setMax(255).setValue(SHAPE_FILL_ALPHA).setCaptionLabel("SHAPE_FILL_ALPHA");
  cp5.addNumberbox("SHAPE_STROKE_ALPHA").setPosition(10, 340).setSize(100, 14).setMultiplier(1).setMin(0).setMax(255).setValue(SHAPE_STROKE_ALPHA).setCaptionLabel("SHAPE_STROKE_ALPHA");
  cp5.addNumberbox("PARTICLE_FORCE_RADIUS").setPosition(10, 380).setSize(100, 14).setMultiplier(1).setMin(0).setMax(1000).setValue(PARTICLE_FORCE_RADIUS).setCaptionLabel("PARTICLE_FORCE_RADIUS");
  cp5.addNumberbox("PARTICLE_FORCE").setPosition(10, 420).setSize(100, 14).setMultiplier(0.01f).setMin(-5f).setMax(5f).setValue(PARTICLE_FORCE).setCaptionLabel("PARTICLE_FORCE");
  cp5.hide();
}

void draw() {
  t += 0.01;
  physics.update();
  canvas.beginDraw();
  for (VerletParticle2D p : physics.particles) {
    for (float i = 0; i < TWO_PI; i+= TWO_PI / NUMBER_OF_ROTATIONS) {
      //int pixel = src.get((int) map(p.x, 0, canvas.width, 0, src.width), (int) map(p.y, 0, canvas.height, 0, src.height));
      int pixel = shapeColors.get(physics.particles.indexOf(p));
      int fillColor = color(red(pixel), green(pixel), blue(pixel), SHAPE_FILL_ALPHA);
      int strokeColor = color(red(pixel), green(pixel), blue(pixel), SHAPE_STROKE_ALPHA);
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

      PShape shape = shapes.get(shapeSrc.get(physics.particles.indexOf(p)));
      shape.resetMatrix();
      shape.scale(map(noise(t), 0, 1, SHAPE_SCALE_MIN, SHAPE_SCALE_MAX));
      shape.rotate(p.getVelocity().heading());
      canvas.shape(shape, p.x-canvas.width / 2, p.y-canvas.height / 2);
      canvas.popMatrix();
    }
  }
  canvas.endDraw();
  image(canvas, 0, 0, width, height);
  if (isToolbarVisible) {
    fill(0, 150);
    rect(0, 0, width, height);
  }
}

void mousePressed() {
  if (isToolbarVisible) return;
  t = random(1000);
  physics.clear();
  shapeSrc.clear();
  shapeColors.clear();
  for (int i = 0; i < SHAPES_PER_CLICK; i++) {
    float pX = map(mouseX, 0, width, 0, canvas.width) + random(-SHAPE_SCATTER, SHAPE_SCATTER);
    float pY = map(mouseY, 0, height, 0, canvas.height) + random(-SHAPE_SCATTER, SHAPE_SCATTER);
    VerletParticle2D p = new VerletParticle2D(pX, pY);
    //p.addVelocity(new Vec2D(random(-10, 10), random(-10, 10)));
    physics.addParticle(p);
    physics.addBehavior(new AttractionBehavior(p, PARTICLE_FORCE_RADIUS, PARTICLE_FORCE));
    shapeSrc.add((int) random(shapes.size()));
    shapeColors.add(src.get((int) random(src.width), (int) random(src.height)));
  }
}

void keyPressed() {
  if (key == 'b') {
    canvas.filter(BLUR, 1);
  }
  if (key == 't') {
    isToolbarVisible = !isToolbarVisible;
    if (isToolbarVisible) cp5.show();
    else cp5.hide();
  }
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

