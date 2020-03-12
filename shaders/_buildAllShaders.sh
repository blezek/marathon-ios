path=$1

cd "$path/shaders"

rm shader_h/*_fs.h
rm shader_h/*_vs.h

renderer=metal

for vertex_shader in ./*_vs.sc; do
    echo Building vertex shader $vertex_shader
    file_base=`basename -s .sc ${vertex_shader}`

    ../submodules/Libraries/bgfx/bgfx/scripts/shadercRelease --platform ios -p ${renderer} --type vertex --varyingdef varying.def.sc --bin2c -f ${vertex_shader} -o shader_h/${renderer}_${file_base}.h
    
    result=$?
    if [ $result -gt 0 ]; then
        exit $result
    fi
done

for fragment_shader in ./*_fs.sc; do
    echo Building fragment shader $fragment_shader
    file_base=`basename -s .sc ${fragment_shader}`

    ../submodules/Libraries/bgfx/bgfx/scripts/shadercRelease --platform ios -p ${renderer} --type fragment --varyingdef varying.def.sc --bin2c -f ${fragment_shader} -o shader_h/${renderer}_${file_base}.h
    
    result=$?
    if [ $result -gt 0 ]; then
        exit $result
    fi
done
