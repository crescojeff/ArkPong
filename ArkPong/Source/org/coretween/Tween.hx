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
 * $Id:Tween.as 50 2009-08-11 22:36:21Z lschreur $
 * $Date:2009-08-12 08:36:21 +1000(Wed, 12 Aug 2009)$
 */

package org.coretween;

import flash.events.EventDispatcher;
import flash.utils.getTimer;

import org.coretween.Tweenable;
import org.coretween.TweenEvent;
import org.coretween.TweenValue;
import org.coretween.TweenManager;

/**
 * The Tween class represents a single Tween object. It keeps track 
 * of all timing and state variables necessary to execute a tween.
 */
class Tween extends EventDispatcher implements Tweenable
{
	/**
	 * Use this constant to specify if time based rendering is preferred 
	 * when executing the tween. Time based rendering can increase the 
	 * smoothness factor with which the tween is performed.
	 * 
	 * @see Tween#type
	 */
	public static var TIME:Int=1;
	
	/**
	 * Use this constant to specify if frame based rendering is preferred 
	 * when executing the tween. Frame based rendering can increase performance 
	 *(decrease CPU overhead). Frame based rendering is the default setting 
	 * if no rendering method is specified.
	 * 
	 * @see Tween#type
	 */
	public static var FRAME:Int=2;
	
	/**
	 * @private
	 */
	private var _tweening:Bool=false;
	
	/**
	 * @private
	 */
	private var _paused:Bool=false;
	
	/**
	 * @private
	 */
	private var _target:Dynamic=null;
	
	/**
	 * @private
	 */
	private var _values:/*Array<TweenValue>*/ Array<Dynamic>=null;
	
	/**
	 * @private
	 */
	private var _equations:Dynamic=null;
	
	/**
	 * @private
	 */
	private var _duration:Float=0;
	
	/**
	 * @private
	 */
	private var _delay:Float=0;
	
	/**
	 * @private
	 */
	private var _type:Int=Tween.FRAME;
	
	/**
	 * @private
	 */
	private var _position:Float=0;
	
	/**
	 * @private
	 */
	private var _loop:Bool=false;
	
	/**
	 * _timeStart is the time(in milliseconds)the tween starts.
	 * 
	 * @private
	 */
	private var _timeStart:Float=0;
	
	/**
	 * _timePaused is the time(in milliseconds)the tween was paused.
	 * 
	 * @private
	 */	
	private var _timePaused:Float=0;
	
	/**
	 * _timePrevious is the time(in milliseconds)of the previous update.
	 * 
	 * @private
	 */
	private var _timePrevious:Float=0;
	
	/**
	 * Returns the current tweening state of the Tween. This property is set 
	 * to true when the Tween object is currently tweening. This means that 
	 * when a Tween is in a paused state this property can still return true 
	 * if the tween was not fully completed.
	 * 
	 * @see Tween#paused
	 */
	public var tweening(get_tweening, set_tweening):Bool;
 	private function get_tweening():Bool
	{
		return(this._tweening);
	}
	
	/**
	 * Returns the current paused state of the Tween object. When this property 
	 * is set to true the Tween object is in a paused state. Whenever this property 
	 * is set to true then also the tweening property will be set to true as well.
	 * 
	 * @see Tween#tweening
	 */
	public var paused(get_paused, set_paused):Bool;
 	private function get_paused():Bool
	{
		return(this._paused);
	}

	/**
	 * Returns the percentage that the tween has completed. When a delay is set 
	 * then this time is taken Into account as well. So, imagine a tween with a 
	 * duration of 4 seconds and a delay of 2 seconds then the whole tween takes 
	 * 6 seconds to complete. The position is the percentage of the total time 
	 * spend including the delayed time.
	 */
	public var position(get_position, set_position):Float;
 	private function get_position():Float
	{
		return(this._position<0 ? 0:this._position>100 ? 100:this._position);
	}
	
	/**
	 * Sets or returns the target the Tween object is operating on. The target 
	 * can be any valid Dynamic with a numeric number for the Tween object to operate 
	 * on.
	 */
	public var target(get_target, set_target):Dynamic;
 	private function get_target():Dynamic
	{
		return(this._target);
	}
	
	private function set_target(target:Dynamic):Void
	{
		this._target=target;
	}
	
