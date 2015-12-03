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
import org.flintparticles.threeD.geom.Quaternion;
import org.flintparticles.threeD.geom.Vector3D;	

/**
 * The RotateEmitter activity rotates the emitter at a constant rate.
 */
class RotateEmitter extends ActivityBase
{
	private var _rotateSpeed:Float=0;
	private var _axis:Vector3D;
	private var _angVel:Quaternion;
	private var temp:Quaternion;
	
	/**
	 * The constructor creates a RotateEmitter activity for use by 
	 * an emitter. To add a RotateEmitter to an emitter, use the
	 * emitter's addActvity method.
	 * 
	 * @see org.flintparticles.common.emitters.Emitter#addActivity()
	 * 
	 * @para angularVelocity The angular velocity for the emitter in 
	 * radians per second.
	 */
	public function new(axis:Vector3D=null, rotateSpeed:Float=0)
	{
		temp=new Quaternion();
		_angVel=new Quaternion();
		this.rotateSpeed=rotateSpeed;
		if(axis)
		{
			this.axis=axis;
		}
	}
	
	
	/**
	 * The axis for the target angular velocity.
	 */
	public var axis(get_axis, set_axis):Vector3D;
 	private function get_axis():Vector3D
	{
		return _axis;
	}
	private function set_axis(value:Vector3D):Void
	{
		_axis=value.unit();
		setAngularVelocity(_axis.multiply(_rotateSpeed));
	}
	
	/**
	 * The size of the target angular velocity.
	 */
	public var rotateSpeed(get_rotateSpeed, set_rotateSpeed):Float;
 	private function get_rotateSpeed():Float
	{
		return _rotateSpeed;
	}
	private function set_rotateSpeed(value:Float):Void
	{
		_rotateSpeed=value;
		if(_axis)
		{
			setAngularVelocity(_axis.multiply(_rotateSpeed));
		}
	}

	private function setAngularVelocity(value:Vector3D):Void
	{
		_angVel.w=0;
		_angVel.x=value.x * 0.5;
		_angVel.y=value.y * 0.5;
		_angVel.z=value.z * 0.5;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function update(emitter:Emitter, time:Float):Void
	{
		var e:Emitter3D=Emitter3D(emitter);
		temp.assign(_angVel);
		temp.postMultiplyBy(e.rotation);
		e.rotation.incrementBy(temp.scaleBy(time)).normalize();
	}
}