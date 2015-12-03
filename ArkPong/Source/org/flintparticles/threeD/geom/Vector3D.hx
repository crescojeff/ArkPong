/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author:Richard Lord
 * Copyright(c)Richard Lord 2008-2010
 * http://flintparticles.org/
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

package org.flintparticles.threeD.geom;

/**
 * Vector3D represents a vector in three-dimensional cartesian 
 * coordinate space.
 */
class Vector3D extends Transformable3D
{
	/**
	 * A zero vector.
	 */
	public static inline var ZERO:Vector3D=new Vector3D(0, 0, 0);
	/**
	 * A unit vector in the direction of the x axis.
	 */
	public static inline var AXISX:Vector3D=new Vector3D(1, 0, 0);
	/**
	 * A unit vector in the direction of the y axis.
	 */
	public static inline var AXISY:Vector3D=new Vector3D(0, 1, 0);
	/**
	 * A unit vector in the direction of the z axis.
	 */
	public static inline var AXISZ:Vector3D=new Vector3D(0, 0, 1);
	
	/**
	 * Constructor
	 *
	 * @param x the x coordinate of the vector
	 * @param y the y coordinate of the vector
	 * @param z the z coordinate of the vector
	 */
	public function new(x:Float=0, y:Float=0, z:Float=0)
	{
		super(x, y, z, 0);
	}
	
	/**
	 * Assigns ArkPongMain coordinates to this vector
	 * 
	 * @param x The ArkPongMain x coordinate
	 * @param y The ArkPongMain y coordinate
	 * @param z The ArkPongMain z coordinate
	 * 
	 * @return a reference to this vector
	 */
	public function reset(x:Float=0, y:Float=0, z:Float=0):Vector3D
	{
		this.x=x;
		this.y=y;
		this.z=z;
		return this;
	}
	
	/**
	 * Copies another vector Into this one.
	 * 
	 * @param v The vector to copy
	 * 
	 * @return a reference to this vector
	 */
	public function assign(v:Vector3D):Vector3D
	{
		x=v.x;
		y=v.y;
		z=v.z;
		return this;
	}

	/**
	 * @inheritDoc
	 */
	override Internal function get classType():Class
	{
		return Vector3D;
	}

	/**
	 * Makes a copy of this vector.
	 * 
	 * @param result The vector to hold the copy of this vector. If
	 * no vector is passed, a ArkPongMain vector is created.
	 * 
	 * @return A copy of this Vector3D
	 */
	public function clone(result:Vector3D=null):Vector3D
	{
		if(result==null)
		{
			result=new Vector3D();
		}
		result.x=x;
		result.y=y;
		result.z=z;
		return result;
	}
	
	/**
	 * Adds another vector to this one, returning the result.
	 * 
	 * @param v the vector to add
	 * @param result The vector to hold the result of the addition. If
	 * no vector is passed, a ArkPongMain vector is created.
	 * 
	 * @return the result of the addition
	 */
	public function add(v:Vector3D, result:Vector3D=null):Vector3D
	{
		if(result==null)
		{
			result=new Vector3D();
		}
		result.x=x + v.x;
		result.y=y + v.y;
		result.z=z + v.z;
		return result;
	}
	
	/**
	 * Subtract another vector from this one, returning the result.
	 * 
	 * @param v The vector to subtract
	 * @param result The vector to hold the result of the subtraction. If
	 * no vector is passed, a ArkPongMain vector is created.
	 * 
	 * @return The result of the subtraction
	 */		
	public function subtract(v:Vector3D, result:Vector3D=null):Vector3D
	{
		if(result==null)
		{
			result=new Vector3D();
		}
		result.x=x - v.x;
		result.y=y - v.y;
		result.z=z - v.z;
		return result;
	}

	/**
	 * Multiply this vector by a number, returning the result.
	 * 
	 * @param s The number to multiply by
	 * @param result The vector to hold the result of the multiplication. If
	 * no vector is passed, a ArkPongMain vector is created.
	 * 
	 * @return The result of the multiplication
	 */
	public function multiply(s:Float, result:Vector3D=null):Vector3D
	{
		if(result==null)
		{
			result=new Vector3D();
		}
		result.x=x * s;
		result.y=y * s;
		result.z=z * s;
		return result;
	}
	
	/**
	 * Divide this vector by a number, returning the result.
	 * 
	 * @param s The number to divide by
	 * @param result The vector to hold the result of the divide. If
	 * no vector is passed, a ArkPongMain vector is created.
	 * 
	 * @return The result of the division
	 */
	public function divide(s:Float, result:Vector3D=null):Vector3D
	{
		if(result==null)
		{
			result=new Vector3D();
		}
		var d:Float=1 / s;
		result.x=x * d;
		result.y=y * d;
		result.z=z * d;
		return result;
	}
	
	/**
	 * Add another vector to this one.
	 * 
	 * @param v The vector to add
	 * 
	 * @return A reference to this vector.
	 */
	public function incrementBy(v:Vector3D):Vector3D
	{
		x +=v.x;
		y +=v.y;
		z +=v.z;
		return this;
	}

