//We want to apply a major change to this class such that one of two design possibilities is implemented:
//1. Create an entire stage full of generic display objects of brick proportions at program start. Do not add them to the display list immediately.
//As stage codes are generated, cast certain generic displayobjects to specific brick types.  When a brick is hit,
//it simply becomes invisible and inert until a level code calls for its use again later(possibly re-casting it to another brick type)or the level respawns.  
//If we go this route, object pooling may be useful.
//   Advantages:No brick-based GC at all, and no in-game load times.  Potentially simpler to handle.
//   Disadvantages:Application has a higher memory footprint overall as memory is reserved for eevry possible brick at all times.
//		   this could be eased by making the invisi-bricks have tiny or no dimensions until they are cast
//			 to actual brick types.  Whenever a level changes(not respawns, but changes)the inert brick types would be cast
//			 back to tiny invisi-bricks so that as little 'inactive memory' is reserved at any given time.
//2. Dynamically create and destroy bricks as we have been doing, but only when a level changes. When bricks are hit, they simply become invisible/inert
//	 they are not made eligible for GC until the level code changes.  When this happens, all the bricks are destroyed together, and the ArkPongMain level
//   is created according to the ArkPongMain level code.
//	Advantages:Potentially a much smaller memory footprint, no 'wasted' resources.
//	Disadvantages:potentially more difficult to manage, bricks will contribute to GC runs, thereby making GC run more often.


package com.ai.arkpong.control;
//import flash.display.MovieClip;
//import flash.display.Sprite;
import com.ai.arkpong.model.AIPaddle;
import com.ai.arkpong.model.UnitBrick;
import com.ai.arkpong.model.InvisiBrick;
import haxe.ui.toolkit.controls.Button;
import openfl.display.*;
import openfl.events.*;
import openfl.utils.Timer;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.Button;
import de.polygonal.core.ObjectPool;

class Bricks extends MovieClip {
	public var myBall:MovieClip;
	public var myPaddle:MovieClip;
	public var ball:PrimaryBall;
	public var countHit:Int;
	public var evilPaddle:MovieClip;
	//public var evilSight:MovieClip;
	public var startButton:Button;
	public var ePaddle:AIPaddle;
	//public var myMenuUI:MovieClip;
	var theX:Float;
	var theY:Float;
	var stageRef:Stage;
	var timeOn:Bool=false;
	var mainRef:ArkPongMain;
	var brickBlockCount:Int=0;
	var brickKiller:Array<Dynamic>=new Array();
	var shortTimer:Timer=new Timer(5000,1);//we may need something listening for event.ENTER_FRAME and checking the ball.bricksDestroyed property continuously in this class.  Alternatively, we could have an eventdispatcher or something in the bricks class that activates the timer here if lvlarray.length==bricksDestroyed.  Regardless, when bricksDestroyed==levelarray.length, the timer is started.
	var frameWaiter:Timer=new Timer(2000,1);
	//public var xLocations:Array<Dynamic>;
	//var bricksDestroyed:Int=0;
	
	//Current level player is on
	var currentLvl:Int=1;
	//The array code for lvl 1
	//ACTUALLY, this can serve as the array for any level-- we will change the array below so that each
	//index is populated dynamically and randomly by a number between, say, 1 and 7(7 being a null space, and 4,5,6 being 1,2, and 3 but with some Y value offset or something)
	var lvl1Code:Array<Dynamic>=new Array(1,2,3,1,2,3,1,2,3,1,2,3,1,2,4,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3);
	///var lvl1Code:Array<Dynamic>=ArkPongMain Array(5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1);
	//The array that contains all of the level codes
	var lvlArray:Array<Dynamic>=new Array(lvl1Code);
	var brickBlockDie:Bool=false;//signal brickBlocks watch for to see if they should kill themselves
	/*
	 * variables pertaining to random level generation
	*/
	var stageSize:Int=0;//this is the total number of bricks in the level
	var stageCount:Int=0;//this increments as the player beats a level. After every five such victories the player fights a boss
	var rand:Float;
	var winner:Int;//this value will be set via Ball's winner property when a player wins or loses. 1=player win 2=enemy win
	var brickCode:Int;//these Ints are the elements of the levelCode array and correspond to the brick object that will be rendered from the levelcode array
	var lvlCode:Array<Dynamic>=new Array();//generated level code passed to each brick's lvlCode field just as lvl1Code is now.
	
	/*
	*the array holding actual brickRed, brickBlue, etc. objects
	*/
	var levelMembers:Array<Dynamic>=new Array();
	private var layoutX:Int;
	private var layoutY:Int;
	//var bricksArray:Array<Dynamic>=ArkPongMain Array();//to make this work, would need to passs it Into each brick type class, and then before a brick removes itself after being hit it pops itself off the array.
	//var colors:Array<Dynamic>;
	//var alphas:Array<Dynamic>;
	//var ratios:Array<Dynamic>;

    /*//dunno what this was
	//the Dynamic Pool experiment for level caching(sp?)
	var pool:DynamicPool=ArkPongMain DynamicPool(false);
	*/
	private var brickWidth:Int=55;
	private var brickHeight:Int=15;
	private var isNewLevel:Bool=false;
	private var isInit:Bool=true;

