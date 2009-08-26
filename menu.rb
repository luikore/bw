# coding: utf-8

# ------------------------------------------------------------------------------
# def

Fops = Object.new
class << Fops

  # confirm whether save modified file
  def go_on? save_proc
    return true unless $bw.modified
    cf = $app.confirm 'File changed, save it?'
    if cf
      save_proc[]
      true
    elsif cf == false
      true
    else # nil
      false
    end
  end

  def new
    $bw.init if go_on? method(:_save)
  end

  def _open
    return unless go_on? method(:_save)
    fn = yield
    return unless fn and File.exist? fn    
    # read file, determine encoding by bom, or utf-8
    ed = EncodingDetect.new fn
    $bw.bom = ed.bom
    $bw.encoding = ed.encoding
    $bw.sci.text = ed.read
    $bw.modified = false
    $bw.filename = fn
    $bw.sci.empty_undo_buffer

    # determine file type and load corresponding plugin
    if fn =~ /\.rbw?$/
      load BW_ROOT + '/ftplugin/ruby/ruby.rb'
    end
  end

  def open
    _open {
      $app.choose_file 'all'=>'*.*'
    }
  end

  def _save fn
    return unless fn
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

  def save
    fn = $bw.filename
    fn = $app.save_file if fn.empty?
    _save fn
    $bw.sci.empty_undo_buffer
  end

  def save_as
    fn = $app.save_file
    _save fn
    $bw.sci.empty_undo_buffer
  end

  # ask if save before exit
  def _exit
    exit if go_on? method(:_save)
    # return nil to stop PostQuitMessage()
  end

  def save_window_pos
    # change config[window]
    win = $config['window']
    win['size'] = $app.main_window.size
    win['pos'] = $app.main_window.pos

    # save to config.yaml
    File.open BW_ROOT + '/config.yaml', 'w' do |f|
      f << YAML.dump($config)
    end
  end

end # end Fops


# ------------------------------------------------------------------------------
# run

# build menu bar, must be executed after main window loaded
$bw.menu.popupmenu do |f|
  f.item_with_key('&New', 'N') { Fops.new }
  f.item_with_key('&Open', 'O') { Fops.open }
  f.item_with_key('&Save', 'S') { Fops.save }
  f.item('Save &As') { Fops.save_as }
  f.line
  f.item('Save &Window Position') { Fops.save_window_pos }
  f.line
  f.item('&About') { $app.alert 'black wing 0.0.1' }
  f.item('E&xit') { Fops._exit }
end

# left click will get it popped too
$bw.menu.onclick = proc do
  x, y = $bw.sci.absolute_pos
  $bw.menu.instance_variable_get("@popupmenu").popup x, y
end

# when X is clicked
$app.main_window.onclose = Fops.method(:_exit)

