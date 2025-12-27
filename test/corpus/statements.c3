fn void random() {}

// hello, world
fn void statements (int a, bool b = false) @public @private {
    if FOO: (10 >= 20 || "aa" == "aa")
        random(); 

    if(1 == 0) {
            random();
    } else if BAR: (2 == 2) {

    } else {
            random();
    }

    statements(a = 20, false);
    
    for (int a=0, int b = 20; a < 50 && b >= 15; a++, --b) {
        break;
    }
    
    for TOTO:(;;) {
            random();
            break TOTO;
    }
    
    for(; a < 50; a++) {
        random(); int j = 30;
        continue;
    }

    for(bool c = true;; c= !c) {
        random();
    }

    // some comments here
    while /*ae*/ BABAR: /*b*/ (int e = 20, e < 20) {
        break BABAR;
        random();
            // comment
            random();
    }

        foreach (index, value : values)
    {
        io::printfn("%d: %f", index, value);
    }

    foreach (&value : values)
    {
        *value *= 2; // l comment
    }

    do { // line comment
    };
    
    // a comment there

    do {
    } while(a >= 10);

    return; 
    return 10 + 20;
    return random();
}