File.open('gljs/left.html', 'w') {|w|
  w.print <<-EOS
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8' />
<title>Global Maps in binary bector tiles</title>
<style>
body { margin:0; padding:0; }
</style>
</head>
<body>
地図中心は東京にセット
<ul>
  EOS

  Dir.glob('gljs/*.html') {|path|
    id = File.basename(path, '.html')
w.print <<-EOS
<li><a target='right' href='#{id}.html'>#{id}</a></li>
EOS
  }

  w.print <<-EOS
</ul>
</body>
</html>
  EOS
}

File.open('gljs/index.html', 'w') {|w|
  w.print <<-EOS
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8' />
<title>GSI Tiles in Mapbox GL Style</title>
<style>
body { margin:0; padding:0; }
iframe {
  position: absolute
  top: 0; left: 0; width: 100%; height: 100%; border: 0;
}
</style>
</head>
<body>
<div style='position: absolute; width: 20%; height: 100%'>
  <iframe name='left' src='left.html'></iframe>
</div>
<div style='position: absolute; right: 0px; width: 80%; height: 100%'>
  <iframe name='right' src='ort.html'></iframe>
</div>
</body>
</html>
  EOS
}
