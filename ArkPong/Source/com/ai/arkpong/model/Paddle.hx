package com.ai.arkpong.model;
import com.ai.arkpong.view.ArkPongMovieClip;
import flash.events.*;
import flash.display.Stage;
import openfl.display.MovieClip;

class Paddle extends ArkPongMovieClip {
	var speed:Int=0;
	public var myPaddle:MovieClip;
	public var myBall:MovieClip;
	var theStage:Stage;
	
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
		  /	   v
		water<--Earth
	*/
	//Elemental affinities
	private var fireAff:Int=0;
	private var waterAff:Int=0;
	private var earthAff:Int=0;
	
	
	//initObject(myPaddle);
	
	public function new(paddle:MovieClip,ball:MovieClip,stageRef:Stage){
		this.myPaddle=paddle;
		this.myBall=ball;
		this.theStage=stageRef;
		myPaddle.addEventListener(Event.ENTER_FRAME, paddleMotion);
		//theStage.addEventListener(MouseEvent.CLICK, tiltPaddleRight);
		//theStage.addEventListener(MouseEvent.MOUSE_WHEEL, tiltPaddleLeft);
		//theStage.addEventListener(KeyboardEvent.KEY_DOWN, paddleMotion2);
		//myPaddle.addEventListener(MouseEvent.CLICK, paddleMotion2);
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
	
	public function paddleMotion(event:Event){
		myPaddle.x=(mouseX -(myPaddle.width/2));
		
		//If the mouse goes off too far to the left
		if(mouseX<myPaddle.width / 2){
			//Keep the paddle on stage
			myPaddle.x=0;
		}
		//If the mouse goes off too far to the right
		if(mouseX>stage.stageWidth - myPaddle.width / 2){
			//Keep the paddle on stage
			myPaddle.x=stage.stageWidth - myPaddle.width;
		}
		
		if(speed==0){
			myPaddle.x=myPaddle.x;
		}
		if(speed<0){
			myPaddle.x -=speed;
		}
		if(speed>0){
			myPaddle.x +=speed;
		}
		
	}
	/*
	public function paddleMotion2(event:KeyboardEvent){
		//trace("hello");
		
		//trace(event.keyCode);
		if(event.keyCode==37){
			myPaddle.x -=5;
		}
		else{
			myPaddle.x +=5;
		}
		
	}
	*/
	
	public function tiltPaddleRight(event:MouseEvent){
			myPaddle.rotation +=45;
	}
	public function tiltPaddleLeft(event:MouseEvent){
			myPaddle.rotation -=45;
	}
}