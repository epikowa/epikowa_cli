package epikowa.cli;

import haxe.macro.PositionTools;
import haxe.macro.Expr.Position;
import haxe.rtti.Meta;

typedef Error = haxe.macro.Expr.Error;
/**
    This class offers CLI tools such as command-line parsing & terminal based UIs
**/
@:nullSafety(Strict)
class Cli {
    static var noOp:Void->Void = () -> {
    };

    /**
        Parses a command and runs associated functions.
    **/
    public static function parse(params:Array<String>, cliHandler:Any) {
        var action:Null<String> = null;
        var params = Lambda.array(params);
        
        var handlerClass = getHandlerClass(cliHandler);
        while (params.length > 0) {
            var param = params.shift();
            if (param == null) {
                throw new Error( 'Param can\'t be null', PositionTools.here());
            }
            if (param.indexOf('-') == 0) {
                handleFlag(param, params, cliHandler);
            } else {
                if (action != null) {
                    throw new Error('Only one action should be provided', PositionTools.here());
                }

                action = param;
            }
        }
        var meta = Meta.getFields(handlerClass);
        trace(meta);
        if (action == null) {
            action = findDefaultCommand(meta);
        }

        if (action == null) {
            throw new Error('No action provided and no default command set', PositionTools.here());
        }

        if (cliHandler == null) {
            throw new Error('cliHandler must not be null', PositionTools.here());
        }

        if (!(Reflect.hasField(meta, action) && (Reflect.hasField(Reflect.field(meta, action), 'command') || Reflect.hasField(Reflect.field(meta, action), 'defaultCommand')))) {
            throw new Error('this action does not exist', PositionTools.here());
        }

        Reflect.callMethod(cliHandler, Reflect.field(cliHandler, action ?? '') ?? noOp, []);
    }

    static function getFlags(meta:Dynamic<Dynamic<Array<Dynamic>>>) {
        var flags:Array<String> = [];
        for (fieldName in Reflect.fields(meta)) {
            var field = Reflect.field(meta, fieldName);
            if (Reflect.hasField(field, 'flag')) {
                flags.push(fieldName);
            }
        }

        return flags;
    }

    static function handleFlag(param:String, params:Array<String>, cliHandler:Any) {
        if (param.indexOf('--') == 0) {
            trace('--field ${param}');
            var paramName = param.substr(2);
            trace(paramName);
            Reflect.setProperty(cliHandler, paramName, params.shift());
        } else if (param.indexOf('-') == 0) {
            trace('-field ${param}');
            throw new Error('shorthand params are not supported yet', PositionTools.here());
        } else {
            trace('field ${param}');
            throw new Error('param has an unexpected value', PositionTools.here());
        }
    }

    static function getHandlerClass(cliHandler:Any) {
        var handlerClass:Null<Class<Any>> = Type.getClass(cliHandler ?? new Cli());
        if (handlerClass == null || handlerClass == Cli) {
            throw new Error('cliHandler has to be an instance of a class', PositionTools.here());
        }

        return handlerClass;
    }

    static function findDefaultCommand(meta:Dynamic<Dynamic<Array<Dynamic>>>):Null<String> {
        for (fieldName in Reflect.fields(meta)) {
            var field = Reflect.field(meta, fieldName);
            if (Reflect.hasField(field, 'defaultCommand')) {
                return fieldName;
            }
        }

        return null;
    }

    public function new() {}
}