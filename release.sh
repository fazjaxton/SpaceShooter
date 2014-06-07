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

info_files=$(git ls-files README* *.txt)

# Build Linux release
linux_dir=${game_name_ver}-linux
linux_path=${release_dir}/${linux_dir}

mkdir ${linux_path}
cp ${info_files} ${linux_path}
cp ${game_bundle} ${linux_path}
pushd ${release_dir} > /dev/null
zip -r ${linux_dir}.zip ${linux_dir} > /dev/null
popd > /dev/null

# Build win32 release
win32_dir=${game_name_ver}-win32
win32_path=${release_dir}/${win32_dir}
win32_bundle=${distrib_dir}/${love_name}-${win32_name}.zip

mkdir ${win32_path}
cp ${info_files} ${win32_path}
unzip -j -d ${win32_path} ${win32_bundle} "*.dll"  > /dev/null
unzip -p ${win32_bundle} "*/license.txt" > ${win32_path}/license-love.txt
unzip -p ${win32_bundle} "*/love.exe" | cat - ${game_bundle} > \
                    ${win32_path}/${game_name_ver}-win32.exe
pushd ${release_dir} > /dev/null
zip -r ${win32_dir}.zip ${win32_dir} > /dev/null
popd > /dev/null

# Build win64 release
win64_dir=${game_name_ver}-win64
win64_path=${release_dir}/${win64_dir}
win64_bundle=${distrib_dir}/${love_name}-${win64_name}.zip

mkdir ${win64_path}
cp ${info_files} ${win64_path}
unzip -j -d ${win64_path} ${win64_bundle} "*.dll" > /dev/null
unzip -p ${win64_bundle} "*/license.txt" > ${win64_path}/license-love.txt
unzip -p ${win64_bundle} "*/love.exe" | cat - ${game_bundle} > \
                    ${win64_path}/${game_name_ver}-win64.exe
pushd ${release_dir} > /dev/null
zip -r ${win64_dir}.zip ${win64_dir} > /dev/null
popd > /dev/null

# Build mac release
mac_dir=${game_name_ver}-mac
mac_path=${release_dir}/${mac_dir}
mac_bundle=${distrib_dir}/${love_name}-${mac_name}.zip
mac_app_dir=${mac_path}/${game_name_ver}.app

mkdir ${mac_path}
cp ${info_files} ${mac_path}
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

pushd ${release_dir} > /dev/null
zip -r ${mac_dir}.zip ${mac_dir} > /dev/null
popd > /dev/null

popd > /dev/null
