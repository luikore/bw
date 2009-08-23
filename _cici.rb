# try to require gem lib, load the local one if failed
begin
  require 'cici'
rescue Exception => e
  require File.expand_path(File.dirname(__FILE__)) + '/../cici/lib/cici.rb'
end
