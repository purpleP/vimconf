import pdb
from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, Number
from pygments.formatters import TerminalTrueColorFormatter


BASE03 = '#002b36'
BASE02 = '#073642'
BASE01 = '#586e75'
BASE00 = '#657b83'
BASE0 = '#839496'
BASE1 = '#93a1a1'
BASE2 = '#eee8d5'
BASE3 = '#fdf6e3'
YELLOW = '#b58900'
ORANGE = '#cb4b16'
RED = '#dc322f'
MAGENTA = '#d33682'
VIOLET = '#6c71c4'
BLUE = '#268bd2'
CYAN = '#2aa198'
GREEN = '#859900'


solarized_true_color = {
    Comment: BASE01,
    Keyword.Constant: CYAN,
    Keyword.Declaration: BLUE,
    Keyword: GREEN,
    Name.Builtin.Pseudo: 'bold ' + BASE1,
    Name.Builtin: YELLOW,
    Name.Class: BLUE,
    Name.Decorator: BLUE,
    Name.Exception: YELLOW,
    Name.Function: BLUE,
    Name: BASE0,
    Number: CYAN,
    String.Backtick: RED,
    String.Char: CYAN,
    String.Doc: CYAN,
    String.Double: CYAN,
    String.Escape: RED,
    String.Heredoc: CYAN,
    String.Interpol: RED,
    String.Other: RED,
    String.Regex: CYAN,
    String.Single: CYAN,
    String.Symbol: CYAN,
    String: CYAN,
}


class SolarizedStyle(Style):
    background_color = '#002b36'
    styles = solarized_true_color


class Config(pdb.DefaultConfig):
    sticky_by_default = True
    def __init__(self):
        self.style = SolarizedStyle
        self.formatter = TerminalTrueColorFormatter(bg='dark', style=self.style)
