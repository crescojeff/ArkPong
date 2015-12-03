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

package org.flintparticles.common.emitters;

import org.flintparticles.common.actions.Action;
import org.flintparticles.common.activities.Activity;
import org.flintparticles.common.behaviours.BehaviourArrayUtils;
import org.flintparticles.common.counters.Counter;
import org.flintparticles.common.counters.ZeroCounter;
import org.flintparticles.common.events.EmitterEvent;
import org.flintparticles.common.events.ParticleEvent;
import org.flintparticles.common.events.UpdateEvent;
import org.flintparticles.common.initializers.Initializer;
import org.flintparticles.common.particles.Particle;
import org.flintparticles.common.particles.ParticleFactory;
import org.flintparticles.common.utils.FrameUpdater;

import flash.events.EventDispatcher;	

/**
 * Dispatched when a particle dies and is about to be removed from the system.
 * As soon as the event has been handled the particle will be removed but at the
 * time of the event it still exists so its properties(e.g. its location)can be
 * read from it.
 * 
 * @eventType org.flintparticles.common.events.ParticleEvent.PARTICLE_DEAD
 */
//[Event(name="particleDead", type="org.flintparticles.common.events.ParticleEvent")]

/**
 * Dispatched when a particle is created and has just been added to the emitter.
 * 
 * @eventType org.flintparticles.common.events.ParticleEvent.PARTICLE_CREATED
 */
//[Event(name="particleCreated", type="org.flintparticles.common.events.ParticleEvent")]

/**
 * Dispatched when a pre-existing particle is added to the emitter.
 * 
 * @eventType org.flintparticles.common.events.ParticleEvent.PARTICLE_ADDED
 */
//[Event(name="particleAdded", type="org.flintparticles.common.events.ParticleEvent")]

/**
 * Dispatched when an emitter attempts to update the particles' state but it 
 * contains no particles. This event will be dispatched every time the update 
 * occurs and there are no particles in the emitter. The update does not occur
 * when the emitter has not yet been started, when the emitter is paused, and
 * after the emitter has been stopped, so the event will not be dispatched 
 * at these times.
 * 
 *<p>See the firework example for an example that uses this event.</p>
 * 
 * @see start();
 * @see pause();
 * @see stop();
 * 
 * @eventType org.flintparticles.common.events.EmitterEvent.EMITTER_EMPTY
 */
//[Event(name="emitterEmpty", type="org.flintparticles.common.events.EmitterEvent")]

/**
 * Dispatched when the particle system has updated and the state of the particles
 * has changed.
 * 
 * @eventType org.flintparticles.common.events.EmitterEvent.EMITTER_UPDATED
 */
//[Event(name="emitterUpdated", type="org.flintparticles.common.events.EmitterEvent")]

/**
 * Dispatched when the counter for the particle system has finished its cycle and so
 * the system will not emit any more particles unless the counter is changed or restarted.
 * 
 * @eventType org.flintparticles.common.events.EmitterEvent.COUNTER_COMPLETE
 */
//[Event(name="counterComplete", type="org.flintparticles.common.events.EmitterEvent")]

/**
 * The Emitter class is the base class for the Emitter2D and Emitter3D classes.
 * The emitter class contains the common behavioour used by these two concrete
 * classes.
 * 
 *<p>An Emitter manages the creation and ongoing state of particles. It uses 
 * a number of utility classes to customise its behaviour.</p>
 * 
 *<p>An emitter uses Initializers to customise the initial state of particles
 * that it creates;their position, velocity, color etc. These are added to the 
 * emitter using the addInitializer method.</p>
 * 
 *<p>An emitter uses Actions to customise the behaviour of particles that
 * it creates;to apply gravity, drag, fade etc. These are added to the emitter 
 * using the addAction method.</p>
 * 
 *<p>An emitter uses Activities to customise its own behaviour in an ongoing
 * manner, to move it or rotate it for example.</p>
 * 
 *<p>An emitter uses a Counter to know when and how many particles to emit.</p>
 * 
 *<p>All timings in the emitter are based on actual time passed, 
 * independent of the frame rate of the flash movie.</p>
 * 
 *<p>Most functionality is best added to an emitter using Actions,
 * Initializers, Activities and Counters. This offers greater 
 * flexibility to combine behaviours without needing to subclass 
 * the Emitter classes.</p>
 */

