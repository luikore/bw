# simple thingys
s = $bw.sci
s.lexer = "ruby"
s.indent = 2

# normal keywords
s.set_keywords 0, "DATA __END__ __FILE__ __LINE__ alias and begin break \
case class def defined? do else elsif end ensure false for if in module \
next nil not or raise redo rescue retry return self super then true \
undef unless until when while yield"

# indent
s.indent_pattern = @indent_pattern = /^\s*
  (?:def|class|if|elsif|else|case|while|for)\b.*
  |.*(?:\bdo|\{)(?:\s*\|[^\|]*?\|)?     \s*$/x

# unindent
s.unindent_pattern = %r"^\s*(?:end|\})\s*$"

# color theme
load File.expand_path(File.dirname(__FILE__)) + './color.rb'
