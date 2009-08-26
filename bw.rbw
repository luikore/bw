# coding: utf-8


# ------------------------------------------------------------------------------
# consts and components

BW_ROOT = File.expand_path File.dirname(__FILE__)
require BW_ROOT + '/_cici'
require BW_ROOT + '/encoding_detect.rb'
require BW_ROOT + '/stylar.rb'


# ------------------------------------------------------------------------------
# config and init runtime

$config = YAML.load_file BW_ROOT + '/config.yaml'
$app = Cici.app ''
$bw = Object.new
class << $bw
  attr_accessor :sci, :cmd, :menu
  attr_accessor :modified, :bom, :encoding

  attr_reader :filename, :theme
  def filename= fn
    $app.main_window.title = fn
    @filename = fn
  end

  def init
    @bom = ''
    if @sci
      @sci.text = '' 
      @sci.empty_undo_buffer
    end
    $app.main_window.title = '' if $app.main_window
    @modified = false
    @filename = ''
    @encoding = ''
  end

  def load_theme
    y = YAML.load_file BW_ROOT + '/themes/' + $config['theme'] + '.yaml'
    y['styles'].each {|k, v|
      y['highlights'][k] = [ v, y['default'][1] ]
    }
    @theme = y['highlights'].dup
    @theme['default'] = y['default']
    @theme['fold_margin'] = y['fold_margin']
  end

end
$bw.load_theme
$bw.init
EncodingDetect.default_encoding = $config['default_encoding']


# ------------------------------------------------------------------------------
# create window and show

$app.paint $config['window']['size'] do |v|
  v.pos = $config['window']['pos']
  grey = RGB[212, 208, 200]
  v.border_stroke = Stroke[grey, solid: 1]
  v.bkcolor = grey

  # build menu
  $bw.menu = v.text "Menu"
  require BW_ROOT + '/menu.rb'

  # cmd, size and pos will be set afterwords
  $bw.cmd = v.edit [10, 10]
  require BW_ROOT + '/cmd.rb'

  # editor
  $bw.sci = v.scintilla [10, 10]
  require BW_ROOT + '/sci.rb'

  # statusbar
end

# size policy
class << $app.main_window
  public
  def onresize
    cx, cy = self.client_size
    return if (cx == 0 or cy == 0 or @children.nil?)
    text, edit, sci = @children

    text.pos = 5, 3
    tcx, tcy = text.size
    edit.displace 9 + tcx, 2, cx - tcx - 11, 20
    sci.displace 2, 27, cx - 4, cy - 29
  end
end

# update sizes and positions of child elements
$app.main_window.onresize

if __FILE__ == $PROGRAM_NAME
  GC.start # check if has gc problem
  $app.message_loop
end
