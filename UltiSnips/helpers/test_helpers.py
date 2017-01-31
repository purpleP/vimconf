from unittest.mock import MagicMock
import pytest

from helpers import (
    lang_context, expand_method_in_right_place, in_imports
)


class_buffer = (
    'class C:\n',
    '    def __init__(self, a, b):\n',
    '        self.a = a\n',
    '\n'
)

def make_snip(buffer):
    mock = MagicMock()
    mock.buffer = list(buffer)
    cursor = [0, 0]
    def set_cursor(l, c):
        cursor[0] = l
        cursor[1] = c
    mock.cursor.__getitem__ = lambda self, x: cursor[x]
    mock.cursor.set = lambda l, c: set_cursor(l, c)
    mock.__class__.line = property(lambda *args, **kwargs: cursor[0])
    mock.__class__.col = property(lambda *args, **kwargs: cursor[0])
    return mock


@pytest.mark.parametrize(
    'cursor, expected',
    (
        ((0, 0), 'module'),
        ((1, 0), 'class'),
        ((2, 0), 'def'),
        ((3, 0), 'module'),
    )
)
def test_context(cursor, expected):
    snip = make_snip(class_buffer)
    snip.cursor.set(*cursor)
    assert lang_context(snip) == expected


def test_expand_less():
    snip = make_snip(class_buffer)
    snip.buffer[-1] = '    \n'
    initial_buffer = tuple(snip.buffer)
    snip.cursor.set(3, 0)
    expand_method_in_right_place(snip)
    expected = list(initial_buffer)
    expected[-1:-1] = ('\n',)
    assert tuple(expected) == tuple(snip.buffer)
    assert (4, 4) == (snip.line, snip.col)


def test_expand_more():
    snip = make_snip(class_buffer)
    initial_buffer = tuple(snip.buffer)
    snip.buffer += ('\n',) * 5
    snip.cursor.set(8, 0)
    expand_method_in_right_place(snip)
    expected = initial_buffer + ('\n',) * 2
    assert expected == tuple(snip.buffer)
    assert (5, 5) == (snip.line, snip.col)


import_buffer = (
    '\n',
    'from some import some\n',
    '\n',
    'import some\n',
    '\n',
    '\n',
)


@pytest.mark.parametrize(
    'cursor,buffer,expected',
    (
        ((0, 0), import_buffer, True),
        ((2, 0), import_buffer, True),
        ((4, 0), import_buffer, True),
        ((5, 0), import_buffer, False),
        ((1, 0), ('from some import some\n', '\n'), True),
    )
)
def test_in_imports(cursor, buffer, expected):
    snip = make_snip(buffer)
    snip.cursor.set(*cursor)
    assert in_imports(snip)
