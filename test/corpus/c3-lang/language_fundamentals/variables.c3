int x;               // x = 0
int y @noinit;       // y is explicitly undefined and must be assigned before use.

AStruct foo;         // foo is implicitly zeroed
AStruct bar = {};    // bar is explicitly zeroed
AStruct baz @noinit; // baz is explicitly undefined