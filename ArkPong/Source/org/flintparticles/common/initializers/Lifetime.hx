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
 
package org.flintparticles.common.initializers 
{
import org.flintparticles.common.emitters.Emitter;
import org.flintparticles.common.particles.Particle;	

/**
 * The Lifetime Initializer sets a lifetime for the particle. It is
 * usually combined with the Age action to age the particle over its
 * lifetime and destroy the particle at the end of its lifetime.
 */
class Lifetime extends InitializerBase
{
	private var _max:Float;
	private var _min:Float;
	
	/**
	 * The constructor creates a Lifetime initializer for use by 
	 * an emitter. To add a Lifetime to all particles created by an emitter, use the
	 * emitter's addInitializer method.
	 * 
	 *<p>The lifetime of particles initialized by this class
	 * will be a random value between the minimum and maximum
	 * values set. If no maximum value is set, the minimum value
	 * is used with no variation.</p>
	 * 
	 * @param minLifetime the minimum lifetime for particles
	 * initialized by the instance.
	 * @param maxLifetime the maximum lifetime for particles
	 * initialized by the instance.
	 * 
	 * @see Emitter.addInitializer.
	 */
	public function new(minLifetime:Float=Number.MAX_VALUE, maxLifetime:Float=NaN)
	{
		_max=maxLifetime;
		_min=minLifetime;
	}
	
	/**
	 * The minimum lifetime for particles initialised by 
	 * this initializer. Should be between 0 and 1.
	 */
	public var minLifetime(get_minLifetime, set_minLifetime):Float;
 	private function get_minLifetime():Float
	{
		return _min;
	}
	private function set_minLifetime(value:Float):Void
	{
		_min=value;
	}
	
	/**
	 * The maximum lifetime for particles initialised by 
	 * this initializer. Should be between 0 and 1.
	 */
	public var maxLifetime(get_maxLifetime, set_maxLifetime):Float;
 	private function get_maxLifetime():Float
	{
		return _max;
	}
	private function set_maxLifetime(value:Float):Void
	{
		_max=value;
	}
	
	/**
	 * When reading, returns the average of minLifetime and maxLifetime.
	 * When writing this sets both maxLifetime and minLifetime to the 
	 * same lifetime value.
	 */
	public var lifetime(get_lifetime, set_lifetime):Float;
 	private function get_lifetime():Float
	{
		return _min==_max ? _min:(_max + _min)* 0.5;
	}
	private function set_lifetime(value:Float):Void
	{
		_max=_min=value;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function initialize(emitter:Emitter, particle:Particle):Void
	{
		if(isNaN(_max))
		{
			particle.lifetime=_min;
		}
		else
		{
			particle.lifetime=_min + Math.random()*(_max - _min);
		}
	}
}