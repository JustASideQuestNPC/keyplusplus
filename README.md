# Key++
A lightweight, "header only" Processing 4 library for making keyboard and mouse input easier to use. To see a dem

# Features
- No annoying setup - just drop the source files into your sketch
- Bind multiple keys and mouse buttons to different actions
- "Stupid Simple" syntax
- Only 140 lines! (not counting comments, whitespace, or the JSON file)

# Quickstart
To use Key++, start by downloading `keyPlusPlus.pde` and `kppInputCodes.json` from the latest release (or directly from the `demo` folder), then placing them in the same folder as the rest of your sketch.

Once you've added the files to your sketch, the first step is to setup an `InputHandler`. This is the core of Key++, and it handles updates for every input you use. Just define it at the top of your code, then create it inside your `setup` function (creating an `InputHandler` also opens the .json file, so it needs to be done in `setup`):
```java
InputHandler inputs;

void setup() {
  inputs = new InputHandler();
}
```

The handler doesn't do anything on its own, so next you'll need to add some inputs. You can do this using the handler's `addInput` method, which takes three parameters:
- `name` is a string with the name of the input, which is used to get whether it's active or not
- `keyStrings` is a string or array of strings with the names of each key or mouse button that can trigger that input
- `mode` is an optional parameter that determines the input's activation mode. There are three modes:
  - `CONTINUOUS` inputs are active whenever a key bound to them is pressed.
  - `PRESS_ONLY` inputs are active for a single frame when a key bound to them is pressed.
  - `RELEASE_ONLY` inputs are active for a single frame when all keys bound to them are released.
  - If you don't specify a mode, the input defaults to `CONTINUOUS`.

You should add one input for each individual action you want to use the keyboard or mouse for:
```java
InputHandler inputs;
String[] moveLeftCodes = {"left arrow", "a"};

void setup() {
  // do setup stuff

  inputs = new InputHandler();

  // when adding an input with multiple keys, you can create the array in a separate variable...
  inputs.addInput("move left", moveLeftCodes);
  // ...or create it as part of the function call
  inputs.addInput("move right", new String[]{"right arrow", "d"});
  
  inputs.addInput("shoot", "left mouse", PRESS_ONLY);
  inputs.addInput("jump", "spacebar", RELEASE_ONLY);
}
```

To use inputs once you add them, the first thing you need to do is make sure the handler is being updated. To do this, just call its `update` method in your `draw` function:
```java
InputHandler inputs;

void setup() {
  // do setup stuff

  inputs = new InputHandler();
  // add some inputs
}

void draw() {
  inputs.update();
  // do other stuff
}
```

Now just use `getState` to check whether an input is active or not:
```java
InputHandler inputs;

void setup() {
  // do setup stuff
  inputs = new InputHandler();
  inputs.addInput("test input", "spacebar");
}

void draw() {
  inputs.update();

  if (inputs.getState("test input")) {
    // do stuff when the spacebar is pressed
  }

  // do other stuff
}
```