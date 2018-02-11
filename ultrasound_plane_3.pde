/****************************** VARIABLES ******************************************/

// We control which screen is active by settings / updating
// gameScreen variable. We display the correct screen according
// to the value of this variable.
// 
// 0: Initial Screen
// 1: Game Screen
// 2: Gameover Screen 
int gameScreen = 0;
int i, j; 
// scoring
int score = 0;
int maxHealth = 100,health = 100,healthDecrease = 1,healthBarWidth = 60;

float Distance_Cherry_Cupcake;
float Distance_Patrick_Cupcake;
boolean start = true;

float cupcake_Y; 
float cupcake_X=400; 
float initial_angle;
int DistanceUltra;  // the incoming Distance from the serial port
int IncomingDistance;
float Cherry_x,Cherry_y;  // Cherry positions in x,y directions
int victory=0;
int level=1;

String DataIn; //incoming data on the serial port

float [] Patrick_x = new float[6];
float [] Patrick_y = new float[6];
int PatrickInterval = 1000;
int PatrickSpeed = 5;
int lastAddTime = 0;
int minGapHeight = 200;
int maxGapHeight = 300;

PImage Patrick,Cherry,Cupcake,Bikini;

PFont myfont;

/********************************* ARDUINO *****************************************/
// serial port configuration
import processing.serial.*; 
Serial myPort;    

/****************************** SETUP BLOCK ******************************************/

void setup() 
{
  size(800, 600);
  
  myfont = createFont("Boink.ttf",32);
  textFont(myfont);
  myPort = new Serial(this, Serial.list()[0], 9600); 
  myPort.bufferUntil(10);   //end the reception as it detects a carriage return
  frameRate(30); 
  rectMode(CORNERS) ; //we give the corners coordinates 
  textSize(16);
  cupcake_Y = 300; //initial cupcake position
  
  Patrick = loadImage("Patrick.png");  //LOAD NECESSARY PICTURES
  Cherry = loadImage("cherry.png");  
  Cupcake = loadImage("cupcake.png");  
  Bikini = loadImage("background.jpg");
  

 // Random Patrick position
 
  for  (int i = 1; i <= 5; i = i+1) {
    Patrick_x[i]=random(1000);
    Patrick_y[i]=random(400);
  }
  score = 0;
  health = maxHealth;
  victory=0;
  healthDecrease=1;
}

//incoming data event on the serial port
void serialEvent(Serial p) { 
  DataIn = p.readString(); 

  IncomingDistance = int(trim(DataIn)); //conversion from string to integer

  println(IncomingDistance); //checks....

  if (IncomingDistance>1  && IncomingDistance<100 ) {
    DistanceUltra = IncomingDistance; //save the value only if its in the range 1 to 100     }
  }
}

/****************************** DRAW BLOCK ******************************************/

void draw() // Display the contents of the current screen
{ 
  if (gameScreen == 0) {
    initialScreen();
  } else if (gameScreen == 1) {
    gameScreen();
  } else if (gameScreen == 2) {
    gameOverScreen();
  } 

}

/****************************** SCREEN CONTENTS ************************************/

void initialScreen() {
  background(Bikini);
  textSize(32);
  textAlign(CENTER,CENTER);
  text("WELCOME!", width/2,height/3);
  text("Collect 20 cherries to win!",width/2,height/2);
  text("Click to start! Good Luck! :)",width/2,2*height/3);
}
void gameScreen() {
    textSize(16);
    background(Bikini);
    text(initial_angle, 40, 30); //debug 
    text(cupcake_Y, 40, 60); 
    text(cupcake_X, 40, 90); 
    drawHealthBar();
    printscore(); 
    printhealth();    
    cupcakeMove();   
    Patrick();
    Cherry();
    UpdateScore();
    CheckPatrickCollision();
    checkvictory();
  }
void gameOverScreen() {
  
  fill(255, 255, 255);
  if (victory==0)
  {
    background(Bikini);
    textSize(32);
    textAlign(CENTER,CENTER);
    text("GAME OVER! :(", width/2,height/3);
  
    if (score <=5)
    {
      text("You collected "+ score +" cherries! Noob!",width/2,height/2);
      text("Press Mouse to start again!",width/2,2*height/3);
    }
    else 
    {
      text("You collected "+ score +" cherries! Great Job!",width/2,height/2);
      text("Press Mouse to start again!",width/2,2*height/3);
    }
  }
  else //αν victory ειναι 1
  {
    background(Bikini);
      textSize(32);
      textAlign(CENTER,CENTER);
      text("VICTORY!You win level "+level+" :)", width/2,height/3);
      text("You collected "+ score +" cherries! Great Job!",width/2,height/2);
      text("Press Mouse to go to the next level!",width/2,2*height/3);
      text("OR Press any key to quit",width/2,2*height/5);// quit
        
  }
}

/****************************** VARIABLES ******************************************/



/********************************* INPUTS ******************************************/
public void mousePressed() {
  if (gameScreen==0) {
    StartGame();
  }
  if(gameScreen == 2)   { //δηλαδη gameOverScreen 
    
    if (victory==1){      
      ContinueGame();
    } else {
      score = 0;
      health = 100;
      cupcake_Y = 300;
      StartGame();    
    }   
    
  }
}
public void keyPressed() {
  if(gameScreen == 2) {
    gameScreen = 0;
  }
}
/****************************** OTHER FUNCTIONS ******************************************/