class Emitter extends EventDispatcher
{
	/**
	 * @private
	 */
	private var _particleFactory:ParticleFactory;
	
	/**
	 * @private
	 */
	private var _initializers:Array<Dynamic>;
	/**
	 * @private
	 */
	private var _actions:Array<Dynamic>;
	/**
	 * @private
	 */
	private var _activities:Array<Dynamic>;
	/**
	 * @private
	 */
	private var _particles:Array<Dynamic>;
	/**
	 * @private
	 */
	private var _counter:Counter;

	/**
	 * @private
	 */
	private var _useInternalTick:Bool=true;
	/**
	 * @private
	 */
	private var _fixedFrameTime:Float=0;
	/**
	 * @private
	 */
	private var _running:Bool=false;
	/**
	 * @private
	 */
	private var _started:Bool=false;
	/**
	 * @private
	 */
	private var _maximumFrameTime:Float=0.1;
	/**
	 * Indicates if the emitter should dispatch a counterComplete event at the
	 * end of the next update cycle.
	 */
	private var _dispatchCounterComplete:Bool=false;

	/**
	 * The constructor creates an emitter.
	 * 
	 * @param useInternalTick Indicates whether the emitter should use its
	 * own tick event to update its state. The Internal tick process is tied
	 * to the framerate and updates the particle system every frame.
	 */
	public function new()
	{
		_particles=new Array();
		_actions=new Array();
		_initializers=new Array();
		_activities=new Array();
		_counter=new ZeroCounter();
	}

	/**
	 * The maximum duration for a single update frame, in seconds.
	 * 
	 *<p>Under some circumstances related to the Flash player(e.g. on MacOSX, when the 
	 * user right-clicks on the flash movie)the flash movie will freeze for a period. When the
	 * freeze ends, the current frame of the particle system will be calculated as the time since 
	 * the previous frame,  which encompases the duration of the freeze. This could cause the 
	 * system to generate a single frame update that compensates for a long period of time and 
	 * hence moves the particles an unexpected long distance in one go. The result is usually
	 * visually unacceptable and certainly unexpected.</p>
	 * 
	 *<p>This property sets a maximum duration for a frame such that any frames longer than 
	 * this duration are ignored. The default value is 0.5 seconds. Developers don't usually
	 * need to change this from the default value.</p>
	 */
	public var maximumFrameTime(get_maximumFrameTime, set_maximumFrameTime):Float;
 	private function get_maximumFrameTime():Float
	{
		return _maximumFrameTime;
	}
	private function set_maximumFrameTime(value:Float):Void
	{
		_maximumFrameTime=value;
	}
	
	/**
	 * The array of all initializers being used by this emitter.
	 */
	public var initializers(get_initializers, set_initializers):Array;
 	private function get_initializers():Array
	{
		return _initializers;
	}
	private function set_initializers(value:Array):Void
	{
		var initializer:Initializer;
		for(initializer in _initializers)
		{
			initializer.removedFromEmitter(this);
		}
		_initializers=value.slice();
		BehaviourArrayUtils.sortArray(_initializers);
		for(initializer in value)
		{
			initializer.addedToEmitter(this);
		}
	}

	/**
	 * Adds an Initializer object to the Emitter. Initializers set the
	 * initial state of particles created by the emitter.
	 * 
	 * @param initializer The Initializer to add
	 * 
	 * @see removeInitializer()
	 * @see org.flintParticles.common.initializers.Initializer.getDefaultPriority()
	 */
	public function addInitializer(initializer:Initializer):Void
	{
		BehaviourArrayUtils.add(_initializers, initializer);
		initializer.addedToEmitter(this);
	}
	
