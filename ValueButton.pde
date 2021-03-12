/**
 * Assignment: petri_dish
 * Date: 2019-05-xx
 * Description: Implements a way to draw and monitor two triangle
 *                button on the screen, as well as a number between them.
 */

class ValueButton {
  
  int cButtonBg = #FF5252;
  int cButtonStroke = cButtonBg;
  int cNumStroke = cButtonStroke;
  int cNumBg = 255;
  int cText = 0;
  int radius = 10;  // For curved corners
  int xTextPad = 5;
  int yTextPad = 1;
  PFont fFont;
  int ySpacing = 10;  // In between button and rect
  
  boolean textSetup = false;  // Changed after setup function is run
  
  int x;  // Center points
  int y;
  int w;  // For widest part of all three elements
  int h;  // Ditto for height
  String topText;  // Top triangle text
  String botText;  // Bottom triangle text
  int topTS;  // textSize variables
  int botTS;
  int num = 0;  // Could be changed to double/float for other uses
  int step = 1;  // Could be changed to double/float for other uses
  boolean limits = false;
  // Limits are inclusive
  int upperLimit;  // Also could be doubles/floats 
  int lowerLimit;
  int numTS;
  int allHeight;  // Height of each button or num box
  int topTriangleLowerY;  // The y-value of the lower line of the top triangle
  int botTriangleUpperY;  // The y-value of the upper line of the bottom triangle
  int triHalfwayWidth;  // The width of the triangle in the middle of its height, used for text sizing 
  
  // Default num of 0
  ValueButton(int x, int y, int w, int h, String tT, String bT) {
    this.x = x;
    this.y = y;
    setDim(w, h);
    topText = tT;
    botText = bT;
  }
  
  // Set start and step
  ValueButton(int x, int y, int w, int h, String tT, String bT, int numStart, int step) {
    this(x, y, w, h, tT, bT);
    num = numStart;
    this.step = step;
  }

  // Set limits
  ValueButton(int x, int y, int w, int h, String tT, String bT, int numStart, int step, int lLim, int uLim) {
    this(x, y, w, h, tT, bT, numStart, step);
    limits = true;
    lowerLimit = lLim;
    upperLimit = uLim;
  }
  
  void blit() {
    // x, y are center points
    rectMode(CENTER);
    textAlign(CENTER, CENTER);

    strokeWeight(1);

    // Set up text if needed
    // Text
    if (!textSetup) {
      // Setup the text sizes if they've never been setup
      // This can't happen in the contructor because setup() needs to be over
      setTextSize(3);
      textSetup = true;
    }
    
    // Num box
    fill(cNumBg);
    stroke(cNumStroke);
    rect(x, y, w, allHeight, radius);
    fill(cText);
    textSize(numTS);
    text(num, x, y-(allHeight/8));  // Hack to try and put text in the middle of the height

    // Upper triangle
    fill(cButtonBg);
    stroke(cButtonStroke);
    triangle(x-w/2, topTriangleLowerY, x, y-h/2, x+w/2, topTriangleLowerY);  // Left, Top, Right
    fill(cText);
    textSize(topTS);
    text(topText, x, (y-h/2)+(allHeight/2));  // Middle of triangle

    // Lower triangle
    fill(cButtonBg);
    stroke(cButtonStroke);
    triangle(x-w/2, botTriangleUpperY, x, y+h/2, x+w/2, botTriangleUpperY);  // Left, Top, Right
    fill(cText);
    textSize(botTS);
    text(botText, x, (y+h/2)-(allHeight/2)-botTS/2);  // -botTS/2 is hack to properly center it
  }
  
  void update(int mx, int my) {
    // Call this in mousePressed() and use getNum to keep track of changes

    if (isTopPressed(mx, my)) {
      if ((limits && num+step <= upperLimit) || !limits) {
        // The next step will NOT put num above the limit, or there are no limits
        num += step;
        setTextSize(2);  // In case it becomes wider than before
      }
    } else if (isBottomPressed(mx, my)) {
      if ((limits && num-step >= lowerLimit) || !limits) {
        num -= step;
        setTextSize(2);  // In case it becomes less wide than before
      }
    }
  }

  boolean isTopPressed(int mx, int my) {
    // Rectangular hitbox for triangle unfortuantely
    if ((mx >= x-w/2 && mx < x+w/2) && (my >= y-h/2 && my < (y-h/2)+allHeight)) {
      return true;
    }
    return false;
  }

  boolean isBottomPressed(int mx, int my) {
    // Rectangular hitbox again
    if ((mx >= x-w/2 && mx < x+w/2) && (my >= (y+h/2)-allHeight && my < y+h/2)) {
      return true;
    }
    return false;
  }
  
  private void setTextSize(int i) {
    // Decides on text size based on the button width and height
    // i: 0, only does first string
    // i: 1, second string
    // i: 2, number string in middle
    // i: 3, all strings
    
    int tempTS;
    
    if (i == 0 || i == 3) {
      // Figure out first text string size
      tempTS = 1;
      textSize(1);
      // Loop until the text is about to exceed the margins, either the top/bottom or the side ones
      while (tempTS < allHeight-(yTextPad*2) && textWidth(topText) < triHalfwayWidth - xTextPad*2) {
        textSize(tempTS);
        tempTS++;
      }
      topTS = tempTS;
    }
    if (i == 1 || i == 3) {
      // Now second string
      tempTS = 1;
      textSize(1);
      while (tempTS < allHeight-(yTextPad*2) && textWidth(botText) < triHalfwayWidth - xTextPad*2) {
        textSize(tempTS);
        tempTS++;
      }
      botTS = tempTS;
    }
    if (i == 2 || i == 3) {
      tempTS = 1;
      textSize(1);
      while (tempTS < allHeight-(yTextPad*2) && textWidth(String.valueOf(num)) < w-(xTextPad*2)) {
        textSize(tempTS);
        tempTS++;
      }
      numTS = tempTS;
    }
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
    allHeight = (h-ySpacing*2) / 3;
    topTriangleLowerY = y-allHeight/2 - ySpacing;
    botTriangleUpperY = y+allHeight/2 + ySpacing;
    // Calculate triHalfwayWidth
    triHalfwayWidth = w/2;  // HACK
    textSetup = false;
  }
  
  String getTopText() {
    return topText;
  }
  
  void setText(String t) {
    topText = t;
    setTextSize(0);
  }
  
  String getBottomText() {
    return botText;
  }
  
  void setBottomText(String t) {
    botText = t;
    setTextSize(1);
  }
  
  int getNum() {
    return num;
  }
  
  void setNum(int n) {
    num = n;
  }
  
  void numPP() {
    num++;
  }
  
  void numMM() {
    num--;
  }
  
}