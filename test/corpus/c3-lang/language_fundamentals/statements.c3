fn void test(int i)
{
    if FOO: (i > 0)
    {
        while (1)
        {
            io::printfn("%d", i);
            // Break out of the top if statement.
            if (i++ > 10) break FOO;
        }
    }
}

fn void test(int x)
{
    do
    {
        if (!x) break;
        io::printf("Hello ");
    };
    io::printf("World!\n");
}

switch (i)
{
    case 1:
        doSomething();
        nextcase; // Jumps to case 2
    case 2:
        doSomethingElse();
}

switch MAIN: (enum_var)
{
    case FOO:
        switch (i)
        {
            case 1:
                doSomething();
                nextcase 3; // Jump to case 3
            case 2:
                doSomethingElse();
            case 3:
                nextcase rand(); // Jump to random case
            default:
                io::printn("Ended");
                nextcase MAIN: BAR;  // Jump to outer (MAIN) switch
        }
    case BAR:
        io::printn("BAR");
    default:
        break;
}

switch (true)
{
    case x < 0:
        xless();
    case x > 0:
        xgreater();
    default:
        xequals();
}

if (x < 0)
{
    xless();
}
else if (x > 0)
{
    xgreater();
}
else
{
    xequals();
}

switch (true)
{
    case x > 0:
        foo();
    case x > 2:
        bar();
}

switch
{
    case foo() > 0:
        bar();
    case test() == 1:
        baz();
}