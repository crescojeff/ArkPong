/**
 * Dynamic Pool V1.1
 * Copyright(c)2008 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files(the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.polygonal.core;

class DynamicPool
{
	private var _factory:DynamicPoolFactory;
	
	private var _initSize:Int;
	private var _currSize:Int;
	private var _usageCount:Int;
	
	private var _grow:Bool=true;
	
	private var _head:ObjNode;
	private var _tail:ObjNode;
	
	private var _emptyNode:ObjNode;
	private var _allocNode:ObjNode;
	
	/**
	 * Creates a ArkPongMain object pool.
	 * 
	 * @param grow If true, the pool grows the first time it becomes empty.
	 */
	public function new(grow:Bool=false)
	{
		_grow=grow;
	}

	/**
	 * Unlock all ressources for the garbage collector.
	 */
	public function deconstruct():Void
	{
		var node:ObjNode=_head;
		var t:ObjNode;
		while(node)
		{
			t=node.next;
			node.next=null;
			node.data=null;
			node=t;
		}
		
		_head=_tail=_emptyNode=_allocNode=null;
	}
	
	/**
	 * The pool size.
	 */

 	private function get_size():Int
	{
		return _currSize;
	}
	
	/**
	 * The total number of 'checked out' objects currently in use.
	 */

 	private function get_usageCount():Int
	{
		return _usageCount;
	}
	
	/**
	 * The total number of unused thus wasted objects. Use the purge()
	 * method to compact the pool.
	 * 
	 * @see #purge
	 */

 	private function get_wasteCount():Int
	{
		return _currSize - _usageCount;	
	}
	
	/**
	 * Get the next available object from the pool or put it back for the
	 * next use. If the pool is empty and resizable, an error is thrown.
	 */

 	private function get_object():Dynamic
	{
		if(_usageCount==_currSize)
		{
			if(_grow)
			{
				_currSize +=_initSize;
				
				var n:ObjNode=_tail;
				var t:ObjNode=_tail;
				
				var node:ObjNode;
				for(i in 0..._initSize)
				{
					node=new ObjNode();
					node.data=_factory.create();
					
					t.next=node;
					t=node;
				}
				
				_tail=t;
				
				_tail.next=_emptyNode=_head;
				_allocNode=n.next;
                var object:Dynamic=_allocNode.data;
				return object;
			}
 				else
				throw new Dynamic("object pool exhausted.");
		}
		else
		{
			var o:Dynamic=_allocNode.data;
			_allocNode.data=null;
			_allocNode=_allocNode.next;
			_usageCount++;
			return o;
		}
	}
	
	/**
	 * @private
	 */
	private function set_object(o:Dynamic):Void
	{
		if(_usageCount>0)
		{
			_usageCount--;
			_emptyNode.data=o;
			_emptyNode=_emptyNode.next;
		}
	}
	
	/**
	 * Define the factory responsible for creating all pool objects.
	 * If you don't want to use a factory, you must provide a class to the
	 * allocate method instead.
	 * 
	 * @see #allocate
	 */
	public function setFactory(factory:DynamicPoolFactory):Void
	{
		_factory=factory;
	}

	/**
	 * Allocate the pool by creating all objects from the factory. 
	 * 
	 * @param size The number of objects to create.
	 * @param C	The class to create for object node in the pool.
	 *			 This overwrites the current factory.
	 */
	public function allocate(size:Int, C:Class=null):Void
	{
		deconstruct();
		
		if(C)
			_factory=new SimpleFactory(C);
		else
			if(!_factory)
				throw new Dynamic("nothing to instantiate.");	
		
		_initSize=_currSize=size;
		
		_head=_tail=new ObjNode();
		_head.data=_factory.create();
		
		var n:ObjNode;
		
		for(i in 1..._initSize)
		{
			n=new ObjNode();
			n.data=_factory.create();
			n.next=_head;
			_head=n;
		}
		
		_emptyNode=_allocNode=_head;
		_tail.next=_head;
	}
	
	/**
	 * Helper method for applying a function to all objects in the pool.
	 * 
	 * @param func The function's name.
	 * @param args The function's arguments.
	 */
	public function initialze(func:String, args:Array):Void
	{
		var n:ObjNode=_head;
		while(n)
		{
			n.data[func].apply(n.data, args);
			if(n==_tail)break;
			n=n.next;	
		}
	}
	
	/**
	 * Remove all unused objects from the pool. If the number of remaining
	 * used objects is smaller than the initial capacity defined by the
	 * allocate()method, ArkPongMain objects are created to refill the pool.
	 */
	public function purge():Void
	{
		var i:Int;
		var node:ObjNode;
		
		if(_usageCount==0)
		{
			if(_currSize==_initSize)
				return;
				
			if(_currSize>_initSize)
			{
				i=0;
				node=_head;
				while(++i<_initSize)
					node=node.next;	
				
				_tail=node;
				_allocNode=_emptyNode=_head;
				
				_currSize=_initSize;
				return;	
			}
		}
		else
		{
			var a:Array<Dynamic>=[];
			node=_head;
			while(node)
			{
				if(!node.data)a[cast(i++,Int)]=node;
				if(node==_tail)break;
				node=node.next;	
			}
			
			_currSize=a.length;
			_usageCount=_currSize;
			
			_head=_tail=a[0];
			for(i in 0..._currSize)
			{
				node=a[i];
				node.next=_head;
				_head=node;
			}
			
			_emptyNode=_allocNode=_head;
			_tail.next=_head;
			
			if(_usageCount<_initSize)
			{
				_currSize=_initSize;
				
				var n:ObjNode=_tail;
				var t:ObjNode=_tail;
				var k:Int=_initSize - _usageCount;
				for(i in 0...k)
				{
					node=new ObjNode();
					node.data=_factory.create();
					
					t.next=node;
					t=node;
				}
				
				_tail=t;
				
				_tail.next=_emptyNode=_head;
				_allocNode=n.next;
				
			}
		}
	}
}

