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

file['new'] = proc do
  if go_on? file['save']
    $bw.init
  end
end
keymap 'n', :ctrl, file['new']

file['open'] = proc do
  if go_on? file['save']
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
keymap 'o', :ctrl, file['open']

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

file['save'] = proc do
  fn = $bw.filename
  fn = save_file() if fn.empty?
  save fn
end
keymap 's', :ctrl, file['save']

file['save as ...'] = proc do
  fn = save_file()
  save fn
end
keymap 's', :ctrl, :shift, file['save as ...']

# ------------------------------------------------------------------------------

file['line1'] = nil

file['exit']  = proc do
  if go_on? file['save']
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

MainMenu['file'] = file


# ------------------------------------------------------------------------------
# edit
# ------------------------------------------------------------------------------

MainMenu['edit'] = {}


# ------------------------------------------------------------------------------
# ?
# ------------------------------------------------------------------------------

MainMenu['?'] = proc do
  alert 'black wing editor'
end
