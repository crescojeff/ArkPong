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

package org.flintparticles.twoD.activities;

import org.flintparticles.common.activities.ActivityBase;
import org.flintparticles.common.emitters.Emitter;
import org.flintparticles.twoD.emitters.Emitter2D;	

/**
 * The MoveEmitter activity moves the emitter at a constant velocity.
 */
class MoveEmitter extends ActivityBase
{
	private var _velX:Float;
	private var _velY:Float;
	
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
	public function new(x:Float=0, y:Float=0)
	{
		this.x=x;
		this.y=y;
	}
	
	/**
	 * The x coordinate of the velocity to move the emitter, 
	 * in pixels per second
	 */
	public function get x():Float
	{
		return _velX;
	}
	public var x(null, set_x):Float;
 	private function set_x(value:Float):Void
	{
		_velX=value;
	}
	
	/**
	 * The y coordinate of the velocity to move the emitter, 
	 * in pixels per second
	 */
	public function get y():Float
	{
		return _velY;
	}
	public var y(null, set_y):Float;
 	private function set_y(value:Float):Void
	{
		_velY=value;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function update(emitter:Emitter, time:Float):Void
	{
		var e:Emitter2D=Emitter2D(emitter);
		e.x +=_velX * time;
		e.y +=_velY * time;
	}
}