    /*//dunno what these were
	//The various potential rendering patterns for IBs to use
	private var redBrickData:DisplayObject=ArkPongMain redbrickrender();
	private var greenBrickData:DisplayObject=ArkPongMain greenbrickrender();
	private var blueBrickData:DisplayObject=ArkPongMain newbluebrickrender();
	private var powerBrickData:DisplayObject=ArkPongMain powerbrickrender();
	private var blockBrickData:DisplayObject=ArkPongMain blockbrickrender();
    */

	 /*
	 *Issue with some bricks not re-drawing themselves is due to the
	 *drawRect function not liking repeated calls for some reason
	 *Initially, simply calling drawRect once and then changing size
	 *is enough, but when you wish to have ArkPongMain levels, thus requiring
	 *(potentially)some bricks to be rendered for the first time and
	 *others to be re-rendered in the same or a different color as
	 *brick type assignments change, things get a little sticky...
	 *
	 *UPDATE:Unit tests reveal that calling drawRect repeatedly is NOT
	 *the issue, nor is setting brick size to 0 width and 0 height
	 *before calling drawRect-- in each of those cases alone the
	 *brick re-rendered itself.
	 *The problem lies in the combination of simple 're-inflating' of the
	 *brick(e.g. IB.width=55)and calling drawRect
	 *
	 *UPDATE2:drawRect shouldn't create a ArkPongMain rectangle object each call;
	 *that was for BitmapData.rect, which returns a rectangle object
	 *
	 *UPDATE3:it now appears the problem is related to the collision of 
	 *functions called by the startButton click-- each IB calls selfDestruct
	 *while Bricks simulataneously calls genLevel!
	 *
	 *UPDATE4:turns out we already call setInert on all active levelMembers inside Bricks.genLevel()
	 *so we disabled the selfDestruct function(by commenting the addWired... function which
	 *ties the bricks to the startbutton
	 *
	 *&*^*&^&*^*(& Though Unitbrick seemed fine with repeated calls to drawRect,
	 *IB immediately fails to re-render in any case when given drawRect repeatedly.
	 *When given the old first drawRect, then expand size approach, it will 
	 *re-render on gnuSystemRemakeLvl but not on genLevel.  It is notable that
	 *the IB objects ARE being activated on genLevel, just not rendered...
	 *
	 *UPDATE5:Okay, reset the isInit checks to be individual fields
	 *on each IB and now rendering and re-rendering work in all 
	 *conditions... this leaves the problem of changing brick colors
	 *to match behaviors however, but at least we basically know what
	 *is going on now.
	 */
	
	//FOR DEBUG USING UNITBRICK
	private var ubrick:UnitBrick;
	
	//OTHER DEBUG
	private var actualStageSize:Int=0;

	public function new(enPaddle:AIPaddle,paddle:MovieClip,ball:MovieClip,theBall:PrimaryBall, ePaddle:MovieClip,startB:Button,stageR:Stage,mainR:ArkPongMain){
		//trace("bricks constructed");
		
		this.ePaddle=enPaddle;
		this.myPaddle=paddle;
		this.myBall=ball;
		this.ball=theBall;
		this.evilPaddle=ePaddle;
		//this.evilSight=eSight;
		this.startButton=startB;
		this.stageRef=stageR;
		this.mainRef=mainR;
/*
		//Creating the bricks object pool
		/////pool.allocate(30,InvisiBrick);//sets the pool size of invisibricks to 30, our level size max.  These will be set to the proper brick types later during level generation according to the level code.
*/
		mallocIB();//ArkPongMain way part 1
		//this is a temporary hard-coded setting of levelSize prior to genLevel method completion
		//ball.levelSize=30;
		
		//this.xLocations=xL;
		countHit=0;
		////shortTimer.addEventListener(TimerEvent.TIMER, countDown);
		shortTimer.addEventListener(TimerEvent.TIMER_COMPLETE, levelRegen);
		//ball.addEventListener(Event.ENTER_FRAME, checkLevel);//old way, with polling
		//startButton.addEventListener(MouseEvent.CLICK, remakeLvl);//only fires if game is won with no bricks left on stage //old way
		
		//startButton.addEventListener(MouseEvent.CLICK, gnuRemakeLvl);//only fires if game is won with no bricks left on stage
		startButton.addEventListener(MouseEvent.CLICK, gnuNewLevel);
		
		////startButton.addEventListener(MouseEvent.CLICK, levelDegen);
		////////////////makeLvl();//old way that worked suckily
		genLevel();//ArkPongMain way part 2
	}
	/*
	Below follow the getters and setters for the X and Y
	layout trackers, which will be important in positioning
	and re-positioning invisibricks as the level is made and
	re-made
	*/
	public function getLayoutX():Int{
		return layoutX;
	}
	public function getLayoutY():Int{
		return layoutY;
	}
	public function setLayoutX(i:Int):Void{
		layoutX=i;
	}
	public function setLayoutY(i:Int):Void{
		layoutY=i;
	}
	
	/*
	*used to get and set the dimensions of the level bricks
	*/
	public function getBrickWidth():Int{
		return brickWidth;
	}
	public function getBrickHeight():Int{
		return brickHeight;
	}
	public function setBrickWidth(i:Int){
		brickWidth=i;
	}
	public function setBrickHeight(i:Int){
		brickHeight=i;
	}
	
