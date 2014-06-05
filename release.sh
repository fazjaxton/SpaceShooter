#! /bin/sh

release_dir="release"
distrib_dir="../distrib"

game_name="SpaceShooter"
game_url="https://github.com/fazjaxton/SpaceShooter"

love_name="love-0.9.1"
mac_name="macosx-x64"
win32_name="win32"
win64_name="win64"

pushd $(dirname $0) > /dev/null

# Remove release directory if it exists
if [ -d ${release_dir} ]; then
    rm -rf ${release_dir}
fi

mkdir -p ${release_dir}

# Read game version
version=$(grep -o "game.version = \".*\"" main.lua | cut -d\" -f2)

# Build .love file
zipfiles=$(git ls-files --cached *.lua)
zipfiles+=" $(git ls-files --cached Assets/)"

game_name_ver=${game_name}-v${version}
game_bundle=${release_dir}/${game_name_ver}.love
zip ${game_bundle} ${zipfiles} > /dev/null

cp $(git ls-files README* *.txt) ${release_dir}

# Build win32 release
win32_path=${release_dir}/win32
win32_bundle=${distrib_dir}/${love_name}-${win32_name}.zip

mkdir ${win32_path}
unzip -j -d ${win32_path} ${win32_bundle} "*.dll" "*/license.txt" > /dev/null
unzip -p ${win32_bundle} "*/love.exe" | cat - ${game_bundle} > \
                    ${win32_path}/${game_name_ver}.exe

# Build win64 release
win64_path=${release_dir}/win64
win64_bundle=${distrib_dir}/${love_name}-${win64_name}.zip

mkdir ${win64_path}
unzip -j -d ${win64_path} ${win64_bundle} "*.dll" "*/license.txt" > /dev/null
unzip -p ${win64_bundle} "*/love.exe" | cat - ${game_bundle} > \
                    ${win64_path}/${game_name_ver}.exe

# Build mac release
mac_path=${release_dir}/mac
mac_bundle=${distrib_dir}/${love_name}-${mac_name}.zip
mac_app_dir=${mac_path}/${game_name_ver}.app

mkdir ${mac_path}
unzip -d ${mac_path} ${mac_bundle} "love.app/*" > /dev/null
mv ${mac_path}/love.app ${mac_app_dir}
cp ${game_bundle} ${mac_app_dir}/Contents/Resources

# This is pretty lazy ... need to write a real perl script to actually
# replace these values in the real file, but this works for now.
sed -e "s#PUTGAMEURLHERE#${game_url}#" \
    -e "s/PUTGAMENAMEHERE/${game_name}/" \
    -e "s/PUTGAMEVERSIONHERE/${version}/" \
      < CustomInfo.plist \
      > ${mac_app_dir}/Contents/Info.plist

popd > /dev/null
