/*
                Documentation
 ===============================================
 Author: Sagar Keim
 Co-Author: Harsh Kumar
 ===============================================

 This sketch takes input from a gyroscope MPU6050
 and two push buttons. It displays the following 
 outputs on serial:
  1. IP : For initial position
  2. CW : For clockwise rotation
  3. AC : For anticlockwise rotation
  4. SS : For start/stop
  5. FF : For fire 

 ===============================================
 */

#include <MPU6050_tockn.h>
#include <Wire.h>

MPU6050 mpu6050(Wire);
int startstop = 9;
int fire = 8;
int rotation=-2;   //0 for initial, -1 for anticlockwise, +1 for clockwise
int startstopvalue = 0;
int firevalue = 0;
int cooldownFire=0, cooldownStart=0;
int cooldownPeriod=60;
int z=0;

void setup()
{
  Serial.begin(9600);
  Wire.begin();
  mpu6050.begin();

  pinMode(startstop, INPUT);
  pinMode(fire, INPUT);
}

void loop() 
{
  mpu6050.update();
  z=mpu6050.getAngleZ();

  if(z>=-10 && z<=10 && rotation!=0)
  {
    Serial.println("IP");   //For initial position
    rotation=0;
  }
  else if(z<-10 && rotation!=-1)
  {
    Serial.println("AC");   //For anticlockwise rotation
    rotation=-1;
  }
  else if(z>10 && rotation!=1)
  {
    Serial.println("CW");    //For clockwise rotation
    rotation=1;
  }
    
  startstopvalue = digitalRead(startstop);
  firevalue = digitalRead(fire);
  
  if(startstopvalue == HIGH)
  {
    cooldownStart--;
    if(cooldownStart<0)
    {
      Serial.println("SS");   //For startstop
      cooldownStart=cooldownPeriod;
    }
  }
  else if(firevalue == HIGH)
  {
    cooldownFire--;
    if(cooldownFire<0)
    {
      Serial.println("FF");   //For fire
      cooldownFire=cooldownPeriod;
    }
  }
}
