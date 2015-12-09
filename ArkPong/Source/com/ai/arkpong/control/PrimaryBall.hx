package com.ai.arkpong.control;
import com.ai.arkpong.view.ArkPongMovieClip;
//import com.ai.arkpong.view.Explode;//TODO: uncomment when particles are back
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.core.DisplayObjectContainer;
import openfl.display.Stage;
import openfl.events.*;
import openfl.display.MovieClip;
import haxe.ui.toolkit.controls.Text;
import openfl.utils.Timer;
import haxe.ui.toolkit.controls.Button;



class PrimaryBall extends Ball {
	
	//These variables are needed for moving the ball
    public var ballXSpeed:Float=5.5;//X Speed of the Ball
    public var ballYSpeed:Float=5.5;//Y Speed of the Ball
    public var leftWallHit:Int=0;//monitors hits in-a-row on left wall
    public var rightWallHit:Int=0;//monitors hits in-a-row on right wall
    public var topHit:Int=0;//monitors hits in-a-row on ceiling
    public var bottomHit:Int=0;//monitors hits in-a-row on floor [probably not needed]
    public var leftWallHit2:Int=0;//monitors hits in-a-row on left wall
    public var rightWallHit2:Int=0;//monitors hits in-a-row on right wall
    public var topHit2:Int=0;//monitors hits in-a-row on ceiling
    public var bottomHit2:Int=0;//monitors hits in-a-row on floor [probably not needed]
    public var theBackground:ArkPongMovieClip = new ArkPongMovieClip();//ArkPongMain myBackground();

    /*//TODO: uncomment when particles are back
	var ex:Explode=new Explode();
    */
    public var power:Power;
    public var trackLvl:Int;
	//var splitTimer:Timer=ArkPongMain Timer(5000, 1);
	//var mainRef:ArkPongMain=ArkPongMain ArkPongMain();//causes a $%&&*(infinite loop!!
	//var h:Graphics=ArkPongMain Graphics();
	//h.
	//var rect:Shape=ArkPongMain Shape();
	public var myBall:MovieClip;
	//public var myBall2:MovieClip;
	public var myPaddle:MovieClip;
	public var evilPaddle:MovieClip;
	public var evilSight:MovieClip;
	public var countHit:Int;
	public var hitControl:Int=0;
	//var myBall2:MovieClip;
    public var playerHP:Float=100;
    public var enemyHP:Float=100;
    public var playerScore:Int=0;
    public var enemyScore:Int=0;
	public var score:Text;//the player's score label
	public var eScore:Text;//the enemy's score label
    public var control:Int=0;	//this variable will be used to track which paddle the ball just bounced off
    public var bricksDestroyed:Int=0;//incremented when a brick is in its 'death' function, currently before the brick is removed from displaylist.  should be fine. 6/2/2011
    public var factor2:Float=0.8;
	public var xLocations:Array<Dynamic>=new Array();
    public var noHurtTimer:Timer=new Timer(500,1);
    public var noHurt:Int=0;
	public var startButton:Button;
    public var theStage:Stage;
    public var doomCount:Int=0;//zero in game, 1 when someone wins, then reinitialized to zero on restart
    public var winnerLabel:Text=new Text();
    public var killAll:Int=0;
	//var callParts:CallParts;//reuse the Explode object!  Just Introduce a ArkPongMain function in Explode to govern the type of particle effect you want here IF NECESSARY
    public var stuckTimer:Timer=new Timer(250,1);
    public var rebuild:Bool=false;
    public var punchPower:Bool=false;
    public var moveTimer:Timer=new Timer(1000/30);//timer to control ball motion instead of enterFrame...
    public var levelSize:Int;//to be instant6iated/set dynamically via Bricks once a level is generated
    public var winner:Int;//set when a player wins or loses. 1=player win 2=enemy win
	////ball2.y=(factor2 * ball2.y)+((1-factor2)* position2);
	///////var shortTimer:Timer=ArkPongMain Timer(500, 1);
	//var brickRed:MovieClip;
	
