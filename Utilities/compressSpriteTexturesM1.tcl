set Scenario [lindex $argv 0]
puts "Compressing $Scenario"

set Vision(0)  "1.000000 1.000000 1.000000 0"
set Vision(1)  "1.000000 1.000000 0.000000 1"
set Vision(2)  "1.000000 1.000000 1.000000 0"
set Vision(3)  "1.000000 1.000000 1.000000 0"
set Vision(4)  "1.000000 1.000000 0.000000 1"
set Vision(5)  "1.000000 1.000000 1.000000 0"
set Vision(6)  "1.000000 1.000000 1.000000 0"
set Vision(7)  "0.000000 1.000000 0.000000 1"
set Vision(8)  "1.000000 1.000000 1.000000 0"
set Vision(9)  "1.000000 0.000000 0.000000 1"
set Vision(10)  "1.000000 1.000000 1.000000 0"
set Vision(11)  "1.000000 1.000000 1.000000 0"
set Vision(12)  "1.000000 1.000000 0.000000 1"
set Vision(13)  "1.000000 1.000000 0.000000 1"
set Vision(14)  "1.000000 1.000000 1.000000 0"
set Vision(15)  "1.000000 1.000000 1.000000 0"
set Vision(16)  "0.000000 0.000000 1.000000 1"
set Vision(17)  "1.000000 1.000000 1.000000 0"
set Vision(18)  "1.000000 1.000000 1.000000 0"
set Vision(19)  "0.000000 0.000000 1.000000 1"
set Vision(20)  "1.000000 1.000000 1.000000 0"
set Vision(21)  "1.000000 1.000000 1.000000 0"
set Vision(22)  "1.000000 1.000000 1.000000 0"
set Vision(23)  "1.000000 1.000000 1.000000 0"
set Vision(24)  "0.000000 0.000000 1.000000 1"
set Vision(25)  "1.000000 1.000000 1.000000 0"
set Vision(26)  "1.000000 1.000000 1.000000 0"
set Vision(27)  "1.000000 1.000000 1.000000 0"
set Vision(28)  "1.000000 1.000000 1.000000 0"
set Vision(29)  "1.000000 1.000000 1.000000 0"
set Vision(30)  "0.000000 0.000000 1.000000 1"
set Vision(31)  "1.000000 1.000000 1.000000 0"


set Weighting --channel-weighting-linear
set BPP        --bits-per-pixel-4
set TextureSize "256x256!"

set BPP        --bits-per-pixel-2
set TextureSize "256x256!"
# Can't do 128, just too many textures
set TextureSize "128x128!"

set TopDir [pwd]
file mkdir SpriteTextures-$Scenario

set fid [open SpriteTextures-$Scenario/Sprites.mml w]
puts $fid "<marathon>"
puts $fid "<opengl>"

cd SpriteTextures-$Scenario-Original

# 9 is PfhorFighter
foreach collection [lsort [glob *]] {
  cd $collection
  set InfraVision [lindex $Vision($collection) 3]
  puts "Collection $collection : $InfraVision"
  foreach clut [lsort [glob *]] {
    puts "\tCLUT: $clut"
    foreach file [lsort [glob $clut/*mask.bmp]] {
      set mask $file
      set image [string replace $mask end-7 end-4]
      # Figure out the bitmap number
      set bitmap [string range $image end-6 end-4]
      set bitmap [string trimleft $bitmap 0]
      if { $bitmap == "" } { set bitmap 0 }
      
      # Convert to 128x128
      puts "\t\tProcessing $image"
      set tail [file tail $image]
      set base [file root $tail]
      set outputFile [file join $TopDir SpriteTextures-$Scenario $collection $clut $base.pvr]
      file mkdir [file dir $outputFile]

      set TempFile [file join $TopDir SpriteTextures-$Scenario-PNG $collection $clut $base.png]
      file mkdir [file dir $TempFile]

      set size [exec identify -format "%w %h" $image]
      set width [lindex $size 0]
      set height [lindex $size 1]
      if { $width > $height } {
        set maxDim $width
      } else {
        set maxDim $height
      }

      # What size to build?  Cap to 128x128?
      if { $maxDim > 100 } {
        set size $TextureSize
      } else {
        set s 4
        while { $s < $maxDim } {
          set s [expr $s * 2]
        }
        if { $s < 16 } {
          puts "\t\t\tNot encoding $image"
          continue
        }
        set size "${s}x${s}!"
      }
      puts "\t\t\tResizing to $size"

      exec convert $image $mask +matte -compose CopyOpacity -composite -filter Catrom -resize $size $TempFile
      exec texturetool -e PVRTC -m -f PVR $Weighting $BPP -o $outputFile $TempFile
      puts $fid "<texture coll=\"$collection\" bitmap=\"$bitmap\" normal_image=\"SpriteTextures-$Scenario/$collection/$clut/$base.pvr\" clut=\"$clut\"/>"

      if { $InfraVision } {
        set VisionFile [file join [file dir $outputFile] $base-IR.pvr]
        set VisionTempFile [file join $TopDir SpriteTextures-$Scenario-PNG $collection $clut $base-IR.png]
        puts "\t\t\tCreating Vision file"
        set R [lindex $Vision($collection) 0]
        set G [lindex $Vision($collection) 1]
        set B [lindex $Vision($collection) 2]
        exec convert $TempFile -channel red -fx "(r+b+g)/3.0*$R" -channel green -fx "(r+b+g)/3.0*$G"  -channel blue -fx "(r+b+g)/3.0*$B" $VisionTempFile
        exec texturetool -e PVRTC -m -f PVR $Weighting $BPP -o $VisionFile $VisionTempFile
        # NB, clut 8 is Infravision, 9 is silhouette
        puts $fid "<texture coll=\"$collection\" bitmap=\"$bitmap\" normal_image=\"SpriteTextures-$Scenario/$collection/$clut/$base-IR.pvr\" clut=\"8\"/>"
      }
    }
  }
  cd ..
}

puts $fid "</opengl>"
puts $fid "</marathon>"
close $fid



# 1000. Interface
# 1001. Weapons in Hand
# 1002. Juggernaut
# 1003. Tick
# 1004. Explosion Effects
# 1005. Hunter
# 1006. Player
# 1007. Items
# 1008. Trooper
# 1009. Pfhor Fighter
# 1010. S'pht'Kr
# 1011. F'lickta
# 1012. Bob
# 1013. VacBob
# 1014. Enforcer
# 1015. Drone
# 1016. S'pht
# 1017. Walls - Water
# 1018. Walls - Lava
# 1019. Walls - Sewage
# 1020. Walls - Jjaro
# 1021. Walls - Pfhor
# 1022. Scenery - Water
# 1023. Scenery - Lava
# 1024. Scenery - Sewage
# 1025. Scenery - Jjaro
# 1026. Scenery - Pfhor
# 1027. Landscape - Day
# 1028. Landscape - Night
# 1029. Landscape - Moon
# 1030. Landscape - Outer Space
# 1031. Cyborg 