	/**
	 * Subtract another vector from this one.
	 * 
	 * @param v The vector to subtract
	 * 
	 * @return A reference to this vector.
	 */
	public function decrementBy(v:Vector3D):Vector3D
	{
		x -=v.x;
		y -=v.y;
		z -=v.z;
		return this;
	}

	/**
	 * Multiply this vector by a number.
	 * 
	 * @param s The number to multiply by
	 * 
	 * @return A reference to this vector.
	 */
	public function scaleBy(s:Float):Vector3D
	{
		x *=s;
		y *=s;
		z *=s;
		return this;
	}
	
	/**
	 * Divide this vector by a number.
	 * 
	 * @param s The number to divide by
	 * 
	 * @return A reference to this vector.
	 */
	public function divideBy(s:Float):Vector3D
	{
		var d:Float=1 / s;
		x *=d;
		y *=d;
		z *=d;
		return this;
	}
	
	/**
	 * Compare this vector to another.
	 * 
	 * @param v The vector to compare with
	 * 
	 * @return true if the vectors have the same coordinates, false otherwise
	 */
	public function equals(v:Vector3D):Bool
	{
		return x==v.x && y==v.y && z==v.z;
	}

	/**
	 * Compare this vector to another.
	 * 
	 * @param v The vector to compare with
	 * @param e The variance allowed between the two vectors
	 * 
	 * @return true if the vectors are within 
	 * variance e of each other, false otherwise
	 */
	public function nearEquals(v:Vector3D, e:Float):Bool
	{
		return this.subtract(v).lengthSquared<=e * e;
	}
	
	/**
	 * Calculate the dot product of this vector with another. 
	 * 
	 * @param v The vector to calculate the dot product with
	 * 
	 * @return The dot product of the two vectors
	 */
	public function dotProduct(v:Vector3D):Float
	{
		return(x * v.x + y * v.y + z * v.z);
	}
	
	/**
	 * Calculate the cross product of this vector with another. 
	 * 
	 * @param v The vector to calculate the cross product with
	 * @param result The vector to hold the result of the cross product. If
	 * no vector is passed, a ArkPongMain vector is created.
	 * 
	 * @return The cross product of the two vectors
	 */
	public function crossProduct(v:Vector3D, result:Vector3D=null):Vector3D
	{
		if(result==null)
		{
			result=new Vector3D();
		}
		result.x=y * v.z - z * v.y;
		result.y=z * v.x - x * v.z;
		result.z=x * v.y - y * v.x;
		return result;
	}
	
	/**
	 * The length of this vector.
	 */
	public var length(get_length, null):Float;
 	private function get_length():Float
	{
		return Math.sqrt(x * x + y * y + z * z);
	}
	
	/**
	 * The square of the length of this vector.
	 */
	public var length(get_length, null):Float;
 	private function get_lengthSquared():Float
	{
		return(x * x + y * y + z * z);
	}
	
	/**
	 * Get the negative of this vector - a vector the same length but in the 
	 * opposite direction. The sign of the x, y and z coordinates is changed.
	 * 
	 * @param result The vector to hold the result of the negation. If
	 * no vector is passed, a ArkPongMain vector is created.
	 * 
	 * @return the negative of this vector
	 */
	public function negative(result:Vector3D=null):Vector3D
	{
		if(result==null)
		{
			result=new Vector3D;
		}
		result.x=-x;
		result.y=-y;
		result.z=-z;
		return result;
	}
	
	/**
	 * Negate this vector. The sign of the x, y, and z coordinates is changed.
	 * 
	 * @return a reference to this vector.
	 */
	public function negate():Vector3D
	{
		x=-x;
		y=-y;
		z=-z;
		return this;
	}
			
	/**
	 * Convert this vector to have length 1.
	 * 
	 * @return A reference to this vector.
	 */
	public function normalize():Vector3D
	{
		var s:Float=this.length;
		if(s !=0)
		{
			s=1 / s;
			x *=s;
			y *=s;
			z *=s;
		}
		else
		{
			throw new Dynamic("Cannot make a unit vector from  the zero vector.");
		}
		return this;
	}
	
	/**
	 * Create a unit vector in the same direction as this one.
	 * 
	 * @param result The vector to hold the unit vector result. If
	 * no vector is passed, a ArkPongMain vector is created.
	 * 
	 * @return A unit vector in the same direction as this one.
	 */
	public function unit(result:Vector3D=null):Vector3D
	{
		if(result==null)
		{
			result=new Vector3D();
		}
		var s:Float=this.length;
		if(s !=0)
		{
			s=1 / s;
			result.x=x * s;
			result.y=y * s;
			result.z=z * s;
		}
		else
		{
			throw new Dynamic("Cannot make a unit vector from  the zero vector.");
		}
		return result;
	}
	
	/**
	 * Get a string representation of this vector
	 * 
	 * @return a string representation of this vector
	 */
	public function toString():String
	{
		return "[Vector3D](x=" + x + ", y=" + y + ", z=" + z + ", w=" + w + ")";
	}
}