require 'json'

def process(layer)
  /{z}\/{x}\/{y}\.(.*?)$/.match(layer['url'])
  return unless %w{jpg png}.include?($1.to_s)
  (id, url, name, minzoom, maxzoom) =
    %w{id url title minZoom maxZoom}.map{|k| layer[k]}
  style = {
    :version => 8,
    :name => name,
    :sources => {
      id => {
        :type => 'raster',
        :tiles => [url],
        :tileSize => 256,
        :minzoom => minzoom ? minzoom : 0,
        :maxzoom => maxzoom ? maxzoom : 18,
        :attribution => "<a href='http://maps.gsi.go.jp/development/ichiran.html' target='_blank'>地理院タイル</a>"
      }
    },
    :layers => [{
      :id => id,
      :type => 'raster',
      :source => id,
      :paint => {'raster-fade-duration' => 100}
    }]
  }
  File.write("style/#{id}.json", JSON::dump(style))
end

def jump_into(entry)
  case entry['type']
  when 'Layer'
    process(entry)
  when 'LayerGroup'
    entry['entries'].each {|e|
      jump_into(e)
    } if entry['entries'] ## otherwise LayerGroup takes src
  else
    raise entry['type'] + 'is unknown'
  end
end

Dir.glob('../gsimaps/layers_txt/*.txt') {|path|
  next if File.basename(path) == 'anchor.txt'
  json = JSON::parse(File.read(path))
  json['layers'].each{|entry|
    jump_into(entry)
  }
}
