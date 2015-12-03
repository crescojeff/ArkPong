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

package org.flintparticles.threeD.renderers;

import org.flintparticles.common.particles.Particle;
import org.flintparticles.common.renderers.SpriteRendererBase;
import org.flintparticles.threeD.geom.Matrix3D;
import org.flintparticles.threeD.geom.Point3D;
import org.flintparticles.threeD.geom.Quaternion;
import org.flintparticles.threeD.geom.Vector3D;
import org.flintparticles.threeD.particles.Particle3D;

import flash.display.DisplayObject;	

/**
 * The DisplayObjectRenderer is a native Flint 3D renderer that draws particles
 * as display objects in the renderer. The particles are drawn face-on to the
 * camera, with perspective applied to position and scale the particles.
 * 
 *<p>Particles may be represented by any DisplayObject and each particle 
 * must use a different DisplayObject instance. The DisplayObject
 * to be used should not be defined using the SharedImage initializer
 * because this shares one DisplayObject instance between all the particles.
 * The ImageClass initializer is commonly used because this creates a ArkPongMain
 * DisplayObject for particle.</p>
 * 
 *<p>The DisplayObjectRenderer has mouse events disabled for itself and any 
 * display objects in its display list. To enable mouse events for the renderer
 * or its children set the mouseEnabled or mouseChildren properties to true.</p>
 * 
 *<p>Because the DisplayObject3DRenderer directly uses the particle's image,
 * it is not suitable in situations where the same particle will be displayed 
 * by two different renderers.</p>
 */
class DisplayObjectRenderer extends SpriteRendererBase
{
	/**
	 * @private
	 */
	private var _zSort:Bool;
	/**
	 * @private
	 */
	private var _camera:Camera;
	
	private var toDegrees:Float=180 / Math.PI;

	/**
	 * The constructor creates a DisplayObject3DRenderer. After creation the
	 * renderer should be added to the display list of a DisplayObjectContainer 
	 * to place it on the stage.
	 * 
	 *<p>Emitter's should be added to the renderer using the renderer's
	 * addEmitter method. The renderer displays all the particles created
	 * by the emitter's that have been added to it.</p>
	 * 
	 * @param zSort Whether to sort the particles according to their
	 * z order when rendering them or not.
	 */
	public function new(zSort:Bool=true)
	{
		_zSort=zSort;
		_camera=new Camera();
	}
	
	/**
	 * Indicates whether the particles should be sorted in distance order for display.
	 */
	public var zSort(get_zSort, set_zSort):Bool;
 	private function get_zSort():Bool
	{
		return _zSort;
	}
	private function set_zSort(value:Bool):Void
	{
		_zSort=value;
	}
	
	/**
	 * The camera controls the view for the renderer
	 */
	public var camera(get_camera, set_camera):Camera;
 	private function get_camera():Camera
	{
		return _camera;
	}
	private function set_camera(value:Camera):Void
	{
		_camera=value;
	}
	
	/**
	 * This method positions and scales the particles according to the
	 * particles' positions relative to the camera viewport.
	 * 
	 *<p>This method is called Internally by Flint and shouldn't need to be called
	 * by the user.</p>
	 * 
	 * @param particles The particles to be rendered.
	 */
	override private function renderParticles(particles:Array):Void
	{
		var pos:Point3D=new Point3D();
		var transform:Matrix3D=_camera.transform;
		var particle:Particle3D;
		var img:DisplayObject;
		var len:Int=particles.length;
		var facing:Vector3D;
		for(i in 0...leni)
		{
			particle=particles[i];
			img=particle.image;
			transform.transform(particle.position, pos);
			particle.zDepth=pos.z;
			if(pos.z<_camera.nearPlaneDistance || pos.z>_camera.farPlaneDistance)
			{
				img.visible=false;
			}
			else
			{
				var scale:Float=particle.scale * _camera.projectionDistance / pos.z;
				pos.project();
				img.scaleX=scale;
				img.scaleY=scale;
				img.x=pos.x;
				img.y=-pos.y;
				img.transform.colorTransform=particle.colorTransform;
				img.visible=true;
				if(particle.rotation.equals(Quaternion.IDENTITY))
				{
					facing=particle.faceAxis.clone();
				}
				else
				{
					var m:Matrix3D=particle.rotation.toMatrixTransformation();
					facing=m.transform(particle.faceAxis)as Vector3D;
				}
				transform.transformSelf(facing);
				if(facing.x !=0 || facing.y !=0)
				{
					var angle:Float=Math.atan2(-facing.y, facing.x);
					img.rotation=angle * toDegrees;
				}
			}
		}
		if(_zSort)
		{
			particles.sort(sortOnZ);
			for(i=0;i<len;++i)
			{
				swapChildrenAt(i, getChildIndex(Particle(particles[i]).image));
			}
		}
	}
	
	/**
	 * @private
	 */
	private function sortOnZ(p1:Particle3D, p2:Particle3D):Int
	{
		return p2.zDepth - p1.zDepth;
	}

	/**
	 * This method is called when a particle is added to an emitter -
	 * usually becaus ethe emitter has just created the particle. The
	 * method adds the particle's image to the renderer's display list.
	 * It is called Internally by Flint and need not be called by the user.
	 * 
	 * @param particle The particle being added to the emitter.
	 */
	override private function addParticle(particle:Particle):Void
	{
		var img:DisplayObject=particle.image as DisplayObject;
		addChildAt(img, 0);
		img.visible=false;
	}
	
	/**
	 * This method is called when a particle is removed from an emitter -
	 * usually because the particle is dying. The method removes the 
	 * particle's image from the renderer's display list. It is called 
	 * Internally by Flint and need not be called by the user.
	 * 
	 * @param particle The particle being removed from the emitter.
	 */
	override private function removeParticle(particle:Particle):Void
	{
		removeChild(particle.image);
	}
}