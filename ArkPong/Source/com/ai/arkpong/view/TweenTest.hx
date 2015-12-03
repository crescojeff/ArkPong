package com.ai.arkpong.view;

import flash.display.*;
import flash.events.*;
import flash.ui.Keyboard;
class TweenTest{

	var velocity:Float=0;
	var acceleration:Float=0.5;
	var friction:Float=0.94;

	var isRightKeyDown:Bool=false;
	var isLeftKeyDown:Bool=false;

	public function new(stage:Stage){

		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}

function keyDownHandler(e:KeyboardEvent):Void {
if(e.keyCode==Keyboard.RIGHT){
	isRightKeyDown=true;
}
if(e.keyCode==Keyboard.LEFT){
	isLeftKeyDown=true;
}
}
function keyUpHandler(e:KeyboardEvent):Void {
if(e.keyCode==Keyboard.RIGHT){
	isRightKeyDown=false;
}
if(e.keyCode==Keyboard.LEFT){
	isLeftKeyDown=false;
}
}
function enterFrameHandler(e:Event):Void {
if(isRightKeyDown){
	velocity +=acceleration;
	if(velocity>10){
		velocity=10;
	}
} else if(isLeftKeyDown){
	velocity -=acceleration;
	if(velocity<-10){
		velocity=-10;
	}
}
velocity *=friction;
this.x +=velocity;
}
}