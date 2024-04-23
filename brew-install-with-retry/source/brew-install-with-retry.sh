#!/bin/bash

# 脚本中的版本号
VERSION="1.0.0"

# 显示版本号
show_version() {
  echo "brew-install-with-retry version ${VERSION}"
}

# 如果未指定任何参数，则显示帮助信息
if [ "$#" -eq 0 ]; then
  echo "用法: $0 -p 包名 [-a 重试次数]"
  echo "  -p 包名: 要安装的包名"
  echo "  -a 重试次数: 可选参数，安装失败时的重试次数，默认为3"
  exit 1
fi

# 处理命令行参数
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --version|-V) show_version; exit 0;;
    *)            echo "Unknown parameter passed: $1"; exit 1;;
  esac
  shift
done



# 定义默认的重试次数
DEFAULT_MAX_ATTEMPTS=3

# 使用getopts处理命令行参数
while getopts "p:a:" opt; do
  case $opt in
    p)
      PACKAGE="$OPTARG"
      ;;
    a)
      MAX_ATTEMPTS="$OPTARG"
      ;;
    \?)
      echo "无效的选项: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "选项 -$OPTARG 需要一个参数。" >&2
      exit 1
      ;;
  esac
done

# 如果没有提供重试次数，则使用默认值
if [ -z "$MAX_ATTEMPTS" ]; then
  MAX_ATTEMPTS=$DEFAULT_MAX_ATTEMPTS
fi

# 当前重试次数
CURRENT_ATTEMPT=0

# 检查是否提供了包名
if [ -z "$PACKAGE" ]; then
  echo "错误：必须提供要安装的包名。"
  echo "用法: $0 -p 包名 [-a 重试次数]"
  exit 1
fi

# 开始安装
until brew install $PACKAGE || [$CURRENT_ATTEMPT -eq $MAX_ATTEMPTS ]
do
  echo "尝试安装 $PACKAGE, 当前尝试次数:$CURRENT_ATTEMPT"
  ((CURRENT_ATTEMPT++))
  if [ $CURRENT_ATTEMPT -eq$MAX_ATTEMPTS ]; then
    echo "已达到最大尝试次数 $MAX_ATTEMPTS，安装失败。"
    exit 1
  fi
  sleep 5 # 等待5秒再重试
done

echo "$PACKAGE 安装成功！"

