﻿/*!
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
 * $Id:Effect.as 20 2009-08-01 03:26:27Z lschreur $
 * $Date:2009-08-01 13:26:27 +1000(Sat, 01 Aug 2009)$
 */

package org.coretween.effects;

import org.coretween.Tween;

class Effect extends Tween
{
	public static var QUALITY_LOW:Int=1;
	public static var QUALITY_MEDIUM:Int=2;
	public static var QUALITY_HIGH:Int=3;
	
	private var _effectTarget:Dynamic=null;
	
	override public var target(get_target, null):Dynamic;
 	private function get_target():Dynamic
	{
		return(_effectTarget);
	}
	
	public function new(target:Dynamic, values:Dynamic, duration:Float, equations:Dynamic, delay:Float=0, loop:Bool=false, type:Int=0xffff)
	{
		super(target, values, duration, equations, delay, loop, type);
	}
}
}

/*!
 * EOF
 */
