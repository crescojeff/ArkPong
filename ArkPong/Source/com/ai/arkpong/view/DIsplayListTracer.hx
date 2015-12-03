/*---------------------------------------------------------------------------------------------

[AS3] traceDL
=======================================================================================

Copyright(c)2009 Tomek 'Og2t' Augustyn

e	tomek@blog2t.net
w	http://play.blog2t.net

Please retain this info when redistributed.

VERSION HISTORY:
v0.1	30/4/2009	Initial concept
v0.2	1/5/2009	Added more params, filter and depth

USAGE:

// displays the whole display list of any displayObject 
traceDL(displayObject);

// displays all displayObjects matching "filterString"
traceDL(displayObject, "filterString");

// displays the display list of any displayObject up to the given depth
traceDL(displayObject, depth);

---------------------------------------------------------------------------------------------*/

package com.ai.arkpong.view;

import openfl.utils.Object;
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;

class DisplayListTracer {

public function traceDL(container:DisplayObjectContainer, options:Dynamic=undefined, indentString:String="", depth:Int=0, childAt:Int=0):Void
{
	if(Type.typeof(options)=="undefined")options=Math.POSITIVE_INFINITY;
	
	if(depth>options)return;

	var INDENT:String="   ";
	var i:Int=container.numChildren;

	while(i--)
	{
		var child:DisplayObject=container.getChildAt(i);
		var output:String=indentString +(childAt++)+ ":" + child.name + " âž” " + child;

		// debug alpha/visible properties
		output +="\t\talpha:" + child.alpha.toFixed(2)+ "/" + child.visible;

		// debug x and y position
		output +=", @:(" + child.x + ", " + child.y + ")";

		// debug transform properties
		output +=", w:" + child.width + "px(" + child.scaleX.toFixed(2)+ ")";
		output +=", h:" + child.height + "px(" + child.scaleY.toFixed(2)+ ")";
		output +=", r:" + child.rotation.toFixed(1)+ "Â°";

		if(Type.typeof(options)=="number")trace(output);
			else if(Type.typeof(options)=="string" && output.match(new EReg(options, "gi")).length !=0)
			{
				trace(output, "in", container.name, "âž”", container);
			}

		if(Std.is(child, DisplayObjectContainer))traceDL(DisplayObjectContainer(child), options, indentString + INDENT, depth + 1);
	}
}
}