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
 * $Id:Tweenable.as 20 2009-08-01 03:26:27Z lschreur $
 * $Date:2009-08-01 13:26:27 +1000(Sat, 01 Aug 2009)$
 */

package org.coretween;

interface Tweenable
{
	function start():Void;
	function stop():Void;
	function pause(... args):Void;
	function resume():Void;
	function rewind():Void;
	function update(currentTime:Float):Void;
}
}

/*!
 * EOF
 */
