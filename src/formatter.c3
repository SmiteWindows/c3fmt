module c3fmt;

import std::io; 
import std::collections;

import ts;
import tree_sitter_c3;

struct Context {
    uint indent_level;
}

struct LineBuffer {
    DString text; 
    List{uint} wrap_points;
}

struct C3Fmt
{
    Config  config;

    Context context;
    String  source_code;

    DString output_code;
    LineBuffer line_buffer;
}

fn C3Fmt new(Allocator allocator, String source_code, Config config) {
    C3Fmt instance;

    instance.source_code = source_code.copy(allocator);
    instance.config = config; 
    instance.output_code = dstring::new(allocator);

    instance.line_buffer.text.init(mem, 64);
    instance.line_buffer.wrap_points.init(mem);

    return instance;
}

fn void C3Fmt.format(&self) {
    TSParser*? parser = ts::parser::new_with_language(tree_sitter_c3::language());
	defer (void)ts::parser_delete(parser);
	if (catch excuse = parser) {
		io::eprintfn("Error: could not create the parser");
        io::eprintfn("Excuse: %s.", excuse);
		return;
	}

    TSTree*? tree = ts::parser::parse_string(parser, null, self.source_code);
    defer (void)ts::tree_delete(tree);
    if (catch excuse = tree) {
        io::eprintfn("Error: could not create the tree");
        io::eprintfn("Excuse: %s.", excuse);
		return;
    }

    TSNode root = ts::tree_root_node(tree);

    if(ts::node_has_error(root)) {
        io::eprintfn("Source code contains error(s).");
        return;
    }

    assert(root.type() == "source_file");
    self.process_node(root);
    self.flush_line(false);

    if(self.output_code[self.output_code.len() - 1] == '\n') {
        self.output_code.chop(self.output_code.len() - 1);
    }

    self.line_buffer.text.free(); 
    self.line_buffer.wrap_points.free();
}

module c3fmt @private;

import std::io;
import ts;

<*
    Can be used for things like compound_stmt, source_file, struct_body, enum_body etc...
    Rules: 
    - Have some delimiters (optional) like curly braces
        * These can either stick to a line currently being written, or start on a new line
    - For each child of the block, write them and preserve blank lines in-between
        * Can optionaly cap to x-amount of blank line
        * Forces one statement per line
        * Comments are not subject to the previous rule
    - Can have an optional string to append after each line (e.g. a comma for enum)
*>
fn void C3Fmt.process_compound
(
    &self, TSNode node, 
    String opening_delimiter = "", String closing_delimiter = "",
    uint max_blank_line_amount = 2, String child_delimiter = "", String pre_child_delimiter = "",
    bool increase_indent = false
) 
{
    self.append_str(opening_delimiter);

    if(increase_indent) {
        self.indent();
    }

    for(uint i = 0; i < ts::node_named_child_count(node); ++i) {
        TSNode child = ts::node_named_child(node, i);
        String type = child.type();

        int blank_line_amount = 0; 
        if(i > 0) {
            TSNode sibling = ts::node_named_child(node, i - 1);
            blank_line_amount = child.start_point_row() - sibling.end_point_row();
        }
        blank_line_amount = min(blank_line_amount, max_blank_line_amount);

        for(int j = 0; j < blank_line_amount - 1; ++j) {
            self.newline();
        }

        self.process_node(child);

        if(i < ts::node_named_child_count(node) - 1) {
            self.append_str(child_delimiter);
        }
    }

    if(increase_indent) {
        self.deindent();
    }

    self.append_str(closing_delimiter);
}

fn void C3Fmt.process_composite(&self, TSNode node, String[] skip_space_type = { ";" }, String[] skip_space_if_after = {}, bool append_newline = false) {    
    for(uint i = 0; i < ts::node_child_count(node); ++i) {
        TSNode child = ts::node_child(node, i);
        String type = child.type();

        if(!skip_space_type.contains(type) && i > 0 
            && !skip_space_if_after.contains(ts::node_child(node, i - 1).type())) {
            self.white_space();
        }

        if(child.is_comment()) {
            self.append_node_str(child);
            continue;
        }

        if(ts::node_is_named(child)) {
            self.process_node(child);
        } else {
            self.append_node_str(child);
        }
    }

    if(append_newline) {
        self.newline();
    }
}

<*
    Process a node of an unknown type
