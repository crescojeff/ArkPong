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
import org.flintparticles.common.utils.WeightedArray<Dynamic>;	

/**
 * The ColorsInit initializer sets the color of the particle. It selects 
 * one of multiple colors, using optional weighting values to produce an uneven
 * distribution for the colors.
 */

class ColorsInit extends InitializerBase
{
	private var _colors:WeightedArray<Dynamic>;
	private var _mxmlColors:Array<Dynamic>;
	private var _mxmlWeights:Array<Dynamic>;
	
	/**
	 * The constructor creates a ColorsInit initializer for use by 
	 * an emitter. To add a ColorsInit to all particles created by 
	 * an emitter, use the emitter's addInitializer method.
	 * 
	 * @param colors An array containing the Colors to use for 
	 * each particle created by the emitter, as 32bit ARGB values.
	 * @param weights The weighting to apply to each color. If no weighting
	 * values are passed, the colors are all assigned a weighting of 1.
	 * 
	 * @see org.flintparticles.common.emitters.Emitter#addInitializer()
	 */
	public function new(colors:Array<Dynamic>=null, weights:Array<Dynamic>=null)
	{
		_colors=new WeightedArray();
		if(colors==null)
		{
			return;
		}
		init(colors, weights);
	}
	
	override public function addedToEmitter(emitter:Emitter):Void
	{
		if(_mxmlColors)
		{
			init(_mxmlColors, _mxmlWeights);
			_mxmlColors=null;
			_mxmlWeights=null;
		}
	}
	
	private function init(colors:Array<Dynamic>=null, weights:Array<Dynamic>=null):Void
	{
		_colors.clear();
		var len:Int=colors.length;
		var i:Int;
		if(weights !=null && weights.length==len)
		{
			for(i=0;i<len;++i)
			{
				_colors.add(colors[i], weights[i]);
			}
		}
		else
		{
			for(i=0;i<len;++i)
			{
				_colors.add(colors[i], 1);
			}
		}
	}
	
	public function addColor(color:Int, weight:Float=1):Void
	{
		_colors.add(color, weight);
	}
	
	public function removeColor(color:Int):Void
	{
		_colors.remove(color);
	}
	
	public var colors(null, set_colors):Array;
 	private function set_colors(value:Array):Void
	{
		if(value.length==1 && value[0] is String)
		{
			_mxmlColors=Std.string(value[0]).split(",");
		}
		else
		{
			_mxmlColors=value;
		}
		checkStartValues();
	}
	
	public var weights(null, set_weights):Array;
 	private function set_weights(value:Array):Void
	{
		if(value.length==1 && value[0] is String)
		{
			_mxmlWeights=Std.string(value[0]).split(",");
		}
		else
		{
			_mxmlWeights=value;
		}
		checkStartValues();
	}
	
	private function checkStartValues():Void
	{
		if(_mxmlColors && _mxmlWeights)
		{
			init(_mxmlColors, _mxmlWeights);
			_mxmlColors=null;
			_mxmlWeights=null;
		}
	}
	
	/**
	 * @inheritDoc
	 */
	override public function initialize(emitter:Emitter, particle:Particle):Void
	{
		particle.color=_colors.getRandomValue();
	}
}