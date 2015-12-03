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

package org.flintparticles.threeD.initializers 
{
import org.flintparticles.common.emitters.Emitter;
import org.flintparticles.common.initializers.InitializerBase;
import org.flintparticles.common.particles.Particle;
import org.flintparticles.threeD.geom.Quaternion;
import org.flintparticles.threeD.geom.Vector3D;
import org.flintparticles.threeD.particles.Particle3D;	

/**
 * The Rotation Initializer sets the rotation of the particle. The rotation is
 * relative to the rotation of the emitter.
 */

class Rotation extends InitializerBase
{
	private var _axis:Vector3D;
	private var _min:Float;
	private var _max:Float;
	private var _rot:Quaternion;

	/**
	 * The constructor creates a Rotation initializer for use by 
	 * an emitter. To add a Rotation to all particles created by an emitter, use the
	 * emitter's addInitializer method.
	 * 
	 *<p>The rotation of particles initialized by this class
	 * will be a random value between the minimum and maximum
	 * values set. If no maximum value is set, the minimum value
	 * is used with no variation.</p>
	 * 
	 * @param axis The axis around which the rotation occurs.
	 * @param minAngle The minimum angle, in radians, for the particle's rotation.
	 * @param maxAngle The maximum angle, in radians, for the particle's rotation.
	 * 
 		 * @see org.flintparticles.common.emitters.Emitter#addInitializer()
	 */
	public function new(axis:Vector3D=null, minAngle:Float=0, maxAngle:Float=NaN)
	{
		_rot=new Quaternion();
		if(axis)
		{
			this.axis=axis;
		}
		this.minAngle=minAngle;
		this.maxAngle=maxAngle;
	}
	
	/**
	 * The axis for the rotation.
	 */
	public var axis(get_axis, set_axis):Vector3D;
 	private function get_axis():Vector3D
	{
		return _axis;
	}
	private function set_axis(value:Vector3D):Void
	{
		_axis=value.unit();
	}
	
	/**
	 * The minimum angle for particles initialised by 
	 * this initializer.
	 */
	public var minAngle(get_minAngle, set_minAngle):Float;
 	private function get_minAngle():Float
	{
		return _min;
	}
	private function set_minAngle(value:Float):Void
	{
		_min=value;
	}
	
	/**
	 * The maximum angle for particles initialised by 
	 * this initializer.
	 */
	public var maxAngle(get_maxAngle, set_maxAngle):Float;
 	private function get_maxAngle():Float
	{
		return _max;
	}
	private function set_maxAngle(value:Float):Void
	{
		_max=value;
	}
	
	/**
	 * When reading, returns the average of minAngle and maxAngle.
	 * When writing this sets both maxAngle and minAngle to the 
	 * same angle value.
	 */
	public var angle(get_angle, set_angle):Float;
 	private function get_angle():Float
	{
		return _min==_max ? _min:(_max + _min)/ 2;
	}
	private function set_angle(value:Float):Void
	{
		_max=_min=value;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function initialize(emitter:Emitter, particle:Particle):Void
	{
		var p:Particle3D=Particle3D(particle);
		var angle:Float;
		if(isNaN(_max))
		{
			angle=_min;
		}
		else
		{
			angle=_min + Math.random()*(_max - _min);
		}
		_rot.setFromAxisRotation(_axis, angle);
		p.rotation.preMultiplyBy(_rot);
	}
}