/**
 * Assignment: petri_dish
 * Date: 2019-05-xx
 * Description: Implements a way to draw and monitor a rectangular
 *                button on the screen.
 */

class RectButton {
  
  int cBg = #FF5252;
  int cText = 0;
  int radius = 10;  // For curved corners
  int xPad = 10;
  int yPad = 1;
  PFont fFont;
  
  boolean textSetup = false;  // Changed after setup function is run
  
  int x;
  int y;
  int w;
  int h;
  String text1;
  String text2;  // Secondary text after toggled, if necessary
  boolean toggler;
  boolean toggleStatus;
  int ts1;  // textSize variables
  int ts2;
  
  // No toggle constructor
  RectButton(int x, int y, int w, int h, String t) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    text1 = t;
    text2 = "Error"; // XXX: Change this after testing?
    toggler = false;
  }
  
  // Toggle constructor with default start status
  RectButton(int x, int y, int w, int h, String t1, String t2) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    text1 = t1;
    text2 = t2;
    toggler = true;
    toggleStatus = false;
  }
  
  // Toggle constructor with manual start status
  RectButton(int x, int y, int w, int h, String t1, String t2, boolean toggleStartStatus) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    text1 = t1;
    text2 = t2;
    toggler = true;
    toggleStatus = toggleStartStatus;
  }
  
  void blit() {
    fill(cBg);
    noStroke();
    rectMode(CORNER);
    rect(x, y, w, h, radius);
    
    // Text
    if (!textSetup) {
      // Setup the text sizes if they've never been setup
      // This can't happen in the contructor because setup() needs to be over
      setTextSize(2);
      textSetup = true;
    }
    String tempText = text1;
    textAlign(CENTER, CENTER);
    textSize(ts1);
    fill(cText);
    if (toggler) {
      if (toggleStatus) {
        // Settings for other toggled text
        tempText = text2;
        textSize(ts2);
        text(tempText, x+w/2, (y+h/2)-ts2/4);  // -ts2/4 is a hack to center it properly
      } else {
        text(tempText, x+w/2, (y+h/2)-ts1/4);
      }
    } else {
      text(tempText, x+w/2, (y+h/2)-ts1/4);
    }
    // 3rd value calculates middle then moves it up further to compensate for letters that go below like y, g, j, |
    //text(tempText, x+w/2, (y+h/2)-2*(h/8));
  }
  
  boolean updatePress(int mx, int my) {
    // Returns true if the specified mouse coord is within the hitbox of the button
    if ((mx >= x && mx < x+w) && (my >= y && my < y+h)) {
      if (toggler) {
        // Toggle is switched. This means that this function needs to be called all the time to keep track of toggling
        toggleStatus = !toggleStatus;
      }
      return true;
    }
    return false;
  }
  
  private void setTextSize(int i) {
    // Decides on text size based on the button width and height
    // i: 0, only does first string
    // i: 1, second string
    // i: 2, both strings
    
    int tempTS;
    
    if (i == 0 || i == 2) {
      // Figure out first text string size
      tempTS = 1;
      textSize(1);
      // Loop until the text is about to exceed the margins, either the top/bottom or the side ones
      while (tempTS < h-(yPad*2) && textWidth(text1) < w-(xPad*2)) {
        textSize(tempTS);
        tempTS++;
      }
      ts1 = tempTS;
    }
    
    if (i == 1 || i == 2) {
      // Now second string
      tempTS = 1;
      textSize(1);
      while (tempTS < h-(yPad*2) && textWidth(text2) < w-(xPad*2)) {
        textSize(tempTS);
        tempTS++;
      }
      ts2 = tempTS;
    }
  }
  
  boolean getToggleStatus() {
    return toggleStatus;
  }
  
  void setToggleStatus(boolean ts) {
    toggleStatus = ts;
  }
  
  boolean isToggler() {
    return toggler;
  }
  
  int[] getPos() {
    return new int[] {x, y};
  }
  
  void setPos(int xx, int yy) {
    x = xx;
    y = yy;
  }
  
  int[] getDim() {
    return new int[] {w, h};
  }
  
  void setDim(int ww, int hh) {
    w = ww;
    h = hh;
  }
  
  String getText() {
    return text1;
  }
  
  void setText(String t) {
    text1 = t;
  }
  
  String getText2() {
    return text2;
  }
  
  void setText2(String t2) {
    text2 = t2;
  }
    
}