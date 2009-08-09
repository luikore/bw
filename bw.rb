# coding: utf-8

# ------------------------------------------------------------------------------
# environment config and components

require 'yaml'
$bwhome = File.expand_path File.dirname(__FILE__)
$config = YAML.load_file $bwhome + '/config.yaml'

$bw = Object.new

class << $bw
  attr_accessor :main_window, :sci
  attr_accessor :modified, :bom, :encoding

  attr_reader :filename
  def filename= fn
    @main_window.title = fn
    @filename = fn
  end

  def init
    @bom = ''
    @sci.text = ''
    @main_window.title = ''
    @modified = false
    @filename = ''
    @encoding = ''
  end
end

$bw.encoding = ''

require $bwhome + '/encoding_detect.rb'
EncodingDetect.default_encoding = $config['default_encoding']

require 'cici'
include Cici::View # enable view helpers

require $bwhome + '/main_menu.rb'


# ------------------------------------------------------------------------------
# create window and show

exit if __FILE__ != $PROGRAM_NAME # for OCRA

win = $config['window']
view [win['width'], win['height']], title: '', layout: :zoom do |v|

  # main window
  v.pos = win['left'], win['top']
  v.menu MainMenu
  v.onexit = MainMenu['File']['Exit']
  $bw.main_window = v

  # editor
  s = scintilla [win['width'] - 8, win['height'] - 46]
  s.lexer       = 'ruby'
  s.font        = Font[ $config['font']['face'], $config['font']['size'] ]
  s.line_margin = 1 # show line number
  s.fold_margin = 2
  s.indent      = 2 # auto indent 2 chars when needed
  s.onmodified  = proc do |sci, lparam|
    unless $bw.modified
      scn = Cici::Scintilla.scn lparam
      if ((scn.modificationType & 3) > 0)
        $bw.modified = true
        v.title = v.title + '*'
      end
    end
  end
  $bw.sci = s

  # statusbar

end
