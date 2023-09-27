// color variables for readability
color white = color(255);
color black = color(0);
color red = color(255, 0, 0);
color green = color(0, 255, 0);

// predefine input handler and input binds
InputHandler inputs;
ContinuousInput mouseBind;
PressInput press;
ReleaseInput release;

// preset key codes for the inputs
String[] continuousCodes = {"spacebar", "t"};
String[] pressCodes = {"a", "d"};

void setup() {
  // create canvas and set framerate
  size(600, 600);
  frameRate(60);
  
  // style presets
  textAlign(CENTER, CENTER);
  textSize(18);
  
  // create input handler - this must be done in setup() because it loads a file
  inputs = new InputHandler();
  
  // add some inputs
  mouseBind = inputs.addContinuous("mouse input", "left mouse");           // if an input only has one key, that key can be passed as a single string.
  inputs.addContinuous("continuous input", continuousCodes);               // if an input has multiple keys, they are passed in an array (list).
  press = inputs.addPress("press input", pressCodes);                      // you can either create the array as another variable and pass it into the adder,
  release = inputs.addRelease("release input", new String[]{"q", "e"});    // or create a new array inside the function call
}

void draw() {
  // update the input handler
  inputs.update();
  
  // clear the canvas
  background(white);
  
  // draw indicators for key presses
  noStroke();
  // if this is confusing, it's called a "ternary operator" and it's really just a tiny if statement.
  // if you want to use it yourself, the syntax is "condition ? value if true : value if false"
  fill(inputs.getState("continuous input") ? green : red);
  ellipse(100, 100, 150, 150);
  
  fill((inputs.getKey("spacebar") || inputs.getKey("t")) ? green : red);
  ellipse(300, 100, 150, 150);
  
  fill(inputs.getState("mouse input") ? green : red);
  ellipse(500, 100, 150, 150);
  
  fill(mouseBind.active() ? green : red);
  ellipse(100, 300, 150, 150);
  
  fill(inputs.getState("press input") ? green : red);
  ellipse(500, 300, 150, 150);
  
  fill(press.active() ? green : red);
  ellipse(100, 500, 150, 150);
  
  fill(inputs.getState("release input") ? green : red);
  ellipse(300, 500, 150, 150);
  
  fill(release.active() ? green : red);
  ellipse(500, 500, 150, 150);
  
  // draw indicator for mouse delta
  stroke(0);
  fill(white);
  rect(225, 225, 150, 150);
  noStroke();
  fill(black);
  // offset mouse delta indicator to the center of the screen
  ellipse(mouseDelta.x + 300, mouseDelta.y + 300, 10, 10);
  
  // draw indicator for both mouse positions
  fill(red);
  ellipse(pmousePos.x, pmousePos.y, 10, 10);
  fill(black);
  ellipse(mousePos.x, mousePos.y, 10, 10);
  
  // draw labels
  fill(black);
  text("Continuous:\nSpacebar or T\n(uses getState)", 100, 100);
  text("Continuous:\nSpacebar or T\n(uses getKey)", 300, 100);
  text("Continuous:\nLeft Mouse\n(uses getState)", 500, 100);
  text("Continuous:\nLeft Mouse\n(uses reference)", 100, 300);
  text("mouseDelta", 300, 365);
  text("Press Only:\nA or D\n(uses getState)", 500, 300);
  text("Press Only:\nA or D\n(uses reference)", 100, 500);
  text("Release Only:\nQ or E\n(uses getState)", 300, 500);
  text("Release Only:\nQ or E\n(uses reference)", 500, 500);
}
