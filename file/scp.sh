#!/bin/sh
#@auth cl
#@time 20240619

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

# 远程服务器地址列表，可以添加一些默认地址，命令参数的地址也会加到这个列表中
REMOTE_HOST_LIST=() #("10.213.151.62:22345", "10.2.23.6:22")

# 远程服务器的默认端口，当获取不到端口时，会取默认端口， 如：“10.2.23.6:”，该端口会取22
DEFAULT_PORT=22


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

# 传输文件到远程服务器上的函数
function scp_file_to_remote()
{
  local_file_path=$1  # 本地文件路径
  remote_host=$2      # 远程服务器地址
  remote_file_path=$3 # 远程文件路径
  username=$4         # 远程服务器用户名
  password=$5         # 远程服务器密码

  # 检查参数是否为空，为空将打印帮助并退出程序
  if [ x${local_file_path} = x"" ]; then
    echo -e "\033[31m ###  local_file_path is none!  ### \033[0m"
    print_help
    exit 1
  fi

  if [ x${remote_file_path} = x"" ]; then
    echo -e "\033[31m ###  remote_file_path is none!  ### \033[0m"
    print_help
    exit 1
  fi

  if [ x${username} = x"" ]; then
    echo -e "\033[31m ###  username is none!  ### \033[0m"
    print_help
    exit 1
  fi

  if [ x${password} = x"" ]; then
    echo -e "\033[31m ###  password is none!  ### \033[0m"
    print_help
    exit 1
  fi

  # 将命令参数中的远程服务器加入到远程服务器地址列表
  local remote_host_list=${REMOTE_HOST_LIST}
  if [ x${remote_host} = x"" ]; then
    echo -e "\033[31m ###  remote_host is None!  ### \033[0m"
    print_help
    exit 1
  else
    remote_host_list+=(${remote_host})
  fi

  # 将文件加入到本地文件路径列表中
  local local_root_path=""  # 本地文件根目录
  local_file_path_list=()   # 本地文件路径列表
  if [ -d ${local_file_path} ]; then # 多文件目录：遍历递归获取多目录文件及路径（本地绝对路径）
    echo -e "\033[37m ### this is dir: ${local_file_path} ### \033[0m"
    local_root_path=`dirname ${local_file_path}`
    local_file_path_list=`find ${local_file_path} -print` # 遍历递归获取
  elif [ -f ${local_file_path} ]; then # 单文件（本地绝对路径或本地相对路径）
    echo -e "\033[37m ### this is file: ${local_file_path} ### \033[0m"
    local_file_path_list+=${local_file_path}
  else
    echo -e "\033[31m ### ${local_file_path}'s type is error!   ### \033[0m"
    exit 1
  fi

  echo -e "\033[37m ### input param is local_file_path_list:${local_file_path_list[@]}   ### \033[0m"
  echo -e "\033[37m ### remote_host_list:${remote_host_list[@]}, remote_file_path:${remote_file_path}, username:${username}, password:${password}, local_root_path:${local_root_path}     ### \033[0m"

  for host in ${remote_host_list[@]}; do # 遍历远程服务器地址列表
    ip_str=$(echo ${host} | awk -F ':' '{print $1}') # 将ip:port格式的host拆解为ip和port字符串
    port_str=$(echo ${host} | awk -F ':' '{print $2}')

    if [ x${port_str} = x"" ]; then
      port_str=${DEFAULT_PORT}
    fi

    if [ x${ip_str} = x"" ] && [ x${port_str} = x"" ]; then
      echo -e "\033[31m ### host is error! host:{host}  ### \033[0m"
      continue
    fi

    for file in ${local_file_path_list[@]}; do # 遍历本地文件路径列表
      if [ x${local_root_path} != x"" ] && [ -d ${local_root_path} ]; then # 如果是多目录文件，根据本地文件根目录local_root_path来判断
        local relative_path="${file#${local_root_path}/}"
        local remote_dir=${remote_file_path}/${relative_path}
        if [ -d ${file} ]; then # 如果是目录，就要去远端创建目录
          echo -e "\033[33m ### remote mkdir ${file} ${username}:${password}@[${ip_str}:${port_str}]:${remote_dir}   ### \033[0m"
          remote_mkdir ${ip_str} ${port_str} ${remote_dir} ${username} ${password} # 在远程服务器上创建目录
        else # 如果是文件
          echo -e "\033[33m ### multiple dir scp ${file} ${username}:${password}@[${ip_str}:${port_str}]:${remote_dir}   ### \033[0m"
          scp_file ${ip_str} ${port_str} ${file} ${remote_dir} ${username} ${password} # 调用传输文件函数
        fi
      else # 如果是单文件
        echo -e "\033[33m ### single scp ${file} ${username}:${password}@[${ip_str}:${port_str}]:${remote_file_path}   ### \033[0m"
        scp_file ${ip_str} ${port_str} ${file} ${remote_file_path} ${username} ${password} # 调用传输文件函数
      fi
    done
  done
}

