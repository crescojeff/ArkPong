﻿/*
--means a bug is resolved
$ marks the implemented resolution
ISSUE TRACKER
--2/15/2011 BUG sev10 #1:brick got hit before menu went up ->menu went up and stopped brick from dying ->reset pressed on menu ->level screwed up because brick that was hit had a handle on it.  Check this out 2/15/2011
$2/17/2011 commented out the if(!mainRef.isPaused)control in the death method of the level bricks so that they could die properly
--2/15/2011 BUG sev7 #2:brick got hit before menu went up ->menu went up and stopped brick from dying ->resume pressed on menu ->hit brick didn't die because it had a handle on it.  Bricksdestroyed never reaches full level, but when someone wins and you press start for a new game it works all right again  Check this out 2/15/2011
$2/17/2011 commented out the if(!mainRef.isPaused)control in the death method of the level bricks so that they could die properly
--2/19/2011 BUG sev7 #3:level overlay... anyone wins with no bricks left->hit 'menu' a few times to [no effect?] while start button visible and things paused->hit start for new game->seemed to play normally at first->hit 'menu' and 'resume'->level regenerated before it was gone, and resulted in overlay 
								-- also happens when not hitting 'menu' before start.
								-- also happens sometimes without ever hitting menu, before or after start...  but the menu/resume combo seems to have something to do with it possibly as it caused the bug to trigger immediately when things seemed to be working otherwise
								--?$Try checking out the controls stopping the level from regenerating while start butto visible, and how that might relate to menu stuff?
								-- This seems to be potentially primarily related to hitting 'start' to restart the game before five seconds have gone by...
 $2/22/2011 Inserted a shortTimer.stop and reset command in bricks.remakeLvl.  Problem was that levelregen clock started and if start button was pressed too soon doomCount would be zero when it fired its timeerComplete event and the levelregen would occur even though remakeLvl already had restored bricks.

--2/15/2011 Feature Request #1:What exactly puts the one-at-a-time control on the bricks? 
						  --...that and only that is what needs to be Interrupted when punchPower is true and restored when it is false...
 $3/8/2011 ball.hitControl was controlling the bricks one-at-a-time exploding.  I fixed a curly brace placement so that if(!ball.punchPower)was ONLY around the hit controlling section of code [stopped just before the ball.control paddle width changing operations]
2/15/2011 Wish #1:Would be good if evilPaddle turned blue or soemthing while frozen, then reverted back when unfrozen...
--2/20/2011 Feature Requirement #1:should put in if(event.target)..is the correct symbol in the listener usePower()for power-clicked mouse event.
 $5/11/2011 done
3/1/2011  Wish #2:A visible countdown to level regeneration might be nice...
--3/4/2011  Bug Sev10 #4:Level overlay somehow... possibly related to bricks.shorttimer/levelregen being about to fire or in the process of firing when I pressed start button to restart
				   -- most likely though it has something to do with the menu and/or the resume button.  Unknown if it has anything to do with menu calling and brick hitting simultaneously again... doesn't seem so.
 $added extra control bricksHandle.numChildren==0 to a few bricks.makeLvl calls, and ball.doomCount !=1 if bricks.timeOn was true when you hit menu->resume and someone had won [if you can even do that, which you shouldn't be able to...].  Also fixed a loophole where bricks.timeOn could be true when it shouldn't be if you hit menu and reset after all bricks were destroyed and before they regenerated [fixed by adding bricks.timeOn=false in beginAgain].
5/17/2011 Wish #3 Using CoreTween or another tweening engine to smooth the menu tween might be nice...
--5/18/2011 BUG #4 sev5:When Ball2 disappears in the area where blocks will appear a 'ghost' of it stays behind and either bricks break magically or we get the error ArgumentError:Dynamic #2025:The supplied DisplayObject must be a child of the caller.
at flash.display::DisplayObjectContainer/removeChild()
at FlashForceMain/endBallMultiply()[E:\miniTD\Flash\FlashForce\FlashForceMain.as:604]
at flash.events::EventDispatcher/dispatchEventFunction()
at flash.events::EventDispatcher/dispatchEvent()
at flash.utils::Timer/tick()... possibly related to a hittestobject handle, but it happened even with no bricks present... investigate
	learned also that bricks will continue to break on ghost(usually? once it seemed that this part never happened.  
	perhaps somethign to do with the length opf time that the bircks have been gone?)along with error message until you summon another ball2.  
	After that the bricks don't break on 'nothing' but you do get the above error everytime the bricks spawn in the spot it vanished...
$solved by adding 'death buffer' time
6/10/2011 BUG #5 sev6:Level does not remake itself if there are any blockbricks remaining when someone whens and you press start to restart.  Seems the count isn't quite getting to what selfdestruct2 wants... may happen with or without any brickblocks present or ever having been present... need to test more 
			see the output for bug 5 txt file for useful clues
12/27/2011	WISH #4:The punchPower control structure should be sensitive to who has control of the ball, such that the ball only passes through bricks when it is coming off a hit from the player's paddle 
				whho activated their punchPower(assuming the enemy is given powers evwentually).
*/




package com.ai.arkpong;

import com.ai.arkpong.view.FlyingNinja;
import com.ai.arkpong.view.PauseMenu;
import com.ai.arkpong.view.ArkPongMovieClip;
import com.ai.arkpong.view.ArkPongMovieClip;
import com.ai.arkpong.model.AIPaddle;
import com.ai.arkpong.control.TemporaryBall;
import com.ai.arkpong.model.InvisiBrick;
import com.ai.arkpong.control.Bricks;
import com.ai.arkpong.control.Bricks;
import com.ai.arkpong.model.Paddle;
import com.ai.arkpong.control.PrimaryBall;