//here we draw the score
void printscore() {
   text("score :", 200, 30); 
   text( score, 260, 30);
}
void printhealth() {
   text("health :", 200, 60); 
   text( health, 260, 60);
}

void cupcakeMove() {
  
    //initial_angle = mouseY-300; //uncomment this line and comment the next one if you want to play with the mouse
    initial_angle = (18- DistanceUltra)*4; 
    
    //check the angle range to prevent the Cupcake to flip on the screen 
    if (initial_angle >= 90 )   initial_angle=90;
    if (initial_angle <= -90 )  initial_angle=-90;
    
    cupcake_Y += sin(radians(initial_angle))*10; //calculates the vertical position of the Cupcake    
    
    //check the height range to keep the Cupcake on the screen     
    if (cupcake_Y < 0)  {
       victory=0;
       gameOver();
    } 
    if (cupcake_Y > 600)  {
       victory=0;
       gameOver();
    } 
    
    TraceCupcake(cupcake_Y, initial_angle); //draw cupcake
}

void StartGame() {
  //setup();
  gameScreen=1;
}
void ContinueGame() {
  score = 0;
  health = maxHealth;
  gameScreen=1;
  healthDecrease+=5;  //nextlevel(); 
  level++;
}
void gameOver() {
  gameScreen=2;
}

void Patrick() {
  
  //draw and move Patrick
    for  (int i = 1; i <= 5; i = i+1) {
      Patrick_x[i] -= cos(radians(initial_angle))*(10+2*i);
  
      image(Patrick, Patrick_x[i], Patrick_y[i],180, 120);
      
      if (Patrick_x[i] < -300) {
        Patrick_x[i]=1000;
        Patrick_y[i] = random(400);
      }
    }     
}

void Cherry() {
  
  Cherry_x -= cos(radians(initial_angle))*10;
  if (Cherry_x < -30) {
    Cherry_x=900;
    Cherry_y = random(600);
    while((Patrick_y[1]-60)<Cherry_y&&Cherry_y<(Patrick_y[1]+60)||   
         (Patrick_y[2]-60)<Cherry_y&&Cherry_y<(Patrick_y[2]+60)||
         (Patrick_y[3]-60)<Cherry_y&&Cherry_y<(Patrick_y[3]+60)|| 
         (Patrick_y[4]-60)<Cherry_y&&Cherry_y<(Patrick_y[4]+60)|| 
         (Patrick_y[5]-60)<Cherry_y&&Cherry_y<(Patrick_y[5]+60)    )
                   
        Cherry_y = random(600);
    
  }
  //displays the cherry. 70 and 50 are the size in pixels of the picture
  image(Cherry, Cherry_x, Cherry_y, 70, 50); 

}

void UpdateScore() {
    //check the distance between the Cupcake and cherry and increase the score
    Distance_Cherry_Cupcake = sqrt(pow((400-Cherry_x), 2) + pow((cupcake_Y-Cherry_y), 2)) ;
  
    if (Distance_Cherry_Cupcake < 70) {
      //we hit the cherry   
      score++;  
      //reset the cherry position
      Cherry_x = 900;
      Cherry_y = random(600);
    }
}

void TraceCupcake(float Y, float Angle) {
  //draw the Cupcake at given position and angle

  noStroke();
  pushMatrix();
  translate(400, Y);
  rotate(radians(Angle)); //in degrees
  scale(0.5); 
  // parameters 2 and 3 are half the picture size, to make sure that the Cupcake rotates in his center.
  image(Cupcake, -60, -70, 120, 140); //120 140 : picture size
  popMatrix(); //end of the rotation matrix
 
}

void drawHealthBar() {
  noStroke();  
  rectMode(CORNER);  
  rect(400-(healthBarWidth/2), cupcake_Y - 30, healthBarWidth, 5);
  fill(189, 195, 199);
  if (health > 60) {
    fill(46, 204, 113);
  } else if (health > 30) {
    fill(230, 126, 34);
  } else {
    fill(231, 76, 60);
  }
  rectMode(CORNER);
  rect(400-(healthBarWidth/2), cupcake_Y - 30, healthBarWidth*(health/maxHealth), 5);
}
/***********************************************----Victory----***************************************************/




void decreaseHealth() {
  health -= healthDecrease;
  if (health <= 0) {
    victory=0;
    gameOver();//το παει στο gameScreen=2; gameOverScreen()..γινεται ο ελεγχος για victory =o αρα εμφανιζει το μηνυμα
  }
}

void checkvictory()
{ 
  if (score ==20){ 
       victory=1;
       gameOver();//παει στο gameScreen=2;gameOverScreen()
      
  }
}
/**********************************-------------end victory-------------******************************/
void CheckPatrickCollision() {
  
   for  (int i = 1; i <= 5; i++) {
      float s = pow(Patrick_x[i]-50-400,2)/pow(20,2)+pow(Patrick_y[i]-cupcake_Y,2)/pow(30,2);
      if(s<=1) decreaseHealth();
      s = pow(Patrick_x[i]-400,2)/pow(20,2)+pow(Patrick_y[i]-30-cupcake_Y,2)/pow(30,2);
      if(s<=1) decreaseHealth();
      s = pow(Patrick_x[i]-400,2)/pow(20,2)+pow(Patrick_y[i]+30-cupcake_Y,2)/pow(30,2);
      if(s<=1) decreaseHealth();  
      s = pow(Patrick_x[i]-400,2)/pow(20,2)+pow(Patrick_y[i]-cupcake_Y,2)/pow(30,2);
      if(s<=1) decreaseHealth(); 
   }
  
  

  
}