# 创建远程文件函数
function remote_mkdir() {
  local ip_str=$1
  local port_str=$2
  local remote_dir=$3
  local username=$4
  local password=$5

  if [ x${ip_str} = x"" ] || [ x${port_str} = x"" ] || [ x${remote_dir} = x"" ] || [ x${username} = x"" ] || [ x${password} = x"" ]; then
    echo -e "\033[31m ### [remote_mkdir] param is error! $@   ### \033[0m"
    return 1
  fi

  local result=0
  local msg=""
  if which sshpass >/dev/null; then
    echo -e "\033[37m ### sshpass exists!  ### \033[0m"
    sshpass -p ${password} ssh -p ${port_str} ${username}@${ip_str} "mkdir -p ${remote_dir}"
    result=$?
    msg="sshpass -p ${password} ssh -p ${port_str} ${username}@${ip_str} mkdir -p ${remote_dir}"
    if [ ${result} -eq 6 ];then  # Host key verification failed.
      ssh -p ${port_str} ${username}@${ip_str} "mkdir -p ${remote_dir}"
      result=$?
      msg="ssh -p ${port_str} ${username}@${ip_str} mkdir -p ${remote_dir}"
    fi
  else
    echo -e "\033[37m ### sshpass not found!  ### \033[0m"
    ssh -p ${port_str} ${username}@${ip_str} "mkdir -p ${remote_dir}"
    result=$?
    msg="ssh -p ${port_str} ${username}@${ip_str} mkdir -p ${remote_dir}"
  fi

  check_result ${result} "${msg}"
}

# 传送文件函数
function scp_file()
{
  local ip_str=$1
  local port_str=$2
  local file=$3
  local remote=$4
  local username=$5
  local password=$6

  if [ x${ip_str} = x"" ] || [ x${port_str} = x"" ] || [ x${remote} = x"" ] || [ x${username} = x"" ] || [ x${password} = x"" ]; then
    echo -e "\033[31m ### [scp_file] param is error! $@   ### \033[0m"
    return 1
  fi

  if [ ! -f ${file} ]; then
    echo -e "\033[31m ### ${file} is not file!   ### \033[0m"
    return 1
  fi

  local result=0
  local msg=""
  if which sshpass >/dev/null; then
    echo -e "\033[37m ### sshpass exists!  ### \033[0m"
    sshpass -p ${password} scp -P ${port_str} ${file} ${username}@${ip_str}:${remote}
    result=$?
    msg="sshpass -p ${password} scp -P ${port_str} ${file} ${username}@${ip_str}:${remote}"
    if [ ${result} -eq 6 ];then  # Host key verification failed.
      scp -P ${port_str} ${file} ${username}@${ip_str}:${remote}
      result=$?
      msg="scp -P ${port_str} ${file} ${username}@${ip_str}:${remote}"
    fi
  else
    echo -e "\033[37m ### sshpass not found!  ### \033[0m"
    scp -P ${port_str} ${file} ${username}@${ip_str}:${remote}
    result=$?
    msg="scp -P ${port_str} ${file} ${username}@${ip_str}:${remote}"
  fi

  check_result ${result} "${msg}"
}

function print_help {
    echo -e "\033[35m ######################### HELP ARCH:${ARCH} ######################### \033[0m"
    echo -e "\033[35m #sh scp_file.sh {param} \033[0m"
    echo -e "\033[35m {param}: \033[0m"
    echo -e "\033[35m        - 1       : local file path(dir or file) \033[0m"
    echo -e "\033[35m        - 2       : remote host(ip:port)  \033[0m"
    echo -e "\033[35m        - 3       : remote file path(dir) \033[0m"
    echo -e "\033[35m        - 4       : username of remote host \033[0m"
    echo -e "\033[35m        - 5       : password of remote host \033[0m"
    echo -e "\033[35m        - help    : help \033[0m"
    echo -e "\033[35m        - example : sh scp.sh [1:local_file_path] [2:remote_host] [3:remote_file_path] [4:username] [5:password] \033[0m"
    echo -e "\033[35m ######################### HELP ARCH:${ARCH} ######################### \033[0m"
    exit 1
}

function main()
{
  echo -e "\033[37m ### input param is $@    ### \033[0m"
  if [ x$1 = x"help" ] || [ x$1 = x"--help" ] || [ x$1 = x"h" ] || [ x$1 = x"-h" ]; then
    print_help
  fi
  scp_file_to_remote $@
}

main $@