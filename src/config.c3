module c3fmt;

struct Config {
	bool use_tab_for_indentation;
    uint indent_size;
    uint max_line_width;
    bool braces_same_line;
    bool else_on_closing_brace;
}

fn Config default_config()
{
    return {
		.use_tab_for_indentation = true,
        .indent_size = 4,
        .max_line_width = 80,
        .braces_same_line = true,
        .else_on_closing_brace = true
    };
}