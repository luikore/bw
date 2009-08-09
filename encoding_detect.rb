# coding: ascii-8bit
# note: string comparation is encoding first

# detect file encoding
# and provide a method to read file and encode to utf-8
class EncodingDetect

  attr_reader :bom, :encoding, :default_enc, :encode_error

  class << self
    attr_accessor :default_encoding
  end

  def initialize filename
    detect_bom File.binread(filename, 4)
    @filename = filename
  end

  def read
    f = File.open @filename, 'r:ascii-8bit'
    f.read @bom.bytesize # skip bom
    ret = f.read
    f.close

    if @encoding == 'utf-8'
      ret
    else
      begin
        @encode_error = false
        ret.encode 'utf-8', @encoding
      rescue
        @encode_error = true
        ret
      end
    end
  end

  def detect_bom bytes
    @encoding =
      if bytes[0..2] == "\xEF\xBB\xBF"
        @bom = "\xEF\xBB\xBF"
        'utf-8'

      elsif bytes == "\xFF\xFE\x00\x00"
        @bom = bytes
        'utf-32le'
      elsif bytes == "\x00\x00\xFE\xFF"
        @bom = bytes
        'utf-32be'
      elsif bytes == "\xFE\xFF\x00\x00"
        @bom = bytes
        'ucs-4le'
      elsif bytes == "\x00\x00\xFF\xFE"
        @bom = bytes
        'ucs-4be'

      elsif bytes[0..1] == "\xFF\xFE"
        @bom = "\xFF\xFE"
        'utf-16le'  # unicode in windows
      elsif bytes[0..1] == "\xFE\xFF"
        @bom = "\xFE\xFF"
        'utf-16be'  # unicode in java

      else
        @bom = ""
        EncodingDetect.default_encoding
      end
  end

  def detect_encoding
    # TODO see fencview.vim
  end
end

EncodingDetect.default_encoding = 'utf-8'
