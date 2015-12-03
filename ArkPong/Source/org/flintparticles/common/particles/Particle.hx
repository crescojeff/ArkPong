/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author:Richard Lord
 * Copyright(c)Richard Lord 2008-2010
 * http://flintparticles.org
 * 
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files(the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package org.flintparticles.common.particles;

import flash.geom.ColorTransform;
import flash.utils.Dictionary;	

/**
 * The Particle class is a set of public properties shared by all particles.
 * It is deliberately lightweight, with only one method. The Initializers
 * and Actions modify these properties directly. This means that the same
 * particles can be used in many different emitters, allowing Particle 
 * objects to be reused.
 * 
 * Particles are usually created by the ParticleCreator class. This class
 * just simplifies the reuse of Particle objects which speeds up the
 * application. 
 */
class Particle
{
	/**
	 * The 32bit ARGB color of the particle. The initial value is 0xFFFFFFFF(white).
	 */
	public var color:Int=0xFFFFFFFF;
	
	private var _colorTransform:ColorTransform=null;
	private var _previousColor:Int;
	
	/**
	 * The scale of the particle(Std.is(1, normal) size).
	 */
	public var scale:Float=1;
	
	/**
	 * The mass of the particle(Std.is(1, the) default).
	 */
	public var mass:Float=1;
	
	/**
	 * The radius of the particle, for collision approximation
	 */
	public var collisionRadius:Float=1;

	/**
	 * The object used to display the image. In a 2D particle, this is usually
	 * a DisplayObject. In a 3D particle, this may be a DisplayObject, for 
	 * displaying on a billboard or similar, or a 3D object in the form used
	 * by the render system.
	 */
	public var image:Dynamic=null;
	
	/**
	 * The lifetime of the particle, in seconds.
	 */
	public var lifetime:Float=0;
	/**
	 * The age of the particle, in seconds.
	 */
	public var age:Float=0;
	/**
	 * The energy of the particle.
	 */
	public var energy:Float=1;
	
	/**
	 * Whether the particle is dead and should be removed from the stage.
	 */
	public var isDead:Bool=false;
	
	/**
	 * The dictionary object enables actions and activities to add additional properties to the particle.
	 * Any object adding properties to the particle should use a reference to itself as the dictionary
	 * key, thus ensuring it doesn't clash with other object's properties. If multiple properties are
	 * needed, the dictionary value can be an object with a number of properties.
	 */
	public var dictionary(get_dictionary, null):Dictionary;
 	private function get_dictionary():Dictionary
	{
		if(_dictionary==null)
		{
			_dictionary=new Dictionary(true);
		}
		return _dictionary;
	}
	private var _dictionary:Dictionary=null;
	
	/**
	 * Creates a particle. Alternatively particles can be reused by using the ParticleCreator to create
	 * and manage them. Usually the emitter will create the particles and the user doesn't need
	 * to create them.
	 */
	public function new()
	{
	}
	
	/**
	 * Sets the particle's properties to their default values.
	 */
	public function initialize():Void
	{
		color=0xFFFFFFFF;
		scale=1;
		mass=1;
		collisionRadius=1;
		lifetime=0;
		age=0;
		energy=1;
		isDead=false;
		image=null;
		_dictionary=null;
		_colorTransform=null;
	}
	
	/**
	 * A ColorTransform object that converts white to the colour of the particle.
	 */
	public var colorTransform(get_colorTransform, null):ColorTransform;
 	private function get_colorTransform():ColorTransform
	{
		if(!_colorTransform || _previousColor !=color)
		{
			_colorTransform=new ColorTransform(((color>>>16)& 255)/ 255,
								((color>>>8)& 255)/ 255,
								((color)& 255)/ 255,
								((color>>>24)& 255)/ 255,
								   0,0,0,0);
			_previousColor=color;
		}
		return _colorTransform;
	}
	
	public var alpha(get_alpha, null):Float;
 	private function get_alpha():Float
	{
		return((color & 0xFF000000)>>>24)/ 255;
	}

	/**
	 * @private
	 */
	private function cloneInto(p:Particle):Particle
	{
		p.color=color;
		p.scale=scale;
		p.mass=mass;
		p.collisionRadius=collisionRadius;
		p.lifetime=lifetime;
		p.age=age;
		p.energy=energy;
		p.isDead=isDead;
		p.image=image;
		if(_dictionary)
		{
			p._dictionary=new Dictionary(true);
			for(key in _dictionary)
			{
				p._dictionary[ key ]=_dictionary[ key ];
			}
		}
		return p;
	}
	
	/**
	 * Creates a ArkPongMain particle with all the same properties as this one.
	 * 
	 *<p>Note that the ArkPongMain particle will use the same image object as the one you're cloning.
	 * This is fine if the particles are used with a Bitmaprenderer, but if they are used with a 
	 * DisplayObjectRenderer you will need to replace teh image property with a ArkPongMain image, otherwise
	 * only one of the particles(original or clone)will be displayed.</p>
	 */
	public function clone(factory:ParticleFactory=null):Particle
	{
		var p:Particle;
		if(factory)
		{
			p=factory.createParticle();
		}
		else
		{
			p=new Particle();
		}
		return cloneInto(p);
	}
	
	public function revive():Void
	{
		lifetime=0;
		age=0;
		energy=1;
		isDead=false;
	}
}