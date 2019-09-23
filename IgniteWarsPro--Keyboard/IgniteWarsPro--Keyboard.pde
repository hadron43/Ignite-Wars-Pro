import processing.sound.*;

SoundFile bgMusic, gameMusic, fireMusic, hitMusic;

//Constants
final int nOfMissiles = 5;
final int sOfTank=8, sOfMissile=15;  //Speed in pixels per second
final int widthOfTank=175, heightOfTank=175;  //Dimensions in pixels
final int margin=150;    //Margin in pixels
PImage bgImage, menu, selectTheme, credits, over, loadingImage;
boolean sS, aA, jJ, kK, wW, eE, iI, oO, gameActive, play, loading=true, singlePlayer=true, autoOnMove=false;
int fade2=0;

enum E {MENU, THEME, CREDITS};
E screen;

String theme="space";
//End of declaring constants

//Variables

tank t1, t2;

//End of Global Variables

//Start of class coord
class coord
{
  float x,y;
  
  public 
  coord()
  {
    x=y=-1.0;
  }
  
  coord(float a, float b)
  {
    x=a; y=b;
  }
  
  void update(float a, float b)
  {
    x=a; y=b;
  }
  
  float getX()
  {
    return x;
  }
  float getY()
  {
    return y;
  }
  boolean inRange()
  {
    if(x>margin && x<(width-margin) && y>margin && y<(height-margin))
      return true;
    else
      return false;
  }
}
//End of Class coord


//Start of class Vector
class vector extends coord
{
  float dirX, dirY; // for dirX.i + dirY.j
  
  public 
  vector()
  {
    dirX=1; dirY=1;
  }
  
  vector(int a, int b)
  {
    dirX=a; dirY=b;
  }
  
  float get_dirX()
  {
    return dirX;
  }
  
  float get_dirY()
  {
    return dirY;
  }
  
  void update(float pos_X, float pos_Y, float dir_X, float dir_Y)
  {
    update(pos_X, pos_Y);
    dirX=dir_X;
    dirY=dir_Y;
  }
  
  void updateDir(float temp_X, float temp_Y)
  {
    dirX=temp_X;
    dirY=temp_Y;
  }
  
  float angle()
  {
    float x=dirX, y=dirY;
    //float ang= abs(atan(y/x));
    float denom = (float)Math.pow(x*x+y*y, 0.5);
    float ang= acos(Math.abs(x/denom));
    //ang= Math.abs(ang);
    if(x>=0 && y<=0)
    {
      ang=2*PI-ang;
    }
    else if(x<=0 && y>=0)
    {
      ang=-ang+PI;
    }
    else if(x<=0 && y<=0)
    {
      ang=ang+PI;
    }
    
    return ang;
  }
  
  void Rotate(boolean clockwise, float unit)
  {
    float theta= angle();
    float modulus= abs(x/(float)Math.pow(x*x+y*y, 0.5));
    
    if(clockwise==true)
    {
      theta+=unit;
    }
    else
    {
      theta-=unit;
    }
    float tempX=modulus*cos(theta);
    float tempY=modulus*sin(theta);
    updateDir(tempX, tempY);
  }
  
  boolean move(float factor)
  {
    vector temp=new vector();
    temp.x=(float)(x+factor*dirX);
    temp.y=(float)(y+factor*dirY);
    
    if(temp.inRange())
    {
      update(temp.getX(), temp.getY());
      return false;
    }
    return true;
  }
  
  boolean move(float factor, tank t3)
  {
    vector temp=new vector();
    temp.x=(float)(x+factor*dirX);
    temp.y=(float)(y+factor*dirY);
    
    if(temp.inRange() && t3.pInTank(temp)==false)
    {
      update(temp.getX(), temp.getY());
      return false;
    }
    return true;
  }
}
//End of Class Vector


//Start of class Tank
class tank
{
  vector pos= new vector();  //For position coordinates
  vector corners[]=  new vector[4];
  vector missile[]= new vector[nOfMissiles];
  int health, missActive;
  PImage img, sphere;
  int fade;
  int healthIncrease;
  
