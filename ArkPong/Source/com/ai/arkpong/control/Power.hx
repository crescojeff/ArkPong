package com.ai.arkpong.control;
import haxe.ui.toolkit.controls.Button;
import openfl.display.*;
import openfl.events.*;
import openfl.display.Bitmap;
import openfl.utils.Timer;
import openfl.net.URLRequest;
import openfl.geom.Matrix;

class Power extends MovieClip {
	public var myBall:MovieClip;
	public var myPaddle:MovieClip;
	public var ball:PrimaryBall;
	public var evilPaddle:MovieClip;
	public var evilSight:MovieClip;
	public var startButton:Button;
	var xCoord:Float;
	var yCoord:Float;
	var lvlCode:Array<Dynamic>;
	var bricksHandle:Bricks;
	var controlAtHit:Int;
	var theImage:String;
	var theBitmap:Bitmap;
	private var url:String;
	private var loader:Loader=new Loader();
	var appeared:Bool=false;
	var myPower:MovieClip;
	var stageRef:Stage;
	var mainRef:ArkPongMain;
	var randomNum:Float;
	
	public function powerUp(paddle:MovieClip,ball:MovieClip,theBall:PrimaryBall,ePaddle:MovieClip,startB:Button,myX:Float,myY:Float,level:Array,bricksH:Bricks,stageR:Stage,mainR:ArkPongMain){
		this.myBall=ball;
		this.myPaddle=paddle;
		this.ball=theBall;
		this.evilPaddle=ePaddle;
		//this.evilSight=eSight;
		this.startButton=startB;
		this.lvlCode=level;
		this.bricksHandle=bricksH;
		this.stageRef=stageR;
		this.mainRef=mainR;
		xCoord=myX;
		yCoord=myY;
		this.x=xCoord;
		this.y=yCoord;
		trace("yCoord:" + yCoord);
		//trace("stageRef.height" + stageRef.height);
		
		this.addEventListener(Event.ENTER_FRAME, drop);
		this.addEventListener(Event.ENTER_FRAME, effect);
		//loadImage();
		conjurePower();
        //TODO: need to manually load image for myPower MC
	}
	public function drop(event:Event){
		//trace("falling power");//this goes on for a while... may wish to look Into it
		if(mainRef.isReset){
			mainRef.isReset=false;
			for(i in 0...this.numChildren){
					if(this.getChildAt(i)!=null){
						this.removeChildAt(i);
						mainRef.myPowerCount--;
					}
				}
			this.removeEventListener(Event.ENTER_FRAME, drop);
			this.removeEventListener(Event.ENTER_FRAME, effect);
			this.parent.removeChild(this);
			appeared=false;
		}
	if(!mainRef.isPaused){
	  if(appeared){
		if(controlAtHit==0){//no idea who was in control, award power with coin flip
			if(Math.random()<0.5){
				controlAtHit=1;
			}
			if(Math.random()>=0.5){
				controlAtHit=2;
			}
		}
		if(controlAtHit==1){
			myPower.y +=5;
			//trace("mypower.y " + myPower.y);
		}
		if(controlAtHit==2){
			myPower.y -=5;
		}
	  }
	}
	}
	public function conjurePower(){
		//mainRef needs to get some control variable passed in that increments whenever a myPower appears onscreen
		//this will control the removal of any myPowers onscreen when reset is clicked in the menu. 
		controlAtHit=ball.control;
		randomNum=Math.random();

        myPower = new MovieClip();
		if(randomNum<.15){
		//if(randomNum<.25){
			//myPower=ArkPongMain powerFire();
			mainRef.power="fire";
			myPower.x=27.5;
			myPower.y=0;
			addChild(myPower);
			mainRef.myPowerCount++;
		}
		
		if(randomNum>=.15 && randomNum<.3){
			//myPower=ArkPongMain powerFreeze();
			mainRef.power="freeze";
			myPower.x=27.5;
			myPower.y=0;
			addChild(myPower)
			mainRef.myPowerCount++;
		}
		if(randomNum>=.3 && randomNum<.45){
		
		//if(randomNum>=.75){
			//myPower=ArkPongMain powerNinja();
			mainRef.power="ninja";
			myPower.x=27.5;
			myPower.y=0;
			addChild(myPower);
			mainRef.myPowerCount++;
		}
		
		//}
		if(randomNum>=.45 && randomNum<.6){
		
			//myPower=ArkPongMain powerSplit();
			mainRef.power="split";
			myPower.x=27.5;
			myPower.y=0;
			addChild(myPower);
			mainRef.myPowerCount++;
		
		}
		
		if(randomNum>=.6 && randomNum<.75){
		
			//myPower=ArkPongMain powerPunch();
			mainRef.power="punch";
			myPower.x=27.5;
			myPower.y=0;
			addChild(myPower);
			mainRef.myPowerCount++;
		
		
		}
		if(randomNum>=.75){
			//myPower=ArkPongMain powerGold();
			mainRef.power="gold";
			myPower.x=27.5;
			myPower.y=0;
			addChild(myPower);
			mainRef.myPowerCount++;
		}
		
		appeared=true;
		
	}
	public function loadImage(){//will need paramter indicating the random number chosen by brickPower before it died
		//number of conditional cases and breakdown of random number ranges will depend on how many powerups there are
		//sets value of theImage property to randomly chosen powerup icon
		//6 atm;
		//fireball is a straight shot completely separate from the ball
		//ice stops the enemy(or you if used by the enemy)from moving for a second or two.
		//ninja stars fires a row of ninja stars at the bricks.  They will destroy non-obstacle bricks, but they cannot score a hit for you agaisnt the opponent
		//rocket punch makes ball go through bricks for a few seconds if the user has cotnrol
		//gold adds directly to total score
		//split adds a ArkPongMain ball to the screen which will last for a few seconds and have all the properties of the original ball before disappearing
		controlAtHit=ball.control;
		var randomNum:Float=Math.random();
		if(randomNum<.15){
			url="powerFire.png"
		}
		if(randomNum>=.15 && randomNum<.3){
			url="powerFreeze.png"
		}
		if(randomNum>=.3 && randomNum<.45){
			url="powerNinja.png"
		}
		if(randomNum>=.45 && randomNum<.6){
			url="powerSplit.png"
		}
		if(randomNum>=.6 && randomNum<.75){
			url="powerPunch.png"
		}
		if(randomNum>=.75){
			url="powerGold.png"
		}
		
		var request:URLRequest=new URLRequest(url);
		
		loader.load(request);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, drawImage);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	
	}
	
	public function drawImage(event:Event){
		var mySprite:Sprite=new Sprite();
		var myBitmap:BitmapData=new BitmapData(loader.width, loader.height, false);
  
		myBitmap.draw(loader);//, ArkPongMain Matrix());
		
		//var matrix:Matrix=ArkPongMain Matrix();
	   // matrix.rotate(Math.PI/4);
		
		mySprite.graphics.beginBitmapFill(myBitmap, null, false);
		mySprite.graphics.drawRect(0, 0, 25, 25);
		mySprite.graphics.endFill();
		
		addChild(mySprite);
	}
	private function ioErrorHandler(event:IOErrorEvent):Void {
		trace("Unable to load image:" + url);
	}
	public function effect(event:Event){
		var i:Int;
		//this function will see what the theImage property was set to, and define an effect based on it that will
		//occur when the powerUp symbol hits either myPaddle or evilPaddle.
		//trace("powerY" + myPower.y);
		if(mainRef.isReset){
			mainRef.isReset=false;
			for(i in 0...this.numChildren){
					if(this.getChildAt(i)!=null){
						this.removeChildAt(i);
						mainRef.myPowerCount--;
					}
				}
			this.removeEventListener(Event.ENTER_FRAME, drop);
			this.removeEventListener(Event.ENTER_FRAME, effect);
			this.parent.removeChild(this);
			appeared=false;
			
		}
		if(!mainRef.isPaused){
		if(appeared){
		if(myPower.hitTestObject(myPaddle)|| myPower.hitTestObject(evilPaddle)|| myPower.y>=((450 - yCoord)+ 35)|| myPower.y<=((-400 + yCoord)- 35)){
			if(myPower.hitTestObject(myPaddle)){
				//showing the 'you got a power!' sparks on myPaddle
				/*this is a terrible bloody implementation -- if we still desire this stupid effect, do it more efficiently!!
				ball.ex=ArkPongMain Explode(myPaddle.x,437,1);
				mainRef.addChildAt(ball.ex,1);
				ball.ex.showPowerUp();
				ball.ex=ArkPongMain Explode(myPaddle.x + 27.5,437,1);
				mainRef.addChildAt(ball.ex,1);
				ball.ex.showPowerUp();
				ball.ex=ArkPongMain Explode(myPaddle.x + 55,437,1);
				mainRef.addChildAt(ball.ex,1);
				ball.ex.showPowerUp();
				*/
				
				//light up the relevant power under player Powers
				//provided mainRef.playerPowerCount is<=2.
			if(mainRef.playerPowerCount<2 && mainRef.power !="gold"){
				//mainRef.playerPowerCount++;
				trace("alpha:" + mainRef.get_abilityFire_Player().alpha);
				trace("pPC:" + mainRef.playerPowerCount);
				if(mainRef.power=="fire" && mainRef.get_abilityFire_Player().alpha<1){
					mainRef.get_abilityFire_Player().alpha=1;
					mainRef.playerPowerCount++;
					trace("pPC:" + mainRef.playerPowerCount);
				}
				if(mainRef.power=="freeze" && mainRef.get_abilityFreeze_Player().alpha<1){
					mainRef.get_abilityFreeze_Player().alpha=1;
					mainRef.playerPowerCount++;
					trace("pPC:" + mainRef.playerPowerCount);
				}
				if(mainRef.power=="ninja" && mainRef.get_abilityNinjaStar_Player().alpha<1){
					mainRef.get_abilityNinjaStar_Player().alpha=1;
					mainRef.playerPowerCount++;
					trace("pPC:" + mainRef.playerPowerCount);
				}
				if(mainRef.power=="punch" && mainRef.get_abilityPunchThrough_Player().alpha<1){
					mainRef.get_abilityPunchThrough_Player().alpha=1;
					mainRef.playerPowerCount++;
					trace("pPC:" + mainRef.playerPowerCount);
				}
				if(mainRef.power=="split" && mainRef.get_abilitySplit_Player().alpha<1){
					mainRef.get_abilitySplit_Player().alpha=1;
					mainRef.playerPowerCount++;
					trace("pPC:" + mainRef.playerPowerCount);
				}
			}
				if(mainRef.power=="gold"){
					//no HUD graphic for gold, but immediate effect
					ball.playerScore++;
					ball.score.text="PLAYER SCORE:" + ball.playerScore;
					if(ball.playerScore>=10){
						ball.playerWin();
					}
					mainRef.power="";
				}
				
				//removing the myPower graphic
				for(i in 0...this.numChildren){
					if(this.getChildAt(i)!=null){
						this.removeChildAt(i);
						mainRef.myPowerCount--;
					}
				}
				//this.parent.removeChild(this);
			}
			
			if(myPower.hitTestObject(evilPaddle)){
				//showing the 'enemy got a power!' sparks on evilPaddle
				
				/*see above
				ball.ex=ArkPongMain Explode(evilPaddle.x,57,1);
				mainRef.addChildAt(ball.ex,1);
				ball.ex.showPowerUp();
				ball.ex=ArkPongMain Explode(evilPaddle.x + 27.5,57,1);
				mainRef.addChildAt(ball.ex,1);
				ball.ex.showPowerUp();
				ball.ex=ArkPongMain Explode(evilPaddle.x + 55,57,1);
				mainRef.addChildAt(ball.ex,1);
				ball.ex.showPowerUp();
				*/
				
				//light up the relevant power under enemy Powers
				//provided mainRef.enemyPowerCount is<=2.
			if(mainRef.enemyPowerCount<2 && mainRef.power !="gold"){
				//mainRef.playerPowerCount++;
				trace("alpha:" + mainRef.get_abilityFire_Enemy().alpha);
				trace("pPC:" + mainRef.enemyPowerCount);
				if(mainRef.power=="fire" && mainRef.get_abilityFire_Enemy().alpha<1){
					mainRef.get_abilityFire_Enemy().alpha=1;
					mainRef.enemyPowerCount++;
					trace("pPC:" + mainRef.enemyPowerCount);
				}
				if(mainRef.power=="freeze" && mainRef.get_abilityFreeze_Enemy().alpha<1){
					mainRef.get_abilityFreeze_Enemy().alpha=1;
					mainRef.enemyPowerCount++;
					trace("pPC:" + mainRef.enemyPowerCount);
				}
				if(mainRef.power=="ninja" && mainRef.get_abilityNinjaStar_Enemy().alpha<1){
					mainRef.get_abilityNinjaStar_Enemy().alpha=1;
					mainRef.enemyPowerCount++;
					trace("pPC:" + mainRef.enemyPowerCount);
				}
				if(mainRef.power=="punch" && mainRef.get_abilityPunchThrough_Enemy().alpha<1){
					mainRef.get_abilityPunchThrough_Enemy().alpha=1;
					mainRef.enemyPowerCount++;
					trace("pPC:" + mainRef.enemyPowerCount);
				}
				if(mainRef.power=="split" && mainRef.get_abilitySplit_Enemy().alpha<1){
					mainRef.get_abilitySplit_Enemy().alpha=1;
					mainRef.enemyPowerCount++;
					trace("pPC:" + mainRef.enemyPowerCount);
				}
			}
				if(mainRef.power=="gold"){
					//no HUD graphic for gold, but immediate effect
					ball.enemyScore++;
					ball.eScore.text="ENEMY SCORE:" + ball.enemyScore;
					if(ball.enemyScore>=10){
						ball.enemyWin();
					}
					mainRef.power="";
				}
				
			
				//remove the powerup graphic
				for(i in 0...this.numChildren){
					if(this.getChildAt(i)!=null){
						this.removeChildAt(i);
						mainRef.myPowerCount--;
					}
				}
				//this.parent.removeChild(this);
			}
			if(myPower.y>=((400 - yCoord)+ 35)){//(myPaddle.y + 20)){// || myPower.y<=0){
			//trace("worked");
				for(i in 0...this.numChildren){
					if(this.getChildAt(i)!=null){
						this.removeChildAt(i);
						mainRef.myPowerCount--;
					}
				}
				//this.parent.removeChild(this);
			}
			if(myPower.y<=((-400 + yCoord)- 35)){//(evilPaddle.y - 20)){// || myPower.y<=0){
			//trace("worked");
				for(i in 0...this.numChildren){
					if(this.getChildAt(i)!=null){
						this.removeChildAt(i);
						mainRef.myPowerCount--;
					}
				}
				//this.parent.removeChild(this);
			}
			this.removeEventListener(Event.ENTER_FRAME, drop);
			this.removeEventListener(Event.ENTER_FRAME, effect);
			this.parent.removeChild(this);
			appeared=false;
		}
		}
		}
	}

}