/* 
    From c3-lang.org 
    (https://c3-lang.org/language-fundamentals/naming/)
*/

struct Foo @cname("foo")
{
    int x;
    Bar bar;
}

union Bar
{
    int i;
    double d;
}

enum Baz
{
    VALUE_1,
    VALUE_2
}

int theGlobal = 1;

fn void foo(int x)
{
    Foo foo = getFoo(x);
    theGlobal++;
}

const int A_VALUE = 12;

enum Baz
{
    VALUE_1,
    VALUE_2
}

faultdef OOPS, LOTS_OF_OOPS;

module foo;

fn int anotherFunction()
{
}

macro justDoIt(x)
{
    justDo(x);
}

alias MyInt = int;    // Types use PascalCase
struct SomeStructType
{
    int a_field;      // Members use snake_case
    double foo_baz;
}
int some_global = 1;  // Globals use snake_case
fn void some_function(int a_param) // Functions and parameters use snake_case
{
    int foo_bar = 4;  // Locals use snake_case
}
// Methods use snake_case, and the first parameter is usually called "self"
fn void SomeStructType.call_me(self, int a)
{
    some_function(self.a_field + a);
}
// Macros use snake_case
macro @some_macro(a)
{
    return a + a;
}
const MY_FOO = 123; // Constants use SCREAMING_SNAKE_CASE

fn int allman(int foo)
{
    if (foo > 2)
    {
        foo++;
    }
    else
    {
        foo *= foo;
    }
    return foo;
}

fn int k_and_r(int foo)
{
    if (foo > 2) {
        foo++;
    } else {
        foo *= foo;
    }
    return foo;
}