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
 * The TargetVelocity action adjusts the velocity of the particle towards the 
 * target velocity.
 */
class TargetVelocity extends ActionBase
{
	private var _velX:Float;
	private var _velY:Float;
	private var _rate:Float;
	
	/**
	 * The constructor creates a TargetVelocity action for use by an emitter. 
	 * To add a TargetVelocity to all particles created by an emitter, use the
	 * emitter's addAction method.
	 * 
	 * @see org.flintparticles.common.emitters.Emitter#addAction()
	 * 
	 * @param velX The x coordinate of the target velocity, in pixels per second.
	 * @param velY The y coordinate of the target velocity, in pixels per second.
	 * @param rate Adjusts how quickly the particle reaches the target velocity.
	 * Larger numbers cause it to approach the target velocity more quickly.
	 */
	public function new(targetVelocityX:Float=0, targetVelocityY:Float=0, rate:Float=0.1)
	{
		this.targetVelocityX=targetVelocityX;
		this.targetVelocityY=targetVelocityY;
		this.rate=rate;
	}
	
	/**
	 * The y coordinate of the target velocity, in pixels per second.
	 */
	public var targetVelocityY(get_targetVelocityY, set_targetVelocityY):Float;
 	private function get_targetVelocityY():Float
	{
		return _velY;
	}
	private function set_targetVelocityY(value:Float):Void
	{
		_velY=value;
	}
	
	/**
	 * The x coordinate of the target velocity, in pixels per second.s
	 */
	public var targetVelocityX(get_targetVelocityX, set_targetVelocityX):Float;
 	private function get_targetVelocityX():Float
	{
		return _velX;
	}
	private function set_targetVelocityX(value:Float):Void
	{
		_velX=value;
	}
	
	/**
	 * Adjusts how quickly the particle reaches the target velocity.
	 * Larger numbers cause it to approach the target velocity more quickly.
	 */
	public var rate(get_rate, set_rate):Float;
 	private function get_rate():Float
	{
		return _rate;
	}
	private function set_rate(value:Float):Void
	{
		_rate=value;
	}
	
	/**
	 * Calculates the difference between the particle's velocity and
	 * the target and adjusts the velocity closer to the target by an
	 * amount proportional to the difference, the time and the rate of convergence.
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
		var p:Particle2D=Particle2D(particle);
		p.velX +=(_velX - p.velX)* _rate * time;
		p.velY +=(_velY - p.velY)* _rate * time;
	}
}