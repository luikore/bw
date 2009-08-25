path = File.expand_path(File.dirname(__FILE__))
require path + '/../_cici.rb'
App = Cici.app 'theme editor'

App.paint [440, 740] do |v|
  v.pos = 200, 20
  v.marginx = 10
  v.br 10
  v.paint([5, 5]).destroy # padding left

  v.button 'open' do
    if f = App.choose_file
      $theme = YAML.load_file f \
        rescue App.alert 'file not found'
      
      # redraw color groups
      x, y = $color_groups.pos
      $color_groups.destroy
      v.instance_variable_set "@turtlex", x
      v.instance_variable_set "@turtley", y
      $color_groups = v.paint [400, 670]
      $color_groups.extend ColorGroups
      $color_groups.draw
      $theme_f = f
    end
  end

  v.button 'save' do
    File.open $theme_f, 'w' do |f|
      f << YAML.dump($theme)
    end if $theme_f
  end

  v.button 'save as' do
    file = App.save_file
    File.open file, 'w' do |f|
      f << YAML.dump($theme)
    end if file
  end

  v.br 12
  $color_groups = v.paint [400, 670]
end

module ColorGroups
  public

  def attr_text v, title
    v.paint [120, 20] do |v|
      fore, back = $theme['default']
      v.bkcolor = back
      t = v.text title.gsub('_',' ')
      t.bkcolor = back
      t.color = fore
    end
  end

  def color_box v, loc, k
    v.paint [30, 18] do |v|
      v.bkcolor = loc[k]
      v.border_stroke = Stroke[$theme['default'][0], solid: 1]
      v.onclick = proc do
        c = App.choose_color
        if c
          loc[k] = c[0]
          v.bkcolor = loc[k]
        end
      end
    end
  end

  def color_group v, key
    $theme[key].each do |name, color|
      attr_text v, name

      if color.is_a? Array
        color_box v, color, 0
        color_box v, color, 1
      else
        color_box v, $theme[key], name
      end
      v.br 1
    end
  end

  def draw
    fore, back = $theme['default']
    App.main_window.bkcolor = back
    self.bkcolor = back
    self.border_stroke = Stroke[back, solid: 1]

    # main and highlights
    paint [230, 670] do |v|
      v.br 21
      attr_text v, 'default color'
      color_box v, $theme['default'], 0
      v.br 1

      attr_text v, 'background'
      color_box v, $theme['default'], 1
      v.br 1

      attr_text v, 'fold margin color'
      color_box v, $theme, 'fold_margin'
      v.br 21

      color_group v, 'highlights'
      v.border_stroke = Stroke[back, solid: 1]
    end

    # styles
    paint [200, 670] do |v|
      color_group v, 'styles'
      v.border_stroke = Stroke[back, solid: 1]
    end

  end
end

GC.start
App.message_loop
