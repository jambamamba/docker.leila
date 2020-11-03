#!/bin/bash -e
set -e
#example usage, if input files are 01.png, 02.png, ... 99.png
#~/imagestomp4.sh /home/oosman/projects/SmartBikeHelmet/15/a %02d.png

#https://www.imakewebsites.ca/posts/2016/10/30/ffmpeg-concatenating-with-image-sequences-and-audio/
#https://hamelot.io/visualization/using-ffmpeg-to-convert-a-set-of-images-into-a-video/

function parseArgs()
{
  for change in $@; do
      set -- `echo $change | tr '=' ' '`
      echo "variable name == $1  and variable value == $2"
      #can assign value to a variable like below
      eval $1=$2;
  done
}

function ffimagesToVideo()
{
	parseArgs $1
	pushd $INPUT_FILE_PATH
	rm -f out.mp4
	VFRAMES=$(ls -1 *.png|wc -l)
	$FFMPEG -start_number $START_FRAME  -framerate $INPUT_FRAME_RATE -r $OUTPUT_FRAME_RATE -i $INPUT_FILE_PATH/$INPUT_FILE_GLOB -c:v libx264 -vf fps=30 -b 8M -pix_fmt yuv420p -crf $QUALITY out.mp4
	popd
}

function ffvideoToImages()
{
	parseArgs $1
	INPUT_DIR=$(dirname $INPUT_FILE_PATH)
	pushd $INPUT_DIR
	$FFMPEG -i $INPUT_FILE_PATH -vf fps=$OUTPUT_FRAME_RATE $INPUT_DIR/out.%d.png
	popd
#(b/w 2 and 6 seconds, and between 15 and 24 seconds
#ffmpeg -i in.mp4 -vf select='between(t,2,6)+between(t,15,24)' -vsync 0 out%d.png
}

function ffextractAudio()
{
	parseArgs $1
	INPUT_DIR=$(dirname $INPUT_FILE_PATH)
	FILE_NAME=$(basename $INPUT_FILE_PATH)
	pushd $INPUT_DIR
	rm -f $INPUT_DIR/$FILE_NAME.aac
	$FFMPEG -i $INPUT_FILE_PATH -vn -acodec copy $INPUT_DIR/$FILE_NAME.aac
	popd
}

function ffextractVideo()
{
	parseArgs $1
	INPUT_DIR=$(dirname $INPUT_FILE_PATH)
	FILE_NAME=$(basename $INPUT_FILE_PATH)
	pushd $INPUT_DIR
	rm -f $INPUT_DIR/$FILE_NAME.out.mp4
	#$FFMPEG -ss $FROM -t $TO -i $INPUT_FILE_PATH -c:v copy -c:a copy $INPUT_DIR/$FILE_NAME.out.mp4
	$FFMPEG -ss $FROM -t $TO -i $INPUT_FILE_PATH -c:v libx264 -vf fps=30 -b 8M -pix_fmt yuv420p -crf $QUALITY $INPUT_DIR/$FILE_NAME.out.mp4
	popd
}

function ffstripAudio()
{
	parseArgs $1
	INPUT_DIR=$(dirname $INPUT_FILE_PATH)
	FILE_NAME=$(basename $INPUT_FILE_PATH)
	pushd $INPUT_DIR
	rm -f $INPUT_DIR/$FILE_NAME.out.mp4
	$FFMPEG -i $INPUT_FILE_PATH -c copy -an $INPUT_DIR/$FILE_NAME.noaudio.mp4
	popd
}

function ffflipVideo()
{
	parseArgs $1
	INPUT_DIR=$(dirname $INPUT_FILE_PATH)
	FILE_NAME=$(basename $INPUT_FILE_PATH)
	pushd $INPUT_DIR
	rm -f $INPUT_DIR/$FILE_NAME.out.mp4
	$FFMPEG -i $INPUT_FILE_PATH -vf $FLIP -c:a copy $INPUT_DIR/$FILE_NAME.flipped.mp4
	popd
}

function ffrotateVideo()
{
	parseArgs $1
	INPUT_DIR=$(dirname $INPUT_FILE_PATH)
	FILE_NAME=$(basename $INPUT_FILE_PATH)
	pushd $INPUT_DIR
	rm -f $INPUT_DIR/$FILE_NAME.out.mp4
	$FFMPEG -i $INPUT_FILE_PATH -vf transpose=$CLOCKWISE -c:a copy $INPUT_DIR/$FILE_NAME.flipped.mp4
	popd
}

function ffmetadata()
{
	parseArgs $1
	INPUT_DIR=$(dirname $INPUT_FILE_PATH)
	FILE_NAME=$(basename $INPUT_FILE_PATH)
	pushd $INPUT_DIR
	rm -f $INPUT_DIR/$FILE_NAME.out.mp4
	$FFMPEG -i $INPUT_FILE_PATH -f ffmetadata $INPUT_DIR/$FILE_NAME.txt
	cat $INPUT_DIR/$FILE_NAME.txt
	popd
}

function ffmix()
{
	parseArgs $1
	INPUT_DIR=$(dirname $INPUT_FILE_PATH)
	FILE_NAME=$(basename $INPUT_FILE_PATH)
	pushd $INPUT_DIR
	rm -f $INPUT_DIR/$FILE_NAME.out.mp4
	$FFMPEG -i $INPUT_FILE_PATH -i $INPUT_AUDIO_PATH -acodec copy -vcodec copy $INPUT_DIR/$FILE_NAME.out.mp4
	popd
}