	//Used to tell if a ArkPongMain level is being generated
	//if that is the case, IB's shouldn't inc ball.bricksDestroyed
	public function getIsNewLevel():Bool{
		return isNewLevel;
	}
	public function setIsNewLevel(b:Bool){
		isNewLevel=b;
	}
	
	//used to get and set value of isInit, which tells us if the the 
	//IB.activateBrick(...)call should consider itself an initialization
	//activation(start of app or genLevel invocation)or a gnuSystemRemake type
	//timely re-activation
	public function getIsInit():Bool{
		return isInit;
	}
	public function setIsInit(b:Bool){
		isInit=b;
	}
	
	//DEGUG getter/setter for actualStageSize -- measures stage size by
	//having IBs report in and inc the variable
	public function getActualStageSize():Int{
		return this.actualStageSize;
	}
	public function setActualStageSize(i:Int):Void{
		this.actualStageSize=i;
	}
	
	
	//Getters for the rendering patterns
	public function getRedBrickData():DisplayObject{
		return this.redBrickData;
	}
	public function getGreenBrickData():DisplayObject{
		return this.greenBrickData;
	}
	public function getBlueBrickData():DisplayObject{
		return this.blueBrickData;
	}
	public function getPowerBrickData():DisplayObject{
		return this.powerBrickData;
	}
	public function getBlockBrickData():DisplayObject{
		return this.blockBrickData;
	}
	
	
	//***Pushes the 30(max level size)invisibricks Into memory.  Based on level size and code determined below, a subset or all of these will be used and their activateBrick method will be called based ont he level code generated
	public function mallocIB(){
		//trace("mallocIB called!");
		
		for(i in 0...30){
			levelMembers.push(new InvisiBrick(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.stageRef,this.mainRef));
		}
	}
	
	public function killLevel2(){ //okay, this looks like it will do the trick for level destruction sweeps...
		for(i in 0...levelMembers.length){
			levelMembers[i].selfDestruct3();
			//levelMembers[i]=null;
			
		}
		levelMembers.splice(0);
	}
	
	//generates a randomized level code usually and a pre-set 'boss' level after every 5 levels
	//this level code is then read by remakelvl and makelvl below to actually render the levels.
	//needs to set the levelSize property of Ball once it is through creating the level
	public function genLevel(){
		var i:Int;
		
		////isInit=true;//when genLevel()is invoked we can consider the activation phase to be initialization again
		//Thing is, we only want init phase for IB's that have not been rendered yet;
		//others which are only being moved and re-rendered via inflation should
		//NOT consider themselves in init phase.  Solution may be to restore
		//isInit boolean flag to the IB objects individually, and let each one manage
		//its tracking of its own phase
		
		isNewLevel=true;//ArkPongMain level creation started
		trace("genLevel invoked!");
		
		//ensure all bricks are inert(could do this better with an auxiliary array tracking active bricks' indexes in levelMembers[])
		//set all levelMembers to inert, eliminate need for selfdestruct method in IB(?)
		for(i in 0...levelMembers.length){
			if(levelMembers[i].getActivatedState()){
			   levelMembers[i].setInert();	
			}
		}
		
		//first set controls
		brickBlockDie=false;
		brickBlockCount=0;//now here we actually do want to drop brickBlockCount to init level of 0
		ball.bricksDestroyed=0;
		ball.killAll=0;
		
		//then determine the context
		if(ball.winnerLabel.text !=""){ //if this is true, somebody just won
			if(ball.winnerLabel.text=="You Win!"){ //player won, so inc stageCount
				stageCount++;
			}
			
		}
		
		//next determine what level to make(random, boss, etc.)
		if(stageCount==5){
			//todo boss level code(s)
			stageCount=0;//reset stagecount to 0 after boss
		}
		else if(stageCount<5){ 
			//first randomly generate the stageSize
			rand=Math.random();
			if(rand<0.3){
				stageSize=10;
			
			}
			else if(rand>=0.3 && rand<0.6){
				stageSize=20;
			}
			else{
				stageSize=30;
			}
			ball.levelSize=stageSize;//make sure Ball knows what the chosen stage size will be, so enemyPaddle can get an easy handle on it also.
			
		}//endif for stage size determination
		
		var brickRow:Int=0;
		var brickColumn:Int=0;
		//now a for loop to actually set the level code for the level
		for(i in 0...stageSize){ //iterations equal to stageSize so that the level code array will have a number of indexes equal to the stageSize, all set in this loop.
			
			//inc brickColumn and brickRow, based on our current brick symbol size
			if(i<=9){
					brickColumn=i;
			}
			else{
					brickColumn=i%10;
			}
			if(i !=0 &&(i+1)%10==0){
					brickRow++;
			}
			
			rand=Math.random();
			if(rand<=0.2){
				lvlCode[i]=1;
				//levelMembers[i].activateBrick("red");
				levelMembers[i].x=(brickWidth-55)+(brickColumn * 55);
				levelMembers[i].y=200+brickRow*20;
				levelMembers[i].activateBrick("red");
				if(!levelMembers[i].getIsChild()){
					addChild(levelMembers[i]);
					levelMembers[i].setIsChild(true);
				}
			}
			if(rand>0.2 && rand<=0.4){
				lvlCode[i]=2;
				//levelMembers[i].activateBrick("green");
				levelMembers[i].x=(brickWidth-55)+(brickColumn * 55);
				levelMembers[i].y=200+brickRow*20;
				levelMembers[i].activateBrick("green");
				if(!levelMembers[i].getIsChild()){
					addChild(levelMembers[i]);
					levelMembers[i].setIsChild(true);
				}
			}
			if(rand>0.4 && rand<=0.6){
				lvlCode[i]=3;
				//levelMembers[i].activateBrick("blue");
				levelMembers[i].x=(brickWidth-55)+(brickColumn * 55);
				levelMembers[i].y=200+brickRow*20;
				levelMembers[i].activateBrick("blue");
				if(!levelMembers[i].getIsChild()){
					addChild(levelMembers[i]);
					levelMembers[i].setIsChild(true);
				}
			}
			if(rand>0.6 && rand<=0.8){
				lvlCode[i]=4;
				//levelMembers[i].activateBrick("power");
				levelMembers[i].x=(brickWidth-55)+(brickColumn * 55);
				levelMembers[i].y=200+brickRow*20;
				levelMembers[i].activateBrick("power");
				if(!levelMembers[i].getIsChild()){
					addChild(levelMembers[i]);
					levelMembers[i].setIsChild(true);
				}
			}
			if(rand>0.8 && rand<=1.0){
				lvlCode[i]=5;
				//levelMembers[i].activateBrick("block");
				levelMembers[i].x=(brickWidth-55)+(brickColumn * 55);
				levelMembers[i].y=200+brickRow*20;
				levelMembers[i].activateBrick("block");
				if(!levelMembers[i].getIsChild()){
					addChild(levelMembers[i]);
					levelMembers[i].setIsChild(true);
				}
			}
			
			/*
			//inc brickColumn and brickRow, based on our current brick symbol size
			if(i<=9){
					brickColumn=i;
			}
			else{
					brickColumn=i%10;
			}
			if(i !=0 &&(i+1)%10==0){
					brickRow++;
			}
			*/
		}//end for loop
		
		//FOR DEBUG
		//gnuMakeUnitTest();
		
		isInit=false;
		isNewLevel=false;//ArkPongMain level creation finished
	}
	
