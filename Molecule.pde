/**
 * Assignment: petri_dish
 * Date: 2019-05-xx
 * Description: Implements a visible molecule object that can move and
 *              bounce around the screen.
 */

class Molecule {
  
  color cFill;
  color cStroke;
  int radius;
  public Vector vector;
  public SoundFile sound;
  
  Molecule(color f, color stk, int r, Vector v, SoundFile s) {
    cFill = f;
    cStroke = stk;
    radius = r;
    vector = v;
    sound = s;
  }
  
  void blit() {
    fill(cFill);
    strokeWeight(1);
    stroke(cStroke);
    ellipseMode(CENTER);
    ellipse(vector.getCurrentPos()[0], vector.getCurrentPos()[1], radius*2, radius*2);
  }
  
  void update() {
    vector.updatePos();
  }
  
  void setFill(color f) {
    cFill = f;
  }
  
  color getFill() {
    return cFill;
  }
  
  void setStroke(color s) {
    cStroke = s;
  }
  
  color getStroke() {
    return cStroke;
  }
  
  void setRadius(int r) {
    radius = r;
  }
  
  int getRadius() {
    return radius;
  }
}