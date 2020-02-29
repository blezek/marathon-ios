path=$1

cd "$path/shaders"

rm *_fs.h
rm *_vs.h

../submodules/Libraries/bgfx/bgfx/scripts/shadercRelease --platform ios -p metal --type vertex --varyingdef varying.def.sc --bin2c -f quad_vs.sc -o quad_vs.h
../submodules/Libraries/bgfx/bgfx/scripts/shadercRelease --platform ios -p metal --type fragment --varyingdef varying.def.sc --bin2c -f quad_fs.sc -o quad_fs.h

