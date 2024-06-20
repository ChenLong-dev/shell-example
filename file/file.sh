#!/bin/bash

# 获取运行服务器架构名称
ARCH=$(uname -m)

#echo -e "\033[30m ### 30:黑   ### \033[0m"
#echo -e "\033[31m ### 31:红   ### \033[0m"
#echo -e "\033[32m ### 32:绿   ### \033[0m"
#echo -e "\033[33m ### 33:黄   ### \033[0m"
#echo -e "\033[34m ### 34:蓝色 ### \033[0m"
#echo -e "\033[35m ### 35:紫色 ### \033[0m"
#echo -e "\033[36m ### 36:深绿 ### \033[0m"
#echo -e "\033[37m ### 37:白色 ### \033[0m"

# 获取shell脚本运行路径
SHELL_BASE_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

# 基础时间格式
DATE_BASE=$(date +%Y%m%d%H%M%S)

# 目的文件路径
DST_FILE_PATH=/tmp/${DATE_BASE}.tar.gz



# 检查结果函数
function check_result()
{
  result=$1
  object=$2
  if [ ${result} -ne 0 ]; then
    echo -e "\033[31m ### [check_result] result is failed! result:${result}, msg:${object}   ### \033[0m"
    exit 1
  fi
  echo -e "\033[32m ### [check_result] result is success! result:${result}, msg:${object}   ### \033[0m"
}

# 检查是否为文件函数
function check_file()
{
  file_path=$1
  if [ ! -f ${file_path} ] ; then
    echo -e "\033[31m ### [check_file] ${file_path} is not exist!   ### \033[0m"
    print_help
    exit 1
  fi
}

# 检查是否为目录函数
function check_dir() {
  file_path=$1
  if [ ! -d ${file_path} ] ; then
    echo -e "\033[31m ### [check_dir] ${file_path} is not exist!   ### \033[0m"
    print_help
    exit 1
  fi
}

# 压缩文件函数
function compress_files() {
  local src_path=$1
  local dst_path=${DST_FILE_PATH}

  if [ x${src_path} = x"" ]; then
    echo -e "\033[31m ### [compress_files] dir or file is none!   ### \033[0m"
    print_help
    exit 1
  fi

  if [ -d ${src_path} ] || [  -f ${src_path} ]; then
        tar -czPf ${dst_path} ${src_path}
        check_result $? "[compress_files] ${src_path} compress is failed!"
        check_file ${dst_path}
  fi
}

function scp_file_to_remote() {
  local scrpit_path=${SHELL_BASE_PATH}/scp.sh
  
  check_file ${scrpit_path}
  
  chmod +x ${scrpit_path}; ${scrpit_path} $@
}

function compress_and_scp() {
    local src_path=$1
    compress_files ${src_path}
    scp_file_to_remote ${DST_FILE_PATH} ${@:2}
}


function print_help {
    echo -e "\033[35m ######################### HELP ARCH:${ARCH} ######################### \033[0m"
    echo -e "\033[35m #sh file.sh {param} \033[0m"
    echo -e "\033[35m {param}: \033[0m"
    echo -e "\033[35m        -c        : Compressed [-c dir or file] eg: ./file.sh -c ../file \033[0m"
    echo -e "\033[35m        -s        : Scp  [-s option] eg: ./file.sh -s readme.md 8.138.122.199:22 /home/cl/tmp root root \033[0m"
    echo -e "\033[35m        -cs       : Compressed And Scp [-cs option] eg: ./file.sh -cs ../file 8.138.122.199:22 /home/cl/tmp root root \033[0m"
    echo -e "\033[35m        -help     : Help \033[0m"
    echo -e "\033[35m ######################### HELP ARCH:${ARCH} ######################### \033[0m"
    exit 1
}

function main() {
  echo -e "\033[34m ######################### sh remote.sh $@ ######################### \033[0m"
  case $1 in
    "-c")
      compress_files ${@:2}
      ;;
    "-s")
      scp_file_to_remote ${@:2}
      ;;
    "-cs")
      compress_and_scp ${@:2}
      ;;
    *)
      print_help
      ;;
  esac
}

main $@