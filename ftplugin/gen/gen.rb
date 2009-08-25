require 'FileUtils'
FileUtils.cd File.expand_path(File.dirname(__FILE__))
require 'yaml'

dict = YAML.load_file 'dict'
theme = YAML.load_file 'theme'
keys = theme['styles'].keys + theme['highlights'].keys
keys << 'default'
keys << 'fold_margin'
Dir.glob('./*.yaml').each do |f|
  s = YAML.load_file f   # ruby.yaml
  /\.\/(?<base>\w+)\.yaml/ =~ f

  # ../ruby/color.rb
  out = File.open '../' + base + '/color.rb', 'w' 

  out << "# GENERATED FILE, PLEASE EDIT ../gen/#{base}.yaml INSTEAD\n"
  out << "s = Cici::SCE.new $bw.sci, $bw.theme\n"
  s.each do |k, v|
    # check if value is in theme
    puts "warning: #{v} not exist" unless keys.include? v
    out << %Q[s.s #{dict[k]},"#{v}"\n]
  end

  out.close
end
