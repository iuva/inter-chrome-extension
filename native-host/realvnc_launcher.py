#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
RealVNC Launcher 本地消息传递主机

此脚本作为 RealVNC Launcher 浏览器扩展的本地消息传递主机。
它处理在 Windows 和 macOS 上使用指定连接文件启动 RealVNC Viewer。
"""

import sys
import json
import struct
import subprocess
import os
import platform
import logging
from pathlib import Path

# 配置日志记录
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(os.path.expanduser('~/realvnc_launcher.log')),
        logging.StreamHandler(sys.stderr)
    ]
)
logger = logging.getLogger(__name__)

class RealVNCLauncher:
    def __init__(self):
        self.system = platform.system()
        logger.info(f"RealVNC Launcher initialized on {self.system}")
        
    def get_default_vnc_path(self):
        """获取当前平台的默认 RealVNC Viewer 可执行文件路径。"""
        if self.system == "Windows":
            # Windows 的常见安装路径
            paths = [
                r"C:\Program Files\RealVNC\VNC Viewer\vncviewer.exe",
                r"C:\Program Files (x86)\RealVNC\VNC Viewer\vncviewer.exe",
                r"C:\Users\{}\AppData\Local\RealVNC\VNC Viewer\vncviewer.exe".format(os.getenv('USERNAME', ''))
            ]
        elif self.system == "Darwin":  # macOS
            paths = [
                "/Applications/VNC Viewer.app/Contents/MacOS/vncviewer",
                "/Applications/VNC Viewer.app",
                os.path.expanduser("~/Applications/VNC Viewer.app")
            ]
        else:  # Linux 和其他类 Unix 系统
            paths = [
                "/usr/bin/vncviewer",
                "/usr/local/bin/vncviewer",
                "/opt/VNC/bin/vncviewer"
            ]
        
        for path in paths:
            if os.path.exists(path):
                logger.info(f"Found RealVNC at: {path}")
                return path
        
        logger.warning("RealVNC Viewer not found in default locations")
        return None
    
    def launch_realvnc(self, connection_file="", custom_vnc_path=""):
        """使用可选连接文件启动 RealVNC Viewer。"""
        try:
            # 确定 VNC 可执行文件路径
            vnc_path = custom_vnc_path if custom_vnc_path else self.get_default_vnc_path()
            
            if not vnc_path:
                raise Exception("RealVNC Viewer not found. Please install RealVNC Viewer or specify custom path.")
            
            # 构建命令
            if self.system == "Windows":
                # 在 Windows 上使用 start 命令启动程序
                cmd = ["cmd", "/c", "start", "", vnc_path]
                if connection_file and os.path.exists(connection_file):
                    cmd.append(connection_file)
                
                # 在 Windows 上使用 subprocess.Popen 以避免阻塞
                process = subprocess.Popen(
                    cmd,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    creationflags=subprocess.CREATE_NEW_PROCESS_GROUP
                )
                
            elif self.system == "Darwin":  # macOS
                if vnc_path.endswith(".app"):
                    # 对 .app 包使用 'open' 命令
                    cmd = ["open", vnc_path]
                    if connection_file and os.path.exists(connection_file):
                        cmd.extend(["--args", connection_file])
                else:
                    # 直接可执行文件
                    cmd = [vnc_path]
                    if connection_file and os.path.exists(connection_file):
                        cmd.append(connection_file)
                
                process = subprocess.Popen(
                    cmd,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )
                
            else:  # Linux 和其他类 Unix 系统
                cmd = [vnc_path]
                if connection_file and os.path.exists(connection_file):
                    cmd.append(connection_file)
                
                process = subprocess.Popen(
                    cmd,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )
            
            logger.info(f"RealVNC launched with command: {' '.join(cmd)}")
            return {
                "success": True,
                "message": "RealVNC Viewer launched successfully",
                "pid": process.pid,
                "command": ' '.join(cmd)
            }
            
        except Exception as e:
            error_msg = f"Failed to launch RealVNC: {str(e)}"
            logger.error(error_msg)
            return {
                "success": False,
                "error": error_msg
            }
    
    def read_message(self):
        """使用 Chrome 本地消息传递协议从 stdin 读取消息。"""
        try:
            # 读取消息长度（4 字节）
            raw_length = sys.stdin.buffer.read(4)
            if not raw_length:
                return None
            
            message_length = struct.unpack('=I', raw_length)[0]
            
            # 读取消息
            message = sys.stdin.buffer.read(message_length).decode('utf-8')
            return json.loads(message)
            
        except Exception as e:
            logger.error(f"Error reading message: {e}")
            return None
    
    def send_message(self, message):
        """使用 Chrome 本地消息传递协议向 stdout 发送消息。"""
        try:
            encoded_message = json.dumps(message).encode('utf-8')
            encoded_length = struct.pack('=I', len(encoded_message))
            
            sys.stdout.buffer.write(encoded_length)
            sys.stdout.buffer.write(encoded_message)
            sys.stdout.buffer.flush()
            
        except Exception as e:
            logger.error(f"Error sending message: {e}")
    
    def run(self):
        """主消息循环。"""
        logger.info("RealVNC Launcher native host started")
        
        try:
            while True:
                message = self.read_message()
                if message is None:
                    break
                
                logger.info(f"Received message: {message}")
                
                action = message.get('action')
                
                if action == 'launch':
                    connection_file = message.get('connectionFile', '')
                    custom_vnc_path = message.get('vncPath', '')
                    svn_content = message.get('svnContent', '')
                    
                    # 如果有SVN内容，先写入文件
                    if svn_content and connection_file:
                        try:
                            # 处理相对路径：将相对路径转换为绝对路径
                            import os
                            if not os.path.isabs(connection_file):
                                # 如果是相对路径，转换为相对于脚本所在目录的绝对路径
                                script_dir = os.path.dirname(os.path.abspath(__file__))
                                connection_file = os.path.join(script_dir, connection_file)
                            
                            # 确保目录存在
                            dir_path = os.path.dirname(connection_file)
                            if dir_path and not os.path.exists(dir_path):
                                os.makedirs(dir_path, exist_ok=True)
                                logger.info(f"Created directory: {dir_path}")
                            
                            # 写入SVN文件
                            with open(connection_file, 'w', encoding='utf-8') as f:
                                f.write(svn_content)
                            logger.info(f"SVN file created: {connection_file}")
                        except Exception as e:
                            logger.error(f"Failed to create SVN file: {e}")
                            self.send_message({
                                "success": False,
                                "error": f"Failed to create SVN file: {e}"
                            })
                            continue
                    
                    result = self.launch_realvnc(connection_file, custom_vnc_path)
                    self.send_message(result)
                    
                elif action == 'ping':
                    self.send_message({
                        "success": True,
                        "message": "pong",
                        "version": "1.0.0",
                        "platform": self.system
                    })
                    
                elif action == 'check_vnc':
                    vnc_path = self.get_default_vnc_path()
                    self.send_message({
                        "success": vnc_path is not None,
                        "vnc_path": vnc_path,
                        "platform": self.system
                    })
                    
                else:
                    self.send_message({
                        "success": False,
                        "error": f"Unknown action: {action}"
                    })
                    
        except KeyboardInterrupt:
            logger.info("Native host interrupted")
        except Exception as e:
            logger.error(f"Unexpected error: {e}")
        finally:
            logger.info("RealVNC Launcher native host stopped")

def main():
    """本地消息传递主机的入口点。"""
    launcher = RealVNCLauncher()
    launcher.run()

if __name__ == '__main__':
    main()