	public function gnuMakeUnitTest(){
		//FOR DEBUG USING UNITBRICK
			ubrick=new UnitBrick(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.stageRef,this.mainRef);
			//addChild(ubrick);
			ubrick.x=100;
			ubrick.y=75;
			ubrick.activateBrick("red");
			addChild(ubrick);
	}
	
	//Used to routinely reset positions etc. of invisibricks
	//in gnuMakeLvl the positions of bricks should be read from genLevel
	public function gnuMakeLvl(){
		//See genLevel above...
			
		
	}
	
	//called by user clicking start button when a ArkPongMain level layout
	//is needed after someone wins
	public function gnuNewLevel(e:MouseEvent){
		ball.playerScore=0;
		ball.enemyScore=0;
		ball.eScore.text="ENEMY SCORE:" + ball.enemyScore;
		ball.score.text="PLAYER SCORE:" + ball.playerScore;
		
		//set controls
		brickBlockDie=false;
		ball.bricksDestroyed=0;
		ball.killAll=0;
		  
		genLevel();
		
		
	}
	
	//used to reset invisibricks on demand from user reset button(s)press
	//in gnuRemakeLvl, the positions of bricks should be the same as the last used positions
	public function gnuRemakeLvl(event:MouseEvent){
		//so what we need to do here is call activateBrick(color:String)
		//on each member of the level pool
		
		//if(ball.playerScore>=10 || ball.enemyScore>=10){
			ball.playerScore=0;
			ball.enemyScore=0;
			ball.eScore.text="ENEMY SCORE:" + ball.enemyScore;
			ball.score.text="PLAYER SCORE:" + ball.playerScore;
			//genLevel();
		//}
		//else{
		
		  //first set controls
		  brickBlockDie=false;
		  //brickBlockCount=0;//old way I believe...
		  ball.bricksDestroyed=0;
		  ball.killAll=0;
		
		  //then iterate through level to activate members
		  for(i in 0...stageSize){
			  if(!levelMembers[i].getActivatedState()){ //don't want to call Activate on an active brick!
				  levelMembers[i].activateBrick(levelMembers[i].getBrickID());
			  }
		  }
		//}
		
		/*
		//FOR DEBUG USING UNITBRICK
		//if(this.contains(ubrick)){
		  if(!ubrick.getActivatedState()){
			  ubrick.activateBrick(ubrick.getBrickID());
		  }
		//}
		*/
		
	}
	
