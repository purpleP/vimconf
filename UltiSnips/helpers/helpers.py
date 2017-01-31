import re
from contextlib import suppress
from operator import sub, itemgetter


def get_indent(line):
    return len(line) - len(line.lstrip().rstrip('\n'))


def higher_indent(indent):
    return lambda line: get_indent(line) > indent


def ensure_indent(buffer, cursor, indent, expand_tab=True, shift_width=4):
    if expand_tab == '1':
        indent_symbol = ' ' * shift_width
    else:
        indent_symbol = '\t'
    buffer[cursor[0]] = indent_symbol * indent
    return (cursor[0], len(buffer[cursor[0]]))


def lines(snip, backward=True):
    buf, lnum = snip.buffer, snip.line
    slice = (lnum - 1, -1, -1) if backward else (lnum + 1, len(buf), 1)
    return ((i, buf[i]) for i in range(*slice))


def in_imports(snip):
    pattern = re.compile(r'^(import .*|from .* import .*)$')
    prev_lines = snip.buffer[:snip.line][-2:]
    next_lines = snip.buffer[snip.line + 1:snip.line + 2]
    result = next(filter(bool, map(pattern.match, prev_lines + next_lines)), False)
    return result


def lang_context(snip):
    indent = get_indent(snip.buffer[snip.line])
    pattern = re.compile(r'^\s*((?:async )?def|class)')
    contexts = (pattern.match(l) for ln, l in lines(snip) if get_indent(l) < indent)
    return next((c.group(1) for c in contexts if c), 'module')


def is_after_def(snip):
    prev_line = snip.buffer[snip.line - 1].strip()
    return prev_line.startswith('def') or prev_line.startswith('class ')


def format_function(tabstops, name_index, params_index):
    with suppress(IndexError):
        tabstops[name_index] = tabstops[name_index].replace(' ', '_')
        tabstops[params_index] = re.sub('([^,])(\s+)', r'\1_', tabstops[params_index])


def params_to_parametrize_arg(tabstops, params_index):
    return tabstops[params_index].replace(' ', '')


def have_visual_placeholder(snip):
    try:
        return snip.visual_mode == 'V'
    except AttributeError:
        return False


def expand_method_in_right_place(snip):
    context = lang_context(snip)
    if context in ('def', 'async def'):
        return
    initial_line = snip.buffer[snip.line]
    initial_indent = get_indent(initial_line)
    lnum = snip.line
    indent_levels = {
        'module': 2,
        'class': 1,
    }
    required = indent_levels[context]
    def next_stmt(backward):
        return next(
            (ln for ln, l in lines(snip, backward) if l.strip() != ''), None
        )
    above, below = (next_stmt(backward=backward) for backward in (True, False))
    if above is None:
        from_ = lnum
    elif above != lnum:
        from_ = above + 1
    else:
        from_ = above
    to = below if below is not None else lnum + 1
    add_above, add_below = (0 if i is None else required for i in (above, below))
    if context == 'class' and snip.buffer[snip.line - 1].strip().startswith('class'):
        add_above = 0
    snip.buffer[from_:to] = ('\n',) * (add_above + add_below + 1)
    snip.cursor.set(from_ + add_above, initial_indent)
    snip.buffer[snip.cursor[0]] = re.match(r'^(\s*).*$', initial_line).group(1)
    snip.context = {
        'call_position': snip.cursor,
        'call_indent': initial_indent,
        'snip.context_match': snip.context,
        'visual': snip.visual_content
    }


def identifier_start(snip):
    line, col = snip.window.cursor
    try:
        char_before = snip.buffer[line - 1][col - 3]
        return re.match('\W', char_before)
    except IndexError:
        return False
