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

package org.flintparticles.common.initializers 
{
import org.flintparticles.common.events.ParticleEvent;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import org.flintparticles.common.emitters.Emitter;
import org.flintparticles.common.particles.Particle;	

/**
 * The MouseEventHandlers Initializer sets event handlers to listen for the mouseOver and mouseOut events on each 
 * particle. To use this initializer, you must use a DisplayObjectRenderer, use an InteractiveObject as the image
 * for particle, and set the mouseChildren property of the renderer to true.
 */

class MouseEventHandlers extends InitializerBase
{
	private var _overHandler:Function;
	private var _outHandler:Function;
	private var _upHandler:Function;
	private var _downHandler:Function;
	private var _clickHandler:Function;
	
	/**
	 * The constructor creates a MassInit initializer for use by 
	 * an emitter. To add a MassInit to all particles created by an emitter, use the
	 * emitter's addInitializer method.
	 * 
	 * @param mass the mass for particles
	 * initialized by the instance.
	 * 
	 * @see org.flintparticles.common.emitters.Emitter#addInitializer().
	 */
	public function new()
	{
	}
	
	/**
	 * The mouseOver event handler.
	 */
	public var overHandler(get_overHandler, set_overHandler):Function;
 	private function get_overHandler():Function
	{
		return _overHandler;
	}
	private function set_overHandler(value:Function):Void
	{
		_overHandler=value;
	}
	
	/**
	 * The mouseOut event handler.
	 */
	public var outHandler(get_outHandler, set_outHandler):Function;
 	private function get_outHandler():Function
	{
		return _outHandler;
	}
	private function set_outHandler(value:Function):Void
	{
		_outHandler=value;
	}
	
	/**
	 * The mouseUp event handler.
	 */
	public var upHandler(get_upHandler, set_upHandler):Function;
 	private function get_upHandler():Function
	{
		return _upHandler;
	}
	private function set_upHandler(value:Function):Void
	{
		_upHandler=value;
	}
	
	/**
	 * The mouseDown event handler.
	 */
	public var downHandler(get_downHandler, set_downHandler):Function;
 	private function get_downHandler():Function
	{
		return _downHandler;
	}
	private function set_downHandler(value:Function):Void
	{
		_downHandler=value;
	}
	
	/**
	 * The mouseClick event handler.
	 */
	public var clickHandler(get_clickHandler, set_clickHandler):Function;
 	private function get_clickHandler():Function
	{
		return _clickHandler;
	}
	private function set_clickHandler(value:Function):Void
	{
		_clickHandler=value;
	}
	
	/**
	 * Listens for particles to die and removes the mouse event listeners from them when this occurs.
	 */
	override public function addedToEmitter(emitter:Emitter):Void
	{
		emitter.addEventListener(ParticleEvent.PARTICLE_DEAD, removeListeners, false, 0, true);
	}
	
	/**
	 * Stops listening for particles to die.
	 */
	override public function removedFromEmitter(emitter:Emitter):Void
	{
		emitter.removeEventListener(ParticleEvent.PARTICLE_DEAD, removeListeners);
	}

	private function removeListeners(event:ParticleEvent):Void
	{
		if(event.particle.image is IEventDispatcher)
		{
			var dispatcher:IEventDispatcher=IEventDispatcher(event.particle.image);
			if(_overHandler !=null)
			{
				dispatcher.removeEventListener(MouseEvent.MOUSE_OVER, _overHandler);
			}
			if(_outHandler !=null)
			{
				dispatcher.removeEventListener(MouseEvent.MOUSE_OVER, _outHandler);
			}
			if(_upHandler !=null)
			{
				dispatcher.removeEventListener(MouseEvent.MOUSE_OVER, _upHandler);
			}
			if(_downHandler !=null)
			{
				dispatcher.removeEventListener(MouseEvent.MOUSE_OVER, _downHandler);
			}
			if(_clickHandler !=null)
			{
				dispatcher.removeEventListener(MouseEvent.MOUSE_OVER, _clickHandler);
			}
		}
		
	}
	
	/**
	 * @inheritDoc
	 */
	override public function initialize(emitter:Emitter, particle:Particle):Void
	{
		if(particle.image is IEventDispatcher)
		{
			var dispatcher:IEventDispatcher=IEventDispatcher(particle.image);
			if(_overHandler !=null)
			{
				dispatcher.addEventListener(MouseEvent.MOUSE_OVER, _overHandler, false, 0, true);
			}
			if(_outHandler !=null)
			{
				dispatcher.addEventListener(MouseEvent.MOUSE_OVER, _outHandler, false, 0, true);
			}
			if(_upHandler !=null)
			{
				dispatcher.addEventListener(MouseEvent.MOUSE_OVER, _upHandler, false, 0, true);
			}
			if(_downHandler !=null)
			{
				dispatcher.addEventListener(MouseEvent.MOUSE_OVER, _downHandler, false, 0, true);
			}
			if(_clickHandler !=null)
			{
				dispatcher.addEventListener(MouseEvent.MOUSE_OVER, _clickHandler, false, 0, true);
			}
		}
	}
}