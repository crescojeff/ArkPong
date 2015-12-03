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

package org.flintparticles.threeD.activities;

import org.flintparticles.common.activities.ActivityBase;
import org.flintparticles.common.emitters.Emitter;
import org.flintparticles.threeD.emitters.Emitter3D;
import org.flintparticles.threeD.geom.Vector3D;	

/**
 * The MoveEmitter activity moves the emitter at a constant velocity.
 */
class MoveEmitter extends ActivityBase
{
	private var _vel:Vector3D;
	private var _temp:Vector3D;
	
	/**
	 * The constructor creates a MoveEmitter activity for use by 
	 * an emitter. To add a MoveEmitter to an emitter, use the
	 * emitter's addActvity method.
	 * 
	 * @see org.flintparticles.common.emitters.Emitter#addActivity()
	 * 
	 * @param x The x coordinate of the velocity to move the emitter, 
	 * in pixels per second.
	 * @param y The y coordinate of the velocity to move the emitter, 
	 * in pixels per second.
	 */
	public function new(velocity:Vector3D=null)
	{
		this.velocity=velocity ? velocity:Vector3D.ZERO;
	}
	
	/**
	 * The velocity to move the emitter, in pixels per second.
	 */
	public var velocity(get_velocity, set_velocity):Vector3D;
 	private function get_velocity():Vector3D
	{
		return _vel;
	}
	private function set_velocity(value:Vector3D):Void
	{
		_vel=value.clone();
	}
	
	/**
	 * The x coordinate of the velocity to move the emitter, in pixels per second.
	 */
	public function get x():Float
	{
		return _vel.x;
	}
	public var x(null, set_x):Float;
 	private function set_x(value:Float):Void
	{
		_vel.x=value;
	}
	
	/**
	 * The y coordinate of  the velocity to move the emitter, in pixels per second.
	 */
	public function get y():Float
	{
		return _vel.y;
	}
	public var y(null, set_y):Float;
 	private function set_y(value:Float):Void
	{
		_vel.y=value;
	}
	
	/**
	 * The z coordinate of the velocity to move the emitter, in pixels per second.
	 */
	public function get z():Float
	{
		return _vel.z;
	}
	public var z(null, set_z):Float;
 	private function set_z(value:Float):Void
	{
		_vel.z=value;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function update(emitter:Emitter, time:Float):Void
	{
		_vel.multiply(time, _temp);
		Emitter3D(emitter).position.incrementBy(_temp);
	}
}