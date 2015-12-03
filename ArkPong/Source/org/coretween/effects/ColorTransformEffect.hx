/*!
 * This program is free software;you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation;either version 2
 * of the License, or(at your option)any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY;without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program;if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA 
 */

/*!
 * $Id:ColorTransformEffect.as 20 2009-08-01 03:26:27Z lschreur $
 * $Date:2009-08-01 13:26:27 +1000(Sat, 01 Aug 2009)$
 */

package org.coretween.effects;

import flash.geom.ColorTransform;

import org.coretween.effects.Effect;
import org.coretween.effects.EffectUtils;

class ColorTransformEffect extends Effect
{
	private var _r:Float=0;
	private var _g:Float=0;
	private var _b:Float=0;
	private var _a:Float=1.0;
	
	public function get r():Float
	{
		return(_effectTarget.transform.colorTransform.redOffset);
	}
	
	public var r(null, set_r):Float;
 	private function set_r(r:Float):Void
	{
		_r=r;
	}
	
	public function get g():Float
	{
		return(_effectTarget.transform.colorTransform.greenOffset);
	}
	
	public var g(null, set_g):Float;
 	private function set_g(g:Float):Void
	{
		_g=g;
	}
	
	public function get b():Float
	{
		return(_effectTarget.transform.colorTransform.blueOffset);
	}
	
	public var b(null, set_b):Float;
 	private function set_b(b:Float):Void
	{
		_b=b;
	}
	
	public function get a():Float
	{
		return(_effectTarget.transform.colorTransform.alphaOffset);
	}
	
	public var a(null, set_a):Float;
 	private function set_a(a:Float):Void
	{
		_a=a;
	}
	
	override public var target(null, set_target):Dynamic;
 	private function set_target(target:Dynamic):Void
	{
		super.target=target;
		
		_effectTarget=target;
	}
	
	override public var values(get_values, set_values):Dynamic;
 	private function get_values():Dynamic
	{
		return({ color:EffectUtils.makeARGB(_a, _r, _g, _b)});
	}
	
	override private function set_values(values:Dynamic):Void
	{
		values.color=values.color !=undefined ? values.color:0xffffffff;
		
		super.values={ r:EffectUtils.getRed(values.color), 
						 g:EffectUtils.getGreen(values.color), 
						 b:EffectUtils.getBlue(values.color), 
						 a:EffectUtils.getAlpha(values.color)};
	}
	
	public function new(target:Dynamic, values:Dynamic, duration:Float, equations:Dynamic, delay:Float=0, loop:Bool=false, type:Int=0xffff)
	{
		super(target, values, duration, equations, delay, loop, type);
	}
	
	override public function start():Void
	{
		_r=this.r;
		_g=this.g;
		_b=this.b;
		_a=this.a;
		
		super.start();		
	}

	override public function update(currentTime:Float):Void
	{
		super.update(currentTime);
		
		if(tweening && !paused)
		{
			trace(_r+","+_g+","+_b+","+_a);
			_effectTarget.transform.colorTransform=new ColorTransform(0, 0, 0, 1, _r, _g, _b, _a);
		}
	}
}
}

/*!
 * EOF
 */
