void maxpage()
{
    section=int(8*(timepoint-restarttime-delta)/songlong);
  int songlongpiece=songlong/32;
  
  if(breathornot==true) breathtime[arrayindex]=1;
  else breathtime[arrayindex]=0;

  if(song.length()-song.position()<=110 && currentBeat==1) {
    startornot=true;
    stopornot=true;//when the start audio stoped
  }
  if(stopornot==false) restarttime=millis();

  timepoint=millis();
  timerate=frameRate;
  if(startornot==true){
  if(startorgo==true && xline==80 & upordown==true && firsttrigger==true) {    
    starttime=millis();
    println("start!");
    clearArrayinterval();
    if(currentBeat==1) {high.trigger();firsttrigger=false;}
  }
   
   xline=(16*w*(timepoint-restarttime-delta)/songlong)%960+80;
   if(xline-prexline>0) movespeed=xline-prexline;
   prexline=xline;
   
   if((xline-startx)%(w/2)<pre){
    
      if(currentBeat % beatsPerBar == 0) {
        high.trigger();}
      else {
        low.trigger();}      
        currentBeat +=1;    
        pre=0;
      }    
   if(startornot==true) pre=(xline-startx)%(w/2);   
   tickSize = (fRate * 60)/tempo; 
  }
  
  //judge if the timepoint is in the upper screen of the downward screen
  //println(upordown," ",(timepoint-restarttime-delta)%(songlong/2)," ",pretime);
  if( (timepoint-restarttime-delta)%(songlong/2)<pretime && startornot==true){
    if(upordown==true) 
      upordown=false;
    else {
      upordown=true;
      arrayindex=0;
    }
    pretime=0;
  }
  
  if(startornot==true) pretime=(timepoint-restarttime-delta)%(songlong/2);
  //draw the breath circle in the middle of the screen
 
  getf();  
     
  writer.println(f);
  if(startornot){
    writer.flush();
    writer.close();
  }
  
  //draw rainbow notes and bar lines
  draw_noteline();
  
  //draw pitch lines
    
  inputtime=millis();
  
  int delaymax=11;
  //if(note.breathinorout==true) println("breath in");
  //else println("breath out");
   
  for(int i=0;i<arrayindex-1;i++){                  
     strokeWeight(3);
     stroke(255,255,255,level[i]+40);

     if(inputpitchX[i+1]>inputpitchX[i])
       //line(inputpitchX[i],inputpitchY[i],inputpitchX[i+1],inputpitchY[i+1]);

      for(int j=1;j<=notecount;j++){
       if(inputpitchX[i]>=eachnote[j].x && inputpitchX[i]<=eachnote[j].x+eachnote[j].notelong*w/2 && inputpitchY[i]>=eachnote[j].y && inputpitchY[i]<=eachnote[j].y+eachnote[j].r)
       {                           
           eachnote[j].setNoteColor();
           colortime[i]=eachnote[j].c;
           stroke(colortime[i],level[i]);      
           //line(inputpitchX[i],eachnote[j].y,inputpitchX[i],eachnote[j].y+eachnote[j].r);            
       }  
           
       if(eachnote[j].nextbreathornot==1 &&sendtime==0 && xline>=eachnote[j].startbreathx && xline<=eachnote[j].xmax && ((inputpitchY[i]<=height/2 && eachnote[j].y<=height/2)||(inputpitchY[i]>height/2 && eachnote[j].y>height/2))) 
       {              
         sendornot[i]=true;  
         sendtime+=1;
       } 
       else sendornot[i]=false;
             
      
     }    
  }
  
  
//if(arrayindex>5) println(arrayindex,"sendornot=",sendornot[arrayindex]);
//println(sendtime,"sendornot=",sendornot);  
if(sendornot[arrayindex]){
  sendtime=0;
  
  }


  int delaytime;
  delaytime=millis()-inputtime;
  if(delaytime<delaymax) delay(delaymax-delaytime);
  
  
    if(startornot==true)
  {
    inputpitchX[arrayindex]=xline;
    level[arrayindex]=AS.GetLevel()*1600+40;
      if( level[arrayindex]>255) level[arrayindex]=255;
    if(upordown==true) {
      inputpitchY[arrayindex]=height/2-f/2+10;    
      if(arrayindex>=1 && (inputpitchY[arrayindex]<=0||inputpitchY[arrayindex+1]-inputpitchY[arrayindex]>=80)) inputpitchY[arrayindex]=inputpitchY[arrayindex-1];
      if(f<100) inputpitchY[arrayindex]=height/2;      
    }
    
    else {
    inputpitchY[arrayindex]=height-f/2-20;
    if(arrayindex>=1 && (inputpitchY[arrayindex]<=height/2||inputpitchY[arrayindex+1]-inputpitchY[arrayindex]>=80)) inputpitchY[arrayindex]=inputpitchY[arrayindex-1];
    if(f<100) inputpitchY[arrayindex]=height-20;
    }    
  }
  
  strokeWeight(4);
  stroke(240,200);
  //if(breathornot==false)line(inputpitchX[arrayindex]-5,inputpitchY[arrayindex],inputpitchX[arrayindex],inputpitchY[arrayindex]);
  
  //println(arrayindex," ",inputpitchX[arrayindex]," ",inputpitchY[arrayindex]);
  //if(arrayindex>2*(width-100)/movespeed) arrayindex-=2*(width-100)/movespeed;
  if(startornot==true) {
    arrayindex+=1;
    
    if(section>=0)arrayinterval[section]+=1;
  }
  if (timepoint%(width)<=5) 
  changepoint=xline;
  
  //draw the time stick
  draw_timestick(xline);
  
  //show the tempo button
  tempobar.update();
  tempobar.display(); 
  
  if(tempobar.over==true && mousePressed==true){
    timerevise=timepoint;
    score=0;
    startorgo=true;
    upordown=true;
  }
  
  textFont(tempo_font,15);
  fill(155,200);
  textAlign(CENTER, CENTER);
  text("Tempo", 3*width/4+65, height/2-10); 
  
  //show the left, right and revise buttons
  updateL(leftX,leftY);
  updateR(rightX,rightY);
  updatePl(playX,playY);
 
  if (leftOver) {
     tint(0,200);
  } else {
      tint(155,200);}  
  left.resize(40,40);
  image(left,leftX,leftY);
  tint(155,200);
  
  if (rightOver) {
     tint(0,200);
  } else {
      tint(155,200);} 
  right.resize(40,40);
  image(right,rightX,rightY);
  tint(155,200);
  
  if (playOver) {
     tint(0,200);
  } else {
      tint(155,200);} 
  if(pauseornot==true){
    pause.resize(40,40);
    image(pause,playX,playY);
    tint(155,200);
  }
  else{    
    play.resize(40,40);
    image(play,playX,playY);
    tint(155,200);
  }
  
  
  /*if (reviseOver) {
     tint(0,200);
  } else {
      tint(155,200);} 
  revise.resize(30,30);
  image(revise,reviseX,reviseY);
  tint(155,200);*/
  
    
  start1.resize(30,30);
  image(start1,startX,startY);
  textFont(tempo_font,15);
  fill(155,200);
  textAlign(CENTER, CENTER);
  text("Start", startX-30, startY); 
  float dex=0.0083;//dex=2*movespeed/w
  //set the two bezier lines
  curve1 = new BezierCurve(A, B, C, D);
  curve2 = new BezierCurve(E, F, G, H);

  lefthand.resize(40,40);
  tint(155,100);
  righthand.resize(40,40);
  tint(155,100);
  int xplus=-10;
  int yplus=40;
  
  int curvexmax=260;
  int curvexmid=200;
  int curvexmin=150;
  
  int curveymax=50;
  int curveymin=-100;

  A.set( width/2-curvexmax+xplus, height/2+yplus);//
  B.set( width/2-curvexmid+xplus, height/2+curveymax+yplus);//
  C.set( width/2-curvexmid+xplus, height/2+curveymin+yplus);//
  D.set( width/2-curvexmin+xplus, height/2+yplus);//
  E.set( width/2+curvexmax+xplus, height/2+yplus);//
  F.set( width/2+curvexmid+xplus, height/2+curveymax+yplus);//
  G.set( width/2+curvexmid+xplus, height/2+curveymin+yplus);//
  H.set( width/2+curvexmin+xplus, height/2+yplus);//
    
  // draw the two curves and show the two hands
  strokeWeight(2);
  //tStep=tempobar.getPos();
  
   
  pushMatrix();
  translate(borderSize, -50);    
  
  circleStyle();
  PVector pos1 = curve1.pointAtFraction(tCurve);
  PVector pos2 = curve2.pointAtFraction(tCurve);
  float pos1y=0;
  float pos2y=0;
  float deltax=0;
  float deltay=0;
  
  
  tCurve -= tStep;
  if(tCurve<0) tCurve+=2;
  
  if(startornot==true){
    tStep=2*movespeed/w;//2*movespeed/w=1/30~~0.03333
  }
  else{
    tStep=0;
  }
  
  if(tCurve>=0.0 && tCurve<1.0 && pos1.x<370){
    
    image(lefthand,pos1.x+80*(2-circleport),pos1.y);
    pos1y=pos1.y-deltax;
    image(righthand,pos2.x-80*(2-circleport),pos2.y);
    pos2y=pos2.y+deltay;
  }
  if(tCurve>=1.0 && tCurve<2.0){
     pos1=curve1.pointAtFraction(2-tCurve);
     pos2=curve2.pointAtFraction(2-tCurve);
     
     image(lefthand,pos1.x+80*(2-circleport),height+2*yplus-pos1.y);
     pos1y=height+2*yplus-pos1.y;
     image(righthand,pos2.x-80*(2-circleport),height+2*yplus-pos2.y);
     pos2y=height+2*yplus-pos2.y;
  }
  
  popMatrix();
}