import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.display.MovieClip;
import openfl.display.StageScaleMode;
import openfl.display.DisplayObject;

import openfl.ui.Mouse;
import openfl.display.Stage;
import openfl.net.*;
import openfl.media.*;
import haxe.ui.toolkit.controls.Button;

import openfl.utils.Timer;
import openfl.system.*;
import com.ai.arkpong.view.PauseMenu;

import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.events.UIEvent;

/*//TODO: uncomment when tweening is back
import org.coretween.easing.*;
import org.coretween.Tween;
*/


class ArkPongMain extends MovieClip{
	//public var myPaddle:MovieClip;
	public var mv_rMainBall:PrimaryBall;
	//public var evilSight:MovieClip;//causes cosntructors below to send a null value to manager objects -- probably doesn't matter since eSight was never actually used, but it should be noted in case soemthing weird happens
	//public var stageRef:Stage;
	//var ball:PrimaryBall;//TODO: why were there both myBall and ball variables?
	var mv_rPlayerPaddle:Paddle;
	var bricks:Bricks;
	//var numBricks:Array<Dynamic>;
	public var evilPaddle:MovieClip;
	public var theBackground:MovieClip;
	var ePaddle:AIPaddle;
	var startButton:Button;
	var endButton:Button;
	var startButtonClicked:Int=0;
	var myPauseButton:Button;
	var isPaused:Bool=false;
	//public var myMenu:MovieClip;
	public var myMenuUI:PauseMenu;
	public var resumePlay:Button;
	public var resetPlay:Button;
	//var theLayers:Array<Dynamic>;
	//var menuLayer:Layer;
	public var menuButton:Button;
	var isReset:Bool=false;
	var myPowerCount:Int=0;//TODO: wtf?  why are there two power count fields?
	var power:String;// power just released.  Once there are multiple powerbricks on the level, this will need to be an array or LL of strings...
	
	var fireBall:ArkPongMovieClip=new ArkPongMovieClip();//these two are projectiles that get instantiated and destroyed repeatedly
	var enemyFireBall:ArkPongMovieClip=new ArkPongMovieClip();// the enemy's fireball
	//var ninjaStars:flyingNinja;//these two are projectiles that get instantiated and destroyed repeatedly
	var starsArray:Array<Dynamic>=new Array();//this array can hold the ninjaStars objects such that they will be indexed and therefore separately addressable
	var numStars:Int=0;
	//var callParts:CallParts;//TODO: uncomment when particles are back
	var freezeTimer:Timer;
	var freezeTimer2:Timer;
	/*//TODO: uncomment when tweening is back
    var myTweenAlpha:Tween;
	var myTweenY:Tween;
    */
	/////var splitTimer:Timer=ArkPongMain Timer(5000, 1);//moved to ball2 now
	public var mv_rTempBall:TemporaryBall;
	var playerPowerCount:Int=0;//the playerPowerCount and enemyPowerCount varaibles track how many powerups the player and enemy have accumluated, respectively.
	var enemyPowerCount:Int=0;//each is allowed up to two powers at a time, but no more.
	var ball2Counter:Int=0;
	var date:Date=new Date();
	////var parts:Particles;
	//var umCount:Int=0;
	//var mainRef:ArkPongMain=ArkPongMain ArkPongMain();
	//public var xLocations:Array<Dynamic>=ArkPongMain Array();
	var invisiBrick:InvisiBrick;

    //power abilities in the UI
    @:isVar var abilityFire_Player(get, null):Button;
    @:isVar var abilityNinjaStar_Player(get, null):Button;
    @:isVar var abilityFreeze_Player(get, null):Button;
    @:isVar var abilityPunchThrough_Player(get, null):Button;
    @:isVar var abilitySplit_Player(get, null):Button;
    @:isVar var abilityFire_Enemy(get, null):Button;
    @:isVar var abilityNinjaStar_Enemy(get, null):Button;
    @:isVar var abilityFreeze_Enemy(get, null):Button;
    @:isVar var abilityPunchThrough_Enemy(get, null):Button;
    @:isVar var abilitySplit_Enemy:Button;

    public function getPlayerPowerCount():Int{
        return playerPowerCount;
    }
    public function incPlayerPowerCount():Void{
        playerPowerCount++;
    }
    public function decPlayerPowerCount():Void{
        playerPowerCount--;
    }
    public function getPlayerPower():String{
        return power;
    }
    public function get_abilityFire_Player():Button {
        return abilityFire_Player;
    }

    public function get_abilityNinjaStar_Player():Button {
        return abilityNinjaStar_Player;
    }

    public function get_abilityFreeze_Player():Button {
        return abilityFreeze_Player;
    }

    public function get_abilityPunchThrough_Player():Button {
        return abilityPunchThrough_Player;
    }

    public function get_abilitySplit_Player():Button {
        return abilitySplit_Player;
    }
    public function get_abilitySplit_Enemy():Button {
        return abilitySplit_Enemy;
    }

    public function get_abilityFire_Enemy():Button {
        return abilityFire_Enemy;
    }

    public function get_abilityNinjaStar_Enemy():Button {
        return abilityNinjaStar_Enemy;
    }

    public function get_abilityFreeze_Enemy():Button {
        return abilityFreeze_Enemy;
    }

    public function get_abilityPunchThrough_Enemy():Button {
        return abilityPunchThrough_Enemy;
    }



