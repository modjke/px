package px.macros;
import haxe.macro.Type.AbstractType;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

class AbstractEnumTools {
  public static macro function getValues(typePath:Expr):Expr {
    // Get the type from a given expression converted to string.
    // This will work for identifiers and field access which is what we need,
    // it will also consider local imports. If expression is not a valid type path or type is not found,
    // compiler will give a error here.
    var type = Context.getType(typePath.toString());

    // Switch on the type and check if it's an abstract with @:enum metadata
    switch (type.follow()) {
      case TAbstract(_.get() => ab, _) if (ab.meta.has(":enum")):
        // @:enum abstract values are actually static fields of the abstract implementation class,
        // marked with @:enum and @:impl metadata. We generate an array of expressions that access those fields.
        // Note that this is a bit of implementation detail, so it can change in future Haxe versions, but it's been
        // stable so far.
        var valueExprs = [];
        for (field in ab.impl.get().statics.get()) {
          if (field.meta.has(":enum") && field.meta.has(":impl")) {
            var fieldName = field.name;
            valueExprs.push(macro $typePath.$fieldName);
          }
        }
        // Return collected expressions as an array declaration.
        return macro $a{valueExprs};
      default:
        // The given type is not an abstract, or doesn't have @:enum metadata, show a nice error message.
        throw new Error(type.toString() + " should be @:enum abstract", typePath.pos);
    }
  }
  
  public static macro function validateEnumValue(value:Expr):Expr {
	var type = Context.getExpectedType().follow();

    // Switch on the type and check if it's an abstract with @:enum metadata
    switch (type) {
      case TAbstract(_.get() => ab, _) if (ab.meta.has(":enum")):

        var valueExprs = [];
        for (field in ab.impl.get().statics.get()) {
          if (field.meta.has(":enum") && field.meta.has(":impl")) {
				var expr = switch (field.expr().expr)
				{
					case TCast(_ => { expr: TConst(TString(val)) }, _): macro $v{val};
					case TCast(_ => { expr: TConst(TInt(val)) }, _): macro $v{val };
					case _ => notImplemented: throw "Not implemented for: " + notImplemented;
				};
				

				if (expr != null)
					valueExprs.push(expr);
				
          }
        }

		var absType:AbstractType = switch (type) { case TAbstract(_.get() => type, _): type; default: null; }; 		
		var typePath:TypePath = { pack: absType.pack, name: absType.name };
        return macro 
		{
			if ($value == null) throw "Enum value should not be null";			
			if ($a{valueExprs}.indexOf($value) == -1) throw "Unknown enum value: " + Std.string($value);
			
			$value;
		}
      default:
        // The given type is not an abstract, or doesn't have @:enum metadata, show a nice error message.
        throw new Error(type.toString() + " should be @:enum abstract", Context.currentPos());
    }
  }
  
  
}