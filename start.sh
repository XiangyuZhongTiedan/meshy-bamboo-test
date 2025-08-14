#!/bin/bash

echo "🚀 启动 BambuStudio Bridge 测试工具"
echo "=================================="

# 检查是否有Python
if command -v python3 &> /dev/null; then
    echo "✅ 使用 Python HTTP 服务器"
    echo "📍 访问地址: http://localhost:8080"
    echo "⏹️  按 Ctrl+C 停止服务器"
    echo ""
    python3 -m http.server 8080
elif command -v python &> /dev/null; then
    echo "✅ 使用 Python2 HTTP 服务器"
    echo "📍 访问地址: http://localhost:8080" 
    echo "⏹️  按 Ctrl+C 停止服务器"
    echo ""
    python -m SimpleHTTPServer 8080
elif command -v node &> /dev/null; then
    echo "✅ 使用 Node.js serve"
    echo "📍 访问地址: http://localhost:8080"
    echo "⏹️  按 Ctrl+C 停止服务器"  
    echo ""
    npx serve . -p 8080
else
    echo "❌ 未找到 Python 或 Node.js"
    echo "请安装其中一个，或直接在浏览器中打开 index.html 文件"
    echo ""
    echo "🌐 直接打开文件:"
    echo "file://$(pwd)/index.html"
fi
