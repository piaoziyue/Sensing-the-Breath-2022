class Ring {
  PFont breathword;
  float x, y; // X-coordinate, y-coordinate
  float diameter; // Diameter of the ring
  boolean on ; // control whether to contract or grow
  float max=250,min=50;
  
  void start(float xpos, float ypos) {
    x = xpos;
    y = ypos;
    on = false;
    diameter = max;   
  }
  
  void grow() {    
      background(diameter/max*80);
      breathword = loadFont("FuturaLT-Light-48.vlw");
      textFont(breathword,diameter/4.5);
      fill(0,120);
      textAlign(CENTER, CENTER);
      text("Breath In", 80+(width-100)/2, height/2); 
      
      if (diameter >= max) {
        on =false;
      }   
      else diameter += 11;//constant speed of breath in
  }
  
  void contract(float speed) {       
      background(diameter/max*80);
      
      breathword = loadFont("FuturaLT-Light-48.vlw");
      textFont(breathword,diameter/2.5);
      fill(0,120);
      textAlign(CENTER, CENTER);
      text("Out", 80+(width-100)/2, height/2); 
      
      if (diameter <= min) {
        on =true;
      }
      if (diameter >= max) {
        on =false;
      } 
      diameter -= 2*speed*(max-min)/(7*w);
    
      
  }
  
  void display() {   
      fill(155,50);
      /*strokeWeight(4);
      stroke(155, 50);*/
      noStroke();
      ellipse(x, y, diameter, diameter);
      //rect(x-diameter/2,y-diameter*5/6+50,diameter,diameter/3);
      
      fill(20,50);
      //ellipse(x-30, y-50, 7, 10);
      //ellipse(x+30, y-50, 7, 10);
    
  }
}
