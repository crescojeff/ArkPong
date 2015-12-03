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
 * $Id:EffectUtils.as 20 2009-08-01 03:26:27Z lschreur $
 * $Date:2009-08-01 13:26:27 +1000(Sat, 01 Aug 2009)$
 */

package org.coretween.effects;

class EffectUtils
{
	public function new()
	{
	}
	
	public static function getAlpha(color:Int):Int
	{
		return((color & 0xff000000)>>>24);
	}
	
	public static function getRed(color:Int):Int
	{
		return((color & 0xff0000)>>>16);
	}
	
	public static function getGreen(color:Int):Int
	{
		return((color & 0x00ff00)>>>8);
	}
	
	public static function getBlue(color:Int):Int
	{
		return(color & 0x0000ff);
	}
	
	public static function makeRGB(r:Int, g:Int, b:Int):Int
	{
		return((r<<16)|(g<<8)| b);
	}

	public static function makeRGBA(r:Int, g:Int, b:Int, a:Int):Int
	{
		return((r<<24)|(g<<16)|(b<<8)| a);
	}
	
	public static function makeARGB(r:Int, g:Int, b:Int, a:Int):Int
	{
		return((a<<24)|(r<<16)|(g<<8)| b);
	}
}
}

/*!
 * EOF
 */
