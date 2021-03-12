/**
 * Assignment: petri_dish
 * Date: 2019-05-xx
 * Description: Implements a vector that can be changed at any time.
 *              This class can be used with any "Sprite" to implement movement
 *              Direction is specified in degrees as follows:
 *                               270
 *                                |
 *                          180 --  -- 0
 *                                |
 *                               90
 */

class Vector {
  
  double deg;  // In degrees, NOT radians
  double mag; // Magnitude: desired distance traveled in px; -1 means it never stops moving
  double speed; // Movement in px per second
  int startPosX;
  int startPosY;
  int currentPosX; // Updated as incremental movements happen
  int currentPosY;
  double disTraveled = 0; // The speed var is added to this everytime the pos updates
                          // Once it equals the mag var we're done moving
  boolean done = false;
  boolean paused = false;
  int framesCounted;
  int fR;
 
 // Polar coords based constructor
  Vector(double d, double m, double s, int startX, int startY, int fr) {
    setDeg(d);
    setMag(m);
    setSpeed(s);
    setStartPos(startX, startY);  // Also sets currentPos and disTraveled values
    framesCounted = frameCount;  // Store the # of frames that have passed at the init of the class
    fR = fr; // Framerate
  }
  
  // Cartesian coords based constructor
  Vector(int startX, int startY, int destX, int destY, double s, int fr) {
    setSpeed(s);
    setStartPos(startX, startY); // Also sets currentPos and disTraveled values
    setDestination(destX, destY);
    framesCounted = frameCount; // Store the # of frames that have passed at the init of the class
    fR = fr; // Framerate
  }
  
  void setDeg(double d) {
    deg = d; 
  }
  
  double getDeg() {
    return deg; 
  }
  
  void setMag(double m) {
    mag = m;
  }
  
  double getMag() {
    return mag; 
  }
  
  boolean isInfinite() {
    return (mag == -1);
  }
  
  void setSpeed(double s) {
    speed = s; 
  }
  
  double getSpeed() {
    return speed;
  }
  
  double getDisTraveled() {
    return disTraveled;
  }

  void setDisTraveled(double dt) {
    // Often used when changing the vector, so that it will restart counting distance towards mag
    //    setDisTraveled(0); is the command for that
    // Usually setStartPos will be used with this too, so that calculations happen correctly
    // If setMag is going to be used, it MUST be used BEFORE this method

    disTraveled = dt;
    // Recalculate if it's done or not
    if (!isInfinite()) {  // Infinite vectors are never done
      if (disTraveled >= mag) {
        done = true;
      }
      else {
        done = false;
      }
    }
  }

  void setStartPos(int x, int y) {
    // setDisTraveled(0); should be used with this usually

    startPosX = x;
    startPosY = y;
    // Reset current pos to the start pos, it's starting again
    currentPosX = x;
    currentPosY = y;
  }
  
  int[] getStartPos() {
    // This should be known already, but still a getter is good, especially since it can change
    return new int[] {startPosX, startPosY};
  }
  
  int[] getCurrentPos() {
    return new int[] {currentPosX, currentPosY};
  }
  
  boolean isDone() {
    return done;
  }
  
  int[] updatePos() {
    // Change position if needed, and return the new/current pos
    
    int tempFrameCount = frameCount;  // Used because frames may pass as calculation is going on
    
    if (paused) {
      // Don't move when paused
      framesCounted = tempFrameCount;  // Frames won't be considered "missed" when it's unpaused
      return getCurrentPos();
    }

    if (isInfinite()) {
      // Move along and don't look at mag, since it's infinite (-1)
      disTraveled += speed * (double) (tempFrameCount-framesCounted) * 1/fR;  // Account for missed frames
    } else {
      // Only do all these checks if it's not infinite
      if (isDone()) {
        framesCounted = tempFrameCount;  // Frames won't be considered "missed" when it's done, in case it changes later
        return getCurrentPos();
      } else if (disTraveled >= mag) {
        // The vector is done moving
        framesCounted = tempFrameCount;  // Frames won't be considered "missed" when it's done, in case it changes later
        done = true;
        return getCurrentPos();
      } else if (disTraveled < mag && disTraveled+(speed * (double) (tempFrameCount-framesCounted) * 1/fR) > mag) {
        // It hasn't reached its final destination yet, but the next regular movement would overshoot
        disTraveled = mag; // Move it to final position, smaller movement then usual
      } else {
        // We're not there yet, move as usual
        disTraveled += speed * (double) (tempFrameCount-framesCounted) * 1/fR;  // Account for missed frames
      }
    }
    
    // Now calculate and return new cartesian coords for anything that hasn't returned already
    int x = round((float) (disTraveled * cos(radians((float) deg)))) + startPosX;
    int y = round((float) (disTraveled * sin(radians((float) deg)))) + startPosY;
    currentPosX = x;
    currentPosY = y;
    framesCounted = tempFrameCount;
    return getCurrentPos();
  }

