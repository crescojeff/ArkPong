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
import org.flintparticles.common.utils.FastWeightedArray<Dynamic>;
import org.flintparticles.threeD.geom.Matrix3D;
import org.flintparticles.threeD.geom.Point3D;
import org.flintparticles.threeD.geom.Vector3D;

import flash.display.BitmapData;
import flash.geom.Point;	

/**
 * The BitmapData zone defines a shaped zone based on a BitmapData object.
 * The zone contains all pixels in the bitmap that are not transparent -
 * i.e. they have an alpha value greater than zero.
 */

class BitmapDataZone implements Zone3D 
{
	private var _bitmapData:BitmapData;
	private var _corner:Point3D;
	private var _cornerVector:Vector3D;
	private var _top:Vector3D;
	private var _scaledWidth:Vector3D;
	private var _left:Vector3D;
	private var _scaledHeight:Vector3D;
	private var _normal:Vector3D;
	private var _basis:Matrix3D;
	private var _distToOrigin:Float;
	private var _dirty:Bool;
	private var _volume:Float;
	private var _validPoints:FastWeightedArray<Dynamic>;
	
	/**
	 * The constructor creates a BitmapDataZone zone. To avoid distorting the zone, the top
	 * and left vectors should be perpendicular and the same lengths as the width and
	 * height of the bitmap data object. Vectors that are not the same width and height
	 * as the bitmap data object will scale the zone and vectors that are not perpendicular
	 * will skew the zone.
	 * 
	 * @param bitmapData The bitmapData object that defines the zone.
	 * @param corner The position for the top left corner of the bitmap data for the zone.
	 * @param top The top side of the zone from the corner. The length of the vector 
	 * indicates how long the side is.
	 * @param left The left side of the zone from the corner. The length of the
	 * vector indicates how long the side is.
	 */
	public function new(bitmapData:BitmapData=null, corner:Point3D=null, top:Vector3D=null, left:Vector3D=null)
	{
		_bitmapData=bitmapData;
		_corner=corner ? corner.clone():new Point3D(0, 0, 0);
		_cornerVector=_corner.toVector3D();
		_top=top ? top.clone():new Vector3D(1, 0, 0);
		_left=left ? left.clone():new Vector3D(0, -1, 0);
		if(_bitmapData)
		{
			_dirty=true;
			invalidate();
		}
	}
	
	/**
	 * The bitmapData object that defines the zone.
	 */
	public var bitmapData(get_bitmapData, set_bitmapData):BitmapData;
 	private function get_bitmapData():BitmapData
	{
		return _bitmapData;
	}
	private function set_bitmapData(value:BitmapData):Void
	{
		_bitmapData=value;
		invalidate();
	}

	/**
	 * The position for the top left corner of the bitmap data for the zone.
	 */
	public var corner(get_corner, set_corner):Point3D;
 	private function get_corner():Point3D
	{
		return _corner.clone();
	}

	private function set_corner(value:Point3D):Void
	{
		_corner=value.clone();
		_cornerVector=value.toVector3D();
	}

	/**
	 * The top side of the zone from the corner. The length of the vector 
	 * indicates how long the side is.
	 */
	public var top(get_top, set_top):Vector3D;
 	private function get_top():Vector3D
	{
		return _top.clone();
	}

	private function set_top(value:Vector3D):Void
	{
		_top=value;
		_dirty=true;
	}

	/**
	 * The left side of the zone from the corner. The length of the
	 * vector indicates how long the side is.
	 */
	public var left(get_left, set_left):Vector3D;
 	private function get_left():Vector3D
	{
		return _left.clone();
	}

	private function set_left(value:Vector3D):Void
	{
		_left=value;
		_dirty=true;
	}

	/**
	 * This method forces the zone to revaluate itself. It should be called whenever the 
	 * contents of the BitmapData object change. However, it is an Intensive method and 
	 * calling it frequently will likely slow your code down.
	 */
	public function invalidate():Void
	{
		_validPoints=new FastWeightedArray();
		_volume=0;
		for(x in 0..._bitmapData.widthx)
		{
			for(y in 0..._bitmapData.heighty)
			{
				var pixel:Int=_bitmapData.getPixel32(x, y);
				var ratio:Float=(pixel>>24 & 0xFF)/ 0xFF;
				if(ratio !=0)
				{
					_validPoints.add(new Point(x, _bitmapData.height-y), ratio);
				}
			}
		}
		_volume=_top.crossProduct(_left).length * _validPoints.totalRatios /(_bitmapData.width * _bitmapData.height);
		_dirty=true;
	}

	private function init():Void
	{
		_normal=_top.crossProduct(_left);
		_distToOrigin=_normal.dotProduct(_cornerVector);
		_scaledWidth=_top.multiply(1 / _bitmapData.width);
		_scaledHeight=_left.multiply(1 / _bitmapData.height);
		_basis=Matrix3D.newBasisTransform(_scaledWidth, _scaledHeight, _top.crossProduct(_left).normalize());
		_basis.prependTranslate(-_corner.x, -_corner.y, -_corner.z);
		_dirty=false;
	}

	/**
	 * The contains method determines whether a point is inside the zone.
	 * This method is used by the initializers and actions that
	 * use the zone. Usually, it need not be called directly by the user.
	 * 
	 * @param x The x coordinate of the location to test for.
	 * @param y The y coordinate of the location to test for.
	 * @return true if point is inside the zone, false if it is outside.
	 */
	public function contains(p:Point3D):Bool
	{
		if(_dirty)
		{
			init();
		}
		var dist:Float=_normal.dotProduct(p.toVector3D());
		if(Math.abs(dist - _distToOrigin)>0.1)// test for close, not exact
		{
			return false;
		}
		var q:Point3D=p.clone();
		_basis.transformSelf(q);
		
		var pixel:Int=_bitmapData.getPixel32(Math.round(q.x), Math.round(_bitmapData.height-q.y));
		return(pixel>>24 & 0xFF)!=0;
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
		var point:Point=Point(_validPoints.getRandomValue()).clone();
		return _corner.add(_scaledWidth.multiply(point.x).incrementBy(_scaledHeight.multiply(point.y)));
	}
	
	/**
	 * The getVolume method returns the size of the zone.
	 * This method is used by the MultiZone class. Usually, 
	 * it need not be called directly by the user.
	 * 
	 * @return a random point inside the zone.
	 */
	public function getVolume():Float
	{
		return _volume;
	}
}