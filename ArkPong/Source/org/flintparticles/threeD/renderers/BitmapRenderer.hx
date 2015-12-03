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

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import org.flintparticles.common.renderers.SpriteRendererBase;
import org.flintparticles.threeD.geom.Matrix3D;
import org.flintparticles.threeD.geom.Point3D;
import org.flintparticles.threeD.geom.Quaternion;
import org.flintparticles.threeD.geom.Vector3D;
import org.flintparticles.threeD.particles.Particle3D;	

/**
 * The BitmapRenderer is a native Flint 3D renderer that draws particles
 * onto a single Bitmap display object. The particles are drawn face-on to the
 * camera, with perspective applied to position and scale the particles.
 * 
 *<p>The region of the projection plane drawn by this renderer must be 
 * defined in the canvas property of the BitmapRenderer. Particles outside this 
 * region are not drawn.</p>
 * 
 *<p>The image to be used for particle is the particle's image property.
 * This is a DisplayObject, but this DisplayObject is not used directly. Instead
 * it is copied Into the bitmap with the various properties of the particle 
 * applied, including 3D positioning and perspective relative to the renderer's
 * camera position. Consequently each particle may be represented by the same 
 * DisplayObject instance and the SharedImage initializer can be used with this 
 * renderer.</p>
 * 
 *<p>The BitmapRenderer allows the use of BitmapFilters to modify the appearance
 * of the bitmap. Every frame, under normal circumstances, the Bitmap used to
 * display the particles is wiped clean before all the particles are redrawn.
 * However, if one or more filters are added to the renderer, the filters are
 * applied to the bitmap instead of wiping it clean. This enables various trail
 * effects by using blur and other filters.</p>
 * 
 *<p>The BitmapRenderer has mouse events disabled for itself and any 
 * display objects in its display list. To enable mouse events for the renderer
 * or its children set the mouseEnabled or mouseChildren properties to true.</p>
 */
class BitmapRenderer extends SpriteRendererBase
{
	protected static var ZERO_POINT:Point=new Point(0, 0);

	private var toDegrees:Float=180 / Math.PI;
	
	/**
	 * @private
	 */
	private var _zSort:Bool;
	/**
	 * @private
	 */
	private var _camera:Camera;

	/**
	 * @private
	 */
	private var _bitmap:Bitmap;
	
	/**
	 * @private
	 */
	private var _bitmapData:BitmapData;
	/**
	 * @private
	 */
	private var _preFilters:Array<Dynamic>;
	/**
	 * @private
	 */
	private var _postFilters:Array<Dynamic>;
	/**
	 * @private
	 */
	private var _colorMap:Array<Dynamic>;
	/**
	 * @private
	 */
	private var _smoothing:Bool;
	/**
	 * @private
	 */
	private var _canvas:Rectangle;
	/**
	 * @private
	 */
	private var _halfWidth:Float;
	/**
	 * @private
	 */
	private var _halfHeight:Float;

