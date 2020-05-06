#!/bin/bash 
OUTPUT=$1
FRAMEWORK_PATH="${TARGET_BUILD_DIR}/${TARGET_NAME}.framework" 
echo "生成路径:$ FRAMEWORK_PATH" 
CURRENTPATH=$(cd $(dirname $0); pwd)
#SDK_OUTPUTFOLDER=${$CURRENTPATH} 
echo $CURRENTPATH 
echo ${PLATFORM_NAME} 
echo "对外输出目录文件路径:" 
OUTPUT_PATH=${CURRENTPATH}/$OUTPUT 
echo$ OUTPUT_PATH 
rm -rf "$OUTPUT_PATH/${TARGET_NAME}.framework" 
echo "源:$FRAMEWORK_PATH" 
echo "目标:$OUTPUT_PATH"
scp -r "$FRAMEWORK_PATH" "$OUTPUT_PATH" 
echo "结束"