	/**
	 * Removes an Initializer from the Emitter.
	 * 
	 * @param initializer The Initializer to remove
	 * 
	 * @see addInitializer()
	 */
	public function removeInitializer(initializer:Initializer):Void
	{
		if(BehaviourArrayUtils.remove(_initializers, initializer))
		{
			initializer.removedFromEmitter(this);
		}
	}
	
	/**
	 * Detects if the emitter is using a particular initializer or not.
	 * 
	 * @param initializer The initializer to look for.
	 * 
	 * @return true if the initializer is being used by the emitter, false 
	 * otherwise.
	 */
	public function hasInitializer(initializer:Initializer):Bool
	{
		return BehaviourArrayUtils.contains(_initializers, initializer);
	}
	
	/**
	 * Detects if the emitter is using an initializer of a particular class.
	 * 
	 * @param initializerClass The type of initializer to look for.
	 * 
	 * @return true if the emitter is using an instance of the class as an
	 * initializer, false otherwise.
	 */
	public function hasInitializerOfType(initializerClass:Class):Bool
	{
		return BehaviourArrayUtils.containsType(_initializers, initializerClass);
	}

	/**
	 * The array of all actions being used by this emitter.
	 */
	public var actions(get_actions, set_actions):Array;
 	private function get_actions():Array
	{
		return _actions;
	}
	private function set_actions(value:Array):Void
	{
		var action:Action;
		for(action in _actions)
		{
			action.removedFromEmitter(this);
		}
		_actions=value.slice();
		BehaviourArrayUtils.sortArray(_actions);
		for(action in value)
		{
			action.addedToEmitter(this);
		}
	}

	/**
	 * Adds an Action to the Emitter. Actions set the behaviour of particles 
	 * created by the emitter.
	 * 
	 * @param action The Action to add
	 * 
	 * @see removeAction();
	 * @see org.flintParticles.common.actions.Action.getDefaultPriority()
	 */
	public function addAction(action:Action):Void
	{
		BehaviourArrayUtils.add(_actions, action);
		action.addedToEmitter(this);
	}
	
	/**
	 * Removes an Action from the Emitter.
	 * 
	 * @param action The Action to remove
	 * 
	 * @see addAction()
	 */
	public function removeAction(action:Action):Void
	{
		if(BehaviourArrayUtils.remove(_actions, action))
		{
			action.removedFromEmitter(this);
		}
	}
	
	/**
	 * Detects if the emitter is using a particular action or not.
	 * 
	 * @param action The action to look for.
	 * 
	 * @return true if the action is being used by the emitter, false 
	 * otherwise.
	 */
	public function hasAction(action:Action):Bool
	{
		return BehaviourArrayUtils.contains(_actions, action);
	}
	
	/**
	 * Detects if the emitter is using an action of a particular class.
	 * 
	 * @param actionClass The type of action to look for.
	 * 
	 * @return true if the emitter is using an instance of the class as an
	 * action, false otherwise.
	 */
	public function hasActionOfType(actionClass:Class):Bool
	{
		return BehaviourArrayUtils.containsType(_actions, actionClass);
	}

	/**
	 * The array of all actions being used by this emitter.
	 */
	public var activities(get_activities, set_activities):Array;
 	private function get_activities():Array
	{
		return _activities;
	}
	private function set_activities(value:Array):Void
	{
		var activity:Activity;
		for(activity in _activities)
		{
			activity.removedFromEmitter(this);
		}
		_activities=value.slice();
		BehaviourArrayUtils.sortArray(_activities);
		for(activity in _activities)
		{
			activity.addedToEmitter(this);
		}
	}