  boolean pInTank(vector v)
  {
    if(((v.x<(pos.x+widthOfTank/2-10)) && (v.x>(pos.x-widthOfTank/2)+10))
       &&((v.y<(pos.y+widthOfTank/2-10)) && (v.y>(pos.y-widthOfTank/2+10))))
       return true;
     else
       return false;
  }
  
  public tank(float pos_X, float pos_Y, float dir_X, float dir_Y, String fileName )
  {
    pos.update(pos_X, pos_Y, dir_X, dir_Y);
    fade=0;
    health=100;
    img=loadImage("data/graphics/"+fileName);
    img.resize(widthOfTank, heightOfTank);
    sphere=loadImage("data/graphics/sphere.png");
    sphere.resize(25,25);
    healthIncrease=40;
    
    for(int i=0; i<nOfMissiles; ++i)
    {
      missile[i]=new vector();
    }
    for(int i=0; i<4; ++i)
    {
      corners[i]=new vector();
      corners[i].updateDir(pos.dirX,pos.dirY);
    }
    missActive=0;
  }
  
  void disp()
  {
    float X=pos.getX(), Y=pos.getY(), angle=pos.angle();
    
    if(!play)
    {
      if(health<=0)
      {
        fill(255,0,0);
        textSize(50);
        text("LOSER", X-widthOfTank/2 , Y+heightOfTank/2+50); 
      }
      else
      {
        fill(0,255,0);
        textSize(50);
        text("WINNER", X-widthOfTank/2 , Y+heightOfTank/2+50); 
      }
    }
    
    translate(X, Y);
    rotate(angle);
    
    if(fade>0)
    {
      tint(0, 153, 150, 126);
      fade--;
    }
    
    imageMode(CENTER);
    image(img, 0, 0);
    noTint();
    
    corners[0].update(widthOfTank/2, heightOfTank/2);
    corners[1].update(-widthOfTank/2, heightOfTank/2);
    corners[2].update(-widthOfTank/2, -heightOfTank/2);
    corners[3].update(widthOfTank/2, -heightOfTank/2);
    
    for(int i=0; i<4; ++i)
    {
      float x=corners[i].getX();
      float y=corners[i].getY();
      corners[i].update(x*cos(-angle)+y*sin(-angle)+X, y*cos(-angle)-x*sin(-angle)+Y);
    }
    
    rotate(-angle);
    translate(-X, -Y);
    
    for(int i=0; i<missActive; ++i)
    {
      imageMode(CENTER);
      image(sphere, missile[i].getX(), missile[i].getY());
    }
    
    healthIncrease--;
    if(healthIncrease<0)
    {
      if(health<100 && play)
        health++;
      healthIncrease=40;
    }
  }
  
  void fire()
  {
    if(missActive<nOfMissiles)
    {
      missile[missActive].update(pos.getX(), pos.getY(), pos.get_dirX(), pos.get_dirY());
      missActive++;
      if(!fireMusic.isPlaying())
        fireMusic.play();
    }
  }
  
  void moveMissiles(float speed, tank t3)
  {
    boolean temp[] = new boolean[nOfMissiles];
    for(int i=0; i<missActive; ++i)
    {
      temp[i]=missile[i].move(speed);
    }
    
    for(int i=0; i<missActive; ++i)
    {
      if(temp[i]==true)
      {
        missile[i]=new vector();
      }
      if(t3.pInTank(missile[i])==true)
      {
        missile[i]=new vector();
        if(play)
          t3.health-=7;
        t3.fade=10;
        if(!hitMusic.isPlaying())
          hitMusic.play();
      }
    }
    
    for(int i=0; i<missActive; ++i)
    {
      if(missile[i].inRange()==false)
      {
        for(int j=i; j<missActive-1; ++j)
        {
          vector v1=missile[j+1];
          missile[j].update(v1.x, v1.y, v1.dirX, v1.dirY);
        }
        
        missActive--;
        missile[missActive]=new vector();
        --i;
      }
    }  
  }
};
//End of class Tank

void startGame()
{
  t1= new tank(400,400, 1, 0, theme+"_vehicle1.png");
  t2= new tank(width-400, height-400, -1, 0, theme+"_vehicle2.png");
}

int cooldown=64;