	/**
	 *<p>Sets or returns the properties to tween and the values to tween to for the 
	 * Tween object to operate on. This value can be set through the Tween class 
	 * constructor or can be set(or changed)after the Tween object has been constructed. 
	 * The general syntax for the values property is:</p>
	 * 
	 *<code>{ [property]:[value] }</code>
	 * 
	 *<p>Where [property] is the property to operate on and [value] is the target value 
	 * that the property will have when to tween process is completed. More than one 
	 * [property]:[value] pair can be supplied. E.g:</p>
	 * 
	 *<code>{ [property]:[value], [property]:[value] }</code>
	 * 
	 *<p>For ArkPongMain values to effectively be set, the values properties of the Tween object
	 * must be assigned. E.g. values that are assigned through an associative array 
	 * technique are not regarded as set values and will not included in the tween process.</p>
	 *
	 * @see Tween#equations 
	 */
	public var values(get_values, set_values):Dynamic;
 	private function get_values():Dynamic
	{
		var v:Dynamic;
		var value:TweenValue;
		
		v=new Dynamic();
		
		for(value in this._values)
		{
			v[ value.prop ]=value.target;
			
		}
		
		return(v);
	}
	
	private function set_values(values:Dynamic):Void
	{
		var s:String;
		
		if(values !=null)
		{
			this._values=new /*Array<TweenValue>()*/ Array();
			
			for(s in values)
			{
				this._values.push(new TweenValue(s, values[ s ]));
			}
			
			this.equations=this._equations;
		}
	}
	
	/**
	 * Sets or returns the duration of the Tween. The duration is always 
	 * specified in seconds. To specify half a second of time use a value 
	 * of 0.5 for one second use 1.0 etc.
	 */
	public var duration(get_duration, set_duration):Float;
 	private function get_duration():Float
	{
		return(this._duration / 1000);
	}
	
	private function set_duration(duration:Float):Void
	{
		this._duration=duration * 1000;
	}
	
	/**
	 *<p>Sets or gets the equations that the Tween object is tweening with. The 
	 * value for this property can be either a reference to a single function, or 
	 * an array specifying a series of equations that match the number of properties 
	 * the Tween object is operating on.</p>
	 *<p>When an array of functions is specified, then the order in which the equations 
	 * are listed must correspond to the order in which the<code>[property]:[value]</code>pairs 
	 * are set with the Tween<code>values</code>property. The following example shows 
	 * the different ways in which the equations property can be set:</p>
	 *<listing version="3.0">
	 * import org.coretween.Tween;
	 * import org.coretween.easing.Expo;
	 * import org.coretween.easing.Elastic;
	 * 
	 * var tween=ArkPongMain Tween(mytarget, { x:10, y:10, z:10 }, 1.5);
	 * 
	 * // All properties are eased with Expo.easeOut.
	 * tween.equations=Expo.easeOut;
	 *
	 * // The x property is eased with Expo.easeOut and y and z with Expo.easeIn. 
	 * tween.equations=[ Expo.easeOut, Expo.easeIn ];
	 * 
	 * // All properties have their own easing. Where the z property has a complex equation assigned.
	 * tween.equations=[ Expo.easeOut, Expo.easeIn, { ease:Back.easeOut, a:0.5, b:1.5 } ];
	 *</listing>
	 * 
	 * @see Tween#values
	 */
	public var equations(null, set_equations):Dynamic;
 	private function set_equations(equations:Dynamic):Void
	{
		var i:Int=0;
		var e:Array<Dynamic>;
		var p:TweenEquation;
		var v:TweenValue;
		
		if(equations !=null)
		{
			this._equations=equations;
			
			e=(Std.is(equations, Array))? equations as Array:[ equations ];
			
			for(v in this._values)
			{
				i=i>e.length - 1 ? e.length - 1:i;
							
				if(e[i] is Function)
				{
					p=new TweenEquation(e[i]);
				}
				else
				{
					p=new TweenEquation(e[i].fn, { a:e[i].a, b:e[i].b });
				}
				
				v.equation=p;
				
				i++;
			}
		}
	}
	
	/**
	 * Sets or gets the delay of a Tween object. Delay is the time to wait before the
	 * actual tweening of an object is started. Delay is always specified in seconds. 
	 * To specify half a second of delay use a value of 0.5 for one second use 1.0 etc.
	 * 
	 * @see Tween#duration
	 */
	public var delay(get_delay, set_delay):Float;
 	private function get_delay():Float
	{
		return(this._delay / 1000);
	}
	
	private function set_delay(delay:Float):Void
	{
		this._delay=delay * 1000;
	}
	
