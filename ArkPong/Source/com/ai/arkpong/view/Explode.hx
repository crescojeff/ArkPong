/*//TODO: uncomment when particles are back
package com.ai.arkpong.view;

  import org.flintparticles.common.counters.*;
import org.flintparticles.common.displayObjects.*;
import org.flintparticles.common.initializers.*;
import org.flintparticles.twoD.actions.*;
import org.flintparticles.twoD.emitters.Emitter2D;
import org.flintparticles.twoD.initializers.*;
import org.flintparticles.twoD.renderers.*;
import org.flintparticles.twoD.zones.*;

  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.text.TextField;
  import flash.display.MovieClip;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  import org.flintparticles.twoD.particles.Particle2D;
  import org.flintparticles.threeD.renderers.DisplayObjectRenderer;
  import org.flintparticles.threeD.initializers.Velocity;
  import org.flintparticles.threeD.zones.DiscZone;
  import org.flintparticles.threeD.actions.RandomDrift;
  import org.flintparticles.threeD.actions.DeathZone;
  import org.flintparticles.threeD.actions.Move;


  ////[SWF(width='500', height='350', frameRate='61', backgroundColor='#000000')]
  
  class Explode extends Sprite
  {
// width:384 height:255
////[Embed(source="assets/184098.jpg")]
//public var Image1:Class;

//private var emitter:Emitter2D;
//private var emitter2:Emitter2D;
private var bitmap:Bitmap;
var victim:MovieClip;
var myColor:Int=0;
var hitLocation:Int;
   // private var renderer:DisplayObjectRenderer;
private var fountainCapTimer:Timer=new Timer(2000,1);//governs when fountainCap should be reset to 0
private var fountainCap:Int=0;
//private var minParticle:Particle2D;
private var minLifetime:Lifetime=new Lifetime(1);
private var emitter:Emitter2D=new Emitter2D();
private var renderer:DisplayObjectRenderer=new DisplayObjectRenderer();
private var colorinit:ColorInit=new ColorInit(0,0);
private var image:ImageClass=new ImageClass(RadialDot, 5);
private var vel:Velocity=new Velocity();
private var discz:DiscZone=new DiscZone();
private var minPoint:Point=new Point(0,0);
private var minDrift:RandomDrift=new RandomDrift();
private var deathz:DeathZone=new DeathZone();
private var rectz:RectangleZone=new RectangleZone();
private var minMove:Move=new Move();
private var minBlast:Blast=new Blast();
private var particleCountTotalHandle:Int;


//var shortTimer:Timer=ArkPongMain Timer(2000,1);//dieParts was a BAD implementation -- want to reuse this Explode
//var shortTimer2:Timer=ArkPongMain Timer(2000,1);
//private var renderer2:DisplayObjectRenderer;

public function new(){//xC:Float,yC:Float,theColor:Int){ //pass in the coordinates of the brick, the brick's color, and where the brick was hit(left side explodes to the right, right side explodes to the left)
	//trace("" + xC + " " + yC);
	//this.x=xC + 27.5;
	//this.y=yC + 7.5;
	//this.myColor=theColor;
	////showExplosion();
	initExplode();
	
}
public function setPos(xC:Float,yC:Float){
	this.x=xC + 27.5;
	this.y=yC + 7.5;
}
public function setColorCode(color:Int){
	this.myColor=color;
}

public function initExplode(){
	trace("init explode called");
	
	fountainCapTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetFountainCap);
	
	
	//Bind emitter to renderer and add renderer to stage as child of Explode
	addChild(renderer);
	renderer.addEmitter(emitter);
	
	//Init control vars for emitter
	//maxLifetime.lifetime=0.5;//asDocs claims this should be a value between 0 and 1... not yet sure exactl what the number means in real time
	minBlast.startCount=5;
	//minPoint.x=0;
	//minPoint.y=0;
	discz.center=minPoint;
	discz.outerRadius=100;
	discz.innerRadius=20;
	vel.zone=discz;
	minDrift.driftX=15;
	minDrift.driftY=15;
	rectz.left=-30;
	rectz.top=-30;
	rectz.right=30;
	rectz.bottom=30;
	deathz.zone=rectz;
	deathz.zoneIsSafe=true;
	
	//Set control paramaters, initializers, and actions for emitter
	emitter.counter=minBlast;
	emitter.addInitializer(colorinit);
	emitter.addInitializer(image);
	emitter.addInitializer(vel);
	emitter.addInitializer(minLifetime);
	emitter.addAction(minDrift);
	emitter.addAction(deathz);
	emitter.addAction(minMove);
	
	
	//trace("renderer's positions in display conatienr is:" + this.getChildIndex(renderer));

}

 public function showExplosion(xC:Float,yC:Float,theColor:Int)
	{
	  particleCountTotalHandle=emitter.getCreator().getParticleState(0);
	  //Throttling method -- ensures there are never more than 20 particle objects in the
	  //pool by subtracting the number of currently active(and therefore non-reuseable)particles from the
	  //emitter's blast startcount.  
	 // minBlast.startCount=20 - emitter.getParticleCreator2D().pollPoolActive();
	//If throttling...
	if(particleCountTotalHandle<20){ // && particleCountTotalHandle>5){ //Hmm, throttling should definitely involve tiers, and the distance of a tier from the MAX_ALLOWED_PARTICLE_VALUE should dictate how many fewer particles are relesed by the emitter on showExplosion()calls
	  trace("pc is between 5 and 20!");
	  minBlast.startCount=5 - particleCountTotalHandle;//Maybe use a percentage of a MAX_ALLOWED_PARTICLES_VALUE?
	  if(minBlast.startCount<=0){
		  minBlast.startCount=1;
	  }
	  
		
	  if(fountainCap<2){
		  //trace("the pool has " + Emitter2D.defaultParticleFactory.pollPool()+ " particles currently");
		this.x=xC + 27.5;
		this.y=yC + 7.5;
		//renderer.x=xC + 27.5;
		//renderer.y=yC + 7.5;
		this.myColor=theColor;
 		
		
  		////emitter=ArkPongMain Emitter2D();//It was at this step that rendering worked again
		////renderer=ArkPongMain DisplayObjectRenderer();
		
  		////addChild(renderer);
		
		
  		
  		////renderer.addEmitter(emitter);
		
		//renderer.addEmitter(emitter2);
		/////emitter.counter=ArkPongMain Blast(20);
		//emitter2.counter=ArkPongMain Blast(20);
		////emitter.addInitializer(ArkPongMain ImageClass(RadialDot, 5));
		//emitter2.addInitializer(ArkPongMain ImageClass(RadialDot, 5));
		if(myColor==1){
			//trace("red");
			colorinit.color=0xFFFF0000;//preferred method
		   //// emitter.addInitializer(ArkPongMain ColorInit(0xFFFF0000,0xFFFF0000));//0x00D20000));
		}
		else if(myColor==2){
			//trace("green");
			colorinit.color=0xFF00FF00;
			////emitter.addInitializer(ArkPongMain ColorInit(0xFF00FF00,0xFF00FF00));
		}
		else if(myColor==3){
			//trace("blue");
			colorinit.color=0xFF0000FF;
			////emitter.addInitializer(ArkPongMain ColorInit(0xFF0000FF, 0xFF0000FF));
		}
		//emitter2.addInitializer(ArkPongMain ColorInit(0x00D20000, 0xFFFF0000));
		////emitter.addInitializer(ArkPongMain Velocity(ArkPongMain DiscZone(ArkPongMain Point(0, 0), 100, 20)));
		//emitter2.addInitializer(ArkPongMain Velocity(ArkPongMain DiscZone(ArkPongMain Point(this.x + 65, this.y + 7), 100, 20)));
		////emitter.addAction(ArkPongMain RandomDrift(15, 15));
		//emitter2.addAction(ArkPongMain RandomDrift(15, 15));

  		///var p:Point=renderer.globalToLocal(ArkPongMain Point((this.x + 65),(this.y + 7)));
  		///emitter.addAction(ArkPongMain Explosion(8, p.x, p.y, 100));
		//emitter.addAction(ArkPongMain Explosion(-8, -p.x, -p.y, -500));
		//emitter.addAction(ArkPongMain DeathZone(ArkPongMain RectangleZone(-30, -30, 30, 30), true));
		//emitter.addAction(ArkPongMain Move());
		
		
		//var p2:Point=renderer.globalToLocal(ArkPongMain Point((this.x + 65),(this.y + 7)));
  		//emitter2.addAction(ArkPongMain Explosion(8, p.x, p.y, 500));
		//emitter2.addAction(ArkPongMain Explosion(-8, -p2.x, -p2.y, -100));
		//emitter2.addAction(ArkPongMain DeathZone(ArkPongMain RectangleZone(-50, -50, 50, 50), true));
		//emitter2.addAction(ArkPongMain Move());
		
		
		emitter.start();
		//shortTimer.addEventListener(TimerEvent.TIMER_COMPLETE, dieParts);
		//shortTimer.start();
		
		fountainCap++;//may remove this later if we get the cap at a more appropriate lcoation successfully(e.g. nearer the particle creation routines)
	  }
	  else if(fountainCap>=2){
		  fountainCapTimer.start();
	  }
	 }//endif particleCountHandle<20
 	 else{
		 trace("too many particles!  No more f*&(ing particles, bitch!");
	 }//endif throttling
	}//end function showExplosion
	
	public function resetFountainCap(e:TimerEvent){
		fountainCapTimer.reset();
		fountainCap=0;
		emitter.getCreator().setEachParticleState(0,0,0);
		particleCountTotalHandle=0;
	}
	
	public function showPowerUp(){
		emitter=new Emitter2D();
		//emitter2=ArkPongMain Emitter2D();
		renderer=new DisplayObjectRenderer();
  		addChild(renderer);
		
  		
  		renderer.addEmitter(emitter);
		
		//renderer.addEmitter(emitter2);
		emitter.counter=new Blast(20);
		//emitter2.counter=ArkPongMain Blast(20);
		emitter.addInitializer(new ImageClass(RadialDot, 5));
		//emitter2.addInitializer(ArkPongMain ImageClass(RadialDot, 5));
		if(myColor==1){
			//trace("red");
			emitter.addInitializer(new ColorInit(0xFFFF0000,0xFFFF0000));//0x00D20000));
		}
		if(myColor==2){
			//trace("green");
			emitter.addInitializer(new ColorInit(0x0000FF00,0xFFFF0000));
		}
		if(myColor==3){
			//trace("blue");
			emitter.addInitializer(new ColorInit(0x000000FF, 0xFFFF0000));
		}
		//emitter2.addInitializer(ArkPongMain ColorInit(0x00D20000, 0xFFFF0000));
		emitter.addInitializer(new Velocity(new DiscZone(new Point(0, 0), 150, 20)));
		//emitter2.addInitializer(ArkPongMain Velocity(ArkPongMain DiscZone(ArkPongMain Point(this.x + 65, this.y + 7), 100, 20)));
		emitter.addAction(new RandomDrift(15, 15));
		//emitter2.addAction(ArkPongMain RandomDrift(15, 15));

  		////var p:Point=renderer.globalToLocal(ArkPongMain Point((this.x + 65),(this.y + 7)));
  		////emitter.addAction(ArkPongMain Explosion(8, p.x, p.y, 100));
		//emitter.addAction(ArkPongMain Explosion(-8, -p.x, -p.y, -500));
		emitter.addAction(new DeathZone(new RectangleZone(-30, -30, 50, 70), true));
		emitter.addAction(new Move());
		

		
		emitter.start();
		//shortTimer2.addEventListener(TimerEvent.TIMER_COMPLETE, dieParts);
		//shortTimer2.start();
	}
	

	
	
	
	

  }
*/