  int[] getNextFramePos() {
    // Calculate where it would be next frame and return that
    
    int tempFrameCount = frameCount + 1; // See next frame
    double tempDisTraveled = disTraveled;
    
    if (paused) {
      // Don't move when paused
      return getCurrentPos();
    }

    if (isInfinite()) {
      // Move along and don't look at mag, since it's infinite (-1)
      tempDisTraveled += speed * (double) (tempFrameCount-framesCounted) * 1/fR;  // Account for missed frames
    } else {
      // Only do all these checks if it's not infinite
      if (isDone()) {
        return getCurrentPos();
      } else if (tempDisTraveled >= mag) {
        // The vector is done moving
        return getCurrentPos();
      } else if (tempDisTraveled < mag && tempDisTraveled+(speed * (double) (tempFrameCount-framesCounted) * 1/fR) > mag) {
        // It hasn't reached its final destination yet, but the next regular movement would overshoot
        tempDisTraveled = mag; // Move it to final position, smaller movement then usual
      } else {
        // We're not there yet, move as usual
        tempDisTraveled += speed * (double) (tempFrameCount-framesCounted) * 1/fR;  // Account for missed frames
      }
    }
    
    // Now calculate and return new cartesian coords for anything that hasn't returned already
    int x = round((float) (tempDisTraveled * cos(radians((float) deg)))) + startPosX;
    int y = round((float) (tempDisTraveled * sin(radians((float) deg)))) + startPosY;
   
    return new int[] {x, y};
  }
  
  void pause() {
    paused = true;
  }

  void unpause() {
    paused = false;
  }
  
  boolean isPaused() {
    return paused;
  }
  
  void setPause(boolean p) {
    paused = p;
  }
  
  void setDestination(int x, int y) {
    // Sets the deg and mag so that it will go to an x and y on the screen
    
    pause();
    
    int vectorX = getCurrentPos()[0];
    int vectorY = getCurrentPos()[1];
      
    // Distance in cartesian coords
    int distX = x - vectorX;
    int distY = y - vectorY;
    
    if (distX == 0 && distY == 0) {
      // No change necessary
      return;
    }
  
    // Depending on the quadrant, sometimes numbers need to be added to theta
    int add = 0;
    if (distY >= 0) {
      // Quadrant I or II
      if (distX >= 0) {
        // Quadrant I
        add = 0;
      } else {
        // Quadrant II
        add = 180;
      }
    } else {
      // Quadrant III or IV
      if (distX >= 0) {
        // Quadrant IV
        add = 360;
      } else {
        // Quadrant III
        add = 180;
      }
    }
  
    // Converting to polar
    double r = (double) sqrt(pow(distX, 2) + pow(distY, 2));
  
    double theta;
    
    // Avoid dividing by zero, and fix some atan issues
    if (distX == 0 && distY > 0) {
      theta = 90;
    } else if (distX == 0 && distY < 0) {
      theta = 270;
    } else if (distY == 0 && distX > 0) {
      theta = 0;
    } else if (distY == 0 && distX < 0) {
      theta = 180;
    } else {
      theta = (double) degrees(atan((float) distY / (float) distX)) + add;
    }
    
    // Redirect vector
    setMag(r);
    setDisTraveled(0);
    setStartPos(vectorX, vectorY);
    setDeg(theta);
  
    unpause();
  }
}