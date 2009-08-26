# coding: utf-8
# cmd box setup

$app.keymap 'ESC' do
  if $bw.sci.has_focus?
    $bw.cmd.focus
  else
    $bw.sci.focus
  end
end

$bw.cmd.onenter = proc do |c|
  /^e (?<file>.+)/ =~ c.text
  Fops._open {file}
end