void auto(tank t2, tank t1)
{
  //Automate t2 with respect to t1
  vector missile[]= new vector[nOfMissiles];
  for(int i=0; i<nOfMissiles; ++i)
  {
    missile[i]=new vector();
    
    if(i<t1.missActive)
      missile[i].update(t1.missile[i].x, t1.missile[i].y, t1.missile[i].dirX, t1.missile[i].dirY);
  }
    
  boolean danger=false;
  
  //Check whether any of the missiles is going to hit tank t2
  int i;
  for(i=0; i<t1.missActive; ++i)
  {
    while(missile[i].inRange()==true)
    {
      missile[i].update(missile[i].x+missile[i].dirX*4, missile[i].y+missile[i].dirY*4);
      if(t2.pInTank(missile[i]))
      {
        danger=true;
        autoOnMove=true;
        break;
      }
    }
    if(danger==true)
      break;
  }
  
  if(danger)
  {
    iI=true;
    //if(abs(t2.pos.angle()-missile[i].angle())<radians(10.0))
      kK=true;
  }
  else
  {
    iI=false;
    kK=false;
  }
    
  //Update direction if needed
  if(t2.pos.x<200 || t2.pos.x>width-200)
    t2.pos.updateDir(-t2.pos.dirX,t2.pos.dirY);
    
  if(t2.pos.y<200 || t2.pos.y>height-200)
    t2.pos.updateDir(t2.pos.dirX,-t2.pos.dirY);
    
  if(!danger)
  {    
    //Code for attacking
    vector v = new vector();  
    float  mod;
    v.dirX=(t1.pos.x-t2.pos.x);
    v.dirY=(t1.pos.y-t2.pos.y);
    mod=pow(v.dirX*v.dirX+ v.dirY*v.dirY, 0.5);
    
    v.dirX=v.dirX/mod;
    v.dirY=v.dirY/mod;
    
    float angDif=-v.angle()+t2.pos.angle();
    
    //if(angDif>PI)
    //  t2.pos.Rotate(true, radians(3.14)); 
    //else
    //  t2.pos.Rotate(false, radians(3.14)); 
    
    if(cooldown<0 || (abs(mod)<200.0&&cooldown<55))
    {      
      //eE=true;
      
      t2.pos.updateDir(v.dirX,v.dirY);
      //if(angDif>-radians(10) && angDif<radians(10))
        t2.fire();
      
      cooldown=64;
    }
    else
      cooldown--;
  }
  
}

void setMove(int k, boolean b)
{
  if(k=='s'||k=='S')
    sS=b;
  else if(k=='a'||k=='A')
    aA=b;
  else if(k=='j'||k=='J')
    jJ=b;
  else if(k=='k'||k=='K')
    kK=b;
  else if(k=='e'||k=='E')
    eE=b;
  else if(k=='o'||k=='O')
    oO=b;
    
  if(b==true)
  {
    if(k=='w'||k=='W')
      if(wW==false)
        wW=true;
      else
        wW=false;
    else if(k=='i'||k=='I')
      if(iI==false)
        iI=true;
      else
        iI=false;
  }
}


void keyPressed()
{
  if(gameActive==true)
  {
    if(key==RETURN||key==ENTER&&!play)
    {
      setup();
      gameActive=false;
    }
    else
      setMove(key, true); 
  }
  else
  {
    if(screen==E.MENU)
    {
      if(key=='1')
      {  
        gameActive=true;
        if(bgMusic.isPlaying())
          bgMusic.stop();
        if(!gameMusic.isPlaying())
          gameMusic.play(0.6, 0.6);
      }
      else if(key=='2')
        screen=E.THEME;
      else if(key=='3')
        exit();
      else if(key=='4')
        screen=E.CREDITS;
      else if(key=='m' || key=='M')
      {
        if(singlePlayer)
          singlePlayer=false;
        else
          singlePlayer=true;
      }
    }
    else if(screen==E.THEME)
    {
      if(key==CODED)
        if(keyCode==LEFT)
        {
          theme="space";
          setup();
          bgImage=loadImage("data/graphics/"+theme+".png");
          bgImage.resize(width,height);
        }
        else if(keyCode==RIGHT)
        {
          theme="grass";
          setup();
          bgImage=loadImage("data/graphics/"+theme+".png");
          bgImage.resize(width,height);
        }
    }
    else if(screen==E.CREDITS)
    {
      screen=E.MENU;
    }
  }
}
 