	//same as above, but does not reauire a user event
	public function gnuSystemRemakeLvl(){
		//so what we need to do here is call activateBrick(color:String)
		//on each member of the level pool
		
		//first set controls
		brickBlockDie=false;
		//brickBlockCount=0;//part of the old way I believe...
		ball.bricksDestroyed=0;
		ball.killAll=0;
		
		//then iterate through level to activate members
		for(i in 0...stageSize){
			if(!levelMembers[i].getActivatedState()){ //don't want to call Activate on an active brick!
				levelMembers[i].activateBrick(levelMembers[i].getBrickID());
			}
		}
		
		/*
		//FOR DEBUG USING UNITBRICK
		if(!ubrick.getActivatedState()){
			ubrick.activateBrick(ubrick.getBrickID());
		}
		*/
	}
	
	
	
/*
	public function remakeLvl(event:MouseEvent){ //depending on whether you won or lost, this will either generate a ArkPongMain random stage or the last one played.  If you won(we only increment levels on victories)and the next level is to be a boss level, it will generate that boss level instead.
		// we'll return to this effort after changing the way the bricks are created to the object-array model
		if(this.numChildren>0){
			killLevel();
		}
		
	
	// brickBlockDie=false;
	// brickBlockCount=0;
	 if(this.numChildren==0){
		 
		shortTimer.stop();
		shortTimer.reset();
		brickBlockDie=false;
		brickBlockCount=0;
		ball.bricksDestroyed=0;
		ball.killAll=0;
		//finding the array length of the lvl code
 
		//The index has to be currentLvl-1 because:
		//array indexes start on 0 and our lvl starts at 1
		//our level will always be 1 higher than the actual index of the array
		var arrayLength:Int=lvlArray[currentLvl-1].length;
		//the current row of bricks we are creating
		var brickRow:Int=0;
		var c:Int=0;
		//Now, creating a loop which places the bricks onto the stage
		for(i in 0...arrayLength){
			//checking if it should place a brick there
			if(lvlArray[currentLvl-1][i]==1){
				//creating a variable which holds the brick instance
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				theX=0 +(c * 55);
				theY=200+brickRow*20;//when levels are to be random, chnage this so also so that the theX and theY variables have randomized instead of constant modifiers(e.g. rand[x] + ... instead of 0 + ... and rand[y] + ... instead of 200 + ...).
				//trace("" + theX + " " + theY);
				////var brick:MovieClip=ArkPongMain brickRed(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef);
				levelMembers.push(ArkPongMain brickRed(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef));
				//brickKiller.push(brick);
				//brick.cacheAsBitmap=true;
				//colors=[0xFF0000, 0x000000];
				//alphas=[1,1];
				//ratios=[0,127]
				//brick.name=brick.name + "" + i;
				//brick.graphics.beginGradientFill(GradientType.RADIAL,colors,alphas,ratios);
				//setting the brick's coordinates via the i variable and brickRow
				//brick.x=15+(i-brickRow*7)*75;
				/*
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				*/
		/*
				/////brick.x=0 +(c * 55);
				/////brick.y=200+brickRow*20;
				levelMembers[levelMembers.length-1].x=0 +(c * 55);
				levelMembers[levelMembers.length-1].y=200+brickRow*20;
				/////ePaddle.brickLocations[0].push(brick.x);
				/////ePaddle.brickLocations[1].push(brick.y);
				ePaddle.brickLocations[0].push(levelMembers[levelMembers.length-1].x);
				ePaddle.brickLocations[1].push(levelMembers[levelMembers.length-1].y);
				ePaddle.brickLocations[2].push("red");
				///ball.xLocations[i+1]=brick.x;
				//bricksArray.push(brick);
				//trace("" + ball.xLocations[i+1]);
				//brick.graphics.drawRect(brick.x,brick.y,55,15);
				//brick.graphics.endFill();
				//checks if the current brick needs a ArkPongMain row
				
				//for(c in 1...10){
					//if(i==c*10-1){
						//brickRow ++;
					//}
				//}
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				
				////addChild(brick);
				addChild(levelMembers[levelMembers.length-1]);
			}
			
			
			if(lvlArray[currentLvl-1][i]==2){
				//creating a variable which holds the brick instance
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				theX=0 +(c * 55);
				theY=200+brickRow*20;
				//trace("" + theX + " " + theY);
				/////var brick:MovieClip=ArkPongMain brickBlue(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef);
				levelMembers.push(ArkPongMain brickBlue(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef));
				
				
				levelMembers[levelMembers.length-1].x=0 +(c * 55);
				levelMembers[levelMembers.length-1].y=200+brickRow*20;
			
				ePaddle.brickLocations[0].push(levelMembers[levelMembers.length-1].x);
				ePaddle.brickLocations[1].push(levelMembers[levelMembers.length-1].y);
				ePaddle.brickLocations[2].push("blue");
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				
				addChild(levelMembers[levelMembers.length-1]);
			}
			if(lvlArray[currentLvl-1][i]==3){
				//creating a variable which holds the brick instance
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				theX=0 +(c * 55);
				theY=200+brickRow*20;
				//trace("" + theX + " " + theY);
				////var brick:MovieClip=ArkPongMain brickGreen(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef);
				levelMembers.push(ArkPongMain brickGreen(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef));
				
				
				levelMembers[levelMembers.length-1].x=0 +(c * 55);
				levelMembers[levelMembers.length-1].y=200+brickRow*20;
			
				ePaddle.brickLocations[0].push(levelMembers[levelMembers.length-1].x);
				ePaddle.brickLocations[1].push(levelMembers[levelMembers.length-1].y);
				ePaddle.brickLocations[2].push("green");
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				
				addChild(levelMembers[levelMembers.length-1]);
			}
			if(lvlArray[currentLvl-1][i]==5){
				brickBlockCount++;
				//creating a variable which holds the brick instance
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				theX=0 +(c * 55);
				theY=200+brickRow*20;
				//trace("" + theX + " " + theY);
				////var brick:MovieClip=ArkPongMain brickBlock(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef);
				levelMembers.push(ArkPongMain brickBlock(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef));
				
				
				levelMembers[levelMembers.length-1].x=0 +(c * 55);
				levelMembers[levelMembers.length-1].y=200+brickRow*20;
			
				ePaddle.brickLocations[0].push(levelMembers[levelMembers.length-1].x);
				ePaddle.brickLocations[1].push(levelMembers[levelMembers.length-1].y);
				ePaddle.brickLocations[2].push("block");
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				
				addChild(levelMembers[levelMembers.length-1]);
			}
			if(lvlArray[currentLvl-1][i]==4){
				//creating a variable which holds the brick instance
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				theX=0 +(c * 55);
				theY=200+brickRow*20;
				//trace("" + theX + " " + theY);
				/////var brick:MovieClip=ArkPongMain brickPower(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.stageRef,this.mainRef);
				levelMembers.push(ArkPongMain brickPower(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.stageRef,this.mainRef));
				
				
				levelMembers[levelMembers.length-1].x=0 +(c * 55);
				levelMembers[levelMembers.length-1].y=200+brickRow*20;
			
				ePaddle.brickLocations[0].push(levelMembers[levelMembers.length-1].x);
				ePaddle.brickLocations[1].push(levelMembers[levelMembers.length-1].y);
				ePaddle.brickLocations[2].push("power");
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				
				addChild(levelMembers[levelMembers.length-1]);
				//brickKiller.push(brick);
				//colors=[0xFF0000, 0x000000];
				//alphas=[1,1];
				//ratios=[0,127]
				//brick.graphics.beginGradientFill(GradientType.RADIAL,colors,alphas,ratios);
				//setting the brick's coordinates via the i variable and brickRow
				//brick.x=15+(i-brickRow*7)*75;
				/*
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				*/
				/*
				brick.x=0 +(c * 55);
				brick.y=200+brickRow*20;
				ePaddle.brickLocations[0].push(brick.x);
				ePaddle.brickLocations[1].push(brick.y);
				ePaddle.brickLocations[2].push("power");
				ball.xLocations[i+1]=brick.x;
				//bricksArray.push(brick);
				//trace("" + ball.xLocations[i+1]);
				//brick.graphics.drawRect(brick.x,brick.y,55,15);
				//checks if the current brick needs a ArkPongMain row
				
				//for(c in 1...10){
					//if(i==c*10-1){
						//brickRow ++;
					//}
				//}
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				addChild(brick);
				*/
		/*
			}
			
		}
	  }
		
	}
	*/
	
