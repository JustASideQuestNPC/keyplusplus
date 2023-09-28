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
PVector mousePos = new PVector(0, 0);   // position of the mouse on the current frame
PVector pmousePos = new PVector(0, 0);  // position of the mouse on the previous frame
PVector mouseDelta = new PVector(0, 0); // how much the mouse has moved since the previous frame

// "enums"
static final int CONTINUOUS = 0;
static final int PRESS_ONLY = 1;
static final int RELEASE_ONLY = 2;

// a single input binding
public class InputBind {
  private int[] boundKeys;    // all keys that can trigger this input
  private boolean active;      // whether the input is active ("pressed")
  private int activationMode; // the input's activation mode - CONTINUOUS, PRESS_ONLY, or RELEASE_ONLY
  private boolean wasActive;    // used for press-only and release-only inputs

  // four constructors because Proccessing is too cool for default parameters (but not too cool for overloading, thankfully)
  InputBind(String[] keyStrings, int mode) {
    // set activation mode
    activationMode = mode;

    // make the boundKeys array the same size as the keyStrings array
    boundKeys = new int[keyStrings.length];

    // loop through the key strings and convert each string to the correct key code (using the data in the json file)
    for (int i = 0; i < keyStrings.length; ++i) {
      boundKeys[i] = inputCodes.getInt(keyStrings[i]);
    }

    // wasActive needs to based on activation mode to prevent a few errors
    if (activationMode == PRESS_ONLY) {
      wasActive = false;
    }
    else {
      wasActive = true;
    }
  }

  // checks key states and updates whether the input is active or not
  void update() {
    // find whether at least one bound key is pressed
    boolean boundKeyPressed = false;
    for (int k : boundKeys) {
      // uses getOrDefault because any key that hasn't been pressed yet won't have an entry in the map yey
      if (keyStates.getOrDefault(k, false)) {
        boundKeyPressed = true;
        break; // break ends the loop early (since checking the rest of the keys is pointless once the first pressed key is found)
      }
    }

    // update whether the input is active based on its activation mode - switch statements work the same as chaining
    // multiple if/else if statements, but they're significantly faster (and more readable imo)
    switch (activationMode) {
      case CONTINUOUS:
        // continuous inputs are active whenever a bound key is pressed
        active = boundKeyPressed;
        break;
      case PRESS_ONLY:
        // press-only inputs are active on the first frame that at least one bound key is pressed
        if (boundKeyPressed) {
          if (wasActive) {
            active = false;
          }
          else {
            active = true;
            wasActive = true;
          }
        }
        else {
          wasActive = false;
        }
        break;
      case RELEASE_ONLY:
        // release-only inputs are active on the first frame that at no bound keys are pressed
        if (!boundKeyPressed) {
          if (wasActive) {
            active = false;
          }
          else {
            active = true;
            wasActive = true;
          }
        }
        else {
          wasActive = false;
        }
        break;
    }
  }

  // returns whether the bind is active or not
  boolean getState() { return active; }
}

// handles updates for as many input binds as you want - create one of these and then add all your inputs to it
public class InputHandler {
  private HashMap<String, InputBind> binds;

  // constructor
  InputHandler() {
    binds = new HashMap<String, InputBind>();
    inputCodes = loadJSONObject("./kppInputCodes.json");
  }

  // adds an input bind to the handler. also returns a reference to the bind in case you want to store it
  InputBind addInput(String name, String[] keyStrings, int mode) {
    binds.put(name, new InputBind(keyStrings, mode));
    return binds.get(name);
  }
  // addInput has three alternate versions ("overloads") to allow using a single string instead of an array
  // when an input is only bound to a single key, and to make mode a default parameter. since they don't do
  // anything else, they just have to call the original addInput with some modifications
  InputBind addInput(String name, String[] keyStrings) {
    return addInput(name, keyStrings, CONTINUOUS);
  }
  InputBind addInput(String name, String keyString, int mode) {
    return addInput(name, new String[]{keyString}, mode);
  }
  InputBind addInput(String name, String keyString) {
    return addInput(name, new String[]{keyString}, CONTINUOUS);
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
    return binds.get(name).getState();
  }

  // returns a reference to a binding. names are case-insensitive, and invalid names create undefined behavior
  InputBind getBindRef(String name) {
    return binds.get(name);
  }

  // returns the state of a key, or false if the name is invalid
  boolean getKeyState(String name) {
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
