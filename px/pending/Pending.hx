package px.pending;
import haxe.macro.ExprTools;
#if macro
import haxe.macro.Expr;
#end
import px.pending.Pending.Resolvable;

typedef Cancelable = { 
	function cancel():Void;
}

/**
 * Very simple future class
 */
class Pending<T>
{
	
	public static function lazy<T>(?response:T):Pending<T>
	{
		return new Resolvable<T>().resolve(response);	
	}
	
	public static function resolvable<T>():Resolvable<T>
	{
		return new Resolvable<T>();
	}
	
	var handler:T->Void = null;
	var response(default, null):T = null;
	
	private function new() 
	{
		
	}
	
	public function handle(handler:T->Void):Pending<T> 
	{
		if (this.handler != null) throw "Handler override!";
		
		this.handler = handler; 
		
		return this;
	}

	
	public function map<A>(mapper:T->A):Pending<A>
	{
		var r = Pending.resolvable(); 
		handle(function (data:T) r.resolve(mapper(data)));
		return r;
	}
	
	public function cancel():Void
	{
		this.handler = null;
		this.response = null;
	}

	//TODO: make it more readable?
	public macro static function of(pendings:Array<ExprOf<Pending<Any>>>):Expr
	{
		
		var count = pendings.length;
		var prefs:Array<Expr> = [for (i in 0...count) macro $i{'p$i'}];
		var pvals:Array<Expr> = [for (i in 0...count) macro @:privateAccess $i{'p$i'}.response];
		
		var block:Array<Expr> = [for (i in 0...count) {
			var name = 'p$i';
			macro var $name = ${pendings[i]};
		}];
		
		block.push(macro {					
			var left = $v{count};					
			{ 
				handle: function (handler):Cancelable {
					
					$b{[
						for (p in prefs) 
							macro $p.handle(function (_) {								
								if (--left == 0) handler($a{pvals});
							})
					]}						
						
					return {
						cancel: function () {
							$b{[for (p in prefs) macro $p.cancel()]}
						}
					};
				}
				
			}
		});
				
		return macro $b{block};
	}
	
}

class Resolvable<T> extends Pending<T>
{	
	var resolvedBeforeHandled:Bool = false;
	var resolved:Bool = false;
	
	private function new()
	{
		super();
	}
	
	public function resolve(?response:T):Pending<T>
	{		
		if (resolved) throw "Resolved twice!";
		
		resolved = true;
		
		this.response = response;
		
		if (handler != null)		
			handler(response);
		else 
			resolvedBeforeHandled = true;
			
		return this;
	}
	
	override public function handle(handler:T->Void):Pending<T> 
	{
		super.handle(handler);
		
		if (resolvedBeforeHandled)		
			if (handler != null)		
				handler(response);		
			
		return this;		
	}
}