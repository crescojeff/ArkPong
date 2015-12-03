package com.ai.arkpong.view;
import com.ai.arkpong.ArkPongMain;
import com.ai.arkpong.control.PrimaryBall;
import flash.display.MovieClip;
import flash.events.Event;

class FlyingNinja extends MovieClip {
	public var evilPaddle:MovieClip;
	var ball:PrimaryBall;
	var mainRef;

	public function flyingNinja(ePaddle:MovieClip,theBall:PrimaryBall,mainR:ArkPongMain){
		this.evilPaddle=ePaddle;
		this.ball=theBall;
		this.mainRef=mainR;
		
		//Re-engineer this so that the creator of flyingNinjas one set
		//in an array which is retained and re-used to avoid GC.
		//When a star is needed, the creator calls activate on each flyingNinja object
		//ball.addChild(this);
		//this.addEventListener(Event.ENTER_FRAME, fly);
	}
	
	public function activateStar(){
		ball.addChild(this);
		this.addEventListener(Event.ENTER_FRAME, fly);
		
	}
	
	public function fly(event:Event){
		if(this.parent==null){
			this.removeEventListener(Event.ENTER_FRAME, fly);
		}
		if(this.parent !=null){
		this.y -=10;
		//trace("myParent:" + this.parent);
		//trace("ninja y:" + this.y);
			if(this.hitTestObject(evilPaddle)){
				mainRef.numStars--;
				this.removeEventListener(Event.ENTER_FRAME, fly);
				ball.removeChild(this);
			}
			else if(this.y<=40){
				//var callParts:CallParts=ArkPongMain CallParts((this.x +(this.width/2)),50);
				//ball.addChild(callParts);
				ball.ex.showExplosion(this.x,this.y,2);
				ball.playerScore +=1;
				ball.score.text="PLAYER SCORE:" + ball.playerScore;
				mainRef.numStars--;
				this.removeEventListener(Event.ENTER_FRAME, fly);
				ball.removeChild(this);
				if(ball.playerScore>=10){
					ball.playerWin();
				}
				
			}
		}
	}
	


}