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
 * The Steady counter causes the emitter to emit particles continuously
 * at a steady rate. It can be used to simulate any continuous particle
 * stream.
 */
class Steady implements Counter
{
	private var _timeToNext:Float;
	private var _rate:Float;
	private var _rateInv:Float;
	private var _stop:Bool;
	
	/**
	 * The constructor creates a Steady counter for use by an emitter. To
	 * add a Steady counter to an emitter use the emitter's counter property.
	 * 
	 * @param rate The number of particles to emit per second.
	 * 
	 * @see org.flintparticles.common.emitter.Emitter.counter
	 */
	public function new(rate:Float=0)
	{
		_stop=false;
		this.rate=rate;
	}
	
	/**
	 * Stops the emitter from emitting particles
	 */
	public function stop():Void
	{
		_stop=true;
	}
	
	/**
	 * Resumes the emitter emitting particles after a stop
	 */
	public function resume():Void
	{
		_stop=false;
	}
	
	/**
	 * The number of particles to emit per second.
	 */
	public var rate(get_rate, set_rate):Float;
 	private function get_rate():Float
	{
		return _rate;
	}
	private function set_rate(value:Float):Void
	{
		if(!value || value<0)
		{
			value=0;
		}
		if(_rate !=value)
		{
			if(_rate && value)
			{
				var timePassed:Float=_rateInv - _timeToNext;
				_rate=value;
				_rateInv=value ? 1 / value:Float.MAX_VALUE;
				_timeToNext=Math.max(_rateInv - timePassed, 0);
			}
			else
			{
				_rate=value;
				_rateInv=value ? 1 / value:Float.MAX_VALUE;
				_timeToNext=_rateInv;
			}
		}
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
		_timeToNext=_rateInv;
		return 0;
	}
	
	/**
	 * Uses the time, rateMin and rateMax to calculate how many
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
			++count;
			_timeToNext +=_rateInv;
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