	/**
	 *<p>Sets or returns the rendering method for the tween. There are two distinc 
	 * rendering methods available in CoreTween;</p>
	 *<code>Tween.FRAME</code><br>
	 *<code>Tween.TIME</code>
	 *<p>Frame based rendering(default);When a tween's type is set to frame based 
	 * rendering, a ArkPongMain frame within the tween will be generated with the frames per
	 * second(fps)the main movie is set to. So, if a movie is set to 12 fps then a 
	 * ArkPongMain tween frame will only be generated 12 times a second. Frame based rendering
	 * is the default setting because it is the most native to the Flash Player's behaviour. 
	 * However, keep in mind that the smoothness of a tween is very much depended on the n
	 * umber of frames calculated within a second. The higher the fps the smoother a tween 
	 * will be.</p>
	 *<p>Time based rendering;When a tween's type is set to time based rendering, a ArkPongMain
	 * frame is calculated based on CoreTween's Internal fps rather than the main movie fps 
	 * value. The default Internal fps is set to 60. This means that when using time based 
	 * rendering with the default Internal fps, a ArkPongMain frame is calculated 60 times a second.
	 * Keep in mind that this heavily depends on the CPU the Flash Player is running on and 
	 * the amount of screen area that needs to be updated. However, when using time based 
	 * rendering you might achieve much smoother animations then with frame based rendering 
	 * because time based rendering is completely independent from the global frame rate. 
	 * It's best to use time based rendering for small animations that do not impact the CPU 
	 * a great deal.</p>
	 *
	 * @see Tween#TIME
	 * @see Tween#FRAME
	 */		
	public var type(get_type, set_type):Int;
 	private function get_type():Int
	{
		return(this._type);
	}
	
	private function set_type(type:Int):Void
	{
		this._type=(type==0 ? TweenManager.renderType:type);
	}

	/**
	 * Indicates whether the Tween object loops or not.
	 */
	public var loop(get_loop, set_loop):Bool;
 	private function get_loop():Bool
	{
		return(this._loop);
	}
	
	private function set_loop(loop:Bool):Void
	{
		this._loop=loop;
	}
	
	/**
	 * The Tween constructor creates a ArkPongMain Tween object.
	 * 
	 * @param target The target to operate on. The target can be any instance that exposes
	 * public numeric properties, e.g. a DisplayObject instance.
	 * @see Tween#target
	 * 
	 * @param values An Dynamic that specifies which properties to operate on and to what
	 * target values the tween must tween these properties.
	 * @see Tween#values
	 * 
	 * @param duration A numeric value that specifies the time frame(in seconds)the tween
	 * takes place. The duration is seperate from the delay so the total time a tween is
	 * operative is<code>delay + duration</code>seconds.
	 * @see Tween#duration
	 * 
	 * @param equations This parameter can either be a reference to a function, an array of
	 * function references or an Dynamic specifing a complex equation.
	 * @see Tween#equations
	 * 
	 * @param delay Defines the amount of delay in seconds before the Tween is started.
	 * @see Tween#delay
	 * 
	 * @param loop Indicates whether this Tween is looping or not.
	 * @see Tween#loop
	 * 
	 * @param type Specifies the rendering type for this tween.
	 * @see Tween#type
	 * 
	 */
	public function new(target:Dynamic=null, values:Dynamic=null, duration:Float=0, equations:Dynamic=null, delay:Float=0, loop:Bool=false, type:Int=0)
	{
		this.target=target;
		this.values=values;
		this.duration=duration;
		this.equations=equations;
		this.delay=delay;
		this.loop=loop;
		this.type=type;
	}
	
	/**
	 *<p>Starts a tween. When starting a tween make sure that all necessary properties 
	 * are set. These include the target, properties, values, duration and equations. 
	 * The delay and type properties are optional. When a tween has been stopped before 
	 * it was ended and the start method is used to restart the tween, the tween will 
	 * be reset to begin from its original start position. To pause a tween use the 
	 * pause method instead.</p>
	 *<p>Calling this method will dispatch an START event when the tween is successfully 
	 * started. This method returns true if the tween was successfully started otherwise 
	 * it will return false.</p>
	 * 
	 * @see Tween#stop()
	 */
	public function start():Void
	{
		var v:TweenValue;
		
		//this.stop();
		
		// Set up timers used for updating the tween.
		this._timeStart=getTimer();
		this._timePaused=0;
		this._timePrevious=this._timeStart;
		
		this._position=0;
		
		for(v in this._values)
		{
			v.start=this._target[ v.prop ];
			v.change=v.target - v.start;
		}
					
		// Reset state variables.
		this._tweening=true;
		this._paused=false;
		
		TweenManager.register(this);
		
		dispatchEvent(new TweenEvent(TweenEvent.START, this));
	}
	
	/**
	 * Stops the tween. Stopping the tween doesn't rewind the tween to the start. 
	 * To rewind the tween use the rewind method instead. Calling this method will 
	 * dispatch an STOP event. Returns true when successfully stopped otherwise false.
	 *
	 * @see Tween#start()
	 */
	public function stop():Void
	{
		this._tweening=false;
		
		TweenManager.unregister(this);

		dispatchEvent(new TweenEvent(TweenEvent.STOP, this));
	}
	
