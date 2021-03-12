/*
TODO:
- Make README
- Fix random placement so there's no overlapping
- Don't play sound when paused
*/



import processing.sound.*;

int fR = 60;
PFont fFont;
int rectButtonLeftMargin = 10;
int rectButtonTopMargin = 20;
int rectButtonWidth = 150;
int rectButtonHeight = 80;
int midMolSize = 35;
int[] molColours = new int[] {#FBFF7A, #7AFF7A, #A07AFF, #FF7AD3, #FFA57A};
int defaultSpeed = 2;
int defaultMolNum = 3;
String[] sounds = new String[] {"0.wav", "1.wav", "2.wav", "3.wav", "4.wav"};

// First 3 items are initialized in setup()
ArrayList<Molecule> molecules = new ArrayList<Molecule>();

// UI elements
ValueButton speedButtons = new ValueButton(690, 145, 150, 250, "Speed+", "Speed-", defaultSpeed, 1, 1, 15);
ValueButton moleculesButtons = new ValueButton(690, 650, 150, 250, "No. +", "No. -", defaultMolNum, 1, 1, 5);
RectButton pauseToggle = new RectButton(rectButtonLeftMargin, rectButtonTopMargin, rectButtonWidth, rectButtonHeight, "Pause", "Play");
RectButton restartButton = new RectButton(rectButtonLeftMargin, rectButtonTopMargin*2+rectButtonHeight*1, rectButtonWidth, rectButtonHeight, "Restart");
RectButton saveButton = new RectButton(rectButtonLeftMargin, rectButtonTopMargin*3+rectButtonHeight*2, rectButtonWidth, rectButtonHeight, "Save to file");

// FileIO
BufferedReader saveReader;  // Init in setup
PrintWriter saveWriter;  // Init in mousePressed


double bounceDegree(double incomingAngle, double surfaceAngle) {
  double normal = (surfaceAngle + 90) % 360;
  double invertedNormal = (normal + 180) % 360;
  double AoI = (invertedNormal - incomingAngle) % 360;  // Angle of Incidence
  double AoR = (normal + AoI) % 360;  // Angle of Reflection
  return AoR;
}

void bounceVector(Vector v, double surfaceAngle) {
  v.setDeg(bounceDegree(v.getDeg(), surfaceAngle));
  v.setStartPos(v.getCurrentPos()[0], v.getCurrentPos()[1]);
  v.setDisTraveled(0);
}

double lineAngle(int x1, int y1, int x2, int y2) {
  return degrees(atan2(y2-y1, x2-x1));
}

boolean contains(int[] arr, int e) {
  for (int n : arr) {
    if (e == n) {
      return true;
    }
  }
  return false;
}

boolean containsWithin(int[] arr, int lower, int upper) {
  // Lower inclusive, upper exclusive

  for (int n : arr) {
    if (n >= lower && n < upper) {
      return true;
    }
  }
  return false;
}

void addMolecules(int n, double speed) {
  // Create int arrays of the current positions of all the vectors
  // They will be used to make sure none of them intersect
  int[] xes = new int[molecules.size()+n];
  int[] yys = new int[molecules.size()+n];
  for (int ii = 0; ii < molecules.size(); ii++) {
    xes[ii] = molecules.get(ii).vector.getCurrentPos()[0];
    yys[ii] = molecules.get(ii).vector.getCurrentPos()[1];
  }

  int start = molecules.size();
  if (start < 0) {
    start = 0;
  }
  for (int ii = start; ii < start+n; ii++) {
    // Randoms are x & y, forming a square inside the circle
    // where molecules will randomly appear
    int x = round(random(253, 546));
    int y = round(random(253, 546));
    // Keep generating them until there are no intersections
    while (containsWithin(xes, round(x-midMolSize*1.2), round(x+midMolSize*1.2+1)) && containsWithin(yys, round(y-midMolSize*1.2), round(y+midMolSize*1.2+1))) {
      x = round(random(253, 546));
      y = round(random(253, 546));
    }
    xes[ii] = x;
    yys[ii] = y;

    // Random size within 20% of middle size
    molecules.add(new Molecule(molColours[ii], 0, round(random(midMolSize*0.8, midMolSize*1.2)), new Vector(random(0, 360), -1, speed, x, y, fR), new SoundFile(this, sounds[ii])));
  }
}

void playCollisionSound(Molecule m) {
  m.sound.stop();
  m.sound.play();
}

String[] getConfigValues(BufferedReader reader, int line) throws IOException {
  // Return the configuration values from the given reader, using the line number
  // Assumes values are comma separated

  String configLine = "";
  try {
    reader.reset();
    reader.mark(1000);
  } catch (IOException e) {
    println("getConfigValues reader reset & mark failed");
  }

  for (int ii = -1; ii != line; ii++) {
    configLine = reader.readLine();
  }
  // Correct number line has been found
  println("Read line "+line+": "+configLine);
  if (configLine == "" || configLine == null || configLine == "\n") { // Empty
    throw new IOException();
  }
  String[] ret = split(configLine, ",");
  return ret;
}

void setup() {
  size(800, 800);
  background(0);
  frameRate(fR);
  fFont = createFont("Roboto", 1);  // Text is resized later
  textFont(fFont);
  
  // File IO
  try {
    saveReader = createReader(dataFile("savedata.txt"));
    saveReader.mark(1000);  // Mark start of file
    // Get file data and set in-game values to saved data
    String[][] lines = new String[6][];
    // First line is speed, following 5 or less are molecule info
    for (int ii = 0; ii < 6; ii++) {
      try {
        lines[ii] = getConfigValues(saveReader, ii);
      } catch (IOException e) {
        // No lines left
        break;
      }
    }

    speedButtons.setNum(Integer.parseInt(lines[0][0]));
    // Molecule info format:
    // <almost all molecule constructor vars comma separated>,<almost vector constructor vars comma separated>
    // framerate (fR) is the one not included vector constructor var
    // and the vector (v) is the one not included molecule constructor var
    for (int ii = 1; ii < 6; ii++) {
      if (lines[ii] != null) {
        // Line exists
        molecules.add(new Molecule(Integer.parseInt(lines[ii][0]), Integer.parseInt(lines[ii][1]), Integer.parseInt(lines[ii][2]), new Vector(Double.parseDouble(lines[ii][3]), Double.parseDouble(lines[ii][4]), Double.parseDouble(lines[ii][5]), Integer.parseInt(lines[ii][6]), Integer.parseInt(lines[ii][7]), fR), new SoundFile(this, sounds[molecules.size()])));
      }
    }
    moleculesButtons.setNum(molecules.size());

  } catch (Exception e) {
    // No file exists, set defaults
    println("Falling back to defaults");
    // Start with 3 molecules
    addMolecules(3, 200);
  }  
}

void draw() {
  background(#5B5B5B);
  
  // Dish
  fill(#8CD8FF);
  strokeWeight(5);
  stroke(0);
  ellipseMode(CENTER);
  ellipse(400, 400, 500, 500);

  // Pause everything if necessary
  if (pauseToggle.getToggleStatus()) {
    for (int ii = 0; ii < molecules.size(); ii++) {
      molecules.get(ii).vector.pause();
    }
  } else {
    for (int ii = 0; ii < molecules.size(); ii++) {
      molecules.get(ii).vector.unpause();
    }
  }
    // Update values of stuff from buttons
  for (int ii = 0; ii < molecules.size(); ii++) {
    molecules.get(ii).vector.setSpeed(speedButtons.getNum()*100);
  }
  if (moleculesButtons.getNum() > molecules.size()) {
    addMolecules(moleculesButtons.getNum()-molecules.size(), speedButtons.getNum()*100);
  } else if (moleculesButtons.getNum() < molecules.size()) {
    // Remove the last few so that the number is correct
    for (int ii = molecules.size()-(molecules.size()-moleculesButtons.getNum()); ii < molecules.size(); ii++) {
      molecules.remove(ii);
    }
  }

  // Molecules
  for (int ii = 0; ii < molecules.size(); ii++) {
    molecules.get(ii).blit();
    molecules.get(ii).update();
  }    

  // Buttons
  speedButtons.blit();
  moleculesButtons.blit();
  pauseToggle.blit();
  restartButton.blit();
  saveButton.blit();

  // ----------- COLLISION DETECTION -----------
  for (int ii = 0; ii < molecules.size(); ii++) {
    Molecule molecule = molecules.get(ii);

    // Sides of dish - 245 is used bc there is a 5px strokeWidth
    if (abs(dist(molecule.vector.getNextFramePos()[0], molecule.vector.getNextFramePos()[1], 400, 400)) + molecule.getRadius() >= 245) {
      // The distance between the molecule's edge and the center of the dish will be
      // the same as or larger than the radius of the dish, next frame
      // This means there will be a collision
      
      if (abs(dist(molecule.vector.getNextFramePos()[0], molecule.vector.getNextFramePos()[1], 400, 400)) + molecule.getRadius() >= 245) {
        // Same logic as above, but only checking if the molecule will go past the edge, not just collide with it
        // That means pushback is required

        double angle = (lineAngle(400, 400, molecule.vector.getCurrentPos()[0], molecule.vector.getCurrentPos()[1])+180) % 360;
        double distPastEdge = (abs(dist(molecule.vector.getNextFramePos()[0], molecule.vector.getNextFramePos()[1], 400, 400)) + molecule.getRadius()) - 245;
        int fixedX = round((float) (distPastEdge * cos(radians((float) angle)))) + molecule.vector.getNextFramePos()[0];
        int fixedY = round((float) (distPastEdge * sin(radians((float) angle)))) + molecule.vector.getNextFramePos()[1];
        molecule.vector.setStartPos(fixedX, fixedY);
        molecule.vector.setDisTraveled(0);
      }

      // Calculate tangent angle for bouncing - the line perpendicular to the line formed from the molecule and dish centerpoints
      double tangent = (lineAngle(400, 400, molecule.vector.getCurrentPos()[0], molecule.vector.getCurrentPos()[1])+90) % 360;
      bounceVector(molecule.vector, tangent);
      playCollisionSound(molecule);
    }

    // Molecules bouncing off each other
    // Look at every other molecule from this molecule's POV
    for (int aa = 0; aa < molecules.size(); aa++) {
      if (ii == aa) {
        // Don't check for collisions with itself
        continue;
      }

      Molecule molecule2 = molecules.get(aa);
      if (abs(dist(molecule.vector.getNextFramePos()[0], molecule.vector.getNextFramePos()[1], molecule2.vector.getNextFramePos()[0], molecule2.vector.getNextFramePos()[1])) <= molecule.getRadius() + molecule2.getRadius()) {
        // Checks if in the next frame, the molecule that is being used (molecule) will collide with
        // the other molecule that is being looked at (molecule2). It checks whether the distance
        // between those two molecules' centerpoints is equal to or larger than the two radii of the
        // molecules added together.
        // This indicates a collision.

        // At the moment, pushback code is not needed for molecule-on-molecule collision
        // The following commented code tried to implement that, but doesn't work
        // Since there is not visible intersection, it does not need to be fixed

        /*
        if (abs(dist(molecule.vector.getNextFramePos()[0], molecule.vector.getNextFramePos()[1], molecule2.vector.getNextFramePos()[0], molecule2.vector.getNextFramePos()[1])) < molecule.getRadius() + molecule2.getRadius()) {
          // Same logic as above, but only checking if the molecule will go past the edge,
          // not just collide with it.
          // That means pushback is required.

          double angle2 = (lineAngle(molecule2.vector.getNextFramePos()[0], molecule2.vector.getNextFramePos()[1], molecule.vector.getCurrentPos()[0], molecule.vector.getCurrentPos()[1])+180) % 360;
          double distIntoMol = (molecule.getRadius()+molecule2.getRadius()) - abs(dist(molecule.vector.getNextFramePos()[0], molecule.vector.getNextFramePos()[1], molecule2.vector.getNextFramePos()[0], molecule2.vector.getNextFramePos()[1]));
          int fixedX = round((float) (distIntoMol * cos(radians((float) angle2)))) + molecule.vector.getNextFramePos()[0];
          int fixedY = round((float) (distIntoMol * sin(radians((float) angle2)))) + molecule.vector.getNextFramePos()[1];
          molecule.vector.setStartPos(fixedX, fixedY);
          molecule.vector.setDisTraveled(0);
        }
        */

        double tangent2 = (lineAngle(molecule2.vector.getNextFramePos()[0], molecule2.vector.getNextFramePos()[1], molecule.vector.getCurrentPos()[0], molecule.vector.getCurrentPos()[1])+90) % 360;
        // Bounce both molecules
        bounceVector(molecule.vector, tangent2);
        playCollisionSound(molecule);
        bounceVector(molecule2.vector, tangent2);
        playCollisionSound(molecule2);
      }
    }
  }

  // ----------- END COLLISION DETECTION -----------
}

void mousePressed() {
  // Toggles
  pauseToggle.updatePress(mouseX, mouseY);

  // ValueButton (s)
  speedButtons.update(mouseX, mouseY);
  moleculesButtons.update(mouseX, mouseY);
  
  // Buttons
  if (restartButton.updatePress(mouseX, mouseY)) {
    molecules.clear();
    speedButtons.setNum(defaultSpeed);
    moleculesButtons.setNum(defaultMolNum);
    addMolecules(moleculesButtons.getNum(), speedButtons.getNum()*100);
  }
  if (saveButton.updatePress(mouseX, mouseY)) {
    // Init saveWriter here to remove all file data in case of multiple saves
    try {
      saveWriter.close();
    } catch (Exception e) {}
    saveWriter = createWriter(dataFile("savedata.txt"));

    saveWriter.println(speedButtons.getNum());
    for (int ii = 0; ii < molecules.size(); ii++) {
      Molecule molecule = molecules.get(ii);
      saveWriter.println(molecule.getFill()+","+molecule.getStroke()+","+molecule.getRadius()+","+molecule.vector.getDeg()+","+molecule.vector.getMag()+","+molecule.vector.getSpeed()+","+molecule.vector.getStartPos()[0]+","+molecule.vector.getStartPos()[1]);
    }
    saveWriter.flush();
  }
}

void exit() {
  try {
    saveWriter.close();
  } catch (Exception e) {}
  super.exit();
}