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

package org.flintparticles.twoD.actions 
{
import org.flintparticles.common.actions.ActionBase;
import org.flintparticles.common.emitters.Emitter;
import org.flintparticles.common.particles.Particle;
import org.flintparticles.twoD.particles.Particle2D;	

/**
 * The GravityWell action applies a force on the particle to draw it towards
 * a single point. The force applied is inversely proportional to the square
 * of the distance from the particle to the point, in accordance with Newton's
 * law of gravity.
 * 
 *<p>This simulates the effect of gravity over large distances(as between
 * planets, for example). To simulate the effect of gravity at the surface
 * of the eacrth, use an Acceleration action with the direction of force 
 * downwards.</p>
 * 
 * @see Acceleration
 */

class GravityWell extends ActionBase
{
	private var _x:Float;
	private var _y:Float;
	private var _power:Float;
	private var _epsilonSq:Float;
	private var _gravityConst:Float=10000;// just scales the power to a more reasonable number
	
	private var lp:Particle2D;
	private var lx:Float;
	private var ly:Float;
	private var ldSq:Float;
	private var ld:Float;
	private var lfactor:Float;
	
	/**
	 * The constructor creates a GravityWell action for use by an emitter.
	 * To add a GravityWell to all particles created by an emitter, use the
	 * emitter's addAction method.
	 * 
	 * @see org.flintparticles.common.emitters.Emitter#addAction()
	 * 
	 * @param power The strength of the gravity force - larger numbers produce a 
	 * stronger force.
	 * @param x The x coordinate of the point towards which the force draws 
	 * the particles.
	 * @param y The y coordinate of the point towards which the force draws 
	 * the particles.
	 * @param epsilon The minimum distance for which gravity is calculated. 
	 * Particles closer than this distance experience a gravity force as if 
	 * they were this distance away. This stops the gravity effect blowing 
	 * up as distances get small. For realistic gravity effects you will want 
	 * a small epsilon(~1), but for stable visual effects a larger
	 * epsilon(~100)is often better.
	 */
	public function new(power:Float=0, x:Float=0, y:Float=0, epsilon:Float=100)
	{
		this.power=power;
		this.x=x;
		this.y=y;
		this.epsilon=epsilon;
	}
	
	/**
	 * The strength of the gravity force - larger numbers produce a 
	 * stronger force.
	 */
	public var power(get_power, set_power):Float;
 	private function get_power():Float
	{
		return _power / _gravityConst;
	}
	private function set_power(value:Float):Void
	{
		_power=value * _gravityConst;
	}
	
	/**
	 * The x coordinate of the point towards which the force draws 
	 * the particles.
	 */
	public function get x():Float
	{
		return _x;
	}
	public var x(null, set_x):Float;
 	private function set_x(value:Float):Void
	{
		_x=value;
	}
	
	/**
	 * The y coordinate of the point towards which the force draws 
	 * the particles.
	 */
	public function get y():Float
	{
		return _y;
	}
	public var y(null, set_y):Float;
 	private function set_y(value:Float):Void
	{
		_y=value;
	}
	
	/**
	 * The minimum distance for which the gravity force is calculated. 
	 * Particles closer than this distance experience the gravity as if
	 * they were this distance away. This stops the gravity effect blowing 
	 * up as distances get small.  For realistic gravity effects you will want 
	 * a small epsilon(~1), but for stable visual effects a larger
	 * epsilon(~100)is often better.
	 */
	public var epsilon(get_epsilon, set_epsilon):Float;
 	private function get_epsilon():Float
	{
		return Math.sqrt(_epsilonSq);
	}
	private function set_epsilon(value:Float):Void
	{
		_epsilonSq=value * value;
	}
	
	/**
	 * Calculates the gravity force on the particle and applies it for
	 * the period of time indicated.
	 * 
	 *<p>This method is called by the emitter and need not be called by the 
	 * user.</p>
	 * 
	 * @param emitter The Emitter that created the particle.
	 * @param particle The particle to be updated.
	 * @param time The duration of the frame - used for time based updates.
	 * 
	 * @see org.flintparticles.common.actions.Action#update()
	 */
	override public function update(emitter:Emitter, particle:Particle, time:Float):Void
	{
		if(particle.mass==0)
		{
			return;
		}
		lp=Particle2D(particle);
		lx=_x - lp.x;
		ly=_y - lp.y;
		ldSq=lx * lx + ly * ly;
		if(ldSq==0)
		{
			return;
		}
		ld=Math.sqrt(ldSq);
		if(ldSq<_epsilonSq)ldSq=_epsilonSq;
		lfactor=(_power * time)/(ldSq * ld);
		lp.velX +=lx * lfactor;
		lp.velY +=ly * lfactor;
	}
}