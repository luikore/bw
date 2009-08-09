# coding: utf-8

MainMenu = {}

# ------------------------------------------------------------------------------
# file
# ------------------------------------------------------------------------------

file = {}

# confirm whether save modified file
def go_on? save_proc
  return true unless $bw.modified
  cf = confirm 'File changed, save it?'
  if cf
    save_proc[]
    true
  elsif cf == false
    true
  else # nil
    false
  end
end

file['New         Ctrl+N'] = proc do
  if go_on? file['Save        Ctrl+S']
    $bw.init
  end
end

file['Open        Ctrl+O'] = proc do
  if go_on? file['Save        Ctrl+S']
    fn = choose_file 'ruby file'=>'*.rb', 'all'=>'*.*'
    if fn and File.exist? fn
      ed = EncodingDetect.new fn
      $bw.bom = ed.bom
      $bw.encoding = ed.encoding
      $bw.sci.text = ed.read
      $bw.modified = false
      $bw.filename = fn
    end
  end
end

# ------------------------------------------------------------------------------

def save fn
  if fn
    File.open fn, 'w' do |f| 
      f << $bw.bom
      if !$bw.encoding or $bw.encoding.empty?
        f << $bw.sci.text
      else
        f << ($bw.sci.text.encode $bw.encoding)
      end
    end
    $bw.modified = false
    $bw.filename = fn
  end
end

file['Save        Ctrl+S'] = proc do
  fn = $bw.filename
  fn = save_file() if fn.empty?
  save fn
end

file['Save as ...'] = proc do
  fn = save_file()
  save fn
end

# ------------------------------------------------------------------------------

file['line1'] = nil

file['Exit']  = proc do
  if go_on? file['Save        Ctrl+S']
    # change config[window]
    win = $config['window']
  
    w, h = $bw.main_window.size
    win['width']  = w
    win['height'] = h
  
    l, t = $bw.main_window.pos
    win['left'] = l
    win['top']  = t
  
    # save to config.yaml
    File.open($bwhome + '/config.yaml', 'w'){ |f| f << YAML.dump($config) }
    exit
  end
  # return nil to stop PostQuitMessage()
end

MainMenu['File'] = file
# keymap
keymap 'N', :ctrl, & file['New         Ctrl+N']
keymap 'O', :ctrl, & file['Open        Ctrl+O']
keymap 'S', :ctrl, & file['Save        Ctrl+S']


# ------------------------------------------------------------------------------
# edit
# ------------------------------------------------------------------------------

MainMenu['Edit'] = {}


# ------------------------------------------------------------------------------
# ?
# ------------------------------------------------------------------------------

MainMenu['?'] = proc do
  alert 'Blackwing Editor ver -1'
end