	function killLevel(){
		var i:Int;
		for(i in 0...this.numChildren){
			brickKiller[i]=this.getChildAt(i);
		}
		
		for(currentBrickIndex in 0...brickKiller.length){
			trace("self-destructing and setting brick "+brickKiller[currentBrickIndex]+" to null");
			
			brickKiller[currentBrickIndex].selfDestruct3();
			brickKiller[currentBrickIndex]=null;
		}
        //this seems like it's way more computationally intensive than the simple clear() we're looking for
        //something like counting down from length and pop()ing each element would probably be best
        //brickKiller.splice(0,brickKiller.length);
		
	}
	
/*
	//Used to push invisibricks Into the array/pool;should only be called ONCE
	//on application init... potentially in onRestart or onResumes from app going Into background
	function makeLvl():Void{ //Places bricks onto Level
		//we'll return to this effort after the bricks are added with an array of objects so we can track the references, and the they are the only references
		//first sweep level of any remaining bricks from previous levels
		if(this.numChildren>0){
			killLevel();
		}
		
		//for(i in 0...brickKiller.length){
			//brickKiller[i]=null;
		//}
	/*
		if(this.numChildren>0){
		for(i in 0...this.numChildren){
			kidKiller[i]=this.getChildAt(i)
			//this.removeChildAt(i);
			
		}
		for(i in 0...kidKiller.length){
			kidKiller[i].removeEventListener(Event.ENTER_FRAME, kidKiller[i].waitToDie);
			kidKiller[i]=null;
		}
		for(i in 0...this.numChildren){
			
			this.removeChildAt(i);
			
		}
		}
		*/
	/*
		brickBlockDie=false;
		brickBlockCount=0;
		ball.bricksDestroyed=0;
		ball.killAll=0;
		//finding the array length of the lvl code
 
		//The index has to be currentLvl-1 because:
		//array indexes start on 0 and our lvl starts at 1
		//our level will always be 1 higher than the actual index of the array
		var arrayLength:Int=lvlArray[currentLvl-1].length;
		//the current row of bricks we are creating
		var brickRow:Int=0;
		var c:Int=0;
		//Now, creating a loop which places the bricks onto the stage
		for(i in 0...arrayLength){
			//checking if it should place a brick there
			if(lvlArray[currentLvl-1][i]==1){
				//creating a variable which holds the brick instance
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				theX=0 +(c * 55);
				theY=200+brickRow*20;
				//trace("" + theX + " " + theY);
				/////var brick:MovieClip=ArkPongMain brickRed(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef);
				
				//For invisibricks, we want to call the activateBrick(color:string)method here.  The objects themselves will already be created in the pool above
				///pool.
				levelMembers.push(ArkPongMain brickRed(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef));
				
				
				//brickKiller.push(brick);
				//brick.cacheAsBitmap=true;
				//colors=[0xFF0000, 0x000000];
				//alphas=[1,1];
				//ratios=[0,127]
				//brick.name=brick.name + "" + i;
				//brick.graphics.beginGradientFill(GradientType.RADIAL,colors,alphas,ratios);
				//setting the brick's coordinates via the i variable and brickRow
				//brick.x=15+(i-brickRow*7)*75;
				/*
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				*/
		/*
				/////brick.x=0 +(c * 55);
				/////brick.y=200+brickRow*20;
				levelMembers[levelMembers.length-1].x=0 +(c * 55);
				levelMembers[levelMembers.length-1].y=200+brickRow*20;
				/////ePaddle.brickLocations[0].push(brick.x);
				/////ePaddle.brickLocations[1].push(brick.y);
				ePaddle.brickLocations[0].push(levelMembers[levelMembers.length-1].x);
				ePaddle.brickLocations[1].push(levelMembers[levelMembers.length-1].y);
				ePaddle.brickLocations[2].push("red");
				///ball.xLocations[i+1]=brick.x;
				//bricksArray.push(brick);
				//trace("" + ball.xLocations[i+1]);
				//brick.graphics.drawRect(brick.x,brick.y,55,15);
				//brick.graphics.endFill();
				//checks if the current brick needs a ArkPongMain row
				
				//for(c in 1...10){
					//if(i==c*10-1){
						//brickRow ++;
					//}
				//}
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				
				////addChild(brick);
				addChild(levelMembers[levelMembers.length-1]);
			}
			
			
			if(lvlArray[currentLvl-1][i]==2){
				//creating a variable which holds the brick instance
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				theX=0 +(c * 55);
				theY=200+brickRow*20;
				//trace("" + theX + " " + theY);
				/////var brick:MovieClip=ArkPongMain brickBlue(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef);
				levelMembers.push(ArkPongMain brickBlue(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef));
				
				
				levelMembers[levelMembers.length-1].x=0 +(c * 55);
				levelMembers[levelMembers.length-1].y=200+brickRow*20;
			
				ePaddle.brickLocations[0].push(levelMembers[levelMembers.length-1].x);
				ePaddle.brickLocations[1].push(levelMembers[levelMembers.length-1].y);
				ePaddle.brickLocations[2].push("blue");
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				
				addChild(levelMembers[levelMembers.length-1]);
			}
			if(lvlArray[currentLvl-1][i]==3){
				//creating a variable which holds the brick instance
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				theX=0 +(c * 55);
				theY=200+brickRow*20;
				//trace("" + theX + " " + theY);
				////var brick:MovieClip=ArkPongMain brickGreen(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef);
				levelMembers.push(ArkPongMain brickGreen(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef));
				
				
				levelMembers[levelMembers.length-1].x=0 +(c * 55);
				levelMembers[levelMembers.length-1].y=200+brickRow*20;
			
				ePaddle.brickLocations[0].push(levelMembers[levelMembers.length-1].x);
				ePaddle.brickLocations[1].push(levelMembers[levelMembers.length-1].y);
				ePaddle.brickLocations[2].push("green");
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				
				addChild(levelMembers[levelMembers.length-1]);
			}
			if(lvlArray[currentLvl-1][i]==5){
				brickBlockCount++;
				//creating a variable which holds the brick instance
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				theX=0 +(c * 55);
				theY=200+brickRow*20;
				//trace("" + theX + " " + theY);
				////var brick:MovieClip=ArkPongMain brickBlock(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef);
				levelMembers.push(ArkPongMain brickBlock(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.mainRef));
				
				
				levelMembers[levelMembers.length-1].x=0 +(c * 55);
				levelMembers[levelMembers.length-1].y=200+brickRow*20;
			
				ePaddle.brickLocations[0].push(levelMembers[levelMembers.length-1].x);
				ePaddle.brickLocations[1].push(levelMembers[levelMembers.length-1].y);
				ePaddle.brickLocations[2].push("block");
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				
				addChild(levelMembers[levelMembers.length-1]);
			}
			if(lvlArray[currentLvl-1][i]==4){
				//creating a variable which holds the brick instance
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				theX=0 +(c * 55);
				theY=200+brickRow*20;
				//trace("" + theX + " " + theY);
				/////var brick:MovieClip=ArkPongMain brickPower(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.stageRef,this.mainRef);
				levelMembers.push(ArkPongMain brickPower(this.ePaddle,this.myPaddle,this.myBall,this.ball, this.evilPaddle,this.evilSight,this.startButton,this.theX,this.theY,this.lvl1Code,this,this.stageRef,this.mainRef));
				
				
				levelMembers[levelMembers.length-1].x=0 +(c * 55);
				levelMembers[levelMembers.length-1].y=200+brickRow*20;
			
				ePaddle.brickLocations[0].push(levelMembers[levelMembers.length-1].x);
				ePaddle.brickLocations[1].push(levelMembers[levelMembers.length-1].y);
				ePaddle.brickLocations[2].push("power");
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				
				addChild(levelMembers[levelMembers.length-1]);
				//brickKiller.push(brick);
				//colors=[0xFF0000, 0x000000];
				//alphas=[1,1];
				//ratios=[0,127]
				//brick.graphics.beginGradientFill(GradientType.RADIAL,colors,alphas,ratios);
				//setting the brick's coordinates via the i variable and brickRow
				//brick.x=15+(i-brickRow*7)*75;
				/*
				if(i<=9){
					c=i;
				}
				else{
					c=i%10;
				}
				*/
				/*
				brick.x=0 +(c * 55);
				brick.y=200+brickRow*20;
				ePaddle.brickLocations[0].push(brick.x);
				ePaddle.brickLocations[1].push(brick.y);
				ePaddle.brickLocations[2].push("power");
				ball.xLocations[i+1]=brick.x;
				//bricksArray.push(brick);
				//trace("" + ball.xLocations[i+1]);
				//brick.graphics.drawRect(brick.x,brick.y,55,15);
				//checks if the current brick needs a ArkPongMain row
				
				//for(c in 1...10){
					//if(i==c*10-1){
						//brickRow ++;
					//}
				//}
				
				if(i !=0 &&(i+1)%10==0){
					brickRow++;
				}
				//finally, add the brick to stage
				addChild(brick);
				*/
		/*
			}
			
		}
		
	}
	*/
	
