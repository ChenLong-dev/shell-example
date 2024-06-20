
<!-- markdownlint-disable MD040 -->

# 使用说明

## 1、 [file.sh](./file.sh) 使用方法

功能：

- 文件压缩：-c
- 文件远程传输：-s
- 文件压缩并远程传输：-cs

## 2、[scp.sh](./scp.sh) 使用方法

用于远程传输文件的脚本

```

 ######################### HELP ARCH:x86_64 ######################### 
 #sh scp_file.sh {param} 
 {param}:
        - 1       : local file path(dir or file)
        - 2       : remote host(ip:port)
        - 3       : remote file path(dir)
        - 4       : username of remote host
        - 5       : password of remote host
        - help    : help
        - example : sh scp.sh [1:local_file_path] [2:remote_host] [3:remote_file_path] [4:username] [5:password]
 ######################### HELP ARCH:x86_64 #########################
 ```

