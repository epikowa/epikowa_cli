# Introduction
This library helps you create command line utilities by providing a command line parser and handler.  
It takes inspiration from [tink_cli](https://www.github.com/haxetink/tink_cli) but does not provide prompts nor (currently) use building macros.

## Why re-build with less features?
Simply because I tried adding tink_cli to one of my projects and it started to severely impair building and VS Code integration.  
It may not really have been tink_cli's bad but it felt to me like it was too much overhead for what I needed.

# How to use
Your users invoke your application and specify an action to run.  
You simply write a handler class and mark functions that should serve as action and the one that should serve as the default.
Use `@defaultCommand` and `@command` annotation to do so :

```haxe
class CliManager {
    public function new() {
    }

    @defaultCommand
    public function startServer() {
    }

    @command
    public function addUser() {
    }

    @command
    public function addOrganisation() {
    }
}
```

Once you've done that, call `epikowa.cli.Cli.parse`:

```haxe
class Main {
    static function main() {
        Cli.parse(Sys.args(), new CliManager());
    }
}
```

Your users can then call:

```bash
% yourapp # Runs CliManager.startServer
% yourapp addUser # Run CliManager.addUser
% yourapp addOrganisation # CliManager.addOrganisation
```

## Flags and parameters
By setting a flag on the command line, your user can set a value on your handler before the action is executed.  
For example, if you have the following:

```haxe
class CliManager {
    public function new() {
    }

    @flag
    var username:String;

    @defaultCommand
    public function sayHello() {
        Sys.println('Hello ${username}');
    }
}
```

you user may run:

```sh
% yourapp --username Benjamin
```

and sayHello will be called with username set to `Benjamin`.

___At the moment, only strings are supported for flag's value. They have to be provided. No shorthands or aliases are supported at the moment.___