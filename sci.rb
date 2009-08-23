# coding: utf-8
# ------------------------------------------------------------------------------
# setup scintilla

s = $bw.sci
s.style_set_all Font[ *$config['font'] ], RGB[0xffffff], RGB[0]
s.has_lineno = true
s.fold_margin = 2
s.indent      = 2 # auto indent 2 chars when needed
s.onstyleneeded = Stylar.method(:onstyleneeded)

s.onmodified  = proc do |sci, scn|
  unless $bw.modified
    if ((scn.modificationType & 3) > 0)
      $bw.modified = true
      $app.main_window.title = $app.main_window.title + '*'
    end
  end
end

