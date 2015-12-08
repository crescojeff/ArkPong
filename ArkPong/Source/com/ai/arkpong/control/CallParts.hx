/*

//DisplayObjectsPool2D Class:
package;

import flash.display.DisplayObject;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;
import org.flintparticles.common.particles.Particle;
import org.flintparticles.twoD.particles.Particle2D;
import org.flintparticles.twoD.particles.ParticleCreator2D;


// Factory for creating Image for particles from pool.
// @author MihaPro

class DisplayObjectsPool2D extends ParticleCreator2D
{
public var dict:Dictionary=new Dictionary;

public function new()
{
}

override public function disposeParticle(particle:Particle):Void
{
// ?????? ???????? ? ???
RecycleImage(Particle2D(particle));

super.disposeParticle(particle);
}

private function RecycleImage(p:Particle2D):Void
{
var image_class:Class=p.image.constructor as Class;
var v:Array<Dynamic>=dict[image_class];
if(!v)
{
v=new Array<Dynamic>();
dict[image_class]=v;
}
v.push(p.image);
p.image=null;
}

public function GetImage(for_class:Class):Dynamic
{
var v:Array<Dynamic>=dict[for_class];
if(v && v.length)return v.pop();
return null;
}

public function Clear():Void
{
dict=new Dictionary();
}
}

}

//PooledImageClass2D class:
package;

import org.flintparticles.common.emitters.Emitter;
import org.flintparticles.common.initializers.InitializerBase;
import org.flintparticles.common.particles.Particle;
import org.flintparticles.common.utils.construct;
import org.flintparticles.twoD.emitters.Emitter2D;


// Pooled image class.
// @author MihaPro

class PooledImageClass2D extends InitializerBase
{
private var _imageClass:Class;
private var _parameters:Array<Dynamic>;
private var pool:DisplayObjectsPool2D;

public function PooledImageClass2D(_pool:DisplayObjectsPool2D, imageClass:Class, ...parameters)
{
pool=_pool;
_imageClass=imageClass;
_parameters=parameters;
}

override public function addedToEmitter(emitter:Emitter):Void
{
super.addedToEmitter(emitter);
Emitter2D(emitter).particleFactory=pool;
}

override public function initialize(emitter:Emitter, particle:Particle):Void
{
particle.image=pool.GetImage(_imageClass);
if(!particle.image)// if not in pool
particle.image=construct(_imageClass, _parameters);
}
}
}



//Usage:
var pool:DisplayObjectsPool2D=new DisplayObjectsPool2D();
...
emitter1.addInitializer(new PooledImageClass2D(pool, Dot, 1,16777215,"normal"));
...
emitter2.addInitializer(new PooledImageClass2D(pool, RadialDot));

*/

/*//TODO: uncomment when particle engine, either flint's or something from OpenFL, is added back
package;

import org.flintparticles.twoD.emitters.Emitter2D;
  import org.flintparticles.twoD.renderers.BitmapRenderer;

  import openfl.display.Sprite;
  import openfl.filters.BlurFilter;
  import openfl.filters.ColorMatrixFilter;
  import openfl.geom.Rectangle;
  import openfl.events.TimerEvent;
  import openfl.utils.Timer;




  class CallParts extends Sprite
  {
private var emitter:Emitter2D;
var shortTimer:Timer=new Timer(2000,1);
var renderer:BitmapRenderer;

public function CallParts(xHit:Float,yHit:Float)//CallParts will need to take in the coordinates of the ball's collision as parameters
{

  emitter=new Particles(yHit);
  
  //var renderer:BitmapRenderer=ArkPongMain BitmapRenderer(ArkPongMain Rectangle(0, 0, 500, 400));
  renderer=new BitmapRenderer(new Rectangle(0, 50, 550, 450));
  renderer.addFilter(new BlurFilter(2, 2, 1));
  renderer.addFilter(new ColorMatrixFilter([ 1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0.95,0 ]));
  renderer.addEmitter(emitter);
  addChild(renderer);
  
  emitter.x=xHit;
  emitter.y=yHit;
  emitter.start();
  shortTimer.addEventListener(TimerEvent.TIMER_COMPLETE, dieParts);
  shortTimer.start();

}
public function dieParts(event:TimerEvent){
		this.removeChild(renderer)
		this.emitter=null;
		//shortTimer.reset();
		//shortTimer.start();
		this.parent.removeChild(this);
	}
  }
*/