	/**
	 * The constructor creates a BitmapRenderer. After creation it should be
	 * added to the display list of a DisplayObjectContainer to place it on 
	 * the stage.
	 * 
	 *<p>Emitter's should be added to the renderer using the renderer's
	 * addEmitter method. The renderer displays all the particles created
	 * by the emitter's that have been added to it.</p>
	 * 
	 * @param canvas The area within the renderer on which particles can be drawn.
	 * Particles outside this area will not be drawn.
	 * @param zSort Whether to sort the particles according to their
	 * z order when rendering them or not.
	 * @param smoothing Whether to use smoothing when scaling the Bitmap and, if the
	 * particles are represented by bitmaps, when drawing the particles.
	 * Smoothing removes pixelation when images are scaled and rotated, but it
	 * takes longer so it may slow down your particle system.
	 * 
	 * @see org.flintparticles.twoD.emitters.Emitter#renderer
	 */
	public function new(canvas:Rectangle, zSort:Bool=true, smoothing:Bool=false)
	{
		super();
		_zSort=zSort;
		_camera=new Camera();
		mouseEnabled=false;
		mouseChildren=false;
		_smoothing=smoothing;
		_preFilters=new Array();
		_postFilters=new Array();
		_canvas=canvas;
		createBitmap();
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
	 * The addFilter method adds a BitmapFilter to the renderer. These filters
	 * are applied each frame, before or after the ArkPongMain particle positions are
	 * drawn, instead of wiping the display clear. Use of a blur filter, for 
	 * example, will produce a trail behind each particle as the previous images
	 * blur and fade more each frame.
	 * 
	 * @param filter The filter to apply
	 * @param postRender If false, the filter is applied before drawing the particles
	 * in their ArkPongMain positions. If true the filter is applied after drawing the particles.
	 */
	public function addFilter(filter:BitmapFilter, postRender:Bool=false):Void
	{
		if(postRender)
		{
			_postFilters.push(filter);
		}
		else
		{
			_preFilters.push(filter);
		}
	}
	
	/**
	 * Removes a BitmapFilter object from the Renderer.
	 * 
	 * @param filter The BitmapFilter to remove
	 * 
	 * @see addFilter()
	 */
	public function removeFilter(filter:BitmapFilter):Void
	{
		for(i in 0..._preFilters.lengthi)
		{
			if(_preFilters[i]==filter)
			{
				_preFilters.splice(i, 1);
				return;
			}
		}
		for(i=0;i<_postFilters.length;++i)
		{
			if(_postFilters[i]==filter)
			{
				_postFilters.splice(i, 1);
				return;
			}
		}
	}
	
	/**
	 * The array of all filters being applied before rendering.
	 */
	public var preFilters(get_preFilters, set_preFilters):Array;
 	private function get_preFilters():Array
	{
		return _preFilters.slice();
	}
	private function set_preFilters(value:Array):Void
	{
		var filter:BitmapFilter;
		for(filter in _preFilters)
		{
			removeFilter(filter);
		}
		for(filter in value)
		{
			addFilter(filter, false);
		}
	}

	/**
	 * The array of all filters being applied before rendering.
	 */
	public var postFilters(get_postFilters, set_postFilters):Array;
 	private function get_postFilters():Array
	{
		return _postFilters.slice();
	}
	private function set_postFilters(value:Array):Void
	{
		var filter:BitmapFilter;
		for(filter in _postFilters)
		{
			removeFilter(filter);
		}
		for(filter in value)
		{
			addFilter(filter, true);
		}
	}
	
	/**
	 * Sets a palette map for the renderer. See the paletteMap method in flash's BitmapData object for
	 * information about how palette maps work. The palette map will be applied to the full canvas of the 
	 * renderer after all filters have been applied and the particles have been drawn.
	 */
	public function setPaletteMap(red:Array<Dynamic>=null , green:Array<Dynamic>=null , blue:Array<Dynamic>=null, alpha:Array<Dynamic>=null):Void
	{
		_colorMap=new Array(4);
		_colorMap[0]=alpha;
		_colorMap[1]=red;
		_colorMap[2]=green;
		_colorMap[3]=blue;
	}
	/**
	 * Clears any palette map that has been set for the renderer.
	 */
	public function clearPaletteMap():Void
	{
		_colorMap=null;
	}
	
	/**
	 * Create the Bitmap and BitmapData objects
	 */
	private function createBitmap():Void
	{
		if(!_canvas)
		{
			return;
		}
		if(_bitmap && _bitmapData)
		{
			_bitmapData.dispose();
			_bitmapData=null;
		}
		if(_bitmap)
		{
			removeChild(_bitmap);
			_bitmap=null;
		}
		_bitmap=new Bitmap(null, "auto", _smoothing);
		_bitmapData=new BitmapData(Math.ceil(_canvas.width), Math.ceil(_canvas.height), true, 0);
		_bitmap.bitmapData=_bitmapData;
		addChild(_bitmap);
		_bitmap.x=_canvas.x;
		_bitmap.y=_canvas.y;
		_halfWidth=_bitmapData.width * 0.5;
		_halfHeight=_bitmapData.height * 0.5;
	}
	
	/**
	 * The canvas is the area within the renderer on which particles can be drawn.
	 * Particles outside this area will not be drawn.
	 */
	public var canvas(get_canvas, set_canvas):Rectangle;
 	private function get_canvas():Rectangle
	{
		return _canvas;
	}
	private function set_canvas(value:Rectangle):Void
	{
		_canvas=value;
		createBitmap();
	}

	public var smoothing(get_smoothing, set_smoothing):Bool;
 	private function get_smoothing():Bool
	{
		return _smoothing;
	}
	private function set_smoothing(value:Bool):Void
	{
		_smoothing=value;
		if(_bitmap)
		{
			_bitmap.smoothing=value;
		}
	}

	/**
	 * This method draws the particles in the bitmap image, positioning and
	 * scaling them according to their positions relative to the camera 
	 * viewport.
	 * 
	 *<p>This method is called Internally by Flint and shouldn't need to be called
	 * by the user.</p>
	 * 
	 * @param particles The particles to be rendered.
	 */
	override private function renderParticles(particles:Array):Void
	{
		if(!_bitmap)
		{
			return;
		}
		var transform:Matrix3D=_camera.transform;
		var i:Int;
		var len:Int;
		var particle:Particle3D;
		_bitmapData.lock();
		len=_preFilters.length;
		for(i=0;i<len;++i)
		{
			_bitmapData.applyFilter(_bitmapData, _bitmapData.rect, BitmapRenderer.ZERO_POINT, _preFilters[i]);
		}
		if(len==0 && _postFilters.length==0)
		{
			_bitmapData.fillRect(_bitmapData.rect, 0);
		}
		len=particles.length;
		for(i=0;i<len;++i)
		{
			particle=particles[i];
			particle.projectedPosition=transform.transform(particle.position)as Point3D;
			particle.zDepth=particle.projectedPosition.z;
		}
		if(_zSort)
		{
			particles.sort(sortOnZ);
		}
		for(i=0;i<len;++i)
		{
			drawParticle(particles[i]);
		}
		len=_postFilters.length;
		for(i=0;i<len;++i)
		{
			_bitmapData.applyFilter(_bitmapData, _bitmapData.rect, BitmapRenderer.ZERO_POINT, _postFilters[i]);
		}
		if(_colorMap)
		{
			_bitmapData.paletteMap(_bitmapData, _bitmapData.rect, ZERO_POINT, _colorMap[1] , _colorMap[2] , _colorMap[3] , _colorMap[0]);
		}
		_bitmapData.unlock();
	}
	
	/**
	 * @private
	 */
	private function sortOnZ(p1:Particle3D, p2:Particle3D):Int
	{
		return p2.zDepth - p1.zDepth;
	}

	/**
	 * Used Internally here and in derived classes to render a single particle.
	 * Each particle is positioned and perspective scaling applied here.
	 * 
	 *<p>Derived classes can modify the rendering of individual particles
	 * by overriding this method.</p>
	 * 
	 * @param particle The particle to draw on the bitmap.
	 */
	private function drawParticle(particle:Particle3D):Void
	{
		var pos:Point3D=particle.projectedPosition;
		if(pos.z<_camera.nearPlaneDistance || pos.z>_camera.farPlaneDistance)
		{
			return;
		}
		var scale:Float=particle.scale * _camera.projectionDistance / pos.z;
		pos.project();
		
		var rot:Float=0;
		var transform:Matrix3D=_camera.transform;			
		var facing:Vector3D;
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
			rot=Math.atan2(-facing.y, facing.x);
		}

		var matrix:Matrix;
		if(rot)
		{
			var cos:Float=scale * Math.cos(rot);
			var sin:Float=scale * Math.sin(rot);
			matrix=new Matrix(cos, sin, -sin, cos, pos.x + _halfWidth, -pos.y + _halfHeight);
		}
		else
		{
			matrix=new Matrix(scale, 0, 0, scale, pos.x + _halfWidth, -pos.y + _halfHeight);
		}

		_bitmapData.draw(particle.image, matrix, particle.colorTransform, DisplayObject(particle.image).blendMode, null, _smoothing);
	}
	
	/**
	 * The bitmap data of the renderer.
	 */
	public var bitmapData(get_bitmapData, null):BitmapData;
 	private function get_bitmapData():BitmapData
	{
		return _bitmapData;
	}
}