	/**
	 * Pauses a tween. If a tween is already paused the tween will resume. Calling 
	 * this method will dispatch an onPause event.
	 * 
	 * @see Tween#resume()
	 */
	public function pause(... args):Void
	{
		this._paused=(args[0]==undefined)? !this._paused:args[0];
		
		dispatchEvent(new TweenEvent(this._paused ? TweenEvent.PAUSE:TweenEvent.RESUME, this));
	}
	
	/**
	 * Resumes a paused tween. The resume method does not affect a none paused tween. 
	 * Calling this method will dispatch an RESUME event.
	 * 
	 * @see Tween#pause()
	 */
	public function resume():Void
	{
		this._paused=false;
		
		dispatchEvent(new TweenEvent(TweenEvent.RESUME, this));
	}
	
	/**
	 * Rewinds a tween to its starting position. The rewind method resets the tween 
	 * to its starting position and leaves the tween in a stopped state. The tween 
	 * can only be started by calling the start method. Calling this method will 
	 * dispatch an REWIND event.
	 *
	 * @see Tween#start()
	 */
	public function rewind():Void
	{
		var v:TweenValue;
		
		for(v in this._values)
		{
			this._target[ v.prop ]=v.start;
		}
		
		update(getTimer());
		
		dispatchEvent(new TweenEvent(TweenEvent.REWIND, this));
	}
	
	/**
	 * Calling the update method will update the visual apearance of the tween. It 
	 * is not necessary to call this method manually since its called by the 
	 * TweenManager that keeps track of the update process. Calling the update method 
	 * will trigger an<code>UPDATE_ENTER</code>event before the tween is updated and an 
	 *<code>UPDATE_LEAVE</code>event after the tween has been updated.
	 * 
	 * @param timeCurrent The current system time in milliseconds.
	 */
	public function update(timeCurrent:Float):Void
	{
		var i:Float;
		var v:TweenValue;
		var e:TweenEquation;
		var x:Dynamic;
		var a:Float=0;
		var b:Float=0;
		var time:Float;

		// State checks. If we're tweening and not paused then do stuff...
		if(this._tweening)
		{
			if(!this._paused)
			{
				// Send an UPDATE_ENTER event to inform any listeners we're about to update
				// the tween.
				if(hasEventListener(TweenEvent.UPDATE_ENTER))
				{
					dispatchEvent(new TweenEvent(TweenEvent.UPDATE_ENTER, this));
				}
				
				// Calculate the current time position within the tween keeping the
				// paused time Into account.
				time=timeCurrent - this._timePaused - this._timeStart;
				
				// Calculate the current position.
				this._position=100 /(this._duration + this._delay)* time;
				
				// When we still haven't passed the set delay time then simply return.
				if(time<this._delay)
				{
					return;
				}
				
				// When we're passed the delay time than adjust the time variable to
				// take delay Into account.
				time -=this._delay;
				
				// If the time spend is greater than the duration of the tween then
				// the tween is done.
				if(time>this._duration)
				{
					for(v in this._values)
					{
						this._target[ v.prop ]=v.target;
					}
					
					if(this._loop)
					{
						// Set up timers used for updating the tween.
						this._timeStart=timeCurrent;
						this._timePaused=0;
						this._timePrevious=this._timeStart;
						
						this._position=0;
		
						rewind();
					}
					else
					{
						dispatchEvent(new TweenEvent(TweenEvent.UPDATE_LEAVE, this));
						
						this.stop();
						
						dispatchEvent(new TweenEvent(TweenEvent.COMPLETE, this));
					}
					
					return;
				}

				// Update all properties to their corresponding values they should be
				// according to their point in time.
				for(v in this._values)
				{
					e=v.equation;
					x=e.extra;

					a=x !=null ? x.a:a;
					b=x !=null ? x.b:b;
					
					this._target[ v.prop ]=e.ease(time, v.start, v.change, this._duration, a, b);
				}

				// Send an UPDATE_LEAVE event to inform any listeners that we just updated
				// the tween.
				if(hasEventListener(TweenEvent.UPDATE_LEAVE))
				{
					dispatchEvent(new TweenEvent(TweenEvent.UPDATE_LEAVE, this));
				}
			}
			else
			{
				// When the tween is paused then keep track of the time spend.
				this._timePaused +=(timeCurrent - this._timePrevious);
			}
			
			this._timePrevious=timeCurrent;
		}
	}
}		
}

/*!
 * EOF;
 */
