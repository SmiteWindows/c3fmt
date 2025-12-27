fn void test(int times)
{
    for (int i = 0; i < times; i++)
    {
        io::printfn("Hello %d", i);
    }
}

fn int test_with_default(int foo = 1)
{
    return foo;
}

fn void test()
{
    test_with_default();
    test_with_default(100);
}

fn void test_named(int times, double data)
{
    for (int i = 0; i < times; i++)
    {
        io::printf("Hello %d\n", i + data);
    }
}

fn void test()
{
    // Named only
    test_named(times: 1, data: 3.0);

    // Unnamed only
    test_named(3, 4.0);

    // Mixing named and unnamed
    test_named(15, data: 3.141592);
}

fn void test_named_default(int times = 1, double data = 3.0, bool dummy = false)
{
    for (int i = 0; i < times; i++)
    {
        io::printfn("Hello %f", i + data);
    }
}

fn void test()
{
    // Named only
    test_named_default(times: 10, data: 3.5);

    // Unnamed and named
    test_named_default(3, dummy: false);

    // Overwriting an unnamed argument with a named argument is an error:
    // test_named_default(2, times: 3); ERROR!

    // Unnamed may not follow named arguments.
    // test_named_default(times: 3, 4.0); ERROR!
}

fn void va_singletyped(int... args)
{
    /* args has type int[] */
}

fn void va_variants_explicit(any... args)
{
    /* args has type any[] */
}

fn void va_variants_implicit(args...)
{
    /* args has type any[] */
}

extern fn void va_untyped(...); // only used for extern C functions

fn void test()
{
    va_singletyped(1, 2, 3);

    int x = 1;
    any v = &x;
    va_variants_explicit(&&1, &x, v); // pass references for non-any arguments

    va_variants_implicit(1, x, "foo"); // arguments are implicitly converted to anys

    va_untyped(1, x, "foo"); // extern C-function
}

fn void test_splat()
{
   int[] x = { 1, 2, 3 };
   va_singletyped(...x);
}

fn void va_singletyped(int... args) {
    io::printfn("%s", args);
}
fn void main()
{
    int[2] arr = {1, 2};
    va_singletyped(...arr); // arr is splatting two arguments
}

fn void foo(int a, int b, int c)
{
    io::printfn("%s, %s, %s", a, b, c);
}
fn void main()
{
    int[2] arr = {1, 2};
    foo(...arr, 7); // arr is splatting two arguments
}

fn void foo(int a, int b, int c)
{
    io::printfn("%s, %s, %s", a, b, c);
}
fn void main()
{
    int[5] arr = {1, 2, 3, 4, 5};
    foo(...arr[:3]); // slice is splatting three arguments
}

fn void testme(int a, double... x, double rate = 1.0) { /* ... */ }

fn void test()
{
    // x is { 2.0, 5.0, 6.0 } rate would be 1.0
    testme(3, 2.0, 5.0, 6.0);
}

fn void testme(int a, double... x, double rate = 1.0) { /* ... */ }

fn void test()
{
    // x is { 2.0, 5.0 } rate would be 6.0
    testme(3, 2.0, 5.0, rate: 6.0);
}

faultdef BAD_LUCK_ERROR, BAD_JOSS_EROR;

fn double? test_error()
{
    double val = random_value();
    if (val >= 0.2) return BAD_JOSS_ERROR?;
    if (val > 0.5) return BAD_LUCK_ERROR?;
    return val;
}

fn void test()
{
    // The following line is either prints a value less than 0.2
    // or does not print at all. The (void) is needed
    // to let the compiler know we're deliberately
    // ignoring the Optional result.
    (void)io::printfn("%d", test_error());

    // ?? sets a default value if an Excuse is found
    double x = (test_error() + test_error()) ?? 100;

    // This prints either a value less than 0.4 or 100:
    io::printfn("%d", x);
}

fn void print_input_with_explicit_checks()
{
    String? line = io::treadline();
    if (try line)
    {
        // line is a regular "string" here.
        int? val = line.to_int();
        if (try val)
        {
            io::printfn("You typed the number %d", val);
            return;
        }
    }
    io::printn("You didn't type an integer :/ ");
}

fn void print_input_with_chaining()
{
    if (try int val = io::treadline().to_int())
    {
        io::printfn("You typed the number %d", val);
        return;
    }
    io::printn("You didn't type an integer :/ ");
}

struct Point
{
    int x;
    int y;
}

fn void Point.add(Point* p, int x)
{
    p.x += x;
}

fn void example()
{
    Point p = { 1, 2 };

    // with struct-functions
    p.add(10);

    // Also callable as:
    Point.add(&p, 10);
}

enum State
{
    STOPPED,
    RUNNING
}

fn bool State.may_open(State state)
{
    switch (state)
    {
        case STOPPED: return true;
        case RUNNING: return false;
    }
}

fn int Foo.test(&self) { /* ... */ }
// equivalent to
fn int Foo.test(Foo* self) { /* ... */ }
fn int Bar.test(self) { /* ... */ }
// equivalent to
fn int Bar.test(Bar self) { /* ... */ }

<*
 @param foo `the number of foos`
 @require foo > 0, foo < 1000
 @return `number of foos x 10`
 @ensure return < 10000, return > 0
*>
fn int test_foo(int foo)
{
    return foo * 10;
}

fn int test_foo(int foo)
{
    assert(foo > 0);
    assert(foo < 1000);
    int _return = foo * 10;
    assert(_return < 10000);
    assert(_return > 0);
    return _return;
}

fn int test_example(int bar)
{
    // The following is always invalid due to the `@ensure`
    if (test_foo(bar) == 0) return -1;
    return 1;
}

fn int test_example(int bar)
{
    return 1;
}

// Regular
fn int square(int x)
{
    return x * x;
}
// Short
fn int square_short(int x) => x * x;

alias IntTransform = fn int(int);
fn void apply(int[] arr, IntTransform t)
{
    foreach (&i : arr) *i = t(*i);
}
fn void main()
{
    int[] x = { 1, 2, 5 };
    // Short syntax with inference:
    apply(x, fn (i) => i * i);
    // Regular syntax without inference:
    // apply(x, fn int(int i) { return i * i; });
    // Prints [1, 4, 25]
    io::printfn("%s", x);
}

fn void run_at_startup() @init
{
    // Run at startup
    some_function.init(512);
}

fn void run_at_shutdown() @finalizer
{
    some_thing.shutdown();
}

// Print "Hello World" at startup.

fn void start_world() @init(3000)
{
    io::printn("World");
}
fn void start_hello() @init(2000)
{
    io::print("Hello ");
}