# coding: utf-8
# ------------------------------------------------------------------------------
# setup scintilla

s = $bw.sci
s.style_set_all Font[ *$config['font'] ], *$bw.theme['default']

s.has_lineno = true
s.fold_margin = 2
s.fold_margin_color = $bw.theme['fold_margin']
s.indent = 2
s.style_set_color 34, *$bw.theme['brace']
s.style_set_color 35, *$bw.theme['brace_unmatched']
s.set_sel_color *$bw.theme['selection']

# s.onstyleneeded = Stylar.method(:onstyleneeded)

s.onmodified  = proc do |sci, scn|
  unless $bw.modified
    if ((scn.modificationType & 3) > 0)
      $bw.modified = true
      $app.main_window.title = $app.main_window.title + '*'
    end
  end
end

s.focus