*>
fn void C3Fmt.process_node(&self, TSNode node) {
    switch (node.type())
    {
        /* ======================================== */
        /* TOP-LEVEL                                */
        /* ======================================== */
        case "source_file": 
            self.process_compound(node);

        /* ======================================== */
        /* FUNCTIONS                                */
        /* ======================================== */
        case "func_definition": 
            self.process_composite(node);
        case "func_header":
        case "func_param_list":
            self.append_node_str(node); // TODO
        case "macro_func_body": 
            TSNode child = ts::node_child(node, 0);
            switch(child.type()) {
                case "compound_stmt":
                    self.process_compound(child, 
                        opening_delimiter: "{\n",
                        closing_delimiter: "}\n", 
                        increase_indent: true
                    );
                case "implies_body": 
                case "=>":
                    self.process_composite(node, append_newline: true);
            }
        case "implies_body":
            self.process_composite(node);
        case "=>": 
            self.process_composite(node);

        /* ======================================== */
        /* DECLARATION                              */
        /* ======================================== */
        case "struct_declaration": 
            self.process_composite(node, append_newline: true);
        case "struct_body":
            self.process_compound(node,
                opening_delimiter: "{\n",
                closing_delimiter: "}", 
                increase_indent: true
            );
        case "struct_member_declaration": 
            self.process_composite(node, append_newline: true);
        case "enum_declaration":
            self.process_composite(node);
        case "enum_body":
            self.process_compound(node,
                opening_delimiter: "{\n",
                closing_delimiter: "}", 
                increase_indent: true
            );
        case "enum_constant": 
            self.process_composite(node);
            self.append_str(",\n"); // TODO
        case "faultdef_declaration":
            self.process_composite(node, 
                skip_space_type: { ",", ";" },
                append_newline: true
            );
        case "module_declaration":
            self.process_composite(node, 
                skip_space_type: { ",", ";" },
                append_newline: true
            );
        case "path_ident": // TODO 
            self.append_node_str(node);

        /* ======================================== */
        /* EXPRESSIONS                              */
        /* ======================================== */
        case "attributes": 
            self.process_composite(node);
        case "identifier_list":
            self.process_composite(node,
                skip_space_type: { "," }
            );
        case "paren_cond":
            self.process_composite(node, 
                skip_space_type: { ")" }, 
                skip_space_if_after: { "(" },
            );     
        case "call_expr":
            self.process_composite(node,
                skip_space_type: { "call_arg_list" }
            );
        case "call_arg_list":
            self.process_composite(node, 
                skip_space_type: { ")", "," }, 
                skip_space_if_after: { "(" },
            ); 
        case "call_args":
            self.process_composite(node); 
        case "call_arg": 
            self.append_node_str(node); // TODO
        case "binary_expr": 
            self.process_composite(node);
        case "unary_expr":
        case "update_expr":
            for(uint i = 0; i < ts::node_child_count(node); ++i) {
                self.append_node_str(ts::node_child(node, i));
            }
        case "assignment_expr": 
            self.process_composite(node);                

        /* ======================================== */
        /* STATEMENTS & CONTROL FLOW                */
        /* ======================================== */
        case "expr_stmt":
            self.process_composite(node, append_newline: true);
        case "return_stmt":
            self.process_composite(node, append_newline: true);  
        case "break_stmt":
            self.process_composite(node, append_newline: true);  
        case "continue_stmt":
            self.process_composite(node, append_newline: true);  
        case "assert_stmt": 
            self.process_composite(node, 
                skip_space_type: { ";", ")" }, 
                skip_space_if_after: { "(" },
                append_newline: true
            ); 
        case "for_stmt": 
            self.process_composite(node, append_newline: true);  
        case "for_cond": 
            self.process_composite(node, 
                skip_space_type: { ";", ")" }, 
                skip_space_if_after: { "(" },
            );  
        case "foreach_stmt":
            self.process_composite(node, append_newline: true);  
        case "foreach_cond": 
            self.process_composite(node, 
                skip_space_type: { ",", ")" }, 
                skip_space_if_after: { "(" },
            );  
        case "while_stmt":
            self.process_composite(node, append_newline: true);   
        case "do_stmt":
            self.process_composite(node, append_newline: true);     
        case "if_stmt": 
            self.process_composite(node);            
            if(!node.has_child_of_type("else_part")) {
                self.newline();
            }
        case "else_part": 
            self.process_composite(node);
            if(!node.has_child_of_type("if_stmt")) {
                self.newline();
            }
        case "compound_stmt": 
            self.process_compound(node,
                opening_delimiter: "{\n",
                closing_delimiter: "}", 
                increase_indent: true
            );

        /* ======================================== */
        /* COMMENTS                                 */
        /* ======================================== */
        case "block_comment":
            self.append_node_str(node);
            self.newline();
        case "line_comment": 
            self.append_node_str(node);
            self.newline();

        /* ======================================== */
        /* COMMON LEAVES                            */
        /* ======================================== */
        case "ident":
        case "ident_expr": 
        case "ct_ident": 
        case "at_ident":
        case "hash_ident":
        case "const_ident": 
        case "ct_const_ident":
        case "type":
        case "type_ident":
        case "ct_type_ident":
        case "at_type_ident":
        case "builtin":
        case "builtin_const":
        case "integer_literal": 
        case "char_literal": 
        case "string_literal": 
        case "raw_string_literal": 
        case "byte_literal": 
        case "label":
        case "label_target":
        case "true":
        case "false": 
        case "null":
        case "attribute": // TODO
            self.append_node_str(node);

        default: 
            io::eprintfn("Type %s is not supported by c3fmt (yet!).", node.type());
            self.append_node_str(node);
            //unreachable();
    }
}