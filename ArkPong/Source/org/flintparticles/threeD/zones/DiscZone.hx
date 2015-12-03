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

package org.flintparticles.threeD.zones 
{
import org.flintparticles.threeD.geom.Point3D;
import org.flintparticles.threeD.geom.Vector3D;
import org.flintparticles.threeD.geom.Vector3DUtils;	

/**
 * The DiscZone zone defines a zone that contains all the points on a disc.
 * The disc can be positioned anywhere in 3D space. The disc may, optionally,
 * have a hole in the middle.
 */

class DiscZone implements Zone3D 
{
	private var _center:Point3D;
	private var _normal:Vector3D;
	private var _innerRadius:Float;
	private var _innerRadiusSq:Float;
	private var _outerRadius:Float;
	private var _outerRadiusSq:Float;
	private var _distToOrigin:Float;
	private var _planeAxis1:Vector3D;
	private var _planeAxis2:Vector3D;
	private var _dirty:Bool;

	private static inline var TWOPI:Float=Math.PI * 2;
	
	/**
	 * The constructor creates a DiscZone 3D zone.
	 * 
	 * @param centre The point at the center of the disc.
	 * @param normal A vector normal to the disc.
	 * @param outerRadius The outer radius of the disc.
	 * @param innerRadius The inner radius of the disc. This defines the hole 
	 * in the center of the disc. If set to zero, there is no hole. 
	 */
	public function new(center:Point3D=null, normal:Vector3D=null, outerRadius:Float=0, innerRadius:Float=0)
	{
		_center=center ? center.clone():new Point3D(0, 0, 0);
		_normal=normal ? normal.unit():new Vector3D(0, 0, 1);
		_innerRadius=innerRadius;
		_innerRadiusSq=_innerRadius * _innerRadius;
		_outerRadius=outerRadius;
		_outerRadiusSq=_outerRadius * _outerRadius;
		_dirty=true;
	}
	
	private function init():Void
	{
		_distToOrigin=_normal.dotProduct(center.toVector3D());
		var axes:Array<Dynamic>=Vector3DUtils.getPerpendiculars(normal);
		_planeAxis1=axes[0];
		_planeAxis2=axes[1];
		_dirty=false;
	}
	
	/**
	 * The point at the center of the disc.
	 */
	public var center(get_center, set_center):Point3D;
 	private function get_center():Point3D
	{
		return _center.clone();
	}
	private function set_center(value:Point3D):Void
	{
		_center=value.clone();
		_dirty=true;
	}

	/**
	 * The vector normal to the disc. When setting the vector, the vector is
	 * normalized. So, when reading the vector this will be a normalized version
	 * of the vector that is set.
	 */
	public var normal(get_normal, set_normal):Vector3D;
 	private function get_normal():Vector3D
	{
		return _normal.clone();
	}
	private function set_normal(value:Vector3D):Void
	{
		_normal=value.unit();
		_dirty=true;
	}

	/**
	 * The inner radius of the disc.
	 */
	public var innerRadius(get_innerRadius, set_innerRadius):Float;
 	private function get_innerRadius():Float
	{
		return _innerRadius;
	}
	private function set_innerRadius(value:Float):Void
	{
		_innerRadius=value;
		_innerRadiusSq=_innerRadius * _innerRadius;
	}

	/**
	 * The outer radius of the disc.
	 */
	public var outerRadius(get_outerRadius, set_outerRadius):Float;
 	private function get_outerRadius():Float
	{
		return _outerRadius;
	}
	private function set_outerRadius(value:Float):Void
	{
		_outerRadius=value;
		_outerRadiusSq=_outerRadius * _outerRadius;
	}

	/**
	 * The contains method determines whether a point is inside the zone.
	 * This method is used by the initializers and actions that
	 * use the zone. Usually, it need not be called directly by the user.
	 * 
	 * @param p The location to test.
	 * @return true if the location is inside the zone, false if it is outside.
	 */
	public function contains(p:Point3D):Bool
	{
		if(_dirty)
		{
			init();
		}
		// is not in plane if dist to origin along normal is different
		var dist:Float=_normal.dotProduct(p.toVector3D());
		if(Math.abs(dist - _distToOrigin)>0.1)// test for close, not exact
		{
			return false;
		}
		// test distance to center
		var distToCenter:Float=center.distance(p);
		if(distToCenter<=_outerRadiusSq && distToCenter>=_innerRadiusSq)
		{
			return true;
		}
		return false;
	}
	
	/**
	 * The getLocation method returns a random point inside the zone.
	 * This method is used by the initializers and actions that
	 * use the zone. Usually, it need not be called directly by the user.
	 * 
	 * @return a random point inside the zone.
	 */
	public function getLocation():Point3D
	{
		if(_dirty)
		{
			init();
		}
		var rand:Float=Math.random();
		var radius:Float=_innerRadius +(1 - rand * rand)*(_outerRadius - _innerRadius);
		var angle:Float=Math.random()* TWOPI;
		return _center.add(_planeAxis1.multiply(radius * Math.cos(angle)).incrementBy(_planeAxis2.multiply(radius * Math.sin(angle))));
	}
	
	/**
	 * The getArea method returns the size of the zone.
	 * This method is used by the MultiZone class. Usually, 
	 * it need not be called directly by the user.
	 * 
	 * @return The surface area of the disc.
	 */
	public function getVolume():Float
	{
		// treat as one pixel tall disc
		return(_outerRadius * _outerRadius - _innerRadius * _innerRadius)* Math.PI;
	}
}