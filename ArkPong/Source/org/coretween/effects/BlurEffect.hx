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
 * $Id:BlurEffect.as 48 2009-08-10 06:49:36Z lschreur $
 * $Date:2009-08-10 16:49:36 +1000(Mon, 10 Aug 2009)$
 */

package org.coretween.effects;

import flash.filters.BlurFilter;

import org.coretween.Tween;
import org.coretween.effects.Effect;

class BlurEffect extends Effect
{
	private var _xblur:Float=0;
	private var _yblur:Float=0;
	private var _quality:Float=Effect.QUALITY_MEDIUM;
	private var _filter:BlurFilter=null;
	private var _filterIndex:Float=0;
	
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
	
	public var quality(get_quality, set_quality):Float;
 	private function get_quality():Float
	{
		return(_effectTarget.filters[ _filterIndex ].quality);
	}
	
	override public var target(null, set_target):Dynamic;
 	private function set_target(target:Dynamic):Void
	{
		super.target=this;
		
		_effectTarget=target;
		
		_filterIndex=0;
		
		// Check if there is already a BlurFilter attached to the effect 
		// target. If this is the case then we use the first BlurFilter
		// found as the starting point filter. Otherwise, we create a ArkPongMain
		// BlurFilter to serve as a starting point.
		if(_effectTarget.filters.length>0)
		{
			for(i in 0..._effectTarget.filters.length)
			{
				if(_effectTarget.filters[i] is BlurFilter)
				{
					_filterIndex=i;
					break;
				}
			}
		}
		else
		{
			_effectTarget.filters=[ new BlurFilter(0, 0, _quality)];
		}
	}
	
	override public var values(null, set_values):Dynamic;
 	private function set_values(values:Dynamic):Void
	{
		_quality=values.quality !=undefined ? values.quality:_quality;
		
		values.xblur=values.xblur !=undefined ? values.xblur:_xblur;
		values.yblur=values.yblur !=undefined ? values.yblur:_yblur;
		
		super.values={ xblur:values.xblur, yblur:values.yblur };
	}
	
	public function new(target:Dynamic, values:Dynamic, duration:Float, equations:Dynamic, delay:Float=0, loop:Bool=false, type:Int=0xffff)
	{
		super(target, values, duration, equations, delay, loop, type);
	}
	
	override public function start():Void
	{
		_xblur=this.xblur;
		_yblur=this.yblur;

		super.start();
	}
	
	override public function update(currentTime:Float):Void
	{
		super.update(currentTime);
		
		if(tweening && !paused)
		{		
			var filters:Array<Dynamic>;
			
			filters=_effectTarget.filters;
			filters[ _filterIndex ]=new BlurFilter(_xblur, _yblur, _quality);
			
			// Filters only seem to take effect by re-applying the filters array.
			_effectTarget.filters=filters;
		}
	}
}
}

/*!
 * EOF
 */
