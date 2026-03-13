#!/bin/bash

echo "🧪 Running Algorithm App Tests..."
echo ""

# 确保依赖已安装
dart pub get

echo ""
echo "Running all tests..."
dart test

echo ""
echo "✅ Test run complete!"
