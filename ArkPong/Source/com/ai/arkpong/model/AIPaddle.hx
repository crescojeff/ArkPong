package com.ai.arkpong.model;
import com.ai.arkpong.view.ArkPongMovieClip;
import com.ai.arkpong.control.PrimaryBall;
import flash.display.*;
import flash.events.*;
//The evilPaddle should endeavor to aim the ball based on three factors:
//First, the data gathered from the evilSight should be considered(it should aim for the nearest brick)
//Second, the scores should be considered when it tries to act more conservatively or liberally(if it is close to losing it should take fewer chances unless the player is also close to losing-- it must consider the ratio of its score to the player's.)
//Third, it should consider its current width(the wider it is the more chances it can take, and the more chances it must take to launch the ball with good speed.)

//it would be nice to add some semblance of AI strategy in which the enemy paddle tries to aim the ball toward bricks...
//this might be done in the follwoing fashion:first, a line of sight for the evil paddle would have to be established.  Then,
//this line would have to raise a flag when it passed over a brick...
//or alternatively, there could be an array of stage locations(just X values?)inside of this class enemyPaddle, the driver for evilPaddle, 
//which could be dynamically populated as the level builds itself.  Essentially, when each brick appeared, it would tell enemyPaddle where it
//appeared.  Whenever a brick is hit, it will erase itself from this same array before being removed from the display list.

class AIPaddle extends ArkPongMovieClip{
	public var myBall:MovieClip;
	public var myPaddle:MovieClip;
	public var ball:PrimaryBall;
	public var evilPaddle:MovieClip;
	//public var evilSight:MovieClip;
	var evilPaddleSpeed:Float=4.0;
	var intent:Int;//may or may not be used if we decided to narrow the scope of target analysis with the swinging enemySight report
	public var intents:Array<Dynamic>=new Array();// 0 means he wants to avoid it, 1 means it is a normal priority target, 2 means it is a high priority target, and 3 means it is an emergency priority target
	var color:String;
	var sightedAt:Array<Dynamic>;
	var brickLocations:Array<Array<Int>>=[new Array<Int>(), new Array<Int>(), new Array<Int>()];//the evilPaddle CPU should be aware of all brick locations.  Evilsight sweeping is a clumsy implementation of AI in this case.
			//in Bricks class, we'll use something along the line os ePaddle.brickLocations[0].push(x)and ePaddle.brickLocations[1].push(y)to set x and y values respectively.
	
	//var xLocations:Array<Dynamic>=ArkPongMain Array(1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3);
	
	/*
	The affinities:whenever a player hits a brick, his affinity for
	the birck's associated element goes up by 1.  The ball also takes
	on the elemental strike property of that brick.  When a player has
	an affinity to an element and they are struck by that element, the
	damage is reduced by their affinity level(base damage is 10, with HP
	starting at 100).  If however the element of the ball at the time a player
	is struck is the foil to his/her highest affinity, they take double damage.
	Relationships:x ->y means x is strong against y...
			fire
		   ^	\
		  /	     v
		water<--Earth
	*/
	//Elemental affinities
	private var fireAff:Int=0;
	private var waterAff:Int=0;
	private var earthAff:Int=0;
	
	
	public function enemyPaddle(paddle:MovieClip,ball:MovieClip,theBall:PrimaryBall,ePaddle:MovieClip,eSight:MovieClip){
		this.myPaddle=paddle;
		//this.xLocations=xL;
		this.myBall=ball;
		this.ball=theBall;
		//this.evilSight=eSight;
		this.evilPaddle=ePaddle;
		this.addEventListener(Event.ENTER_FRAME, fight);
	}
	
	//Getters/Setters/Incrementers for the affinities
	public function getFireAff():Int{
		return this.fireAff;
	}
	public function getWaterAff():Int{
		return this.waterAff;
	}
	public function getEarthAff():Int{
		return this.earthAff;
	}
	public function setFireAff(i:Int):Void{
		this.fireAff=i;
	}
	public function setWaterAff(i:Int):Void{
		this.waterAff=i;
	}
	public function setEarthAff(i:Int):Void{
		this.earthAff=i;
	}
	public function incFireAff(i:Int):Void{
		this.fireAff +=i;
	}
	public function incWaterAff(i:Int):Void{
		this.waterAff +=i;
	}
	public function incEarthAff(i:Int):Void{
		this.earthAff +=i;
	}
	
