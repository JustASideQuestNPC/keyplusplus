/*
 *       __ __              __     __
 *      / //_/___  __ __ __/ /_ __/ /_
 *     / ,<  / -_)/ // //_  __//_  __/
 *    /_/|_| \__/ \_, /  /_/    /_/
 *               /___/
 *
 *    version 1.1.0
 *    https://github.com/JustASideQuestNPC/keyplusplus
 *
 *    Copyright (C) 2023 Joseph Williams
 *
 *    This software may be modified and distributed under the terms of
 *    the MIT license. See the LICENSE file for details.
 *
 *    THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 *    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 *    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 *    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 *    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


// globals
JSONObject inputCodes;
HashMap<Integer, Boolean> keyStates = new HashMap<Integer, Boolean>();
PVector mousePos = new PVector(0, 0); // position of the mouse on the current frame
PVector pmousePos = new PVector(0, 0); // position of the mouse on the previous frame
PVector mouseDelta = new PVector(0, 0); // how much the mouse has moved since the previous frame

// superclass for input binds - you shouldn't ever need to create this on its own
public abstract class InputBind {
  private int[] boundKeys; // all keys/buttons that trigger this action
  protected boolean isActive; // whether the input is active (pressed) or not

  // constructor
  InputBind(String[] keyStrings) {
    // initalize boundKeys to the correct length
    boundKeys = new int[keyStrings.length];

    // iterate through keyStrings and convert each string to the correct keyCode int
    for (int i = 0; i < keyStrings.length; ++i) {
      boundKeys[i] = inputCodes.getInt(keyStrings[i].toLowerCase());
    }
  }
  // alternate constructor that uses a single key
  InputBind(String keyString) {
    boundKeys = new int[1];
    boundKeys[0] = inputCodes.getInt(keyString.toLowerCase());
  }

  // checks if at least one of the keys bound to the bind is pressed
  protected boolean boundKeyPressed() {
    for (int i : boundKeys) {
      if (keyStates.getOrDefault(i, false)) return true;
    }
    return false;
  }

  // update is a abstract function (meaning all subclasses have a different version of it), so it doesn't need to be defined
  abstract void update();

  // gets whether the input is pressed or not
  boolean active() { return isActive; }
}

// subclasses for the different input types
public class ContinuousInput extends InputBind {
  // java classes never inherit their superclass's constructors, so this just calls it manually
  ContinuousInput(String[] keyStrings) { super(keyStrings); }
  ContinuousInput(String keyString) { super(keyString); }
  void update() {
    this.isActive = boundKeyPressed();
  }
}

public class PressInput extends InputBind {
  boolean wasPressed;

  PressInput(String[] keyStrings) {
    // start by calling the superclass constructor, then set up a few PressInput-specific things
    super(keyStrings);
    wasPressed = false;
  }
  PressInput(String keyString) {
    // start by calling the superclass constructor, then set up a few PressInput-specific things
    super(keyString);
    wasPressed = false;
  }

  void update() {
    boolean isPressed = boundKeyPressed();

    if (isPressed) {
      if (wasPressed) {
        this.isActive = false;
      }
      else {
        this.isActive = true;
        wasPressed = true;
      }
    }
    else {
      wasPressed = false;
    }
  }
}

public class ReleaseInput extends InputBind {
  boolean wasReleased;

  ReleaseInput(String[] keyStrings) {
    // start by calling the superclass constructor, then set up a few ReleaseInput-specific things
    super(keyStrings);
    wasReleased = true;
  }
  ReleaseInput(String keyString) {
    // start by calling the superclass constructor, then set up a few ReleaseInput-specific things
    super(keyString);
    wasReleased = true;
  }

  void update() {
    boolean isPressed = boundKeyPressed();

    if (!isPressed) {
      if (wasReleased) {
        this.isActive = false;
      }
      else {
        this.isActive = true;
        wasReleased = true;
      }
    }
    else {
      wasReleased = false;
    }
  }
}

// handles updates for as many input binds as you want - create one of these and then add all your inputs to it
public class InputHandler {
  private HashMap<String, InputBind> binds;

  // constructor
  InputHandler() {
    binds = new HashMap<String, InputBind>();
    inputCodes = loadJSONObject("./kppInputCodes.json");
  }

  // methods to add each type of input. adders also return a reference to the input in case you want to store it somewhere
  ContinuousInput addContinuous(String name, String[] keyStrings) {
    ContinuousInput input = new ContinuousInput(keyStrings);
    binds.put(name, input);
    return input;
  }
  ContinuousInput addContinuous(String name, String keyString) {
    ContinuousInput input = new ContinuousInput(keyString);
    binds.put(name, input);
    return input;
  }

  PressInput addPress(String name, String[] keyStrings) {
    PressInput input = new PressInput(keyStrings);
    binds.put(name, input);
    return input;
  }
  PressInput addPress(String name, String keyString) {
    PressInput input = new PressInput(keyString);
    binds.put(name, input);
    return input;
  }

  ReleaseInput addRelease(String name, String[] keyStrings) {
    ReleaseInput input = new ReleaseInput(keyStrings);
    binds.put(name, input);
    return input;
  }
  ReleaseInput addRelease(String name, String keyString) {
    ReleaseInput input = new ReleaseInput(keyString);
    binds.put(name, input);
    return input;
  }

  // updates all bindings and mouse positios
  void update() {
    // update mouse position vectors
    mousePos.set(mouseX, mouseY);
    pmousePos.set(pmouseX, pmouseY);
    mouseDelta.set(mouseX - pmouseX, mouseY - pmouseY);

    // loop through the hashmap and update all binds
    for (InputBind bind : binds.values()) {
      bind.update();
    }
  }

  // gets the state of a binding. names are case-insensitive, and invalid names create undefined behavior (in other words, i have no idea what will happen)
  boolean getState(String name) {
    return binds.get(name).active();
  }

  // gets the state of a key. if the name is invalid, it returns false.
  boolean getKey(String name) {
    // this defaults to false because any key that hasn't been pressed yet won't have an entry in the hashmap
    return keyStates.getOrDefault(inputCodes.getInt(name), false);
  }
}

// definitions for the Processing-specific input functions - don't touch!
void keyPressed() { keyStates.put(keyCode, true); }
void keyReleased() { keyStates.put(keyCode, false); }
void mousePressed() {
  switch (mouseButton) {
    case LEFT:
      keyStates.put(0, true);
      break;
    case RIGHT:
      keyStates.put(1, true);
      break;
    case CENTER:
      keyStates.put(2, true);
      break;
  }
}
void mouseReleased() {
  switch (mouseButton) {
    case LEFT:
      keyStates.put(0, false);
      break;
    case RIGHT:
      keyStates.put(1, false);
      break;
    case CENTER:
      keyStates.put(2, false);
      break;
  }
}
