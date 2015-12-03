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
import org.flintparticles.common.utils.interpolateColors;	

/**
 * The ColorInit Initializer sets the color of the particle.
 */

class ColorInit extends InitializerBase
{
	private var _min:Int;
	private var _max:Int;
	
	/**
	 * The constructor creates a ColorInit initializer for use by 
	 * an emitter. To add a ColorInit to all particles created by an emitter, use the
	 * emitter's addInitializer method.
	 * 
	 *<p>The color of particles initialized by this class
	 * will be a random value between the two values pased to
	 * the constructor. For a fixed value, pass the same color
	 * in for both parameters.</p>
	 * 
	 * @param color1 the 32bit(ARGB)color at one end of the color range to use.
	 * @param color2 the 32bit(ARGB)color at the other end of the color range to use.
	 * 
	 * @see org.flintparticles.common.emitters.Emitter#addInitializer()
	 */
	public function new(color1:Int=0xFFFFFF, color2:Int=0xFFFFFF)
	{
		_min=color1;
		_max=color2;
	}
	
	/**
	 * The minimum color value for particles initialised by 
	 * this initializer. Should be between 0 and 1.
	 */
	public var minColor(get_minColor, set_minColor):Int;
 	private function get_minColor():Int
	{
		return _min;
	}
	private function set_minColor(value:Int):Void
	{
		_min=value;
	}
	
	/**
	 * The maximum color value for particles initialised by 
	 * this initializer. Should be between 0 and 1.
	 */
	public var maxColor(get_maxColor, set_maxColor):Int;
 	private function get_maxColor():Int
	{
		return _max;
	}
	private function set_maxColor(value:Int):Void
	{
		_max=value;
	}
	
	/**
	 * When reading, returns the average of minColor and maxColor.
	 * When writing this sets both maxColor and minColor to the 
	 * same color.
	 */
	public var color(get_color, set_color):Int;
 	private function get_color():Int
	{
		return _min==_max ? _min:InterpolateColors(_max, _min, 0.5);
	}
	private function set_color(value:Int):Void
	{
		_max=_min=value;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function initialize(emitter:Emitter, particle:Particle):Void
	{
		if(_max==_min)
		{
			particle.color=_min;
		}
		else
		{
			particle.color=interpolateColors(_min, _max, Math.random());
		}
	}
}