	/**
	 * Adds an Activity to the Emitter. Activities set the behaviour
	 * of the Emitter.
	 * 
	 * @param activity The activity to add
	 * 
	 * @see removeActivity()
	 * @see org.flintParticles.common.activities.Activity.getDefaultPriority()
	 */
	public function addActivity(activity:Activity):Void
	{
		BehaviourArrayUtils.add(_activities, activity);
		activity.addedToEmitter(this);
	}
	
	/**
	 * Removes an Activity from the Emitter.
	 * 
	 * @param activity The Activity to remove
	 * 
	 * @see addActivity()
	 */
	public function removeActivity(activity:Activity):Void
	{
		if(BehaviourArrayUtils.remove(_activities, activity))
		{
			activity.removedFromEmitter(this);
		}
	}
	
	/**
	 * Detects if the emitter is using a particular activity or not.
	 * 
	 * @param activity The activity to look for.
	 * 
	 * @return true if the activity is being used by the emitter, false 
	 * otherwise.
	 */
	public function hasActivity(activity:Activity):Bool
	{
		return BehaviourArrayUtils.contains(_activities, activity);
	}
	
	/**
	 * Detects if the emitter is using an activity of a particular class.
	 * 
	 * @param activityClass The type of activity to look for.
	 * 
	 * @return true if the emitter is using an instance of the class as an
	 * activity, false otherwise.
	 */
	public function hasActivityOfType(activityClass:Class):Bool
	{
		return BehaviourArrayUtils.containsType(_activities, activityClass);
	}

	/**
	 * The Counter for the Emitter. The counter defines when and
	 * with what frequency the emitter emits particles.
	 */		
	public var counter(get_counter, set_counter):Counter;
 	private function get_counter():Counter
	{
		return _counter;
	}
	private function set_counter(value:Counter):Void
	{
		_counter=value;
		if(running)
		{
			_counter.startEmitter(this);
		}
	}
	
	/**
	 * Used by counters to tell the emitter to dispatch a counter complete event.
	 */
	public function dispatchCounterComplete():Void
	{
		_dispatchCounterComplete=true;
	}
	
	/**
	 * Indicates whether the emitter should manage its own Internal update
	 * tick. The Internal update tick is tied to the frame rate and updates
	 * the particle system every frame.
	 * 
	 *<p>If users choose not to use the Internal tick, they have to call
	 * the emitter's update method with the appropriate time parameter every
	 * time they want the emitter to update the particle system.</p>
	 */		
	public var useInternalTick(get_useInternalTick, set_useInternalTick):Bool;
 	private function get_useInternalTick():Bool
	{
		return _useInternalTick;
	}
	private function set_useInternalTick(value:Bool):Void
	{
		if(_useInternalTick !=value)
		{
			_useInternalTick=value;
			if(_started)
			{
				if(_useInternalTick)
				{
					FrameUpdater.instance.addEventListener(UpdateEvent.UPDATE, updateEventListener, false, 0, true);
				}
				else
				{
					FrameUpdater.instance.removeEventListener(UpdateEvent.UPDATE, updateEventListener);
				}
			}
		}
	}
	
	/**
	 * Indicates a fixed time(in seconds)to use for every frame. Setting 
	 * this property causes the emitter to bypass its frame timing 
	 * functionality and use the given time for every frame. This enables
	 * the particle system to be frame based rather than time based.
	 * 
	 *<p>To return to time based animation, set this value to zero(the 
	 * default).</p>
	 * 
	 *<p>This feature only works if useInternalTick is true(the default).</p>
	 * 
	 * @see #useInternalTick
	 */		
	public var fixedFrameTime(get_fixedFrameTime, set_fixedFrameTime):Float;
 	private function get_fixedFrameTime():Float
	{
		return _fixedFrameTime;
	}
	private function set_fixedFrameTime(value:Float):Void
	{
		_fixedFrameTime=value;
	}
	
	/**
	 * Indicates if the emitter is currently running.
	 */
	public var running(get_running, set_running):Bool;
 	private function get_running():Bool
	{
		return _running;
	}
	