	public function new(paddle:MovieClip,ball:MovieClip,ePaddle:MovieClip,startB:Button,stageRef:Stage,eSight:MovieClip){
        super();

        theBackground.loadImage("assets/wood_wavy_BG.jpg");

        score=new Text();
		//addChild(score);
		eScore=new Text();
		//addChild(eScore);
		this.myBall=ball;
		//this.myBall2=ball2;
		this.myPaddle=paddle;
		this.evilPaddle=ePaddle;
		this.startButton=startB;
		this.theStage=stageRef;
		this.evilSight=eSight;
		//myBall2=ArkPongMain Ball(myPaddle,myBall,evilPaddle,startButton,theStage,evilSight);
		//this.mainRef=main;
		//this.xLocations=xL;
		countHit=0;
		myBall.addEventListener(Event.ENTER_FRAME, ballMotion);
		noHurtTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hurtAgain);
		stuckTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetHits);
		//splitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, endMultiply);
		score.x=0;
		score.y=30;
		score.width=200;
		score.text="PLAYER SCORE:" + playerScore;
		eScore.x=275.85;
		eScore.y=30;
		eScore.width=200;
		eScore.text="ENEMY SCORE:" + enemyScore;
		addChild(score);
		addChild(eScore);
/*//TODO: uncomment when particles are back
        addChild(ex);
        */
		//moveTimer.addEventListener(TimerEvent.TIMER, expMotion);
		//moveTimer.start();
		
		//brickRed=ArkPongMain brickRed(this.myPaddle,this.myBall);
		//addChild(brickRed);
		tempLvlSizeSet();
		
	}
	
	public function tempLvlSizeSet(){
		//this is a temporary hard-coded setting of levelSize prior to genLevel method completion
		levelSize=30;
	}
	
	public function expMotion(e:TimerEvent){
		/*
		trace("Ball driver width:" + this.width);//should be okay....
		trace("Ball driver height:" + this.height);
		*/
		myBall.x +=5.01 * ballXSpeed;
		myBall.y +=5.01 * ballYSpeed;
		////myBall.x +=(factor2 * ballXSpeed)//+((1-factor2)* ballXSpeed);
		////myBall.y +=(factor2 * ballYSpeed)//+((1-factor2)* ballYSpeed);
		//need to get control right before stuckhandlers encountered
		if(myBall.hitTestObject(myPaddle)){
			control=1;
			
		}
		
		//collision with evil paddle
		if(myBall.hitTestObject(evilPaddle)){
			control=2;
			
		}
		
		//Bouncing the ball off of the walls
		if(myBall.x>=stage.stageWidth-myBall.width){
			//if the ball hits the right side
			//of the screen, then bounce off
			ballXSpeed *=-1;
			rightWallHit +=1;
			leftWallHit=0;
			topHit=0;
			bottomHit=0;
			stuckTimer.reset();
			stuckTimer.start();
			if(rightWallHit>3){
				stuckHandler();
			}
		}
		if(myBall.x<=0){
			//if the ball hits the left side
			//of the screen, then bounce off
			ballXSpeed *=-1;
			leftWallHit +=1;
			rightWallHit=0;
			topHit=0;
			bottomHit=0;
			stuckTimer.reset();
			stuckTimer.start();
			if(leftWallHit>3){
				stuckHandler();
			}
		}
		if(myBall.y>=stage.stageHeight-myBall.height){
			//if the ball hits the bottom
			//then bounce up
			
			////theBackground.
			
			if(punchPower){
				punchPower=false;
			}
			
			ballYSpeed *=-1;
			bottomHit +=1;
			topHit=0;
			if(noHurt==0){
			enemyScore +=1;
			//addChild(eScore);
			//callParts=ArkPongMain CallParts((myBall.x +(myBall.width/2)),450);
/*//TODO: uncomment when particles are back
                ex.showExplosion(myBall.x,myBall.y,3);
                */
			
			//addChild(callParts);
			eScore.text="ENEMY SCORE:" + enemyScore;
				if(enemyScore>=10){
					enemyWin();
					/*
					winnerLabel.x=240;
					winnerLabel.y=100;
					winnerLabel.width=150;
					winnerLabel.text="Computer Wins!";
					addChild(winnerLabel);
					myBall.x=275;
					evilPaddle.x=275;
					evilSight.x=evilPaddle.x +(evilPaddle.width/2);
					evilSight.rotation=0;
					myBall.y=272;
					ballXSpeed=0;
					ballYSpeed=0;
					control=0;
					////killAll=1;
					doomCount=1;
					//trace("" + theStage.numChildren);
					//trace("" + theStage.getChildAt(0));
					//////reset();
					//startButton.visible=true;
					*/
				}
			}
			stuckTimer.reset();
			stuckTimer.start();
			if(bottomHit>3){
				stuckHandler3();
			}
			noHurtTimer.start();
			noHurt=1;
		}
		if(myBall.y<=50){
			//if the ball hits the top
			//then bounce down
			
			if(punchPower){
				punchPower=false;
			}
			
			ballYSpeed *=-1;
			topHit +=1;
			bottomHit=0;
			//addChild(score);
			if(noHurt==0){
			playerScore +=1;
			//callParts=ArkPongMain CallParts((myBall.x +(myBall.width/2)),50);
			//addChild(callParts);
/*//TODO: uncomment when particles are back
			ex.showExplosion(myBall.x,myBall.y,2);
                */
			
			score.text="PLAYER SCORE:" + playerScore;
				if(playerScore>=10){
					playerWin();
					/*
					winnerLabel.x=240;
					winnerLabel.y=100;
					winnerLabel.width=150;
					winnerLabel.text="You Win!";
					addChild(winnerLabel);
					myBall.x=275;
					evilPaddle.x=275;
					evilSight.x=evilPaddle.x +(evilPaddle.width/2);
					evilSight.rotation=0;
					//myBall.y=172;//this might be the cause of a level overlay-- ball might be touching top level of bricks if it hasnt been destroyed and when you hit start button to reset it gets screwed up 2/13/2011
					myBall.y=72;//try this height instead.  Still, should try to place a control in to avoid that lingering reference stopping gc of old bricks. 2/13/2011
					ballXSpeed=0;
					ballYSpeed=0;
					control=2;
					////killAll=1;//one isolated circumstance where thigns go wrong--when someone wins and there are no bricks on stage, no bricks are added when you press start again
					doomCount=1;
					//trace("" + theStage.numChildren);
					//////reset();
					//startButton.visible=true;
					*/
				}
			}
			stuckTimer.reset();
			stuckTimer.start();
			if(topHit>3){
				stuckHandler2();
			}
			noHurtTimer.start();
			noHurt=1;
		}
		
		//collision with paddlw
		if(myBall.hitTestObject(myPaddle)){
			control=1;
			calcBallAngle();
		}
		
		//collision with evil paddle
		if(myBall.hitTestObject(evilPaddle)){
			control=2;
			calcBallAngle2();
		}
		
		//collision with a brick
		//if(this.parent.contains(brickRed)){
			//if(myBall.hitTestObject(brickRed)){
			
				//brickHitHandler();
			//}
		//}
		
		e.updateAfterEvent();
	}
	
	public function resetHits(event:TimerEvent){
		topHit=0;
		bottomHit=0;
		rightWallHit=0;
		leftWallHit=0;
	}
	
	public function ballMotion(event:Event){
		
		/*
		trace("Ball driver width:" + this.width);//should be okay....
		trace("Ball driver height:" + this.height);
		*/
		myBall.x +=1.51 * ballXSpeed;
		myBall.y +=1.51 * ballYSpeed;
		////myBall.x +=(factor2 * ballXSpeed)//+((1-factor2)* ballXSpeed);
		////myBall.y +=(factor2 * ballYSpeed)//+((1-factor2)* ballYSpeed);
		//need to get control right before stuckhandlers encountered
		if(myBall.hitTestObject(myPaddle)){
			control=1;
			
		}
		
		//collision with evil paddle
		if(myBall.hitTestObject(evilPaddle)){
			control=2;
			
		}
		
		//Bouncing the ball off of the walls
		if(myBall.x>=stage.stageWidth-myBall.width){
			//if the ball hits the right side
			//of the screen, then bounce off
			ballXSpeed *=-1;
			rightWallHit +=1;
			leftWallHit=0;
			topHit=0;
			bottomHit=0;
			stuckTimer.reset();
			stuckTimer.start();
			if(rightWallHit>3){
				stuckHandler();
			}
		}
		if(myBall.x<=0){
			//if the ball hits the left side
			//of the screen, then bounce off
			ballXSpeed *=-1;
			leftWallHit +=1;
			rightWallHit=0;
			topHit=0;
			bottomHit=0;
			stuckTimer.reset();
			stuckTimer.start();
			if(leftWallHit>3){
				stuckHandler();
			}
		}
		if(myBall.y>=stage.stageHeight-myBall.height){
			//if the ball hits the bottom
			//then bounce up
			
			////theBackground.
			
			if(punchPower){
				punchPower=false;
			}
			
			ballYSpeed *=-1;
			bottomHit +=1;
			topHit=0;
			if(noHurt==0){
			enemyScore +=1;
			//addChild(eScore);
			//callParts=ArkPongMain CallParts((myBall.x +(myBall.width/2)),450);
			//addChild(callParts);
/*//TODO: uncomment when particles are back
			ex.showExplosion(myBall.x,myBall.y,3);
                */
			
			eScore.text="ENEMY SCORE:" + enemyScore;
				if(enemyScore>=10){
					enemyWin();
					/*
					winnerLabel.x=240;
					winnerLabel.y=100;
					winnerLabel.width=150;
					winnerLabel.text="Computer Wins!";
					addChild(winnerLabel);
					myBall.x=275;
					evilPaddle.x=275;
					evilSight.x=evilPaddle.x +(evilPaddle.width/2);
					evilSight.rotation=0;
					myBall.y=272;
					ballXSpeed=0;
					ballYSpeed=0;
					control=0;
					////killAll=1;
					doomCount=1;
					//trace("" + theStage.numChildren);
					//trace("" + theStage.getChildAt(0));
					//////reset();
					//startButton.visible=true;
					*/
				}
			}
			stuckTimer.reset();
			stuckTimer.start();
			if(bottomHit>3){
				stuckHandler3();
			}
			noHurtTimer.start();
			noHurt=1;
		}
		if(myBall.y<=50){   //CONDITION SHOULD BE  myBall.y<=50 FOR RELEASE
			//if the ball hits the top
			//then bounce down
			
			if(punchPower){
				punchPower=false;
			}
			
			ballYSpeed *=-1;
			topHit +=1;
			bottomHit=0;
			//addChild(score);
			if(noHurt==0){
			playerScore +=1;
			//callParts=ArkPongMain CallParts((myBall.x +(myBall.width/2)),50);//CONDITION SHOULD BE  myBall.y<=50 FOR RELEASE
			//addChild(callParts);
/*//TODO: uncomment when particles are back
			ex.showExplosion(myBall.x,myBall.y,2);
                */
			
			score.text="PLAYER SCORE:" + playerScore;
				if(playerScore>=10){
					playerWin();
					/*
					winnerLabel.x=240;
					winnerLabel.y=100;
					winnerLabel.width=150;
					winnerLabel.text="You Win!";
					addChild(winnerLabel);
					myBall.x=275;
					evilPaddle.x=275;
					evilSight.x=evilPaddle.x +(evilPaddle.width/2);
					evilSight.rotation=0;
					//myBall.y=172;//this might be the cause of a level overlay-- ball might be touching top level of bricks if it hasnt been destroyed and when you hit start button to reset it gets screwed up 2/13/2011
					myBall.y=72;//try this height instead.  Still, should try to place a control in to avoid that lingering reference stopping gc of old bricks. 2/13/2011
					ballXSpeed=0;
					ballYSpeed=0;
					control=2;
					////killAll=1;//one isolated circumstance where thigns go wrong--when someone wins and there are no bricks on stage, no bricks are added when you press start again
					doomCount=1;
					//trace("" + theStage.numChildren);
					//////reset();
					//startButton.visible=true;
					*/
				}
			}
			stuckTimer.reset();
			stuckTimer.start();
			if(topHit>3){
				stuckHandler2();
			}
			noHurtTimer.start();
			noHurt=1;
		}
		
		//collision with paddlw
		if(myBall.hitTestObject(myPaddle)){
			control=1;
			calcBallAngle();
		}
		
		//collision with evil paddle
		if(myBall.hitTestObject(evilPaddle)){
			control=2;
			calcBallAngle2();
		}
		
		//collision with a brick
		//if(this.parent.contains(brickRed)){
			//if(myBall.hitTestObject(brickRed)){
			
				//brickHitHandler();
			//}
		//}
		
	}
	
	
	
	public function enemyWin(){
					winner=2;
					winnerLabel.x=240;
					winnerLabel.y=100;
					winnerLabel.width=150;
					winnerLabel.text="Computer Wins!";
                    var dispContainer:DisplayObjectContainer = new haxe.ui.toolkit.core.DisplayObjectContainer();
					dispContainer.addChild(winnerLabel);
                    /*
                    So that seems to work for the addChild()'ing of haxe.ui display objects.
                    That means we have two choices --
                    1. Tie ourselves to haxe.ui display system
                    2. Try to have our own display components implement haxe.ui's IDisplayObject
                     */
                    addChild(winnerLabel);
					myBall.x=275;
					evilPaddle.x=275;
					evilSight.x=evilPaddle.x +(evilPaddle.width/2);
					evilSight.rotation=0;
					myBall.y=272;
					ballXSpeed=0;
					ballYSpeed=0;
					control=0;
					////killAll=1;
					doomCount=1;
	}
	public function playerWin(){
					winner=1;
					winnerLabel.x=240;
					winnerLabel.y=100;
					winnerLabel.width=150;
					winnerLabel.text="You Win!";
					addChild(winnerLabel);//TODO: getting a compile error here that actually looks real -- I think haxeui components, as haxe.ui.toolkit.core.DisplayObject instances, need to be addChild()'d to a haxe.ui.toolkit.core.DisplayObjectContainer rather than any of the OpenFL flash-y display object containers like OpenFL movieclip
					myBall.x=275;
					evilPaddle.x=275;
					evilSight.x=evilPaddle.x +(evilPaddle.width/2);
					evilSight.rotation=0;
					//myBall.y=172;//this might be the cause of a level overlay-- ball might be touching top level of bricks if it hasnt been destroyed and when you hit start button to reset it gets screwed up 2/13/2011
					myBall.y=72;//try this height instead.  Still, should try to place a control in to avoid that lingering reference stopping gc of old bricks. 2/13/2011
					ballXSpeed=0;
					ballYSpeed=0;
					control=2;
					////killAll=1;//one isolated circumstance where thigns go wrong--when someone wins and there are no bricks on stage, no bricks are added when you press start again
					doomCount=1;
	}
	
	public function calcBallAngle(){
		//ballPosition is the position of the ball is on the paddle
		var ballPosition:Float=myBall.x - myPaddle.x;
		//hitPercent converts ballPosition Into a percent
		//All the way to the left is -.5
		//All the way to the right is .5
		//The center is 0
		var hitPercent:Float=(ballPosition /(myPaddle.width - myBall.width))- .5;
		//Gets the hitPercent and makes it a larger number so the
		//ball actually bounces
		ballXSpeed=hitPercent * 10;
		//ballXSpeed=ballXSpeed +(hitPercent + 1.0);
		//Making the ball bounce back up
		ballYSpeed *=-1;
		
	}
	
	public function calcBallAngle2(){
		//ballPosition is the position of the ball is on the paddle
		var ballPosition:Float=myBall.x - evilPaddle.x;
		//hitPercent converts ballPosition Into a percent
		//All the way to the left is -.5
		//All the way to the right is .5
		//The center is 0
		var hitPercent:Float=(ballPosition /(evilPaddle.width - myBall.width))- .5;
		//Gets the hitPercent and makes it a larger number so the
		//ball actually bounces
		ballXSpeed=hitPercent * 10;
		//ballXSpeed=ballXSpeed +(hitPercent + 1.0);
		//Making the ball bounce back up
		ballYSpeed *=-1;
		
	}
	
	
	
	
	public function stuckHandler(){
		if(rightWallHit>3){
			myBall.x -=(myBall.width + 1);
			if(control==1){
				myBall.y -=(Math.abs(myPaddle.y - myBall.y)+ 1);
			}
			if(control==2){
				myBall.y +=(Math.abs(evilPaddle.y - myBall.y)+ 1);
			}
		}
		if(leftWallHit>3){
			myBall.x +=(myBall.width + 1);
			if(control==1){
				myBall.y -=(Math.abs(myPaddle.y - myBall.y)+ 1);
			}
			if(control==2){
				myBall.y +=(Math.abs(evilPaddle.y - myBall.y)+ 1);
			}
		}
		leftWallHit=0;
		rightWallHit=0;
	}
	
	public function stuckHandler2(){
		myBall.y +=(myBall.height * 3);
		topHit=0;
	}
	
	
	public function stuckHandler3(){
		myBall.y -=(myBall.height * 3);
		bottomHit=0;
	}
	
	
	//public function brickHitHandler(){
		//ballYSpeed *=-1;
	//}
	
	public function hurtAgain(event:TimerEvent){
		noHurt=0;
		noHurtTimer.reset();
		
	}
	/*
	public function multiply(){
		myBall2=ArkPongMain Ball(this.myPaddle,this.myBall,this.evilPaddle,this.startButton,this.theStage,this.evilSight);
		myBall2.x=myBall.x +(myBall.width + 5);
		myBall2.y=myBall.y;
		addChild(myBall2);
		myBall2.addEventListener(Event.ENTER_FRAME, ballMotion2);
		
		
	}
	
	public function endMultiply(event:TimerEvent){
		myBall2.removeEventListener(Event.ENTER_FRAME, ballMotion2);
		removeChild(myBall2);
	}
	*/
	//The reset function will reset all properties to their initial values/values appropriate for ending a game and standing by for a ArkPongMain one
	/*
	public function reset(){
		//problem here might be that the stage itself has no children-- the classes that have addChild()are the parents...
		for(i in 0...theStage.numChildren){
			if(theStage.getChildAt(i+1)!=null){
				theStage.removeChildAt(i);
			}
			if(theStage.getChildAt(i+1)==null){
				theStage.removeChildAt(i);
				Mouse.show();
				startButton.visible=true;
				break;
			}
		}
	*/
	/*
		//These variables are needed for moving the ball
	ballXSpeed=0;//X Speed of the Ball
	ballYSpeed=0;//Y Speed of the Ball
	leftWallHit=0;//monitors hits in-a-row on left wall
	rightWallHit=0;//monitors hits in-a-row on right wall
	topHit=0;//monitors hits in-a-row on ceiling
	bottomHit=0;//monitors hits in-a-row on floor [probably not needed]
	//theBackground:MovieClip=ArkPongMain myBackground();
	//var h:Graphics=ArkPongMain Graphics();
	//h.
	//var rect:Shape=ArkPongMain Shape();
	//public var myBall:MovieClip;
	//public var myPaddle:MovieClip;
	//public var evilPaddle:MovieClip;
	countHit=0;
	playerHP=100;
	enemyHP=100;
	playerScore=0;
	enemyScore=0;
	//public var score:Label;
	//public var eScore:Label;
	control=0;	//this variable will be used to track which paddle the ball just bounced off
	bricksDestroyed=0;
	factor2=0.8;
	//public var xLocations:Array<Dynamic>=ArkPongMain Array();
	//noHurtTimer:Timer=ArkPongMain Timer(500,1);
	noHurt=0;
	*/
	//}
	
}