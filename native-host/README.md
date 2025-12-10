# RealVNC 原生主机注册说明

## 📋 概述

本目录包含用于浏览器扩展与RealVNC Viewer通信的原生主机组件。通过注册原生主机，浏览器扩展可以安全地启动RealVNC Viewer来建立VNC连接。

## 📁 文件说明

| 文件 | 说明 |
|------|------|
| `com.realvnc.vncviewer.json` | 原生主机配置文件 |
| `realvnc_launcher.bat` | Windows批处理启动器 |
| `realvnc_launcher.py` | Python主脚本（跨平台） |
| `realvnc_launcher.sh` | Linux/macOS启动脚本 |
| `register_native_host.bat` | **一键注册脚本（推荐）** |
| `unregister_native_host.bat` | 卸载脚本 |

## 🚀 快速开始

### 方法一：一键注册（推荐）

1. **右键点击** `register_native_host.bat`
2. 选择 **"以管理员身份运行"**
3. 按照提示完成注册
4. 脚本会自动注册到所有支持的浏览器

### 方法二：手动注册

如果需要手动注册，可以按以下步骤操作：

1. 打开注册表编辑器（regedit）
2. 导航到相应的注册表路径：
   - **Chrome**: `HKEY_LOCAL_MACHINE\SOFTWARE\Google\Chrome\NativeMessagingHosts\com.realvnc.vncviewer`
   - **Edge**: `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Edge\NativeMessagingHosts\com.realvnc.vncviewer`
   - **Firefox**: `HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\NativeMessagingHosts\com.realvnc.vncviewer`
3. 设置默认值为配置文件的完整路径：
   ```
   F:\sourcePc\cpu-test-browser-extension\native-host\com.realvnc.vncviewer.json
   ```

## 🔧 系统要求

- **操作系统**: Windows 7/8/10/11
- **Python**: 3.7 或更高版本（必须安装）
- **RealVNC Viewer**: 必须安装
- **浏览器**: Chrome/Edge/Firefox 最新版本

## 📝 注册脚本功能

### 注册脚本 (`register_native_host.bat`)
- ✅ 自动检测管理员权限
- ✅ 验证必要文件存在
- ✅ 自动更新配置文件路径
- ✅ 注册到所有支持的浏览器
- ✅ 提供详细的注册结果反馈

### 卸载脚本 (`unregister_native_host.bat`)
- ✅ 清理所有浏览器注册项
- ✅ 保留配置文件供后续使用
- ✅ 提供卸载状态反馈

## 🛠️ 故障排除

### 常见问题

1. **权限错误**
   - 确保以管理员身份运行脚本
   - 检查用户账户控制(UAC)设置

2. **注册失败**
   - 检查Python是否已安装并添加到PATH
   - 验证RealVNC Viewer是否安装
   - 确认配置文件路径正确

3. **浏览器无法连接**
   - 重启浏览器
   - 检查浏览器是否支持原生消息传递
   - 查看浏览器控制台错误信息

### 验证注册

注册完成后，可以通过以下方式验证：

1. **检查注册表**：
   ```cmd
   reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Google\Chrome\NativeMessagingHosts\com.realvnc.vncviewer"
   ```

2. **测试连接**：
   - 打开浏览器扩展
   - 尝试建立VNC连接
   - 查看是否成功启动RealVNC Viewer

## 🔄 更新和维护

### 更新配置
如果需要更新配置文件，请：
1. 修改 `com.realvnc.vncviewer.json`
2. 重新运行注册脚本

### 完全卸载
如需完全卸载：
1. 运行 `unregister_native_host.bat`
2. 手动删除 `native-host` 目录（可选）

## 📞 技术支持

如果遇到问题，请检查：
- 系统日志中的错误信息
- 浏览器开发者工具的控制台输出
- Python脚本的运行日志

---

**注意**: 使用前请确保已阅读并理解相关安全注意事项，原生主机功能需要谨慎配置以确保系统安全。