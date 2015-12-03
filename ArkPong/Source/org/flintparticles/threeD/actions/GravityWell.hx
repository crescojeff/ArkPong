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

package org.flintparticles.threeD.actions 
{
import org.flintparticles.common.actions.ActionBase;
import org.flintparticles.common.emitters.Emitter;
import org.flintparticles.common.particles.Particle;
import org.flintparticles.threeD.geom.Point3D;
import org.flintparticles.threeD.geom.Vector3D;
import org.flintparticles.threeD.particles.Particle3D;	

/**
 * The GravityWell action applies a force on the particle to draw it towards
 * a single point. The force applied is inversely proportional to the square
 * of the distance from the particle to the point.
 */

class GravityWell extends ActionBase
{
	private var _position:Point3D;
	private var _power:Float;
	private var _epsilonSq:Float;
	private var _gravityConst:Float=10000;// just scales the power to a more reasonable number
	
	/**
	 * The constructor creates a GravityWell action for use by 
	 * an emitter. To add a GravityWell to all particles created by an emitter, use the
	 * emitter's addAction method.
	 * 
	 * @see org.flintparticles.common.emitters.Emitter#addAction()
	 * 
	 * @param power The strength of the force - larger numbers produce a stringer force.
	 * @param position The point towards which the force draws the particles.
	 * @param epsilon The minimum distance for which gravity is calculated. Particles closer
	 * than this distance experience a gravity force as it they were this distance away.
	 * This stops the gravity effect blowing up as distances get small. For realistic gravity 
	 * effects you will want a small epsilon(~1), but for stable visual effects a larger
	 * epsilon(~100)is often better.
	 */
	public function new(power:Float=0, position:Point3D=null, epsilon:Float=100)
	{
		this.power=power;
		this.position=position ? position:Point3D.ZERO;
		this.epsilon=epsilon;
	}
	
	/**
	 * The strength of the gravity force.
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
	 * The x coordinate of the center of the gravity force.
	 */
	public var position(get_position, set_position):Point3D;
 	private function get_position():Point3D
	{
		return _position;
	}
	private function set_position(value:Point3D):Void
	{
		_position=value.clone();
	}
	
	/**
	 * The x coordinate of the point that the force pulls the particles towards.
	 */
	public function get x():Float
	{
		return _position.x;
	}
	public var x(null, set_x):Float;
 	private function set_x(value:Float):Void
	{
		_position.x=value;
	}
	
	/**
	 * The y coordinate of the point that the force pulls the particles towards.
	 */
	public function get y():Float
	{
		return _position.y;
	}
	public var y(null, set_y):Float;
 	private function set_y(value:Float):Void
	{
		_position.y=value;
	}
	
	/**
	 * The z coordinate of the point that the force pulls the particles towards.
	 */
	public function get z():Float
	{
		return _position.z;
	}
	public var z(null, set_z):Float;
 	private function set_z(value:Float):Void
	{
		_position.z=value;
	}
	
	/**
	 * The minimum distance for which the gravity force is calculated. 
	 * Particles closer than this distance experience the gravity as it they were 
	 * this distance away. This stops the gravity effect blowing up as distances get 
	 * small.
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
	 * @inheritDoc
	 */
	override public function update(emitter:Emitter, particle:Particle, time:Float):Void
	{
		if(particle.mass==0)
		{
			return;
		}
		var p:Particle3D=Particle3D(particle);
		var offset:Vector3D=p.position.vectorTo(_position);
		var dSq:Float=offset.lengthSquared;
		if(dSq==0)
		{
			return;
		}
		var d:Float=Math.sqrt(dSq);
		if(dSq<_epsilonSq)dSq=_epsilonSq;
		var factor:Float=(_power * time)/(dSq * d);
		p.velocity.incrementBy(offset.scaleBy(factor));
	}
}