	/**
	 * This is the particle factory used by the emitter to create and dispose 
	 * of particles. The 2D and 3D libraries each have a default particle
	 * factory that is used by the Emitter2D and Emitter3D classes. Any custom 
	 * particle factory should implement the ParticleFactory Interface.
	 * @see org.flintparticles.common.particles.ParticleFactory
	 */		
	public var particleFactory(get_particleFactory, set_particleFactory):ParticleFactory;
 	private function get_particleFactory():ParticleFactory
	{
		return _particleFactory;
	}
	private function set_particleFactory(value:ParticleFactory):Void
	{
		_particleFactory=value;
	}
	
	/**
	 * The array of all particles created by this emitter.
	 */
	public var particles(get_particles, set_particles):Array;
 	private function get_particles():Array
	{
		return _particles;
	}
	private function set_particles(value:Array):Void
	{
		killAllParticles();
		addExistingParticles(value, false);
	}

	/*
	 * Used Internally to create a particle.
	 */
	private function createParticle():Particle
	{
		var particle:Particle=_particleFactory.createParticle();
		var len:Int=_initializers.length;
		initParticle(particle);
		for(i in 0...leni)
		{
			Initializer(_initializers[i]).initialize(this, particle);
		}
		_particles.push(particle);
		dispatchEvent(new ParticleEvent(ParticleEvent.PARTICLE_CREATED, particle));
		return particle;
	}
	
	/**
	 * Emitters do their own particle initialization here - usually involves 
	 * positioning and rotating the particle to match the position and rotation 
	 * of the emitter. This method is called before any initializers that are
	 * assigned to the emitter, so initializers can override any properties set 
	 * here.
	 * 
	 *<p>The implementation of this method in this base class does nothing.</p>
	 */
	private function initParticle(particle:Particle):Void
	{
	}
	
	/**
	 * Adds existing particles to the emitter. This enables users to create 
	 * particles externally to the emitter and then pass the particles to the
	 * emitter for management.
	 * 
	 * @param particles An array of particles
	 * @param applyInitializers Indicates whether to apply the emitter's
	 * initializer behaviours to the particle(true)or not(false).
	 */
	public function addExistingParticles(particles:Array, applyInitializers:Bool=false):Void
	{
		var len:Int=particles.length;
		var i:Int;
		if(applyInitializers)
		{
			var len2:Int=_initializers.length;
			for(j in 0...len2j)
			{
				for(i=0;i<len;++i)
				{
					Initializer(_initializers[j]).initialize(this, particles[i]);
				}
			}
		}
		for(i=0;i<len;++i)
		{
			_particles.push(particles[i]);
			dispatchEvent(new ParticleEvent(ParticleEvent.PARTICLE_ADDED, particles[i]));
		}
	}

	public function killAllParticles():Void
	{
		var len:Int=_particles.length;
		for(i in 0...leni)
		{
			dispatchEvent(new ParticleEvent(ParticleEvent.PARTICLE_DEAD, _particles[i]));
			_particleFactory.disposeParticle(_particles[i]);
		}
		_particles.length=0;
	}
	
	/**
	 * Starts the emitter. Until start is called, the emitter will not emit or 
	 * update any particles.
	 */
	public function start():Void
	{
		if(_useInternalTick)
		{
			FrameUpdater.instance.addEventListener(UpdateEvent.UPDATE, updateEventListener, false, 0, true);
		}
		_started=true;
		_running=true;
		var len:Int=_activities.length;
		for(i in 0...leni)
		{
			Activity(_activities[i]).initialize(this);
		}
		len=_counter.startEmitter(this);
		for(i=0;i<len;++i)
		{
			createParticle();
		}
	}
	
	/**
	 * Update event listener used to fire the update function when using teh Internal tick.
	 */
	private function updateEventListener(ev:UpdateEvent):Void
	{
		if(_fixedFrameTime)
		{
			update(_fixedFrameTime);
		}
		else
		{
			update(ev.time);
		}
	}
	
