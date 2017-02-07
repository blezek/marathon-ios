set Weighting --channel-weighting-linear
set BPP        --bits-per-pixel-4

# Try a large size, but 2bpp
set BPP        --bits-per-pixel-2
set TextureSize "256x256!"

set SizeLimit 256

set TopDir [pwd]
file mkdir WEP

cd WEP-Original/wep

set Files [exec find . -name *.dds -type f]

foreach file [lsort $Files] {
  set path [file dir $file]
  set image [file tail $file]

  set size [exec identify -format "%w %h" $file]
  set width [lindex $size 0]
  set height [lindex $size 1]
  if { $width > $height } {
    set maxDim $width
  } else {
    set maxDim $height
  }

  # Make sure maxDim is a power of 2
  set size 2
  while { $size < $maxDim } {
    set size [expr $size * 2]
  }
  set maxDim $size
  if { $maxDim > $SizeLimit } {
        set maxDim $SizeLimit
  }
  
  if { $width == $height } {
    set Compress 1
    set size "128x128!"
    set size $TextureSize
  } else {
    set Compress 1
    set size "${maxDim}x${maxDim}!"
  }

  puts "\t\tProcessing $path/$image"
  set tail [file tail $image]
  set base [file root $tail]
  set outputFile [file join $TopDir WEP $path $base.pvr]
  file mkdir [file dir $outputFile]
  
  set TempFile [file join $TopDir WEP-PNG $path $base.png]
  file mkdir [file dir $TempFile]
  
  # Square, so we resize
  exec convert $file -resize $size $TempFile
  puts "\t\tResized to $size"
  exec texturetool -e PVRTC -m -f PVR $Weighting $BPP -o $outputFile $TempFile
}


