# BambuStudio Bridge 测试工具

这是一个用于测试 BambuStudio 集成的最小化测试项目。

## 🎯 目标

验证是否可以从 webapp 发送 3MF 文件到 BambuStudio，模拟 meshy-webapp 的 DCC bridge 功能。

## 🚀 使用方法

### 步骤1：启动BambuStudio
确保你的 BambuStudio 软件正在运行。

### 步骤2：打开测试工具
直接在浏览器中打开 `index.html` 文件，或者使用本地服务器：

```bash
# 使用Python简单服务器
python3 -m http.server 8080

# 或者使用Node.js
npx serve .

# 然后访问 http://localhost:8080
```

### 步骤3：测试集成
1. 点击"检查 BambuStudio 状态"按钮
2. 如果状态正常，点击"发送到 BambuStudio"
3. 观察 BambuStudio 是否收到并导入模型

## 🔧 测试方法

工具提供了三种测试方法：

### 方法1：协议处理器
```
bambustudio://open?file=<3MF_URL>
```
- 模拟点击链接的方式
- BambuStudio 应该会弹出导入对话框

### 方法2：HTTP API
```json
POST http://localhost:13618/
{
  "sequence_id": "timestamp",
  "command": "homepage_model_download",
  "model": {
    "url": "<3MF_URL>"
  }
}
```
- 直接向BambuStudio发送HTTP请求
- 更可靠的编程方式

### 方法3：直接下载
- 在新窗口打开3MF文件URL
- 用于验证文件是否可访问

## 📋 测试数据

- **测试API**: `https://api.meshy.ai/web/v1/showcases/01988b05-ebde-7d82-9506-34e41549f529/asset-url?format=3mf&height=NaN`
- **BambuStudio端口**: `http://localhost:13618`
- **协议格式**: `bambustudio://open?file=...`

## ⚠️ 注意事项

### 认证问题
由于跨域限制，测试工具可能无法自动获取3MF文件URL（需要认证）。如果遇到这种情况：

1. 在 meshy.ai 上打开开发者工具
2. 执行下载3MF操作
3. 从Network面板找到 `asset-url?format=3mf` 请求
4. 复制Response中的 `result` 字段（真实的3MF文件URL）
5. 在测试工具中手动粘贴

### 安全限制
BambuStudio生产版本可能会显示安全确认对话框：
```
"This file is not from a trusted site, do you want to open it anyway?"
```
点击"YES"继续即可。

### 域名白名单
如果使用AWS S3或阿里云OSS托管文件，可以避免安全提示：
- `amazonaws.com`
- `aliyuncs.com`  
- `makerworld.*`
- `public-cdn.bblmw.com`

## 🐛 故障排除

### BambuStudio状态检查失败
- 确保BambuStudio正在运行
- 检查端口13618是否被占用
- 检查防火墙设置

### 协议处理器不工作
- 确认BambuStudio已注册协议处理器
- 检查URL格式是否正确
- 尝试在地址栏直接输入协议URL

### HTTP API调用失败
- 检查BambuStudio HTTP服务器是否启动
- 验证JSON格式是否正确
- 查看浏览器控制台错误信息

## 📊 预期结果

### 成功场景
- BambuStudio接收到文件并显示导入对话框
- 模型正确加载到打印床上
- 测试工具显示成功消息

### 失败场景  
- 需要用户确认安全提示
- 网络连接问题
- 文件格式不支持

## 🔄 下一步

如果测试成功，证明：
- ✅ BambuStudio的协议处理器工作正常
- ✅ 3MF文件传输机制可行
- ✅ 可以集成到实际的meshy-webapp中

如果测试失败，可以：
- 🔧 调整URL格式或API调用方式
- 🔧 检查BambuStudio配置
- 🔧 尝试不同的文件托管方式
