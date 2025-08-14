# BambuStudio Bridge 集成需求文档

## 📋 需求概述

**目标**: 为 Meshy webapp 添加 BambuStudio 一键导入功能，支持所有资产（Task/Showcase/Animation）直接发送到用户本地的 BambuStudio 软件。

**优先级**: P1（用户高频需求）

---

## 🔍 背景分析

### 现有 DCC Bridge 架构
- **支持软件**: Blender、Unity、Maya、Godot、Unreal
- **通信方式**: HTTP 协议 + 本地插件服务器
- **文件格式**: GLB/FBX（硬编码限制）
- **工作流程**: webapp → API获取URL → HTTP发送给插件 → 插件下载导入

### BambuStudio 特殊性
- **无插件支持**: BambuStudio 不支持第三方插件开发
- **原生协议**: 支持 `bambustudioopen://` 协议处理器
- **原生格式**: 主要使用 3MF 格式（支持 GLB 但 3MF 更优）
- **直接导入**: 无需中间服务器，直接处理 URL

---

## 🎯 技术方案

### 方案对比
| 方案 | DCC Bridge (现有) | BambuStudio Bridge (新增) |
|------|------------------|---------------------------|
| **通信协议** | HTTP | URL 协议处理器 |
| **服务器依赖** | 需要本地插件服务器 | 无需服务器 |
| **文件格式** | GLB/FBX | **3MF**(推荐)/GLB |
| **跨平台** | 插件统一处理 | 需区分 macOS/Windows 协议 |

### 协议格式差异
```javascript
// macOS
bambustudioopen://encoded_url

// Windows/Linux  
bambustudio://open?file=encoded_url
```

---

## 🔧 API 需求分析

### 🆗 好消息：现有 API 基本满足需求

经过分析，现有的 asset-url API 已经返回预签名的直接下载 URL：

```json
// 请求: GET /v1/tasks/{id}/asset-url?format=3mf
// 响应:
{
    "code": "OK", 
    "result": "https://assets.meshy.ai/uploads/model.3mf?Expires=xxx&Signature=xxx"
}
```

### ✅ 确认支持的格式
- `/v1/tasks/{id}/asset-url?format=3mf` ✅
- `/v1/showcases/{id}/asset-url?format=3mf` ✅  
- `/v2/tasks/{id}/asset-url?format=3mf` ✅

**请后端确认**: 所有相关的 asset-url 接口都已支持 `format=3mf` 参数吗？

---

## 🛠️ 前端实现计划

### 1. 扩展 DCC 类型定义
```typescript
// DCCBridgeButton.tsx
export type DCC_TYPE = "blender" | "godot" | "unity" | "unreal" | "maya" | "bambustudio";

const dccPortMap = {
  // ... 现有映射
  bambustudio: null, // 不使用端口，使用协议处理器
};
```

### 2. 格式处理逻辑
```typescript
const trueFormat =
  dcc === "bambustudio"
    ? "3mf"                    // 🆕 BambuStudio 专用 3MF 格式
    : dcc === "blender"
      ? "glb" 
      : fileFormat && ["glb", "fbx"].includes(fileFormat)
        ? fileFormat
        : "glb";
```

### 3. 协议处理器实现
```typescript
const sendToBambuStudio = async (props: {
  modelUrl: string;
  fileName?: string;
}) => {
  // 🔑 关键修复：添加清洁文件名参数（避免 BambuStudio 崩溃）
  const cleanUrl = `${props.modelUrl}&name=${props.fileName || 'model.3mf'}`;
  
  // 检测操作系统
  const isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0;
  
  // 构建协议 URL
  const protocolUrl = isMac 
    ? `bambustudioopen://${encodeURIComponent(cleanUrl)}`
    : `bambustudio://open?file=${encodeURIComponent(cleanUrl)}`;
  
  // 触发协议处理器
  window.location.href = protocolUrl;
  return true;
};
```

### 4. 集成到现有组件
- `ModelDownloaderForTask` 
- `ModelDownloaderForShowcase`
- `ModelDownloaderForAnimation`
- Workspace v2 `DownloadPanel`

---

## 🧪 测试验证

### 已完成测试
- ✅ **协议处理器工作正常**: `bambustudioopen://` (macOS) 和 `bambustudio://open?file=` (Windows)
- ✅ **3MF 格式支持**: BambuStudio 可正常导入 3MF 文件
- ✅ **清洁文件名修复**: `&name=model.3mf` 参数避免崩溃
- ✅ **完整流程验证**: webapp → API → 协议处理器 → BambuStudio 导入成功

### 测试文件
已创建测试工具: `/meshy-bamboo-test/index.html`
- 模拟完整的 webapp 调用流程
- 验证协议处理器在不同操作系统的兼容性
- 确认文件名处理逻辑

---

## 📝 API 确认清单

请后端同事确认以下接口的 **3MF 格式支持**：

### Task 相关
- [ ] `GET /v1/tasks/{id}/asset-url?format=3mf` 
- [ ] `GET /v2/tasks/{id}/asset-url?format=3mf`

### Showcase 相关  
- [ ] `GET /v1/showcases/{id}/asset-url?format=3mf`

### Animation 相关
- [ ] `GET /v1/animations/{id}/asset-url?format=3mf`

### 测试用例
请提供一个测试用的 Task ID 或 Showcase ID，我将验证：
1. API 返回格式正确
2. 返回的 URL 可直接下载 3MF 文件
3. 文件可在 BambuStudio 中正常打开

---

## 🚀 上线计划

### 阶段 1: API 确认 (1 天)
- 后端确认所有 asset-url 接口支持 3MF 格式
- 提供测试数据验证

### 阶段 2: 前端开发 (2-3 天)  
- 实现 BambuStudio 协议处理器
- 集成到所有下载组件
- 添加用户设置开关

### 阶段 3: 测试发布 (1 天)
- 内部测试验证
- 灰度发布
- 收集用户反馈

---

## ❓ 待确认问题

1. **API 支持确认**: 所有 asset-url 接口都已支持 `format=3mf` 吗？
2. **文件大小限制**: 3MF 文件是否有特殊的大小限制？
3. **错误处理**: 如果 3MF 生成失败，API 如何返回错误信息？
4. **缓存策略**: 3MF 文件的 CDN 缓存策略与 GLB 一致吗？

---

## 💡 技术优势

- **零服务器依赖**: 不需要用户安装插件或运行本地服务器
- **原生体验**: 直接调用操作系统协议，用户体验流畅
- **格式优化**: 使用 BambuStudio 原生的 3MF 格式，兼容性更好
- **跨平台支持**: 自动检测操作系统，使用对应的协议格式

---

**联系人**: [你的姓名]  
**日期**: 2025-01-15  
**文档版本**: v1.0
