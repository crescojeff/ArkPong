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
 * The TweenPosition action adjusts the particle's position between two
 * locations as it ages. The position is relative to the particle's energy,
 * which changes as the particle ages in accordance with the energy easing
 * function used. This action should be used in conjunction with the Age action.
 */

class TweenPosition extends ActionBase
{
	private var _diffX:Float=0;
	private var _endX:Float=0;
	private var _diffY:Float=0;
	private var _endY:Float=0;
	
	/**
	 * The constructor creates a TweenPosition action for use by an emitter. 
	 * To add a TweenPosition to all particles created by an emitter, use the
	 * emitter's addAction method.
	 * 
	 * @see org.flintparticles.common.emitters.Emitter#addAction()
	 * 
	 * @param startX The x value for the particle's position when its energy is 1.
	 * @param startY The y value for the particle's position when its energy is 1.
	 * @param endX The x value of the particle's position when its energy is 0.
	 * @param endY The y value of the particle's position when its energy is 0.
	 */
	public function new(startX:Float=0, startY:Float=0, endX:Float=0, endY:Float=0)
	{
		this.startX=startX;
		this.endX=endX;
		this.startY=startY;
		this.endY=endY;
	}
	
	/**
	 * The x position for the particle's position when its energy is 1.
	 */
	public var startX(get_startX, set_startX):Float;
 	private function get_startX():Float
	{
		return _endX + _diffX;
	}
	private function set_startX(value:Float):Void
	{
		_diffX=value - _endX;
	}
	
	/**
	 * The X value for the particle's position when its energy is 0.
	 */
	public var endX(get_endX, set_endX):Float;
 	private function get_endX():Float
	{
		return _endX;
	}
	private function set_endX(value:Float):Void
	{
		_diffX=_endX + _diffX - value;
		_endX=value;
	}
	
	/**
	 * The y position for the particle's position when its energy is 1.
	 */
	public var startY(get_startY, set_startY):Float;
 	private function get_startY():Float
	{
		return _endY + _diffY;
	}
	private function set_startY(value:Float):Void
	{
		_diffY=value - _endY;
	}
	
	/**
	 * The y value for the particle's position when its energy is 0.
	 */
	public var endY(get_endY, set_endY):Float;
 	private function get_endY():Float
	{
		return _endY;
	}
	private function set_endY(value:Float):Void
	{
		_diffY=_endY + _diffY - value;
		_endY=value;
	}
	
	/**
	 * Calculates the current position of the particle based on it's energy.
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
		p.x=_endX + _diffX * p.energy;
		p.y=_endY + _diffY * p.energy;
	}
}