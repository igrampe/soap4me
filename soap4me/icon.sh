#!/bin/sh
if [[ -z $1 ]] || [[ 1 -ne $1 ]] 
then
    echo "Icon will not be changed"
    exit
fi
echo "Changing Icon"
# номер версии
version=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${INFOPLIST_FILE}"`
# номер билда
build=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFOPLIST_FILE}"`
# если нужно, можно взять имя ветки из git
branch=`git rev-parse HEAD | git branch -a --contains | grep remotes | sed s/.*remotes.origin.//`

# функция генерации иконки
function processIcon() {
    export PATH=$PATH:/usr/local/bin
    base_file=$1
    target_icon_name=$2
    base_path=`find ${SRCROOT} -name $base_file`
    
    if [[ ! -f ${base_path} || -z ${base_path} ]]; then
    return;
    fi
    
    target_file=`echo $target_icon_name | sed "s/_base//"`
    target_path="${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${target_file}"
    
    width=`identify -format %w ${base_path}`
    
    convert -background '#0008' -fill white -font Helvetica-Neue -gravity south -size ${width}x -pointsize 26\
    caption:"${version} ${build}"\
    "${base_path}" +swap -gravity south -composite "${target_path}"

    convert -background '#0008' -fill white -font Helvetica-Neue -gravity north -size ${width}x -pointsize 26\
    caption:"${branch}"\
    "${target_path}" +swap -composite "${target_path}"
}

# запускаем генерацию
processIcon "icon-60@2x.png" "AppIcon60x60@2x.png"
processIcon "icon-60@3x.png" "AppIcon60x60@3x.png"