	public function fight(event:Event){
		//so, for the AI...
		/*below may change based on time played on current level and/or bricks remaining-- 
		  more bricks is lower priority for seekign score and higher for hitting bricks and growing larger.  Opposite for when there are fewer bricks
		
		//use ball.levelSize to check how much of the stage remains
		>50% level remains(phase 1)priorities:
		First priority, destroy bricks to grow larger.  Give power bricks high Intent and block bricks low Intent
		Second priority, keep control of the ball

		<50% level remains(phase 2)priorities:
		Zero level priority, IF size is half original size skip trying to score on the enemy and instead focus on destroying bricks to reset the level
		First priority, the enemy paddle needs to take Into account where the player paddle is so that it can try to score on him/her
		   during this process it also needs to find a clear path to aim the ball down
		Second priority, defense/offensive power use to score
		Third priority, IF size is greater than player's try to avoid hitting any bricks.  ELSE continue to try to destroy bricks
		Fourth priority, IF size is less than half original size, avoid hitting ball with edge of paddle so as to keep it under control.
		*/
		//evilPaddle.x=myBall.x;
		//evilPaddle.x=(myBall.x -(evilPaddle.width/2))
		
		/*
		 *evilPaddle AI PHASE I
		*/
		if(ball.levelSize/2>ball.bricksDestroyed){ //greater than 50% of level remains
		//trace("here1");
		  //first defense:determine that the ball is not about to hit the evilPaddle score area
		  if(myBall.y<185){ //danger zone for evilPaddle && myBall.x<evilPaddle.x || myBall.y<185 && myBall.x>(evilPaddle.x + evilPaddle.width)){
			  if(myBall.x<evilPaddle.x){
				//evilPaddle.x=myBall.x - 20;
				evilPaddleSpeed=10.0;
			  }
			  else if(myBall.x>evilPaddle.x + evilPaddle.width){
				  //evilPaddle.x=myBall.x -(evilPaddle.width - 20);
				  evilPaddleSpeed=10.0;
			  }
			  else{
				  evilPaddleSpeed=4.0;
			  }
		  }
		
			//first offense:determine Intents for potential target in the set {player score area, brickRGB, brickBlock, brickPower}.  If multiple targets have equal Intent(Std.is(usually, the) case)
			//then target is chosen by proximity to center of evilPaddle
			for(i in 0...brickLocations[0].length){
				//trace("here2");
				if(brickLocations[2][i]=="power"){
					intents[i]=2;
				}
				else if(brickLocations[2][i]=="block"){
					intents[i]=0;
				}
				else if(brickLocations[2][i]=="red"){
					intents[i]=1;
				}
				else if(brickLocations[2][i]=="green"){
					intents[i]=1;
				}
				else if(brickLocations[2][i]=="blue"){
					intents[i]=1;
				}
			}
		}
		
		/*
		 *evilPaddle AI PAHSE II
		*/
		if(ball.levelSize/2<ball.bricksDestroyed){ //less than 50% of the level remains
			//first defense
			if(myBall.y<185){ //danger zone for evilPaddle && myBall.x<evilPaddle.x || myBall.y<185 && myBall.x>(evilPaddle.x + evilPaddle.width)){
			  if(myBall.x<evilPaddle.x){
				//evilPaddle.x=myBall.x - 20;
				evilPaddleSpeed=10.0;
			  }
			  else if(myBall.x>evilPaddle.x + evilPaddle.width){
				  //evilPaddle.x=myBall.x -(evilPaddle.width - 20);
				  evilPaddleSpeed=10.0;
			  }
			  else{
				  evilPaddleSpeed=4.0;
			  }
		  }
		
			
		}
		
		//If the mouse goes off too far to the left
		if(evilPaddle.x<=0){   //myBall.x<evilPaddle.width / 2){
			//Keep the paddle on stage
			evilPaddle.x=0;
			//evilSight.x=evilPaddle.x +(evilPaddle.width/2);
		}
		//If the mouse goes off too far to the right
		if((evilPaddle.x + evilPaddle.width)>=stage.stageWidth){  //myBall.x>stage.stageWidth - evilPaddle.width / 2){
			//Keep the paddle on stage
			evilPaddle.x=stage.stageWidth - evilPaddle.width;
			//evilSight.x=stage.stageWidth -(evilPaddle.width/2);
			
		}
		//Ball is to the right;evilPaddle moves right to Intercept
		if(myBall.x>(evilPaddle.x +(evilPaddle.width/2))){
			//if(sightedAt 
			evilPaddle.x +=evilPaddleSpeed;//Math.abs((myBall.x -(evilPaddle.x +(evilPaddle.width/2))))+ 2.5;
			//evilSight.x +=evilPaddleSpeed;//Math.abs((myBall.x -(evilPaddle.x +(evilPaddle.width/2))))+ 2.5;
			//evilSight.rotation=0;
			//if(evilSight.rotation>-65){
				//evilSight.rotation -=1.5;
			//}
			
		}
		//Ball is to the left;evilPaddle moves left to Intercept
		if(myBall.x<(evilPaddle.x +(evilPaddle.width/2))){
			evilPaddle.x -=evilPaddleSpeed;//Math.abs((myBall.x -(evilPaddle.x +(evilPaddle.width/2))));
			//evilSight.x -=evilPaddleSpeed;
			//if(evilSight.rotation<65){
				//evilSight.rotation +=1.5;
			//}
			
		}
	
	}
	
	public function checkSight(str:String, coordX:Float, coordY:Float){
		//trace(str);
		sightedAt=[coordX,coordY];
		//trace("sightedat:" + sightedAt);
		//the evilPaddle will go after normal bricks with mediocre Intent(1)
		if(str=="blue" || str=="green" || str=="red"){
			intent=1;
		}
		//the evilPaddle will go after power bricks with high itnent(2)
		else if(str=="power"){
			intent=2;
		}
		//the evilPaddle will avoid block bricks with no Intent(0)
		else if(str=="block"){
			intent=0;
		}
	}
	

}