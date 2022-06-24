#!/bin/bash

wikiname=$1
echo "Generating wiki evolution for $wikiname..."
echo

gource --help | head -n 1
ffmpeg --help 2>&1 | head -n2

echo

# settings
resolution=1900x1200
seconds_per_day=0.04
auto_skip_seconds=0.05
elasticity=0.01
fps=25
bitrate=5000K
extension=webm

# environment
dir=`dirname $0`

echo "My directory: $dir"

# set up the environment
workdir="/tmp/wiki-evolution/output/$wikiname"
mkdir -p $workdir

input=$workdir"/log.gource"
output=$workdir"/movie.$extension"

echo "Input:        $input"
echo "Rendering to: $output"
echo

# call wiki2gource
if [ ! -f $input ]; then
	echo "Calling wiki2gource..."
	/usr/bin/env node $dir/wiki2gource.js $wikiname $EDITS_COMPRESSION | sort > $input
else
	echo "$input exists, remove to regenerate"
fi

echo
echo "Rendering $extension at $resolution @ $fps fps to $output..."
echo

# TODO: fetch custom backgrounds and logos #	--stop-at-end \

# call gource
xvfb-run -a -s "-screen 0 $resolution""x16" gource \
  -t 10 \
	--log-format custom \
	--seconds-per-day $seconds_per_day \
	--auto-skip-seconds $auto_skip_seconds \
	--elasticity $elasticity \
	--highlight-users \
	--background-colour 222222 \
	--hide dirnames,progress,mouse \
	--font-size 16 \
	--title "wiki-evolution for $wikiname" \
	--user-filter "Wikiw?W?orks*" \
	--user-friction 0.5 \
	--filename-time 0.5 \
	--filename-colour 02FB73 \
	--highlight-users \
  --highlight-colour FB02CA \
	--dir-colour 02FB73 \
	-$resolution \
	--output-ppm-stream - \
	--output-framerate $fps \
	$input | ffmpeg -y -r $fps -f image2pipe -vcodec ppm -i - -b:v $bitrate -vcodec libvpx $output

echo
echo "Done, enjoy!"
