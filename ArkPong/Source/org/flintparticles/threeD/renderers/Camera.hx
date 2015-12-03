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

package org.flintparticles.threeD.renderers 
{
import org.flintparticles.threeD.geom.Matrix3D;
import org.flintparticles.threeD.geom.Point3D;
import org.flintparticles.threeD.geom.Vector3D;
import org.flintparticles.threeD.renderers.controllers.CameraController;	

/**
 * The camera class is used by Flint's Internal 3D renderers to manage the view on the 3D
 * world that is displayed by the renderer. Each renderer has a camera property, which is
 * its camera object.
 */
class Camera 
{
	private var _projectionDistance:Float=400;
	private var _nearDistance:Float=10;
	private var _farDistance:Float=2000;

	private var _transform:Matrix3D;
	private var _spaceTransform:Matrix3D;
	
	private var _position:Point3D;
	private var _up:Vector3D;
	private var _target:Point3D;
	
	private var _controller:CameraController;
	
	/*
	 * These properties have private getters because they can be
	 * invalidated when other properties are set - the getter
	 * recalculates the value if it has been invalidated
	 */
	private var _pDirection:Vector3D;
	private var _pTrack:Vector3D;
	private var _pFront:Vector3D;
	
	/**
	 * The constructor creates a Camera object. Usually, users don't need to create camera
	 * objects, but will use the camera objects that are properties of Flint's renderers.
	 */
	public function new()
	{
		_position=new Point3D(0, 0, 0);
		_target=new Point3D(0, 0, 0);
		_up=new Vector3D(0, 1 , 0);
		_pDirection=new Vector3D(0, 0, 1);
	}

	/**
	 * The point that the camera looks at. Setting this will
	 * invalidate any setting for the camera direction - the direction
	 * will be recalculated based on the position and the target.
	 * 
	 * @see #direction
	 */
	public var target(get_target, set_target):Point3D;
 	private function get_target():Point3D
	{
		return _target.clone();
	}
	private function set_target(value:Point3D):Void
	{
		_target=value.clone();
		_pDirection=null;
		_pTrack=null;
		_spaceTransform=null;
	}
	
	/**
	 * The location of the camera.
	 */
	public var position(get_position, set_position):Point3D;
 	private function get_position():Point3D
	{
		return _position.clone();
	}
	private function set_position(value:Point3D):Void
	{
		_position=value.clone();
		_spaceTransform=null;
		if(_target)
		{
			_pDirection=null;
			_pTrack=null;
		}
	}
	
	/**
	 * The direction the camera is pointing. Setting this will invalidate any
	 * setting for the target, since the camera now points in this direction
	 * rather than pointing towards the target.
	 * 
	 * @see #target
	 */
	public var direction(get_direction, set_direction):Vector3D;
 	private function get_direction():Vector3D
	{
		return _direction.clone();
	}
	private function set_direction(value:Vector3D):Void
	{
		_pDirection=value.unit();
		_target=null;
		_spaceTransform=null;
		_pTrack=null;
	}
	
	/**
	 * The up direction for the camera. Is this is not perpendicular to the direction, the camera
	 * is tilted down or up from this up direction to point in the direction or at the target.
	 */
	public var up(get_up, set_up):Vector3D;
 	private function get_up():Vector3D
	{
		return _up.clone();
	}
	private function set_up(value:Vector3D):Void
	{
		_up=value.unit();
		_spaceTransform=null;
		_pTrack=null;
	}
	
	/**
	 * The transform matrix that converts positions in world space to positions in camera space.
	 * The projection transform is part of this transform - so vectors need only to have their
	 * project method called to get their position in 2D camera space.
	 * 
	 * @see org.flintparticles.threeD.geom.Vector3D#project()
	 */
	public var transform(get_transform, set_transform):Matrix3D;
 	private function get_transform():Matrix3D
	{
		if(!_spaceTransform || !_transform)
		{
			_transform=spaceTransform.clone();
			var projectionTransform:Matrix3D=new Matrix3D([
				_projectionDistance, 0, 0, 0,
				0, _projectionDistance, 0, 0,
				0, 0, 1, 0,
				0, 0, 1, 0
			]);
			_transform.append(projectionTransform);
		}
		return _transform;
	}

	/**
	 * The transform matrix that converts positions in world space to positions in camera space.
	 * The projection transform is not part of this transform.
	 * 
	 * @see org.flintparticles.threeD.geom.Vector3D#project()
	 */
	public var spaceTransform(get_spaceTransform, set_spaceTransform):Matrix3D;
 	private function get_spaceTransform():Matrix3D
	{
		if(!_spaceTransform)
		{
			var realUp:Vector3D=_direction.crossProduct(_track);
			_spaceTransform=Matrix3D.newBasisTransform(_track.unit(), realUp.unit(), _direction.unit());
			_spaceTransform.prependTranslate(-_position.x, -_position.y, -_position.z);
		}
		return _spaceTransform;
	}
			
	/**
	 * Dolly or Track the camera in/out in the direction it's facing.
	 * 
	 * @param distance The distance to move the camera. Positive values track in and
	 * negative values track out.
	 */
	public function dolly(distance:Float):Void
	{
		_position.incrementBy(_direction.multiply(distance));
		_spaceTransform=null;
	}
	
	/**
	 * Raise or lower the camera.
	 * 
	 * @param distance The distance to lift the camera. Positive values raise the camera
	 * and negative values lower the camera.
	 */
	public function lift(distance:Float):Void
	{
		_position.incrementBy(_up.multiply(distance));
		_spaceTransform=null;
	}
	
	/**
	 * Dolly or Track the camera left/right.
	 * 
	 * @param distance The distance to move the camera. Positive values move the camera to the
	 * right, negative values move it to the left.
	 */
	public function track(distance:Float):Void
	{
		_position.incrementBy(_track.multiply(distance));
		_spaceTransform=null;
	}
	
	/**
	 * Tilt the camera up or down.
	 * 
	 * @param The angle(in radians)to tilt the camera. Positive values tilt up,
	 * negative values tilt down.
	 */
	public function tilt(angle:Float):Void
	{
		var m:Matrix3D=Matrix3D.newRotate(angle, _track);
		m.transformSelf(_direction);
		_spaceTransform=null;
		_target=null;
	}
	
	/**
	 * Pan the camera left or right.
	 * 
	 * @param The angle(in radians)to pan the camera. Positive values pan right,
	 * negative values pan left.
	 */
	public function pan(angle:Float):Void
	{
		var m:Matrix3D=Matrix3D.newRotate(angle, _up);
		m.transformSelf(_direction);
		_pTrack=null;
		_spaceTransform=null;
		_target=null;
	}

	/**
	 * Roll the camera clockwise or counter-clockwise.
	 * 
	 * @param The angle(in radians)to roll the camera. Positive values roll clockwise,
	 * negative values roll counter-clockwise.
	 */
	public function roll(angle:Float):Void
	{
		var m:Matrix3D=Matrix3D.newRotate(angle, _front);
		m.transformSelf(_up);
		_pTrack=null;
		_spaceTransform=null;
	}
	
	/**
	 * Orbit the camera around the target.
	 * 
	 * @param The angle(in radians)to orbit the camera. Positive values orbit to the right,
	 * negative values orbit to the left.
	 */
	public function orbit(angle:Float):Void
	{
		if(!_target)
		{
			throw new Dynamic("Attempting to orbit camera when no target is set");
		}
		var m:Matrix3D=Matrix3D.newRotate(-angle, up);
		m.transformSelf(_position);
		_pDirection=null;
		_pTrack=null;
		_spaceTransform=null;
	}
	 
	/**
	 * The distance to the camera's near plane
	 * - particles closer than this are not rendered.
	 * 
	 * The default value is 10.
	 */
	public var nearPlaneDistance(get_nearPlaneDistance, set_nearPlaneDistance):Float;
 	private function get_nearPlaneDistance():Float
	{
		return _nearDistance;
	}
	private function set_nearPlaneDistance(value:Float):Void
	{
		_nearDistance=value;
	}
	
	/**
	 * The distance to the camera's far plane
	 * - particles farther away than this are not rendered.
	 * 
	 * The default value is 2000.
	 */
	public var farPlaneDistance(get_farPlaneDistance, set_farPlaneDistance):Float;
 	private function get_farPlaneDistance():Float
	{
		return _farDistance;
	}
	private function set_farPlaneDistance(value:Float):Void
	{
		_farDistance=value;
	}
	
	/**
	 * The distance to the camera's projection distance. Particles this
	 * distance from the camera are rendered at their normal size. Perspective
	 * will cause closer particles to appear larger than normal and more 
	 * distant particles to appear smaller than normal.
	 * 
	 * The default value is 400.
	 */
	public var projectionDistance(get_projectionDistance, set_projectionDistance):Float;
 	private function get_projectionDistance():Float
	{
		return _projectionDistance;
	}
	private function set_projectionDistance(value:Float):Void
	{
		_projectionDistance=value;
		_transform=null;
	}
	
	/*
	 * private getters for properties that can be invaliadated.
	 */
	private var _track(get__track, set__track):Vector3D;
 	private function get__track():Vector3D
	{
		if(_pTrack==null)
		{
			_pTrack=_up.crossProduct(_direction);
		}
		_pFront==null;
		return _pTrack;
	}

	private var _front(get__front, set__front):Vector3D;
 	private function get__front():Vector3D
	{
		if(_pFront==null)
		{
			_pFront=_track.crossProduct(_up);
		}
		return _pFront;
	}
	
	private var _direction(get__direction, set__direction):Vector3D;
 	private function get__direction():Vector3D
	{
		if(_pDirection==null && _target)
		{
			_pDirection=_position.vectorTo(_target).normalize();
		}
		return _pDirection;
	}
	
	public var controller(get_controller, set_controller):CameraController;
 	private function get_controller():CameraController
	{
		return _controller;
	}
	private function set_controller(value:CameraController):Void
	{
		if(_controller)
		{
			_controller.camera=null;
		}
		_controller=value;
		_controller.camera=this;
	}
}