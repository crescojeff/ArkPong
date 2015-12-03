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

package org.flintparticles.twoD.zones 
{
import org.flintparticles.twoD.particles.Particle2D;
import org.flintparticles.common.utils.FastWeightedArray<Dynamic>;

import flash.display.BitmapData;
import flash.geom.Point;	

/**
 * The Greyscale zone defines a shaped zone based on a BitmapData object.
 * The zone contains all pixels in the bitmap that are not black, with a weighting
 * such that lighter pixels are more likely to be selected than darker pixels
 * when creating particles inside the zone.
 */

class GreyscaleZone implements Zone2D
{
	private var _bitmapData:BitmapData;
	private var _offsetX:Float;
	private var _offsetY:Float;
	private var _scaleX:Float;
	private var _scaleY:Float;
	private var _validPoints:FastWeightedArray<Dynamic>;
	
	/**
	 * The constructor creates a GreyscaleZone object.
	 * 
	 * @param bitmapData The bitmapData object that defines the zone.
	 * @param offsetX A horizontal offset to apply to the pixels in the BitmapData object 
	 * to reposition the zone
	 * @param offsetY A vertical offset to apply to the pixels in the BitmapData object 
	 * to reposition the zone
	 */
	public function new(bitmapData:BitmapData=null, offsetX:Float=0, offsetY:Float=0, scaleX:Float=1, scaleY:Float=1)
	{
		_bitmapData=bitmapData;
		_offsetX=offsetX;
		_offsetY=offsetY;
		_scaleX=scaleX;
		_scaleY=scaleY;
		invalidate();
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
	 * A horizontal offset to apply to the pixels in the BitmapData object 
	 * to reposition the zone
	 */
	public var offsetX(get_offsetX, set_offsetX):Float;
 	private function get_offsetX():Float
	{
		return _offsetX;
	}
	private function set_offsetX(value:Float):Void
	{
		_offsetX=value;
	}

	/**
	 * A vertical offset to apply to the pixels in the BitmapData object 
	 * to reposition the zone
	 */
	public var offsetY(get_offsetY, set_offsetY):Float;
 	private function get_offsetY():Float
	{
		return _offsetY;
	}
	private function set_offsetY(value:Float):Void
	{
		_offsetY=value;
	}

	/**
	 * A scale factor to stretch the bitmap horizontally
	 */
	public var scaleX(get_scaleX, set_scaleX):Float;
 	private function get_scaleX():Float
	{
		return _scaleX;
	}
	private function set_scaleX(value:Float):Void
	{
		_scaleX=value;
	}

	/**
	 * A scale factor to stretch the bitmap vertically
	 */
	public var scaleY(get_scaleY, set_scaleY):Float;
 	private function get_scaleY():Float
	{
		return _scaleY;
	}
	private function set_scaleY(value:Float):Void
	{
		_scaleY=value;
	}

	/**
	 * This method forces the zone to revaluate itself. It should be called whenever the 
	 * contents of the BitmapData object change. However, it is an Intensive method and 
	 * calling it frequently will likely slow your application down.
	 */
	public function invalidate():Void
	{
		if(! _bitmapData)
		{
			return;
		}
		_validPoints=new FastWeightedArray();
		for(x in 0...bitmapData.widthx)
		{
			for(y in 0...bitmapData.heighty)
			{
				var pixel:Int=_bitmapData.getPixel32(x, y);
				var grey:Float=0.11 *(pixel & 0xFF)+ 0.59 *((pixel>>>8)& 0xFF)+ 0.3 *((pixel>>>16)& 0xFF);
				if(grey !=0)
				{
					_validPoints.add(new Point(x, y), grey / 255);
				}
			}
		}
	}

	/**
	 * The contains method determines whether a point is inside the zone.
	 * 
	 * @param point The location to test for.
	 * @return true if point is inside the zone, false if it is outside.
	 */
	public function contains(x:Float, y:Float):Bool
	{
		if(x>=_offsetX && x<=_offsetX + _bitmapData.width * scaleX
			&& y>=_offsetY && y<=_offsetY + _bitmapData.height * scaleY)
		{
			var pixel:Int=_bitmapData.getPixel32(Math.round((x - _offsetX)/ _scaleX), Math.round((y - _offsetY)/ _scaleY));
			return(pixel & 0xFFFFFF)!=0;
		}
		return false;
	}

	/**
	 * The getLocation method returns a random point inside the zone.
	 * 
	 * @return a random point inside the zone.
	 */
	public function getLocation():Point
	{
		var p:Point=Point(_validPoints.getRandomValue()).clone();
		p.x=p.x * _scaleX + _offsetX;
		p.y=p.y * _scaleY + _offsetY;
		return p;
	}
	
	/**
	 * The getArea method returns the size of the zone.
	 * It's used by the MultiZone class to manage the balancing between the
	 * different zones.
	 * 
	 * @return the size of the zone.
	 */
	public function getArea():Float
	{
		return _validPoints.totalRatios * _scaleX * _scaleY;
	}

	/**
	 * Manages collisions between a particle and the zone. The particle will collide with the edges of
	 * the zone, from the inside or outside. In the Interests of speed, these collisions do not take 
	 * account of the collisionRadius of the particle and they do not calculate an accurate bounce
	 * direction from the shape of the zone. Priority is placed on keeping particles inside 
	 * or outside the zone.
	 * 
	 * @param particle The particle to be tested for collision with the zone.
	 * @param bounce The coefficient of restitution for the collision.
	 * 
	 * @return Whether a collision occured.
	 */
	public function collideParticle(particle:Particle2D, bounce:Float=1):Bool
	{
		if(contains(particle.x, particle.y)!=contains(particle.previousX, particle.previousY))
		{
			particle.x=particle.previousX;
			particle.y=particle.previousY;
			particle.velX=- bounce * particle.velX;
			particle.velY=- bounce * particle.velY;
			return true;
		}
		else
		{
			return false;
		}
	}
}