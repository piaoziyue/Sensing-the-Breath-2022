class Button {
  static final int W = 120, H = 40, TXTSZ = 020;
  static final color BTNC = #00A0A0, HOVC = #00FFFF, TXTC = 0;
 
  final String label;
  final int x, y, xW, yH;
  final String shape;
 
  boolean isHovering;
 
  Button(String txt, int xx, int yy, String c) {
    label = txt;
 
    x = xx;
    y = yy;
 
    xW = xx + W;
    yH = yy + H;
    
    shape=c;
  }
 
  void display() {
   if(isInside()==false) fill(255,100);
   else fill(150,100);
    if(shape=="r") rect(x-W/2, y, W, H,7);
    else if(shape=="c") ellipse(x-W/2, y, H-5, H-5);
     
    textSize(20);
    
    if(shape=="r"){fill(51); text(label, x , y + H/2+5);}
    else if(shape=="c") {fill(51); text(label, x-W/2, y);}
  }
 
  boolean isInside() {
    if(shape=="r") return isHovering = mouseX > x-W/2 & mouseX < xW-W/2 & mouseY > y & mouseY < yH;
    else return isHovering = mouseX > x-W/2-H+5 & mouseX < x-W/2+H-5 & mouseY > y-H+5 & mouseY < y+H-5;
  }
}
