# coding: utf-8

# ------------------------------------------------------------------------------
# def

fops = Object.new
class << fops

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
    if go_on? method(:_save)
      $bw.init
    end
  end

  def open
    if go_on? method(:_save)
      fn = $app.choose_file 'ruby file'=>'*.rb', 'all'=>'*.*'
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

  def _save fn
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

  def save
    fn = $bw.filename
    fn = $app.save_file if fn.empty?
    _save fn
  end

  def save_as
    fn = $app.save_file
    _save fn
  end

  # ask if save before exit
  def _exit
    if go_on? method(:_save)
      exit
    end
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

end # end fops


# ------------------------------------------------------------------------------
# run

# build menu bar, must be executed after main window loaded
$app.main_window.menubar do |m|
  m.menu '&File' do |f|
    f.item_with_key('&New', 'N') { fops.new }
    f.item_with_key('&Open', 'O') { fops.open }
    f.item_with_key('&Save', 'S') { fops.save }
    f.item('Save &As') { fops.save_as }
    f.line
    f.item('Save &Window Position') { fops.save_window_pos }
    f.item('E&xit') { fops._exit }
  end
  m.menu '&Edit'
  m.item('&?') { $app.alert 'black wing 0.0.1' }
end

# when X is clicked
$app.main_window.onclose = fops.method(:_exit)