	public function levelRegen(event:TimerEvent){
		trace("hello you!");
		if(ball.doomCount==0){
			
			/* old way
			if(this.numChildren<=brickBlockCount && this.numChildren>0){
				brickBlockDie=true;
				frameWaiter.start();
			}
			*/
		
		//if(this.numChildren==0){ // || this.numChildren<=brickBlockCount){ // || this.numChildren==brickBlockCount){
		//makeLvl();//old way
		gnuSystemRemakeLvl();//ArkPongMain way
		evilPaddle.width=130;
		//evilSight.x=evilPaddle.x +(evilPaddle.width/2);
		myPaddle.width=130;
		timeOn=false;
		//shortTimer.reset();
		//} //endif for old way 2
		
		}
	}
	
	public function levelRegen2(event:TimerEvent){
		trace("regen2 start");
		if(this.numChildren==0){
			trace("regen2 more");
		frameWaiter.reset();
		frameWaiter.removeEventListener(TimerEvent.TIMER_COMPLETE, levelRegen2);
		//makeLvl();//old way
		genLevel();//ArkPongMain way(?)
		evilPaddle.width=130;
		//evilSight.x=evilPaddle.x +(evilPaddle.width/2);
		myPaddle.width=130;
		timeOn=false;
		//shortTimer.reset();
		}
	}
	