void keyReleased()
{
  if(gameActive==true)
    setMove(key, false);
}

void setup()
{
  fullScreen();
  //size(1920, 1080);
  screen=E.MENU;
  gameActive=false;
  play=true;
  fade2=0;
  
  loadingImage=loadImage("data/graphics/loadingImage.jpg");
  imageMode(CENTER);
  background(0);
  image(loadingImage, width/2, height/2);
  imageMode(CORNER);
 
  startGame();
  sS=aA=jJ=kK=wW=eE=iI=oO=false;  //Direction inputs
}

void load()
{
  menu=loadImage("data/graphics/menu.jpg");
  menu.resize(width, height);
  
  selectTheme=loadImage("data/graphics/theme.png");
  selectTheme.resize(width, height);
  
  credits=loadImage("data/graphics/credits.png");
  credits.resize(width, height);
  
  over=loadImage("data/graphics/over.png");
  over.resize(width, height);
  
  bgImage=loadImage("data/graphics/"+theme+".png");
  bgImage.resize(width, height);
  
  bgMusic=new SoundFile(this, "data/audio/bgMusic.mp3");
  gameMusic=new SoundFile(this, "data/audio/gameMusic.mp3");
  fireMusic= new SoundFile(this, "data/audio/fireMusic.wav");
  hitMusic= new SoundFile(this, "data/audio/hitMusic.wav");
}

void mainMenu()
{
  PImage gImage=loadImage("data/graphics/back.png");
  gImage.resize(width,height);
  background(gImage);
}

void draw()
{  
  if(loading)
  {
    load();
    loading=false;
  }
  if(gameActive==false)
  {
    if(screen==E.CREDITS)
    {
      background(credits);
    }
    else if(screen==E.THEME)
    {
      background(selectTheme);
    }
    else if(screen==E.MENU)   //For Menu
    {
      background(menu);
      fill(255,0,0);
      textSize(200);
      if(singlePlayer)
        text("S", width-125 , height-50);
      else
        text("M", width-200 , height-50);
      
      if(gameMusic.isPlaying())
        gameMusic.stop();
      if(!bgMusic.isPlaying())
        bgMusic.play(0.6, 0.6);
    }
  }
  else
  {
    
    play=t1.health>0&&t2.health>0;
    
    background(bgImage);
    if(!gameMusic.isPlaying())
      gameMusic.play(0.6, 0.6);
    if(bgMusic.isPlaying())
      bgMusic.stop();
    //For changing directions of tanks
    
    if(singlePlayer)
      auto(t2, t1);
    
    if(sS==true)
      t1.pos.Rotate(true, radians(3.14));
    if(aA==true)
      t1.pos.Rotate(false, radians(3.14));
    if(kK==true)
      t2.pos.Rotate(true, radians(3.14));
    if(jJ==true)
      t2.pos.Rotate(false, radians(3.14));
    if(eE==true)
    {  t1.fire(); eE=false; }
    if(oO==true)
    {  t2.fire(); oO=false; }
     
    //End of Changing directions
      
    //For Changing Coordinates
    if(wW==true)
      t1.pos.move(sOfTank, t2);
    if(iI==true)
      t2.pos.move(sOfTank, t1);
    //End of Changing Coordinates
    
    t1.moveMissiles(sOfMissile, t2);
    t2.moveMissiles(sOfMissile, t1);
    
    if(!play)
    {
      tint(0, 153, 204, fade2);
      imageMode(CORNER);
      
      image(over, 0,0);
      
      imageMode(CENTER);
      noTint();
      
      if(fade2<1000)
        fade2++;
    }    
    else
    {
      fill(275-(t1.health)*2.55, t1.health*2.55, 0);
      rect(20 , 10, t1.health*1.75, 20);
      
      fill(275-(t2.health)*2.55, t2.health*2.55, 0);
      rect(width-200 , 10, t2.health*1.75, 20);  
    }
    
    t1.disp(); t2.disp();
  
  }
}
