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
 * The Sine counter causes the emitter to emit particles continuously
 * at a rate that varies according to a sine wave.
 */
class SineCounter implements Counter
{
	private var _emitted:Float;
	private var _rateMin:Float;
	private var _rateMax:Float;
	private var _period:Float;
	private var _stop:Bool;
	private var _timePassed:Float;
	private var _factor:Float;
	private var _scale:Float;
	
	/**
	 * The constructor creates a SineCounter counter for use by an emitter. To
	 * add a SineCounter counter to an emitter use the emitter's counter property.
	 * 
	 * @period The period of the sine wave used, in seconds.
	 * @param rateMax The number of particles emitted per second at the peak of
	 * the sine wave.
	 * @param rateMin The number of particles to emit per second at the bottom
	 * of the sine wave.
	 * 
	 * @see org.flintparticles.common.emitter.Emitter.counter
	 */
	public function new(period:Float=1, rateMax:Float=0, rateMin:Float=0)
	{
		_stop=false;
		_period=period;
		_rateMin=rateMin;
		_rateMax=rateMax;
		_factor=2 * Math.PI / period;
		_scale=0.5 *(_rateMax - _rateMin);
	}
	
	/**
	 * Stops the emitter from emitting particles
	 */
	public function stop():Void
	{
		_stop=true;
	}
	
	/**
	 * Resumes the emitting of particles after a stop
	 */
	public function resume():Void
	{
		_stop=false;
		_emitted=0;
	}
	
	/**
	 * The number of particles to emit per second at the bottom
	 * of the sine wave.
	 */
	public var rateMin(get_rateMin, set_rateMin):Float;
 	private function get_rateMin():Float
	{
		return _rateMin;
	}
	private function set_rateMin(value:Float):Void
	{
		_rateMin=value;
		_scale=0.5 *(_rateMax - _rateMin);
	}
	
	/**
	 * The number of particles emitted per second at the peak of
	 * the sine wave.
	 */
	public var rateMax(get_rateMax, set_rateMax):Float;
 	private function get_rateMax():Float
	{
		return _rateMax;
	}
	private function set_rateMax(value:Float):Void
	{
		_rateMax=value;
		_scale=0.5 *(_rateMax - _rateMin);
	}
	
	/**
	 * The period of the sine wave used, in seconds.
	 */
	public var period(get_period, set_period):Float;
 	private function get_period():Float
	{
		return _period;
	}
	private function set_period(value:Float):Void
	{
		_period=value;
		_factor=2 * Math.PI / _period;
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
		_timePassed=0;
		_emitted=0;
		return 0;
	}
	
	/**
	 * Uses the time, period, rateMin and rateMax to calculate how many
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
		_timePassed +=time;
		var count:Int=Math.floor(_rateMax * _timePassed + _scale *(1 - Math.cos(_timePassed * _factor))/ _factor);
		var ret:Int=count - _emitted;
		_emitted=count;
		return ret;
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