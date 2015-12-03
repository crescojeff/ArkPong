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
 * $Id:GlowEffect.as 20 2009-08-01 03:26:27Z lschreur $
 * $Date:2009-08-01 13:26:27 +1000(Sat, 01 Aug 2009)$
 */

package org.coretween.effects;

import flash.filters.GlowFilter;

import org.coretween.Tween;
import org.coretween.effects.Effect;
import org.coretween.effects.EffectUtils;

class GlowEffect extends Effect
{
	private var _r:Float=0;
	private var _g:Float=0;
	private var _b:Float=0;
	private var _alpha:Float=100;
	private var _xblur:Float=0;
	private var _yblur:Float=0;
	private var _color:Float=0xffffff;
	private var _inner:Bool=false;
	private var _knockout:Bool=false;
	private var _quality:Float=Effect.QUALITY_MEDIUM;
	private var _strength:Float=1.0;
	private var _filter:GlowFilter=null;
	private var _filterIndex:Float=0;
	
	public function get r():Float
	{
		return(EffectUtils.getRed(_color));
	}
	
	public var r(null, set_r):Float;
 	private function set_r(r:Float):Void
	{
		_r=r;
	}
	
	public function get g():Float
	{
		return(EffectUtils.getGreen(_color));
	}
	
	public var g(null, set_g):Float;
 	private function set_g(g:Float):Void
	{
		_g=g;
	}
	
	public function get b():Float
	{
		return(EffectUtils.getBlue(_color));
	}
	
	public var b(null, set_b):Float;
 	private function set_b(b:Float):Void
	{
		_b=b;
	}
	
	public var alpha(get_alpha, set_alpha):Float;
 	private function get_alpha():Float
	{
		return(_effectTarget.filters[ _filterIndex ].alpha * 100);
	}
	
	private function set_alpha(alpha:Float):Void
	{
		_alpha=alpha;
	}
	
	public var xblur(get_xblur, set_xblur):Float;
 	private function get_xblur():Float
	{
		return(_effectTarget.filters[ _filterIndex ].blurX);
	}
	
	private function set_xblur(xblur:Float):Void
	{
		_xblur=xblur;
	}
	
	public var yblur(get_yblur, set_yblur):Float;
 	private function get_yblur():Float
	{
		return(_effectTarget.filters[ _filterIndex ].blurY);
	}
	
	private function set_yblur(yblur:Float):Void
	{
		_yblur=yblur;
	}
	
	public var strength(get_strength, set_strength):Float;
 	private function get_strength():Float
	{
		return(_effectTarget.filters[ _filterIndex ].strength);
	}
	
	private function set_strength(strength:Float):Void
	{
		_strength=strength;
	}
	
	public var color(get_color, set_color):Float;
 	private function get_color():Float
	{
		return(_effectTarget.filters[ _filterIndex ].color);
	}
	
	private function set_color(color:Float):Void
	{
		_color=color;
	}
	
	override public var target(null, set_target):Dynamic;
 	private function set_target(target:Dynamic):Void
	{
		super.target=this;
		
		_effectTarget=target;
	
		_filterIndex=0;
		
		if(_effectTarget.filters.length>0)
		{
			for(i in 0..._effectTarget.filters.length)
			{
				if(_effectTarget.filters[i] is GlowFilter)
				{
					_filterIndex=i;
					break;
				}
			}
		}
		else
		{
			// create a filter with the default settings.
			_effectTarget.filters=[ new GlowFilter(_color, _alpha / 100, _xblur, _yblur, _strength, _quality, _inner, _knockout)];
		}
	}
	
	override public var values(null, set_values):Dynamic;
 	private function set_values(values:Dynamic):Void
	{
		_inner=values.inner !=undefined ? values.inner:_inner;
		_knockout=values.knockout !=undefined ? values.knockout:_knockout;
		_quality=values.quality !=undefined ? values.quality:_quality;
		
		values.color=values.color !=undefined ? values.color:_color;
		values.xblur=values.xblur !=undefined ? values.xblur:_xblur;
		values.yblur=values.yblur !=undefined ? values.yblur:_yblur;
		values.alpha=values.alpha !=undefined ? values.alpha:_alpha;
		values.strength=values.strength !=undefined ? values.strength:_strength;
		
		super.values={ r:EffectUtils.getRed(values.color), 
						 g:EffectUtils.getGreen(values.color), 
						 b:EffectUtils.getBlue(values.color), 
						 xblur:values.xblur, 
						 yblur:values.yblur, 
						 alpha:values.alpha, 
						 strength:values.strength };
	}
	
	public function new(target:Dynamic, values:Dynamic, duration:Float, equations:Dynamic, delay:Float=0, loop:Bool=false, type:Int=0xffff)
	{
		super(target, values, duration, equations, delay, loop, type);
	}

	override public function start():Void
	{
		_color=this.color;
		_alpha=this.alpha;
		_xblur=this.xblur;
		_yblur=this.yblur;
		_strength=this.strength;
		
		_r=this.r;
		_g=this.g;
		_b=this.b;

		super.start();	
	}
	
	override public function update(currentTime:Float):Void
	{
		var filters:Array<Dynamic>;
		
		if(tweening && !paused)
		{		
			super.update(currentTime);
		
			filters=_effectTarget.filters;
			filters[ _filterIndex ]=new GlowFilter(EffectUtils.makeRGB(_r, _g, _b), _alpha / 100, _xblur, _yblur, _strength, _quality, _inner, _knockout);
		
			_effectTarget.filters=filters;
		}
	}
}
}

/*!
 * EOF
 */
