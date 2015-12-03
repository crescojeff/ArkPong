/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * This class is a modified version of Robert Penner's Actionscript 2 easing equations
 * which are available under the following licence from http://www.robertpenner.com/easing/
 * 
 * TERMS OF USE - EASING EQUATIONS
 * 
 * Open source under the BSD License.
 * 
 * Copyright(c)2001 Robert Penner
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice, this list of 
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list 
 * of conditions and the following disclaimer in the documentation and/or other materials 
 * provided with the distribution.
 * Neither the name of the author nor the names of contributors may be used to endorse 
 * or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
 * SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
 * OF SUBSTITUTE GOODS OR SERVICES;LOSS OF USE, DATA, OR PROFITS;OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
 * TORT(INCLUDING NEGLIGENCE OR OTHERWISE)ARISING IN ANY WAY OUT OF THE USE OF THIS 
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 *==================================================
 * 
 * Modifications:
 * 
 * Author:Richard Lord
 * Copyright(c)Richard Lord 2008-2010
 * http://flintparticles.org
 * 
 * 
 * Used in the Flint Particle System which is licenced under the MIT license. As per the
 * original license for Robert Penner's classes, these specific classes are released under 
 * the BSD License.
 */

package org.flintparticles.common.energyEasing;

/**
 * A modified form of Robert Penner's easing equations, optimised for the specific use
 * of calculating the energy over a particle's lifetime.
 * 
 * @see org.flintparticles.common.actions.Age
 */
class Bounce
{
	public static function easeOut(age:Float, lifetime:Float):Float
	{
		if((age /=lifetime)<1 / 2.75)
		{
			return 1 - 7.5625 * age * age;
		}
		else if(age<2 / 2.75)
		{
			return 0.25 - 7.5625 *(age -=(1.5 / 2.75))* age;
		}
		else if(age<2.5 / 2.75)
		{
			return 0.0625 - 7.5625 *(age -=(2.25 / 2.75))* age;
		}
		else
		{
			return 0.015625 - 7.5625 *(age -=(2.625 / 2.75))* age;
		}
	}
	public static function easeIn(age:Float, lifetime:Float):Float
	{
		return 1 - easeOut(lifetime - age, lifetime);
	}
	public static function easeInOut(age:Float, lifetime:Float):Float
	{
		if(age<lifetime * 0.5)
		{
			return easeIn(age * 2, lifetime)* 0.5 + 0.5;
		}
		else
		{
			return easeOut(age * 2 - lifetime, lifetime)* 0.5;
		}
	}
}