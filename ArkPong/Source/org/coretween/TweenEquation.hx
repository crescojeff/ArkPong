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
 * $Id:TweenEquation.as 52 2009-08-14 05:26:14Z lschreur $
 * $Date:2009-08-14 15:26:14 +1000(Fri, 14 Aug 2009)$
 */

package org.coretween;

/**
 * Represents the equation used for the tween.
 */
class TweenEquation
{
	public var ease:Function=null;
	public var extra:Dynamic=null;

	public function new(ease:Function, extra:Dynamic=null)
	{
		this.ease=ease;
		this.extra=extra;
	}
}
}

/*!
 * EOF
 */
