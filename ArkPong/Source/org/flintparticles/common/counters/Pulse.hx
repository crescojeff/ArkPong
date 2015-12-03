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

package org.flintparticles.common.counters;

import org.flintparticles.common.emitters.Emitter;		

/**
 * The Pulse counter causes the emitter to emit groups of particles at a regular
 * Interval.
 */
class Pulse implements Counter
{
	private var _timeToNext:Float;
	private var _period:Float;
	private var _quantity:Float;
	private var _stop:Bool;
	
	/**
	 * The constructor creates a Pulse counter for use by an emitter. To
	 * add a Pulse counter to an emitter use the emitter's counter property.
	 * 
	 * @param period The time, in seconds, between each pulse.
	 * @param quantity The number of particles to emit at each pulse.
	 * 
	 * @see org.flintparticles.common.emitter.Emitter.counter
	 */
	public function new(period:Float=1, quantity:Int=0)
	{
		_stop=false;
		_quantity=quantity;
		_period=period;
	}
	
	/**
	 * Stops the emitter from emitting particles
	 */
	public function stop():Void
	{
		_stop=true;
	}
	
	/**
	 * Resumes the emitter after a stop
	 */
	public function resume():Void
	{
		_stop=false;
	}
	
	/**
	 * The time, in seconds, between each pulse.
	 */
	public var period(get_period, set_period):Float;
 	private function get_period():Float
	{
		return _period;
	}
	private function set_period(value:Float):Void
	{
		_period=value;
	}
	
	/**
	 * The number of particles to emit at each pulse.
	 */
	public var quantity(get_quantity, set_quantity):Int;
 	private function get_quantity():Int
	{
		return _quantity;
	}
	private function set_quantity(value:Int):Void
	{
		_quantity=value;
	}
	
	/**
	 * Initilizes the counter. Returns 0 to indicate that the emitter should 
	 * emit no particles when it starts.
	 * 
	 *<p>This method is called within the emitter's start method 
	 * and need not be called by the user.</p>
	 * 
	 * @param emitter The emitter.
	 * @return 0
	 * 
	 * @see org.flintparticles.common.counters.Counter#startEmitter()
	 */
	public function startEmitter(emitter:Emitter):Int
	{
		_timeToNext=_period;
		return _quantity;
	}
	
	/**
	 * Uses the time, period and quantity to calculate how many
	 * particles the emitter should emit now.
	 * 
	 *<p>This method is called within the emitter's update loop and need not
	 * be called by the user.</p>
	 * 
	 * @param emitter The emitter.
	 * @param time The time, in seconds, since the previous call to this method.
	 * @return the number of particles the emitter should create.
	 * 
	 * @see org.flintparticles.common.counters.Counter#updateEmitter()
	 */
	public function updateEmitter(emitter:Emitter, time:Float):Int
	{
		if(_stop)
		{
			return 0;
		}
		var count:Int=0;
		_timeToNext -=time;
		while(_timeToNext<=0)
		{
			count +=_quantity;
			_timeToNext +=_period;
		}
		return count;
	}

	/**
	 * Indicates if the counter has emitted all its particles. For this counter
	 * this will always be false.
	 */
	public var complete(get_complete, null):Bool;
 	private function get_complete():Bool
	{
		return false;
	}
}