	/**
	 * Used to update the emitter. If using the Internal tick, this method
	 * will be called every frame without any action by the user. If not
	 * using the Internal tick, the user should call this method on a regular
	 * basis to update the particle system.
	 * 
	 *<p>The method asks the counter how many particles to create then creates 
	 * those particles. Then it calls sortParticles, applies the activities to 
	 * the emitter, applies the Actions to all the particles, removes all dead 
	 * particles, and finally dispatches an emitterUpdated event which tells 
	 * any renderers to redraw the particles.</p>
	 * 
	 * @param time The duration, in seconds, to be applied in the update step.
	 * 
	 * @see sortParticles();
	 */
	public function update(time:Float):Void
	{
		if(!_running)
		{
			return;
		}
		if(time>_maximumFrameTime)
		{
			time=_maximumFrameTime;
		}
		var i:Int;
		var particle:Particle;
		var len:Int=_counter.updateEmitter(this, time);
		for(i=0;i<len;++i)
		{
			createParticle();
		}
		sortParticles();
		len=_activities.length;
		for(i=0;i<len;++i)
		{
			Activity(_activities[i]).update(this, time);
		}
		if(_particles.length>0)
		{
			
			// update particle state
			len=_actions.length;
			var action:Action;
			var len2:Int=_particles.length;
			
			for(j in 0...lenj)
			{
				action=_actions[j];
				for(i=0;i<len2;++i)
				{
					particle=_particles[i];
					action.update(this, particle, time);
				}
			}
			// remove dead particles
			for(i=len2;i--;)
			{
				particle=_particles[i];
				if(particle.isDead)
				{
					_particles.splice(i, 1);
					dispatchEvent(new ParticleEvent(ParticleEvent.PARTICLE_DEAD, particle));
					if(particle.isDead)
					{
						_particleFactory.disposeParticle(particle);
					}
				}
			}
		}
		else 
		{
			dispatchEvent(new EmitterEvent(EmitterEvent.EMITTER_EMPTY));
		}
		dispatchEvent(new EmitterEvent(EmitterEvent.EMITTER_UPDATED));
		if(_dispatchCounterComplete)
		{
			_dispatchCounterComplete=false;
			dispatchEvent(new EmitterEvent(EmitterEvent.COUNTER_COMPLETE));
		}
	}
	
	/**
	 * Used to sort the particles as required. In this base class this method 
	 * does nothing.
	 */
	private function sortParticles():Void
	{
	}
	
	/**
	 * Pauses the emitter.
	 */
	public function pause():Void
	{
		_running=false;
	}
	
	/**
	 * Resumes the emitter after a pause.
	 */
	public function resume():Void
	{
		_running=true;
	}
	
	/**
	 * Stops the emitter, killing all current particles and returning them to the 
	 * particle factory for reuse.
	 */
	public function stop():Void
	{
		if(_useInternalTick)
		{
			FrameUpdater.instance.removeEventListener(UpdateEvent.UPDATE, updateEventListener);
		}
		_started=false;
		_running=false;
		killAllParticles();
	}
	
	/**
	 * Makes the emitter skip forwards a period of time with a single update.
	 * Used when you want the emitter to look like it's been running for a while.
	 * 
	 * @param time The time, in seconds, to skip ahead.
	 * @param frameRate The frame rate for calculating the ArkPongMain positions. The
	 * emitter will calculate each frame over the time period to get the ArkPongMain state
	 * for the emitter and its particles. A higher frameRate will be more
	 * accurate but will take longer to calculate.
	 */
	public function runAhead(time:Float, frameRate:Float=10):Void
	{
		var maxTime:Float=_maximumFrameTime;
		var step:Float=1 / frameRate;
		_maximumFrameTime=step;
		while(time>0)
		{
			time -=step;
			update(step);
		}
		_maximumFrameTime=maxTime;
	}
}