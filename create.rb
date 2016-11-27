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
  File.open("gljs/#{id}.html", 'w') {|w|
    w.print <<-EOS
<!doctype html>
<html>
<head>
  <meta charset='UTF-8' />
  <meta name='viewport' content='initial-scale=1,maximum-scale=1,user-scalable=no' />
  <link href='https://api.mapbox.com/mapbox-gl-js/v0.28.0/mapbox-gl.css' rel='stylesheet' />
  <script src='https://api.mapbox.com/mapbox-gl-js/v0.28.0/mapbox-gl.js'></script>
  <style>
  html { height: 100%; }
  body { margin:0; padding:0; height: 100%; }
  #map { height: 100%; width:100%; }
  </style>
</head>
<body>
<div id='map' />
<script>
  var map = new mapboxgl.Map({
    container: 'map', hash: true,
    center: [139.77669, 35.68418],
    zoom: 10, minzoom: 0, maxzoom: 17,
    style: '../style/#{id}.json'
  });
</script>
</body>
</html>
    EOS
  }
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
