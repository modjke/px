package px.macros;
import haxe.macro.Context;
#if macro
import haxe.io.Eof;
import haxe.macro.Expr.ExprOf;

import sys.io.Process;
#end

class Mercurial 
{

	macro public static function currentRevisionHash():ExprOf<String>
	{
		var hg = new Process("hg", ["id", "-i"]);
		var output = "";
		while (true)
			try {
				output += hg.stdout.readLine() + "\n";
			} catch (eof:Eof)
				break;			
				
		var re = ~/([0-9,a-f]+)(\+?)/;
		if (re.match(output))
		{
			var hash = re.matched(1);
			var plus = re.matched(2).length > 0;			
			if (plus)
				Context.warning('Local changes detected, <+> ignored', Context.currentPos());
				
			return macro $v { hash };
		} else 
			throw 'Invalid output: $output';
			
		
	}
	
}