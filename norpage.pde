void norpage(){
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
      //sss
    }
    
    pretime=0;
  }
  
  if(startornot==true) pretime=(timepoint-restarttime-delta)%(songlong/2);
  //draw the breath circle in the middle of the screen
 

  getf();  
  //println("breathornot=",breathornot);
     
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

     //abNorBreath[i]=[chuli];
     //wlNorBreath[i]=int(a[1]);
     //wrNorBreath[i]=int(a[2]);
     //llNorBreath[i]=int(a[3]);
     //lrNorBreath[i]=int(a[4]);
     
     //line(inputpitchX[i],abNorBreath[i],inputpitchX[i+1],abNorBreath[i+1]);
     //line(inputpitchX[i],wlNorBreath[i],inputpitchX[i+1],wlNorBreath[i+1]);
     //line(inputpitchX[i],wrNorBreath[i],inputpitchX[i+1],wrNorBreath[i+1]);
     //line(inputpitchX[i],inputpitchY[i],inputpitchX[i+1],inputpitchY[i+1]);
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
  if(breathornot==false)line(inputpitchX[arrayindex]-5,inputpitchY[arrayindex],inputpitchX[arrayindex],inputpitchY[arrayindex]);
  
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
  
  if(startornot==false){
    textFont(tempo_font,28);
  text("Breath in the normal way you like.", width/2, height*2/5); 
  text("Follow your own tempo.", width/2, height/2); 
  text("Stop breathing until the bar moves to the end.", width/2, height*3/5); 
  } 
  
  if (myString != null & startornot==true) {  //if the string is not empty, print the following

    String[] a = split(myString, ' ');  // a new array (called 'a') that stores values into separate cells (separated by commas specified in your Arduino program)
    abNorBreath[arrayindex]=int(a[0]);
    wlNorBreath[arrayindex]=int(a[1]);
    wrNorBreath[arrayindex]=int(a[2]); 
    llNorBreath[arrayindex]=int(a[3]);
    lrNorBreath[arrayindex]=int(a[4]);
    
    if(arrayindex>10) {
      abNorBreath[arrayindex]=abNorBreath[arrayindex]/((abNorBreath[1]+abNorBreath[2]+abNorBreath[3]+abNorBreath[4]+abNorBreath[5]+abNorBreath[6]+abNorBreath[7]+abNorBreath[8])/8);
      wlNorBreath[arrayindex]=wlNorBreath[arrayindex]/((wlNorBreath[1]+wlNorBreath[2]+wlNorBreath[3]+wlNorBreath[4]+wlNorBreath[5]+wlNorBreath[6]+wlNorBreath[7]+wlNorBreath[8])/8);
      wrNorBreath[arrayindex]=wrNorBreath[arrayindex]/((wrNorBreath[1]+wrNorBreath[2]+wrNorBreath[3]+wrNorBreath[4]+wrNorBreath[5]+wrNorBreath[6]+wrNorBreath[7]+wrNorBreath[8])/8); 
      llNorBreath[arrayindex]=llNorBreath[arrayindex]/((llNorBreath[1]+llNorBreath[2]+llNorBreath[3]+llNorBreath[4]+llNorBreath[5]+llNorBreath[6]+llNorBreath[7]+llNorBreath[8])/8);
      lrNorBreath[arrayindex]=lrNorBreath[arrayindex]/((lrNorBreath[1]+lrNorBreath[2]+lrNorBreath[3]+lrNorBreath[4]+lrNorBreath[5]+lrNorBreath[6]+lrNorBreath[7]+lrNorBreath[8])/8); 
    }
    //println(indexNorPage," ",abNorBreath[indexNorPage]," ",wlNorBreath[indexNorPage]," ",wrNorBreath[indexNorPage]," ",llNorBreath[indexNorPage]," ",int(a[4]));
    
    indexNorPage++;    
   }
  
  waNorBreath[arrayindex]= (wlNorBreath[arrayindex]+wrNorBreath[arrayindex])/2;
  luNorBreath[arrayindex]= (llNorBreath[arrayindex]+lrNorBreath[arrayindex])/2;
  
 println(arrayindex," ",abNorBreath[arrayindex]," ", llNorBreath[arrayindex]," ",lrNorBreath[arrayindex]);
    
}