	public function new(){
		//trace("anything?");
		//stage.align=StageAlign.TOP_LEFT;
		stage.scaleMode=StageScaleMode.EXACT_FIT;
		//stage.stageHeight=Capabilities.screenResolutionY;
		//stage.stageWidth=Capabilities.screenResolutionX;
		//myPaddle.addEventListener(KeyboardEvent.KEY_DOWN, paddleHandler);
		//myPaddle.addEventListener(KeyboardEvent.KEY_UP, paddleHandler);
		//myPaddle.addEventListener(MouseEvent.MOUSE_OVER, paddleHandler);
		//breakTime()
		//ballHandler();
		////brickRed=ArkPongMain brickRed(this.myPaddle,this.myBall);
		////addChild(brickRed);
		//stageRef=this.stage;
		/*
		paddle=ArkPongMain Paddle(this.myPaddle,this.myBall,this.stage);
		addChild(paddle);
		ePaddle=ArkPongMain enemyPaddle(this.myPaddle,this.myBall,this.ball,this.evilPaddle);
		addChild(ePaddle);
		ball=ArkPongMain Ball(this.myPaddle,this.myBall,this.evilPaddle);
		addChild(ball);
		bricks=ArkPongMain Bricks(this.myPaddle,this.myBall,this.ball,this.evilPaddle);
		addChild(bricks);
		*/
		//playBattleSong()//the mp3 seems to be too much for the android;find a midi
		startButton=new Button();
		startButton.x=255;
		startButton.y=160;
		startButton.text="START!";
		freezeTimer=new Timer(2000, 1);
		freezeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, unfreeze);
		freezeTimer2=new Timer(2000, 1);
		freezeTimer2.addEventListener(TimerEvent.TIMER_COMPLETE, unfreeze2);
		addChild(startButton);
		startButton.addEventListener(MouseEvent.CLICK, begin);
		menuButton.addEventListener(MouseEvent.CLICK, pausePlay);
		//theBackground.addEventListener(MouseEvent.MOUSE_WHEEL, usePower);

        //TODO: instantiate and layout ability buttons etc.

		abilityFire_Player.addEventListener(MouseEvent.CLICK,usePower);
		abilityNinjaStar_Player.addEventListener(MouseEvent.CLICK,usePower);
		abilityFreeze_Player.addEventListener(MouseEvent.CLICK,usePower);
		abilityPunchThrough_Player.addEventListener(MouseEvent.CLICK,usePower);
		abilitySplit_Player.addEventListener(MouseEvent.CLICK,usePower);
		
		abilityFire_Enemy.addEventListener(MouseEvent.CLICK,usePower);
		abilityNinjaStar_Enemy.addEventListener(MouseEvent.CLICK,usePower);
		abilityFreeze_Enemy.addEventListener(MouseEvent.CLICK,usePower);
		abilityPunchThrough_Enemy.addEventListener(MouseEvent.CLICK,usePower);
		abilitySplit_Enemy.addEventListener(MouseEvent.CLICK,usePower);


		//DEBUG//this.stage.addEventListener(KeyboardEvent.KEY_DOWN, forceLevel);
		
		//addEventListener(Event.ENTER_FRAME, checkGC);
		//splitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, endBallMultiply);
		/////splitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, startEndBall2);//moved to ball2 now
		
		//this.addEventListener(Event.ENTER_FRAME, resetCheck);
		
