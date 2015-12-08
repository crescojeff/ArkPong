﻿package com.ai.arkpong.control;

//import com.ai.arkpong.view.Explode;//TODO: uncomment when particles are back
import haxe.ui.toolkit.controls.Button;
import openfl.display.*;
import openfl.events.*;
import openfl.display.Graphics;
import openfl.display.Shape;
import haxe.ui.toolkit.controls.Text;
import openfl.utils.Timer;
import haxe.ui.toolkit.controls.Button;
import openfl.ui.Mouse;
//import org.flintparticles.common.counters.TimePeriod;//TODO: uncomment when particles are back

class TemporaryBall extends Ball{
   //These variables are needed for moving the ball
	var ballXSpeed:Float=5.5;//X Speed of the Ball
	var ballYSpeed:Float=5.5;//Y Speed of the Ball
	//var leftWallHit:Int=0;//monitors hits in-a-row on left wall
	//var rightWallHit:Int=0;//monitors hits in-a-row on right wall
	//var topHit:Int=0;//monitors hits in-a-row on ceiling
	//var bottomHit:Int=0;//monitors hits in-a-row on floor [probably not needed]
	var leftWallHit2:Int=0;//monitors hits in-a-row on left wall
	var rightWallHit2:Int=0;//monitors hits in-a-row on right wall
	var topHit2:Int=0;//monitors hits in-a-row on ceiling
	var bottomHit2:Int=0;//monitors hits in-a-row on floor [probably not needed]
	//var theBackground:MovieClip=new myBackground();
	//var ex:Explode;//TODO: uncomment when particles are back
	var power:Power;
	var trackLvl:Int;
	public var myBall:PrimaryBall;
	public var myPaddle:MovieClip;
	public var evilPaddle:MovieClip;
	public var evilSight:MovieClip;
	public var countHit:Int;
	public var hitControl:Int=0;
	var control2:Int=0;	//this variable will be used to track which paddle the ball just bounced off
	var bricksDestroyed:Int=0;
	var factor2:Float=0.8;
	public var xLocations:Array<Dynamic>=new Array();
	var noHurtTimer:Timer=new Timer(500,1);
	var moveTimer:Timer=new Timer(50,250);//timer to control ball motion instead of enterFrame...
	var noHurt:Int=0;
	public var startButton:Button;
	var theStage:Stage;
	//var callParts:CallParts;//TODO: uncomment when particles are back
	var stuckTimer:Timer=new Timer(250,1);
	var deathTimer:Timer=new Timer(200,1);//this timer will be invoked just after the ball2 is slated to disappear such that it exists for a split second AFTER it is no longer listening for collisions etc. This way we won't get phantom leaks when the ball2 dies as it is still registering a collision.
	var splitTimer:Timer=new Timer(5000, 1);//decided to have splittiemr here so that ball2 handles itself completely
	var rebuild:Bool=false;
	//var ballRef:PrimaryBall;
	var mainRef:ArkPongMain;
	var creationTime:Float;
	var dying:Bool=false;
	var date:Date=new Date();
	
	
	public function new(paddle:MovieClip,ball:PrimaryBall,ePaddle:MovieClip,stageRef:Stage,eSight:MovieClip,mainR:ArkPongMain){
		
		this.myBall=ball;
		this.myPaddle=paddle;
		this.evilPaddle=ePaddle;
		this.theStage=stageRef;
		this.evilSight=eSight;
		//this.ballRef=ballR;
		this.mainRef=mainR;
		countHit=0;
		//addEventListener(Event.ENTER_FRAME, screamlikeabitch);
		addEventListener(Event.ENTER_FRAME, ballMotion2);
		noHurtTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hurtAgain);
		stuckTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetHits);
		//mainRef.stage.addEventListener(KeyboardEvent.KEY_UP, toggleDebug);
		splitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, startEndBall2);
		mainRef.ball2Counter++;
		splitTimer.start();
		//addEventListener(Event.ENTER_FRAME, checkGC)
		////creationTime=//system.getClockinmilliseconds or some such
		//moveTimer.addEventListener(TimerEvent.TIMER, expMotion);
		//moveTimer.start();
		
		
	}
	public function checkGC(e:Event){
		trace("ball2 still exists at " + this.date.getTime());
		trace("" + this.name);
	}
	public function screamlikeabitch(e:Event){
		trace(mainRef.ball2Counter + " WAAAAA");
	}
	
	public function toggleDebug(e:KeyboardEvent){
		if(e.keyCode==65){
			trace("yohello");
			this.removeEventListener(Event.ENTER_FRAME, ballMotion2);
			this.x=100;
			this.y=250;
			
		}
	}
	
	public function expMotion(e:TimerEvent){
		e.updateAfterEvent();
	}
	
	public function resetHits(event:TimerEvent){
		topHit2=0;
		bottomHit2=0;
		rightWallHit2=0;
		leftWallHit2=0;
	}
	
	public function ballMotion2(event:Event){ 
	//trace("Number " + mainRef.ball2Counter + " ball2 exists!");//"for " system.gettime-creationTime " milliseconds" 
		if(myBall.doomCount==1){
			//mainRef.splitTimer.dispatchEvent(ArkPongMain TimerEvent(TimerEvent.TIMER_COMPLETE));
			splitTimer.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
			
		}
		else{
		/*
		A displayobject will be as large as it need sto be to contain its children...
		trace("this is again:" + this);
		trace("ball2 x:" + this.x);
		trace("ball2 y:" + this.y);
		trace("ball2 xSpeed:" + this.ballXSpeed);
		trace("ball2 ySpeed:" + this.ballYSpeed);
		trace("stage width " + stage.stageWidth);
		trace("stage height " + stage.stageHeight);
		trace("ball2 width " + this.width);
		trace("ball2 height " + this.height);
		trace("mywidth " + this.width);
		trace("myheight " + this.height);
		trace("ball2 scale x:" + this.scaleX);
		trace("ball2 scale y:" + this.scaleY);
		*/
		this.x=this.x;
		this.y=this.y;
		this.x +=1.51 * ballXSpeed;
		this.y +=1.51 * ballYSpeed;
		
		
		if(this.hitTestObject(myPaddle)){
			control2=1;
			
		}
		
		//collision with evil paddle
		if(this.hitTestObject(evilPaddle)){
			control2=2;
			
		}
		
		//Bouncing the ball off of the walls
		if(this.x>=stage.stageWidth-this.width){
			//if the ball hits the right side
			//of the screen, then bounce off
			ballXSpeed *=-1;
			rightWallHit2 +=1;
			leftWallHit2=0;
			topHit2=0;
			bottomHit2=0;
			stuckTimer.reset();
			stuckTimer.start();
			if(rightWallHit2>3){
				stuckHandler4();
			}
		}
		if(this.x<=0){
			//if the ball hits the left side
			//of the screen, then bounce off
			ballXSpeed *=-1;
			leftWallHit2 +=1;
			rightWallHit2=0;
			topHit2=0;
			bottomHit2=0;
			stuckTimer.reset();
			stuckTimer.start();
			if(leftWallHit2>3){
				stuckHandler4();
			}
		}
		if(this.y>=stage.stageHeight-this.height){
			trace("this is at bottomhit:" + this);
			//if the ball hits the bottom
			//then bounce up
			
			ballYSpeed *=-1;
			bottomHit2 +=1;
			topHit2=0;
			if(noHurt==0){
			    myBall.enemyScore +=1;
			    //addChild(eScore);
			    /*//TODO: uncomment when particles are back
                callParts=new CallParts((this.x +(this.width/2)),450);
                myBall.addChild(callParts);
                */
                myBall.eScore.text="ENEMY SCORE:" + myBall.enemyScore;
				if(myBall.enemyScore>=10){
                    myBall.enemyWin();
					
				}
			}
			stuckTimer.reset();
			stuckTimer.start();
			if(bottomHit2>3){
				stuckHandler6();
			}
			noHurtTimer.start();
			noHurt=1;
		}
		if(this.y<=50){
			trace("this is at tophit:" + this);
			//if the ball hits the top
			//then bounce down
			
			ballYSpeed *=-1;
			topHit2 +=1;
			bottomHit2=0;
			//addChild(score);
			if(noHurt==0){
                myBall.playerScore +=1;
			    /*//TODO: uncomment when particles are back
                callParts=new CallParts((this.x +(this.width/2)),50);
                myBall.addChild(callParts);
                */
                myBall.score.text="PLAYER SCORE:" + myBall.playerScore;
				if(myBall.playerScore>=10){
                    myBall.playerWin();
					
				}
			}
			stuckTimer.reset();
			stuckTimer.start();

			if(topHit2>3){
				stuckHandler5();
			}
			noHurtTimer.start();
			noHurt=1;
		}
		
		//collision with paddlw
		if(this.hitTestObject(myPaddle)){
			control2=1;
			calcBallAngle3();
		}
		
		//collision with evil paddle
		if(this.hitTestObject(evilPaddle)){
			control2=2;
			calcBallAngle4();
		}
		
	 }
	}
	
	public function calcBallAngle3(){
		//ballPosition is the position of the ball is on the paddle
		var ballPosition:Float=this.x - myPaddle.x;
		//hitPercent converts ballPosition Into a percent
		//All the way to the left is -.5
		//All the way to the right is .5
		//The center is 0
		var hitPercent:Float=(ballPosition /(myPaddle.width - this.width))- .5;
		//Gets the hitPercent and makes it a larger number so the
		//ball actually bounces
		ballXSpeed=hitPercent * 10;
		//Making the ball bounce back up
		ballYSpeed *=-1;
		
	}
	
	public function calcBallAngle4(){
		//ballPosition is the position of the ball is on the paddle
		var ballPosition:Float=this.x - evilPaddle.x;
		//hitPercent converts ballPosition Into a percent
		//All the way to the left is -.5
		//All the way to the right is .5
		//The center is 0
		var hitPercent:Float=(ballPosition /(evilPaddle.width - this.width))- .5;
		//Gets the hitPercent and makes it a larger number so the
		//ball actually bounces
		ballXSpeed=hitPercent * 10;
		//Making the ball bounce back up
		ballYSpeed *=-1;
		
	}
	
	public function stuckHandler4(){
		trace("stuck 4!");
		if(rightWallHit2>3){
			this.x -=(this.width + 1);
			if(control2==1){
				this.y -=(Math.abs(myPaddle.y - this.y)+ 1);
			}
			if(control2==2){
				this.y +=(Math.abs(evilPaddle.y - this.y)+ 1);
			}
		}
		if(leftWallHit2>3){
			this.x +=(this.width + 1);
			if(control2==1){
				this.y -=(Math.abs(myPaddle.y - this.y)+ 1);
			}
			if(control2==2){
				this.y +=(Math.abs(evilPaddle.y - this.y)+ 1);
			}
		}
		leftWallHit2=0;
		rightWallHit2=0;
	}
	
	public function stuckHandler5(){
		trace("stuck 5!");
		this.y +=(this.height * 3);
		topHit2=0;
	}
	
	
	public function stuckHandler6(){
		trace("stuck 6!");
		this.y -=(this.height * 3);
		bottomHit2=0;
	}
	
	public function hurtAgain(event:TimerEvent){
		noHurt=0;
		noHurtTimer.reset();
		
	}
	
	public function startEndBall2(event:TimerEvent){ //I'm thinking we should migrate thus code to ball2 class, then have the ball2 class destroy itself via this.parent.removechild(this)
		splitTimer.reset();
		removeEventListener(Event.ENTER_FRAME, ballMotion2);
		deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, endBallMultiply);
		deathTimer.start();
		dying=true;
	}
	
	public function endBallMultiply(event:TimerEvent){
		//splitTimer.reset();
		//myBall2.removeEventListener(Event.ENTER_FRAME, myBall2.ballMotion2);
		trace("fuck the girls from ball2!");
		deathTimer.reset();
		deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, endBallMultiply);
		this.parent.stage.removeEventListener(KeyboardEvent.KEY_UP, toggleDebug);
		
		//ending other potential listener handles here...
		removeEventListener(Event.ENTER_FRAME, screamlikeabitch);
		noHurtTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, hurtAgain);
		stuckTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, resetHits);
		splitTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, startEndBall2);
		//removeEventListener(Event.ENTER_FRAME, checkGC)
		//this.parent.removeChild(this);
		mainRef.killTemporaryBall();
		
		//myBall2==null;
	}
	
	public function hardEndBall2(){
		trace("fuck her hard from ball2!");
		splitTimer.reset();
		
		removeEventListener(Event.ENTER_FRAME, ballMotion2);
		deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, endBallMultiply);
		deathTimer.start();
	}
	
	
	

}