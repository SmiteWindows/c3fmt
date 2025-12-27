module foo;

module some::foo;
fn void test() {}

module bar;
import some;
// import some::foo; <- not needed, as it is a sub module to "some"
fn void test()
{
    foo::test();
    // some::foo::test() also works.
}

module abc;
struct Context
{
    int a;
}

module de;
struct Context
{
    void* ptr;
}

module test1;
import de, abc;
// Context c = {} <- ambiguous
abc::Context c = {};

module foo;

fn void init() { .. }

fn void open() @private { .. }

// File foo.c3
module foo;
fn void abc() @private { }
fn void de() @local { }

// File foo2.c3
module foo;
fn void test()
{
    abc(); // Access of private in the same module is ok
    // de(); <- Error: function is local to foo.c3
}

// File a.c3
module a;

fn void a_function() @private { ... }

// File b.c3
module b;

fn void b_function() @private { ... }

// File c.c3
module c;
import a;
import b @public;

fn void test()
{
    // Error! a_function() is private
    a::a_function();

    // Allowed since `import b @public` allowed `b`
    // to "public" in this context.
    b::b_function();
}

module foo @private;

fn void ab_private() { ... } // Private

module foo;

fn void ab_public() { ... } // Public

module bar;
import foo;

fn void test()
{
    foo::ab_public(); // Works
    // foo::ab_private(); <- Error, private method
}

module foo @private;

fn void ab_private() { ... }        // Private
fn void ab_public() @public { ... } // Public

// File a.c3

module a;

struct Foo { ... }
struct Bar { ... }
struct TheAStruct { ... }

fn void anAFunction() { ... }

// File b.c3

module b;

struct Foo { ... }
struct Bar { ... }
struct TheBStruct { ... }

fn void aBFunction() { ... }

// File c.c3
module c;
import a, b;

struct TheCStruct { ... }
struct Bar { ... }

fn void aCFunction() { ... }

fn void test()
{
    TheAStruct stA;
    TheBStruct stB;
    TheCStruct stC;
    // Name required to avoid ambiguity;
    b::Foo stBFoo;
    // Will always pick the current module's
    // name.
    Bar bar;
    // Namespace required:
    a::aAFunction();
    b::aBFunction();
    // A local symbol does not require it:
    aCFunction();
}

// File foo.c3
module foo;
fn int hello_world()
{
    return my_hello_world();
}

module foo @private;
import std::io;         // The import is only visible in this section.
fn int my_hello_world() // @private by default
{
    io::printn("Hello, world\n");
    return 0;
}

module foo @test;
fn void test_hello() // @test by default
{
    assert(hello_world() == 0);
}

module dynlib;
fn void do_something() @dynamic(4.0)
fn void do_something_else() @dynamic(0, 5.0)
fn void do_another_thing() @dynamic(0, 2.5)

import dynlib;
fn void test()
{
    if (@available(dynlib::do_something))
    {
        dynlib::do_something();
    }
    else
    {
        dynlib::do_someting_else();
    }
}

if (@available(dynlib::do_another_thing))
{
    // Error: This function is not available with 3.0
    dynlib::do_another_thing();
}

module maybe_dynlib;
fn void testme() @dynamic;

import maybe_dynlib;
fn void testme2()
{
    if (@available(maybe_dynlib::testme))
    {
        dynlib::testme();
    }
}

module foo;

$include("Foo.x");

fn void test()
{
    io::printf("%d", testX(2));
}

fn testX(int i)
{
    return i + 1;
}

module foo;

fn testX(int i)
{
    return i + 1;
}

fn void test()
{
    io::printf("%d", testX(2));
}

import std::io;

// On Linux or MacOS this will insert 'String a = "Hello world!";'
$exec("echo", { "String a = \\\"Hello world!\\\"\\;" });

fn void main()
{
  io::printn(a);
}

import std::io;

// Compile foo.c3 and bar.c3 in the /scripts directory, invoke the resulting binary
// with the argument 'test'
$exec("foo.c3;bar.c3", { "test" });

// Non-recursive import
import mylib @norecurse;

// Normal import
import mylib;

module mylib;
import std::io;
fn void only_want_this()
{
    io::printn("only_want_this");
}

module mylib::submod;
import std::io;
fn void undesired_fn()
{
    io::printn("undesired_fn");
}

module my_code;
// Using Non-recursive import undesired_fn not found
import mylib @norecurse;

// Using Recursive import undesired_fn is found
// import mylib;

fn void main()
{
    mylib::only_want_this();
    submod::undesired_fn(); // This should error
}