function ffoverlayImage()
{
#ffmpeg -i input.mp4 -i image.png \
-filter_complex "[0:v][1:v] overlay=25:25:enable='between(t,0,20)'" \
-pix_fmt yuv420p -c:a copy \
output.mp4
	parseArgs $1
	INPUT_DIR=$(dirname $INPUT_FILE_PATH)
	FILE_NAME=$(basename $INPUT_FILE_PATH)
	pushd $INPUT_DIR
	rm -f $INPUT_DIR/$FILE_NAME.out.mp4
	$FFMPEG -i $INPUT_FILE_PATH -i $INPUT_IMAGE_PATH -filter_complex "[0:v][1:v] overlay=25:25:enable='between(t,0,20)'" -pix_fmt yuv420p -c:a copy  $INPUT_DIR/$FILE_NAME.out.mp4
	popd

}

function ffreencode()
{
#ffmpeg -i input.mp4 -c:v libx264 -crf 18 -preset slow -c:a copy output.mp4
	parseArgs $1
	INPUT_DIR=$(dirname $INPUT_FILE_PATH)
	FILE_NAME=$(basename $INPUT_FILE_PATH)
	pushd $INPUT_DIR
	rm -f $INPUT_DIR/$FILE_NAME.out.mp4
	$FFMPEG -i $INPUT_FILE_PATH -c:v libx264 -b 8M -pix_fmt yuv420p -crf $QUALITY $INPUT_DIR/$FILE_NAME.out.mp4
	#-vf fps=30 
	popd
}

function ffhelp()
{
	echo "Helper script with macros that let you perform media operations:"
	echo "	ff.sh fn=metadata INPUT_FILE_PATH=x"
	echo "	ff.sh rfn=eencode INPUT_FILE_PATH=x <QUALITY=0-25>"
	echo "	ff.sh fn=overlayImage INPUT_FILE_PATH=x INPUT_IMAGE_PATH=x"
	echo "	ff.sh fn=mix INPUT_FILE_PATH=x INPUT_AUDIO_PATH=x"
	echo "	ff.sh fn=rotateVideo INPUT_FILE_PATH=x CLOCKWISE=1|2"
	echo "	ff.sh fn=flipVideo INPUT_FILE_PATH=x FLIP=0|1"
	echo "	ff.sh fn=stripAudio INPUT_FILE_PATH=x"
	echo "	ff.sh fn=extractVideo INPUT_FILE_PATH=x FROM=x TO=x QUALITY=0-25"
	echo "	ff.sh fn=extractAudio INPUT_FILE_PATH=x"
	echo "	ff.sh fn=videoToImages INPUT_FILE_PATH=x OUTPUT_FRAME_RATE=x"
	echo "	ff.sh fn=imagesToVideo INPUT_FILE_PATH=x INPUT_FILE_GLOB=x START_FRAME=x INPUT_FRAME_RATE=x OUTPUT_FRAME_RATE=x"
}


#INPUT_FILE_PATH=$1
#file%02d.png for file01.png to file99.png
#INPUT_FILE_GLOB=$2
#export LD_LIBRARY_PATH=/opt/bf-booby-screen-recorder/gpl
#FFMPEG=/opt/bf-booby-screen-recorder/gpl/ffmpeg
FFMPEG=~/$DOCKERUSER/.libs/ffmpeg/ffmpeg
START_FRAME=0
#END_FRAME=
#-vframes=$END_FRAME
INPUT_FRAME_RATE=1
OUTPUT_FRAME_RATE=5
QUALITY=25

parseArgs $@

if [ "$fn"="" ]; then
	ffhelp
	exit 0
fi

ff$fn

#imagesToVideo INPUT_FILE_PATH=$INPUT_FILE_PATH FFMPEG=$FFMPEG START_FRAME=$START_FRAME INPUT_FRAME_RATE=$INPUT_FRAME_RATE OUTPUT_FRAME_RATE=$OUTPUT_FRAME_RATE INPUT_FILE_PATH=$INPUT_FILE_PATH INPUT_FILE_GLOB=$INPUT_FILE_GLOB QUALITY=$QUALITY

#videoToImages INPUT_FILE_PATH=$INPUT_FILE_PATH OUTPUT_FRAME_RATE=$OUTPUT_FRAME_RATE
#extractAudio INPUT_FILE_PATH=$INPUT_FILE_PATH

#FROM and TO are time hh:mm:ss.mmmm 
#extractVideo "INPUT_FILE_PATH=$INPUT_FILE_PATH FROM=$2 TO=$3"

#stripAudio INPUT_FILE_PATH=$INPUT_FILE_PATH

#flipVideo "INPUT_FILE_PATH=$INPUT_FILE_PATH FLIP=vflip"
#rotateVideo INPUT_FILE_PATH=$INPUT_FILE_PATH CLOCKWISE=1 #2 for counterclockwise

#metaData INPUT_FILE_PATH=$INPUT_FILE_PATH

#mix "INPUT_FILE_PATH=$INPUT_FILE_PATH INPUT_AUDIO_PATH=$2"
#overlayImage "INPUT_FILE_PATH=$INPUT_FILE_PATH INPUT_IMAGE_PATH=$2"

#reencode INPUT_FILE_PATH=$INPUT_FILE_PATH
