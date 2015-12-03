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

package org.flintparticles.twoD.renderers.mxml;

import org.flintparticles.common.renderers.FlexRendererBase;
import org.flintparticles.twoD.particles.Particle2D;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.filters.BitmapFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;	

/**
 * The BitmapRenderer draws particles onto a single Bitmap display object. The
 * region of the particle system covered by this bitmap object must is defined
 * by the width and height of the renderer. Particles outside this region
 * are not drawn.
 * 
 *<p>The image to be used for particle is the particle's image property.
 * This is a DisplayObject, but this DisplayObject is not used directly. Instead
 * it is copied Into the bitmap with the various properties of the particle 
 * applied. Consequently each particle may be represented by the same 
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
 * 
 *<p>This version of the BitmapRenderer is a UIComponent and is Intended for
 * use in MXML documents.</p>
 */
class BitmapRenderer extends FlexRendererBase
{
	protected static var ZERO_POINT:Point=new Point(0, 0);
	
	/**
	 * @private
	 */
	private var _bitmap:Bitmap;
	
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
	private var _clearBetweenFrames:Bool;
	
	private var _canvasChanged:Bool=true;
	
	/**
	 * The constructor creates a BitmapRenderer. After creation it should be
	 * added to the display list of a DisplayObjectContainer to place it on 
	 * the stage and should be applied to an Emitter using the Emitter's
	 * renderer property.
	 * 
	 * @param canvas The area within the renderer on which particles can be drawn.
	 * Particles outside this area will not be drawn.
	 * @param smoothing Whether to use smoothing when scaling the Bitmap and, if the
	 * particles are represented by bitmaps, when drawing the particles.
	 * Smoothing removes pixelation when images are scaled and rotated, but it
	 * takes longer so it may slow down your particle system.
	 * 
	 * @see org.flintparticles.twoD.emitters.Emitter#renderer
	 */
	public function new(canvas:Rectangle=null, smoothing:Bool=false)
	{
		super();
		mouseEnabled=false;
		mouseChildren=false;
		_smoothing=smoothing;
		_clearBetweenFrames=true;
		_preFilters=new Array();
		_postFilters=new Array();
		if(canvas==null)
		{
			_canvas=new Rectangle(0, 0, 0, 0);
		}
		else
		{
			_canvas=canvas;
		}
		createBitmap();
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
	 * Controls whether the display is cleared between each render frame.
	 * If you use pre-render filters, this value is ignored and the display is
	 * not cleared. If you use no filters or only post-render filters, this value 
	 * governs whether the screen is cleared.
	 * 
	 *<p>For BitmapRenderer and PixelRenderer, this value defaults to true.
	 * For BitmapLineRenderer it defaults to false.</p>
	 */
	public var clearBetweenFrames(get_clearBetweenFrames, set_clearBetweenFrames):Bool;
 	private function get_clearBetweenFrames():Bool
	{
		return _clearBetweenFrames;
	}
	private function set_clearBetweenFrames(value:Bool):Void
	{
		_clearBetweenFrames=value;
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
		if(!_canvas || _canvas.width==0 || _canvas.height==0)
		{
			return;
		}
		_bitmap=new Bitmap(null, "auto", _smoothing);
		_bitmapData=new BitmapData(Math.ceil(_canvas.width), Math.ceil(_canvas.height), true, 0);
		_bitmap.bitmapData=_bitmapData;
		addChild(_bitmap);
		_bitmap.x=_canvas.x;
		_bitmap.y=_canvas.y;
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
		_canvasChanged=true;
		invalidateDisplayList();
	}
	
	public var canvas(get_canvas, set_canvas):Rectangle;
 	private function get_canvasX():Float
	{
		return _canvas.x;
	}
	private function set_canvasX(value:Float):Void
	{
		_canvas.x=value;
		_canvasChanged=true;
		invalidateDisplayList();
	}
	public var canvas(get_canvas, set_canvas):Rectangle;
 	private function get_canvasY():Float
	{
		return _canvas.y;
	}
	private function set_canvasY(value:Float):Void
	{
		_canvas.y=value;
		_canvasChanged=true;
		invalidateDisplayList();
	}
	override public var width(null, set_width):Float;
 	private function set_width(value:Float):Void
	{
		super.width=value;
		_canvas.width=value;
		_canvasChanged=true;
		invalidateDisplayList();
	}
	override public var height(null, set_height):Float;
 	private function set_height(value:Float):Void
	{
		super.height=value;
		_canvas.height=value;
		_canvasChanged=true;
		invalidateDisplayList();
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
	 * @inheritDoc
	 */
	override private function renderParticles(particles:Array):Void
	{
		if(!_bitmap)
		{
			return;
		}
		var i:Int;
		var len:Int;
		_bitmapData.lock();
		len=_preFilters.length;
		for(i=0;i<len;++i)
		{
			_bitmapData.applyFilter(_bitmapData, _bitmapData.rect, BitmapRenderer.ZERO_POINT, _preFilters[i]);
		}
		if(_clearBetweenFrames && len==0)
		{
			_bitmapData.fillRect(_bitmap.bitmapData.rect, 0);
		}
		len=particles.length;
		if(len)
		{
			for(i=len;i--;)// draw ArkPongMain particles first so they are behind old particles
			{
				drawParticle(particles[i]);
			}
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
	 * Used Internally here and in derived classes to alter the manner of 
	 * the particle rendering.
	 * 
	 * @param particle The particle to draw on the bitmap.
	 */
	private function drawParticle(particle:Particle2D):Void
	{
		var matrix:Matrix;
		matrix=particle.matrixTransform;
		matrix.translate(-_canvas.x, -_canvas.y);
		_bitmapData.draw(particle.image, matrix, particle.colorTransform, DisplayObject(particle.image).blendMode, null, _smoothing);
	}
	
	/**
	 * The bitmap data of the renderer.
	 */
	public var bitmapData(get_bitmapData, set_bitmapData):BitmapData;
 	private function get_bitmapData():BitmapData
	{
		return _bitmapData;
	}

	override private function updateDisplayList(unscaledWidth:Float, unscaledHeight:Float):Void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		if(_canvasChanged)
		{
			createBitmap();
		}
	}

}