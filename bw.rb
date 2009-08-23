# coding: utf-8

# ------------------------------------------------------------------------------
# consts and components

require 'yaml'
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
  attr_accessor :sci
  attr_accessor :modified, :bom, :encoding

  attr_reader :filename
  def filename= fn
    $app.main_window.title = fn
    @filename = fn
  end

  def init
    @bom = ''
    @sci.text = '' if @sci
    $app.main_window.title = '' if $app.main_window
    @modified = false
    @filename = ''
    @encoding = ''
  end
end
$bw.init
EncodingDetect.default_encoding = $config['default_encoding']


# ------------------------------------------------------------------------------
# create window and show

$app.paint $config['window']['size'], Cici::ZoomLayout do |v|
  v.pos = $config['window']['pos']

  # build menu
  require BW_ROOT + '/menu.rb'

  # editor
  $bw.sci = v.scintilla v.client_size
  require BW_ROOT + '/sci.rb'

  # statusbar
end

if __FILE__ == $PROGRAM_NAME
  $app.message_loop
end
