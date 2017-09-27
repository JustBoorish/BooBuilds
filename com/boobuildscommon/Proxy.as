/**
 * There is no copyright on this code
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 * LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
 * NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * Based on code from org.sitedaniel.utils.Proxy
 */
class com.boobuildscommon.Proxy
{
    public static function create(t:Object, f:Function):Function
    {
        var _args:Array = arguments.slice(2);
        var _func:Function = function(a:Object):Void
        {
			f.apply(t, _args);
        };
        return _func;
    }
	
    public static function createOneArg(t:Object, f:Function):Function
    {
        var _args:Array = arguments.slice(2);
        var _func:Function = function(a:Object):Void
        {
			var tempArgs:Array = [ a ];
			for (var i:Number = 0; i < _args.length; ++i)
			{
				tempArgs.push(_args[i]);
			}
			f.apply(t, tempArgs);
        };
        return _func;
    }
	
    public static function createTwoArgs(t:Object, f:Function):Function
    {
        var _args:Array = arguments.slice(2);
        var _func:Function = function(a:Object, b:Object):Void
        {
			var tempArgs:Array = [ a, b ];
			for (var i:Number = 0; i < _args.length; ++i)
			{
				tempArgs.push(_args[i]);
			}
			f.apply(t, tempArgs);
        };
        return _func;
    }
	
    public static function createThreeArgs(t:Object, f:Function):Function
    {
        var _args:Array = arguments.slice(2);
        var _func:Function = function(a:Object, b:Object, c:Object):Void
        {
			var tempArgs:Array = [ a, b, c ];
			for (var i:Number = 0; i < _args.length; ++i)
			{
				tempArgs.push(_args[i]);
			}
			f.apply(t, tempArgs);
        };
        return _func;
    }
	
    public static function createFourArgs(t:Object, f:Function):Function
    {
        var _args:Array = arguments.slice(2);
        var _func:Function = function(a:Object, b:Object, c:Object, d:Object):Void
        {
			var tempArgs:Array = [ a, b, c, d ];
			for (var i:Number = 0; i < _args.length; ++i)
			{
				tempArgs.push(_args[i]);
			}
			f.apply(t, tempArgs);
        };
        return _func;
    }	
}