	//checks to see if the level should be reactivated
	//SHould not Poll like it does now;rather an Interrupt should
	//be sent by the last non-block brick on the stage when it is
	//hit and made inert
	//public function checkLevel(event:Event){ //old way, with polling
	public function checkLevel(){ //ArkPongMain way, with Interrupt
	trace("did we get to checkLevel?  We did");
	/*
		if(ball.bricksDestroyed==lvl1Code.length-brickBlockCount && ball.doomCount==0 && ball.killAll !=1 && startButton.visible !=true && this.numChildren<=brickBlockCount){
			//trace("bricks destoryed:" + ball.bricksDestroyed);
			//brickBlockDie=true;
			frameWaiter.addEventListener(TimerEvent.TIMER_COMPLETE, levelRegen2);
			shortTimer.reset();
			shortTimer.start();
			timeOn=true;
			ball.bricksDestroyed=0;
		}
		if(ball.bricksDestroyed==lvl1Code.length && ball.doomCount==0 && ball.killAll !=1 && startButton.visible !=true && this.numChildren==0){
		*/	
			shortTimer.reset();
			shortTimer.start();
			timeOn=true;
			ball.bricksDestroyed=0;
		/*
		}
		*/
		
	}
	/*
	//put this method in another class;we don't want any children of Bricks other than the bricks.
	public function countDown(event:TimerEvent){
		var countDown:Int=5;
		var countLabel:Label=ArkPongMain Label();
		countLabel.x=225;
		countLabel.y=100;
		countLabel.text="" + countDown;
		addChild(countLabel);
		countDown -=1;
	}
	
	public function reset(){
		
		//lvl1Code=[0];
		//makeLvl();
	}
	/*
	public function levelDegen(event:MouseEvent){
		if(ball.killAll==1){
			if(this.contains(brickRed)){
				removeChild(brickRed);
			}
			if(this.contains(brickGreen)){
				removeChild(brickGreen);
			}
			if(this.contains(brickBlue)){
				removeChild(brickBlue);
			}
		}
		/*
		trace("bricks has " + numChildren + " children");
		
		for(i in 0...numChildren){
			//var mc:MovieClip=_clips[i];
			//removeChild(mc);
			trace("" + getChildAt(i));
			removeChildAt(i);
		}
		makeLvl();
		
	}
	*/

	

}