		/////Mouse.hide();
	}
	public function getPowerFire():DisplayObject{
		return this.fireBall;
	}
	
	public function forceLevel(k:KeyboardEvent){
		if(k.keyCode==65){
			trace("hello1");
			if(bricks !=null){
				trace("hello2");
				bricks.killLevel2();
			}
		}
	}
	
	public function checkGC(e:Event){
		
		//if(this.getChildIndex(Ball2)!=null || this.getChildByName("Ball2")!=null || this.getChildByName("myBall2")!=null){
		//if(myBall2.name !=null){
			//trace("ball2 still exists at " + date.getMilliseconds());
		//}
		if(bricks !=null && mv_rMainBall !=null && ePaddle !=null){
			trace("levelSize:" + mv_rMainBall.levelSize);
			trace("bricksdestroyed:" + mv_rMainBall.bricksDestroyed);
			for(i in 0...ePaddle.intents.length){
				trace("intents:" + ePaddle.intents[i]);
			}
			/*
			for(var i:Int=0;i<ePaddle.brickLocations[0].length;i++){
				//for(var j:Int=0;j<
				trace("brickLocation X:" + ePaddle.brickLocations[0][i] + "brick location Y:" + ePaddle.brickLocations[1][i] + " brick color:" + ePaddle.brickLocations[2][i]);
				
			}
			*/
			//trace("brick children:" + bricks.numChildren);
			//trace("block bricks:" + bricks.brickBlockCount);
			//trace("level size:" + bricks.lvl1Code.length);
			//trace("bricks destroyed:" + ball.bricksDestroyed);
		}
	}
	
	
	public function beginAgain(){
		//trace("beginAgain");
		//if(this.contains(myMenuUI)){
			//this.removeChild(myMenuUI);
		//}
		//reset the power ID string
		//splitTimer.stop();
		//splitTimer.reset();
		//splitTimer.dispatchEvent(TimerEvent.TIMER_COMPLETE);
		
		bricks.timeOn=false;
		power="";
		mv_rMainBall.punchPower=false;
		bricks.frameWaiter.reset();
		if(bricks.frameWaiter.hasEventListener(TimerEvent.TIMER_COMPLETE)){
			bricks.frameWaiter.removeEventListener(TimerEvent.TIMER_COMPLETE, bricks.levelRegen2);
		}
		/*
		 * conditional here for below....
		*/
		//ball.winner=0;//reset the who won flag -- will need conditional here to ensure Bricks has received the value before setting it bacxk to 0.
		numStars=0;
		starsArray<Dynamic>=[];
		//reset the transparency of power display icons in HUD
        abilityFire_Player.alpha=.25;
        abilityNinjaStar_Player.alpha=.25;
        abilityFreeze_Player.alpha=.25;
        abilitySplit_Player.alpha=.25;
        abilityPunchThrough_Player.alpha=.25;
		playerPowerCount=0;

        abilityFire_Enemy.alpha=.25;
        abilityNinjaStar_Enemy.alpha=.25;
        abilityFreeze_Enemy.alpha=.25;
        abilitySplit_Enemy.alpha=.25;
        abilityPunchThrough_Enemy.alpha=.25;
		enemyPowerCount=0;

        mv_rMainBall.killAll=1;
        mv_rMainBall.hitControl=0;
		//ball.bricksDestroyed=0;
        mv_rMainBall.doomCount=0;//may work here...
		startButton.visible=false;
		Mouse.hide();
		///ball.playerScore=0;//old place;moved to Bricks gnuRemakeLvl
		///ball.enemyScore=0;//old place;moved to Bricks gnuRemakeLvl
		//ball.ballXSpeed=10;
		//ball.ballYSpeed=10;
        mv_rMainBall.ballXSpeed=5.5;
        mv_rMainBall.ballYSpeed=5.5;
		mv_rPlayerPaddle.width=130;
		evilPaddle.width=130;
		//evilSight.x=evilPaddle.x +(evilPaddle.width/2);
		//evilSight.width=12;
		//evilSight.height=226;
		//evilSight.rotation=0;
		///isReset=false;
		//ball.bricksDestroyed=0;///I think this being AFTER ball.doomCount=0 is responsible for the overlapping levels every now and then.
		//need a degen level method in Bricks to destroy old level-- the old level is definitely staying because paddles are inc/dec in
		//width by more than 5 after makeLvl called multiple times.  Blocks are laying over each other and multiple ones are dying at once.
		//ball.eScore.text="ENEMY SCORE:" + ball.enemyScore;//part of old way
		//ball.score.text="PLAYER SCORE:" + ball.playerScore;//part of old way
        mv_rMainBall.winnerLabel.text="";
		if(!ePaddle.hasEventListener(Event.ENTER_FRAME)){
			ePaddle.addEventListener(Event.ENTER_FRAME, ePaddle.fight);
		}
		if(mv_rTempBall !=null){ // && this.getChildByName("myBall2")!=null){
			mv_rTempBall.hardEndBall2();
		}
		//bricks.levelDegen();
		//ball.killAll=0;
		//for(i in 1...bricks.lvl1Code.length){
		/*
		if(ball.rebuild){
			trace("shoudl make level...");
			bricks.makeLvl();
			ball.rebuild=false;
			
		}
		*/
		//}
	}
	
	
	public function begin(event:MouseEvent){
		//trace("began!");
/*  		//This is the experimental Invisibrick class. Attempting to query memory impact too, but not very reliable metric...
		trace("before:" + System.totalMemory);
			invisiBrick=ArkPongMain InvisiBrick();
			trace("after1:" + System.totalMemory);
			addChild(invisiBrick);
			trace("after2:" + System.totalMemory);
*/
			
		//myPaddle.addEventListener(KeyboardEvent.KEY_DOWN, paddleHandler);
		//myPaddle.addEventListener(KeyboardEvent.KEY_UP, paddleHandler);
		//removeChild(startButton);
		if(startButtonClicked==1){
			beginAgain();
		}
		if(startButtonClicked==0){
			//trace("dont want to see this more than once");
			startButton.visible=false;
			startButtonClicked=1;
			Mouse.hide();
			
			//parts=ArkPongMain Particles();
			//addChild(parts);
			mv_rPlayerPaddle=new Paddle(this.myPaddle,this.mv_rMainBall,this.stage);
			addChild(mv_rPlayerPaddle);
			//ePaddle=ArkPongMain enemyPaddle(this.myPaddle,this.myBall,this.ball,this.evilPaddle,this.evilSight);
			//addChild(ePaddle);
            mv_rMainBall=new PrimaryBall(this.myPaddle,this.mv_rMainBall,this.evilPaddle,this.startButton,this.stage,this.evilSight);
			addChild(mv_rMainBall);
			ePaddle=new AIPaddle(this.myPaddle,this.mv_rMainBall,this.ball,this.evilPaddle,this.evilSight);
			addChild(ePaddle);
			this.addEventListener(Event.ENTER_FRAME, resetCheck);
			//ball.addEventListener(Event.ENTER_FRAME, resetCheck);
			//ninjaStars=ArkPongMain flyingNinja(this.evilPaddle,this.ball,this);
			//addChild(ninjaStars);
			bricks=new Bricks(this.ePaddle,this.myPaddle,this.mv_rMainBall,this.ball,this.evilPaddle,this.startButton,this.stage,this);
			addChild(bricks);
			//trace("bricks manager added!");
			//Now that all the driver objects exist, call the master event.ENTER_FRAME listener function here...
			////addEventListener(Event.ENTER_FRAME, masterEF);
			
			// EXPERIMENTAL CODE for alt Bricks class option 1
			//invisiBrick=ArkPongMain InvisiBrick(ePaddle,myPaddle,myBall,ball,evilPaddle,evilSight,startButton,100,100,null,bricks,this.stage,this);
			
			//invisiBrick=cast(invisiBrick, brickRed);
			//invisiBrick=ArkPongMain brickRed(ePaddle,myPaddle,myBall,ball,evilPaddle,evilSight,startButton,100,100,null,bricks,this);
			
			//addChild(invisiBrick);
			
			
		}
		
		
		
		/*
		endButton=ArkPongMain Button();
		endButton.width=50;
		endButton.height=40
		endButton.x=500;
		endButton.y=360;
		endButton.label="END";
		addChild(endButton)
		endButton.addEventListener(MouseEvent.CLICK, beginAgain);
		*/
		
	}
	
	public function masterEnterFrame(e:Event){
			//this function calls all the functions from all the drivers that would otherwise create their own
			//enter_frame listeners-- consolidating like this should improve performance
			//NB:for the bricks objects, after pooling them to make them permanent objects that simple change their
			//status on the displaylist etc. as they are 'destroyed' in-game, you should be able to call their waittodie
			//enter_frame function from here too.  Not 100% sure how to do this efficiently, as we don't want this function
			//running through all possible brick objects to check their status on every frame to know if it should call
			//their waittodie function or not and which waittodie function should be called...
			
			//seems we'd have to iterate through all IB's and check their
			//brickID and activatedState which would be disastrous on every frame
			//using auxiliary arrays to track which IB's are active and which
			//are inert would help shorten the array, but still wouldn't eliminate
			//the efficiency problem with an onEnterFrame iterator...
			
		}
	
	public function pausePlay(event:MouseEvent){
		//trace("timeOn:" + bricks.timeOn);
		if(!isPaused){
			/*
			*You actually can(try to)force GC in AIR apps it turns out
			*without using any unspported hacks
			*When the pause menu is up would be a good time to run it
			*Also when transitioning between levels.
			*/
			System.gc();
			//System.gc();//I seriously doubt you need to invoke this twice to get both DRC and MS algorithms run-- it sounds like those are just what Flash GC always does
			if(!startButton.visible){
				//for(i in 0...ball.numChildren){
				//trace("ball children:" + ball.getChildAt(i));
				//}
				//trace("");
			if(mv_rTempBall !=null){
				if(!mv_rTempBall.dying){
				mv_rTempBall.splitTimer.stop();//potentially good to make sure ball2 doesn't disappear while game is paused??
				mv_rTempBall.removeEventListener(Event.ENTER_FRAME, mv_rTempBall.ballMotion2);
				}
				else if(mv_rTempBall.dying){
					mv_rTempBall.deathTimer.stop();//stops ball from disappearing while paused if it has started the death cycle
					
				}
			}
			mv_rMainBall.removeEventListener(Event.ENTER_FRAME, mv_rMainBall.ballMotion);
			mv_rPlayerPaddle.removeEventListener(Event.ENTER_FRAME, mv_rPlayerPaddle.paddleMotion);
			ePaddle.removeEventListener(Event.ENTER_FRAME, ePaddle.fight);
			//
			//if(event.currentTarget.label=="Resume"){
				if(bricks.timeOn){
					//bricks.shortTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, bricks.levelRegen);
					//need to catch the current value of bricks.shortTimer and then pause bricks.shortTimer, then resume bricks.shortTimer in unpausePlay with the value it had when menu button was pressed.
					bricks.shortTimer.stop();
				}
			//}

            //TODO: rebuild menu UI in code from haxe.ui stuff
			myMenuUI = new PauseMenu();
			myMenuUI.getResumeButton().addEventListener(MouseEvent.CLICK, unpausePlay);
			myMenuUI.getResetButton().addEventListener(MouseEvent.CLICK, unpausePlay);
			myMenuUI.x=150;
			myMenuUI.y=150;
			this.addChild(myMenuUI);
			this.setChildIndex(myMenuUI, this.numChildren - 1);
			//var myTween:Tween=ArkPongMain Tween(myMenuUI, "x", Strong.easeOut, 0, 300, 3, true);
			//var myTweenX:Tween=ArkPongMain Tween(myMenuUI, "x", Strong.easeOut, 0, 150, 3, true);
			/*//TODO: revisit with OpenFL-based tween later
                myTweenAlpha=new Tween(myMenuUI, "alpha", 0.5, 0, 1, 3, true);
			myTweenY=new Tween(myMenuUI, "y", 0.5, 0, 150, 3, true);
			*/
			//var myTweenWidth:Tween=ArkPongMain Tween(myMenuUI, "width", Strong.easeOut, myMenuUI.width-200, myMenuUI.width, 3, true);
			//var myTweenHeight:Tween=ArkPongMain Tween(myMenuUI, "height", Strong.easeOut, myMenuUI.height-200, myMenuUI.height, 3, true);
			//var myTweenRotation:Tween=ArkPongMain Tween(myMenuUI, "rotation", Strong.easeOut, 0, 360, 3, true);
			//for(i in 0...numChildren){
				//trace("" + this.getChildAt(i));
			//}
			Mouse.show();
			isPaused=true;
			}
		}
		
		/*
		bricks.stop();
		ball.stop();
		paddle.stop();
		ePaddle.stop();
		myBall.stop();
		myPaddle.stop();
		evilPaddle.stop();
		this.stop();
		*/
		
	}
	
	public function unpausePlay(event:MouseEvent){
		if(isPaused){
			Mouse.hide();
			myMenuUI.getResumeButton().removeEventListener(MouseEvent.CLICK, unpausePlay);
			myMenuUI.getResetButton().removeEventListener(MouseEvent.CLICK, unpausePlay);
			removeChild(myMenuUI);
            myMenuUI = null;//release this object's reference to it as well so it can be gc'd.  Alternative would be to allocate for one menu UI in the beginning and then just add and remove it from display list
			/*//this should only be of consequence if the user chooses 'resume'.  For simplicity's sake, I'll let the 'reset' option handle the fate of ball2 as it wants without possibility of Interruption etc from this part of the method.
			if(myBall2 !=null){
				if(!myBall2.dying){
				myBall2.splitTimer.start();//potentially good to make sure ball2 doesn't disappear while game is paused??
				myBall2.addEventListener(Event.ENTER_FRAME, myBall2.ballMotion2);
				}
				else if(myBall2.dying){
					myBall2.deathTimer.start();
				}
			}
			*/
			mv_rMainBall.addEventListener(Event.ENTER_FRAME, mv_rMainBall.ballMotion);
			mv_rPlayerPaddle.addEventListener(Event.ENTER_FRAME, mv_rPlayerPaddle.paddleMotion);
			ePaddle.addEventListener(Event.ENTER_FRAME, ePaddle.fight);
			//TODO: this is rather wacky... consider figuring out how to
            //wire up discrete event handlers to each UI control so you don't wind up
            //sifting through strings like some kind of... ugh... web developer
            if(event.currentTarget.text=="Resume"){
                mv_rMainBall.hitControl=0;
				if(mv_rTempBall !=null){
					if(!mv_rTempBall.dying){
						mv_rTempBall.splitTimer.start();//potentially good to make sure ball2 doesn't disappear while game is paused??
						mv_rTempBall.addEventListener(Event.ENTER_FRAME, mv_rTempBall.ballMotion2);
					}
					else if(mv_rTempBall.dying){
						mv_rTempBall.deathTimer.start();
					}
				}
				if(bricks.timeOn && bricks.numChildren==0 && mv_rMainBall.doomCount !=1){
					//bricks.shortTimer.addEventListener(TimerEvent.TIMER_COMPLETE, bricks.levelRegen);
					bricks.shortTimer.start();//this could be where Bug #4 comes from... see how bricks.timeOn is handled...3/4/2011
				}
			}
			//isPaused=false;
			//trace("" + event.currentTarget + " " + event.target + " " + event.relatedObject);
			if(event.currentTarget.text=="Reset"){
				if(myPowerCount>0){
					isReset=true;
				}
                //TODO: make these x,y values be relative to stage size. Ex. x value of half stage width minus half ball width and y value of halfway between closest layer of bricks and
                //bottom or top of stage depending on player or enemy control minus ball height
				if(mv_rMainBall.control==0){
					mv_rMainBall.x=275;
					mv_rMainBall.y=280;
				}
				if(mv_rMainBall.control==1){ //this is so if reset is pressed while the ball is in contact with a stage border it won't stuck half-on half-off the stage
					mv_rMainBall.x=275;
					mv_rMainBall.y=280;
				}
				if(mv_rMainBall.control==2){
					mv_rMainBall.x=275;
					mv_rMainBall.y=80;
				}
				bricks.shortTimer.stop();
				bricks.shortTimer.reset();
				beginAgain();
				bricks.gnuRemakeLvl(event);//ArkPongMain way
				//bricks.remakeLvl(event);//old way
			}
			isPaused=false;
		}
	}
	
	public function playBattleSong(){
		
		var loader:URLLoader=new URLLoader();
		//configureListeners(loader);
		var request:URLRequest=new URLRequest("106_Vitriolic_a_stroke.mp3");
		try {
			loader.load(request);
		} catch(error:Dynamic){
			trace("Unable to load requested sound file "+request.url);
		}
		
		var snd:Sound=new Sound(request);
		//var snd:Sound=ArkPongMain Sound(ArkPongMain URLRequest("Alice_FeastofCrows1.mp3"));
		snd.play(0,100);
		//gotoAndStop -- possibly send to blank scene which immediately(or when reset button pressed)sends back to this scene anew?
		
	}
	
	//public function paddleHandler(event:MouseEvent){   
	  
	 //  myPaddle.startDrag();
	  
	  /*
	   if(event.charCode==97){
		 myPaddle.x=myPaddle.x - 105;
	   }
	   if(event.charCode==100){
		 myPaddle.x=myPaddle.x + 105;
	   }
	   */
	   
	//}
	
	public function resetCheck(event:Event){
		//trace("checking for reset");
		//if(this.getChildByName("ball")!=null){
			//trace("isReset:" + isReset);
			//trace("ball children:" + ball.getChildAt(ball.numChildren - 1));
			if(mv_rMainBall.doomCount==1){
				//reset();
				//trace("second if passed");
				Mouse.show();
				startButton.visible=true;
				
				//gotoAndPlay("1");
				//this.reset();
				//this.scenes. 
				
			}
			//trace("first if passed")
		//}
		//trace("" + ball.doomCount);
	}
	
	public function reset(){
		//problem here might be that the stage itself has no children-- the classes that have addChild()are the parents...
		
		for(i in 0...this.numChildren){
			if(this.getChildAt(i+1)!=null){
				if(this.getChildAt(i)!=startButton){
					this.removeChildAt(i);
				}
			}
			if(this.getChildAt(i+1)==null){
				trace("yo");
				if(this.getChildAt(i)!=startButton){
					this.removeChildAt(i);
				}
				Mouse.show();
				startButton.visible=true;
				gotoAndStop("1");
				break;
			}
		}
		
	}
	
	public function usePower(event:MouseEvent){
		//playerPowerCount--;
		//put in if(event.target)..is the correct symbol to specify the power used and no other.
		if(event.target==abilityFire_Player && abilityFire_Player.alpha==1){
			playerPowerCount--;
			trace("used fire!");
			//fireBall=ArkPongMain powerFire()
			//trace(fireBall.name);
			fireBall.x=(mv_rPlayerPaddle.x +(mv_rPlayerPaddle.width/2));
			fireBall.y=mv_rPlayerPaddle.y - 15;
			fireBall.scaleX=5;
			fireBall.scaleY=5;
			addChild(fireBall);
			//powerMotion("fire",fireBall,1,Event.ENTER_FRAME);
			fireBall.addEventListener(Event.ENTER_FRAME, powerMotion);
			power="";
            abilityFire_Player.alpha=.25;
		}
		if(event.target==abilityFreeze_Player && abilityFreeze_Player.alpha==1){
			playerPowerCount--;
			trace("used freeze!");
			ePaddle.removeEventListener(Event.ENTER_FRAME, ePaddle.fight);
			freezeTimer.start();
			//freezeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, unfreeze);
			power="";
            abilityFreeze_Player.alpha=.25;
		}
		if(event.target==abilityNinjaStar_Player && abilityNinjaStar_Player.alpha==1){
			playerPowerCount--;
			trace("used ninja stars!");
			for(i in 0...10){
				var ninjaStars=new FlyingNinja(this.evilPaddle,this.mv_rMainBall,this);
				ninjaStars.x=((55*i)+ 15);
				ninjaStars.y=mv_rPlayerPaddle.y - 15;
				starsArray[i]=ninjaStars;
				numStars++;
				//ball.addChild(starsArray[i]);
				//ninjaStars.addEventListener(Event.ENTER_FRAME, ninjaStars.fly);
				//ninjaStars.addEventListener(Event.ENTER_FRAME, powerMotion);
			}
			//for(i in 0...this.numChildren){
				//trace("ffmain children:" + this.getChildAt(i));
			//}
			power="";
            abilityNinjaStar_Player.alpha=.25;
		}
		if(event.target==abilityPunchThrough_Player && abilityPunchThrough_Player.alpha==1){
			playerPowerCount--;
			trace("used punch!");
            mv_rMainBall.punchPower=true;
			power="";
            abilityPunchThrough_Player.alpha=.25;
		}
		if(event.target==abilitySplit_Player && abilitySplit_Player.alpha==1){
			playerPowerCount--;
			trace("used split!");
			ballMultiply();
			power="";
            abilitySplit_Player.alpha=.25;
		}
		/*
		if(power=="fire"){
			trace("used fire!");
			power="";
			playerFire.alpha=.25
		}
		if(power=="freeze"){
			trace("used freeze!");
			power="";
			playerFreeze.alpha=.25
		}
		if(power=="ninja"){
			trace("used ninja stars!");
			power="";
			playerNinja.alpha=.25
		}
		if(power=="punch"){
			trace("used punch!");
			power="";
			playerPunch.alpha=.25
		}
		if(power=="split"){
			trace("used split!");
			power="";
			playerSplit.alpha=.25
		}
		*/
		//if(power=="gold"){
			//this has an immediate effect applied in class powerUp
		//}
	}
	
	//now the enemy's power use method
	//Enemy AI must call this function and provide a power to use
	public function enemyUsePower(powerChosen:String){
		//below needs repurposing for eenmy stuff...
		if(powerChosen=="fire"){
			enemyPowerCount--;
			trace("enemy used fire!");
			//fireBall=ArkPongMain powerFire()
			//trace(fireBall.name);
			enemyFireBall.x=(evilPaddle.x +(evilPaddle.width/2));
			enemyFireBall.y=evilPaddle.y + 15;
			enemyFireBall.scaleX=5;
			enemyFireBall.scaleY=5;
			addChild(enemyFireBall);
			//powerMotion("fire",fireBall,1,Event.ENTER_FRAME);
			enemyFireBall.addEventListener(Event.ENTER_FRAME, ePowerMotion);
			power="";
			abilityFire_Enemy.alpha=.25;
		}
		if(powerChosen=="freeze"){
			enemyPowerCount--;
			trace("enemy used freeze!");
			mv_rPlayerPaddle.removeEventListener(Event.ENTER_FRAME, mv_rPlayerPaddle.paddleMotion);
			freezeTimer2.start();
			//freezeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, unfreeze);
			power="";
			abilityFreeze_Enemy.alpha=.25;
		}
		if(powerChosen=="stars"){
			playerPowerCount--;
			trace("used ninja stars!");
			for(i in 0...10){
				var ninjaStars=new FlyingNinja(this.evilPaddle,this.ball,this);
				ninjaStars.x=((55*i)+ 15);
				ninjaStars.y=mv_rPlayerPaddle.y - 15;
				starsArray[i]=ninjaStars;
				numStars++;
				//ball.addChild(starsArray[i]);
				//ninjaStars.addEventListener(Event.ENTER_FRAME, ninjaStars.fly);
				//ninjaStars.addEventListener(Event.ENTER_FRAME, powerMotion);
			}
			//for(i in 0...this.numChildren){
				//trace("ffmain children:" + this.getChildAt(i));
			//}
			power="";
			abilityNinjaStar_Player.alpha=.25;
		}
		if(powerChosen=="punch"){
			playerPowerCount--;
			trace("used punch!");
            mv_rMainBall.punchPower=true;
			power="";
			abilityPunchThrough_Player.alpha=.25;
		}
		if(powerChosen=="split"){
			playerPowerCount--;
			trace("used split!");
			ballMultiply();
			power="";
			abilitySplit_Player.alpha=.25;
		}
	}
	
	public function unfreeze(event:TimerEvent){
		freezeTimer.reset();
		//freezeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, unfreeze);
		ePaddle.addEventListener(Event.ENTER_FRAME, ePaddle.fight);
	}
	public function unfreeze2(event:TimerEvent){
		freezeTimer2.reset();
		//freezeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, unfreeze);
		mv_rPlayerPaddle.addEventListener(Event.ENTER_FRAME, mv_rPlayerPaddle.paddleMotion);
	}
	
	public function ePowerMotion(event:Event){
		if(this.contains(enemyFireBall)){
			//trace("fireball.y:" + fireBall.y);
			enemyFireBall.y +=10;
			if(enemyFireBall.hitTestObject(mv_rPlayerPaddle)){
				enemyFireBall.removeEventListener(Event.ENTER_FRAME, ePowerMotion);
				removeChild(enemyFireBall);
			}
			else if(enemyFireBall.y>=550){
                /*//TODO: uncomment when particles are back
				callParts=new CallParts((enemyFireBall.x +(enemyFireBall.width/2)),550);
				addChild(callParts);
                */
                mv_rMainBall.enemyScore +=1;
                mv_rMainBall.eScore.text="ENEMY SCORE:" + mv_rMainBall.enemyScore;
				enemyFireBall.removeEventListener(Event.ENTER_FRAME, ePowerMotion);
				removeChild(enemyFireBall);
				if(mv_rMainBall.enemyScore>=10){
                    //TODO: oh dammit, man... don't have the damn ball process someone's victory
                    mv_rMainBall.enemyWin();
				}
				
			}
		}
	}
	
	public function powerMotion(event:Event){//thePowerID:String, thePower:MovieClip, thePlayer:Int, event:Event){
		//this function will be called from the above usePower function and will handle the
		//actual motion of projectile powerups.  It takes the power ID, the controlling player, and
		//an ENTER_FRAME event as paramters.  The ENTER_FRAME eventlistener will be added when this function
		//is called in usePower.
		if(this.contains(fireBall)){
			//trace("fireball.y:" + fireBall.y);
			fireBall.y -=10;
			if(fireBall.hitTestObject(evilPaddle)){
				fireBall.removeEventListener(Event.ENTER_FRAME, powerMotion);
				removeChild(fireBall);
			}
			else if(fireBall.y<=40){
                /*//TODO: uncomment when particles are back
				callParts=new CallParts((fireBall.x +(fireBall.width/2)),50);
				addChild(callParts);
                */
                mv_rMainBall.playerScore +=1;
                mv_rMainBall.score.text="PLAYER SCORE:" + mv_rMainBall.playerScore;
				fireBall.removeEventListener(Event.ENTER_FRAME, powerMotion);
				removeChild(fireBall);
				if(mv_rMainBall.playerScore>=10){
                    //TODO: wtf
                    mv_rMainBall.playerWin();
				}
				
			}
		}
		

		//if(this.contains(ninjaStars){
			//playerNinja.alpha=.25
			//trace("contains nstars!");
			/*
			ninjaStars.y -=10;
			if(ninjaStars.hitTestObject(evilPaddle)){
				ninjaStars.removeEventListener(Event.ENTER_FRAME, powerMotion);
				removeChild(ninjaStars);
			}
			else if(ninjaStars.y<=40){
				callParts=ArkPongMain CallParts((ninjaStars.x +(ninjaStars.width/2)),50);
				addChild(callParts);
				ball.playerScore +=1;
				ball.score.text="PLAYER SCORE:" + ball.playerScore;
				ninjaStars.removeEventListener(Event.ENTER_FRAME, powerMotion);
				removeChild(ninjaStars);
				
			}
			*/
		//}
		
		//if(thePowerID=="fire" && thePlayer==1){
			//thePower.x -=1;
		//}
		
	}
	
	public function ballMultiply(){
		mv_rTempBall=new TemporaryBall(this.myPaddle,this.mv_rMainBall,this.evilPaddle,this.stage,this.evilSight,this);//this.myPaddle,this.myBall,this.myBall2,this.evilPaddle,this.startButton,this.stage,this.evilSight);
		mv_rTempBall.x=mv_rMainBall.x +(mv_rMainBall.width + 5);
		mv_rTempBall.y=mv_rMainBall.y;
		addChild(mv_rTempBall);
		//myBall2.addEventListener(Event.ENTER_FRAME, myBall2.ballMotion2);
		//splitTimer.reset();
		//splitTimer.start();
		
		
	}
	
	public function killTemporaryBall(){
		
		removeChild(mv_rTempBall);
		mv_rTempBall=null;
	}
	/*
	public function startEndBall2(event:TimerEvent){ //I'm thinking we should migrate thus code to ball2 class, then have the ball2 class destroy itself via this.parent.removechild(this)
		splitTimer.reset();
		myBall2.removeEventListener(Event.ENTER_FRAME, myBall2.ballMotion2);
		myBall2.deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, endBallMultiply);
		myBall2.deathTimer.start();
	}
	
	public function hardEndBall2(){
		trace("fuck her hard!");
		myBall2.splitTimer.reset();
		myBall2.removeEventListener(Event.ENTER_FRAME, myBall2.ballMotion2);
		myBall2.deathTimer.addEventListener(TimerEvent.TIMER_COMPLETE, endBallMultiply);
		myBall2.deathTimer.start();
	}
	
	public function endBallMultiply(event:TimerEvent){
		//splitTimer.reset();
		//myBall2.removeEventListener(Event.ENTER_FRAME, myBall2.ballMotion2);
		trace("fuck the girls!");
		myBall2.deathTimer.reset();
		myBall2.deathTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, endBallMultiply);
		this.stage.removeEventListener(KeyboardEvent.KEY_UP, myBall2.toggleDebug);
		removeChild(myBall2);
		//myBall2==null;
	}
	*/

}