#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/deepseek.py"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/watch.log"
PID_FILE="$SCRIPT_DIR/deepseek.pid"

# 创建logs目录
mkdir -p "$LOG_DIR"

# 检查Python脚本是否存在
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    echo "[$(date)] 错误: 找不到 $PYTHON_SCRIPT" >> "$LOG_FILE"
    exit 1
fi

while true; do
    # 检查进程是否运行（使用PID文件更精确）
    if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        # 进程运行中，静默检查（不记录日志）
        :
    else
        # 进程未运行，重启
        echo "[$(date)] 重启程序..." >> "$LOG_FILE"
        python3 "$PYTHON_SCRIPT" >> "$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"
        
        # 简单验证启动是否成功
        sleep 2
        if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "[$(date)] 程序已启动 (PID: $(cat "$PID_FILE"))" >> "$LOG_FILE"
        else
            echo "[$(date)] 启动失败" >> "$LOG_FILE"
            rm -f "$PID_FILE"
        fi
    fi
    
    sleep 30
done