#!/bin/bash
# GitHub仓库创建和推送脚本

echo "=== 樱井政博游戏开发课堂知识库 - GitHub推送脚本 ==="
echo ""

# 检查是否设置了GITHUB_TOKEN
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  警告: 未设置 GITHUB_TOKEN 环境变量"
    echo ""
    echo "请按以下步骤操作："
    echo "1. 访问 https://github.com/settings/tokens 创建Personal Access Token"
    echo "2. 设置环境变量: export GITHUB_TOKEN='your_token_here'"
    echo "3. 重新运行此脚本"
    echo ""
    echo "或者手动创建仓库："
    echo "1. 访问 https://github.com/new"
    echo "2. 仓库名: sakurai-classroom"
    echo "3. 描述: 樱井正博游戏开发课堂学习笔记"
    echo "4. 选择 Public（公开）"
    echo "5. 不要勾选 Initialize this repository with a README"
    echo "6. 点击 Create repository"
    echo "7. 运行以下命令推送："
    echo ""
    echo "   git remote add origin https://github.com/YOUR_USERNAME/sakurai-classroom.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo ""
    exit 1
fi

# 获取GitHub用户名
echo "正在获取GitHub用户名..."
GITHUB_USER=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/user | grep -o '"login": "[^"]*"' | cut -d'"' -f4)

if [ -z "$GITHUB_USER" ]; then
    echo "❌ 无法获取GitHub用户名，请检查GITHUB_TOKEN是否有效"
    exit 1
fi

echo "✓ GitHub用户名: $GITHUB_USER"
echo ""

# 创建仓库
echo "正在创建GitHub仓库..."
RESPONSE=$(curl -s -X POST "https://api.github.com/user/repos" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d '{
        "name": "sakurai-classroom",
        "description": "樱井正博游戏开发课堂学习笔记",
        "private": false,
        "auto_init": false
    }')

# 检查是否成功
if echo "$RESPONSE" | grep -q '"name": "sakurai-classroom"'; then
    echo "✓ 仓库创建成功！"
    echo "  地址: https://github.com/$GITHUB_USER/sakurai-classroom"
    echo ""
    
    # 添加远程仓库并推送
    echo "正在推送到GitHub..."
    git remote add origin "https://github.com/$GITHUB_USER/sakurai-classroom.git" 2>/dev/null || \
        git remote set-url origin "https://github.com/$GITHUB_USER/sakurai-classroom.git"
    git branch -M main
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ 推送成功！"
        echo "  仓库地址: https://github.com/$GITHUB_USER/sakurai-classroom"
    else
        echo ""
        echo "❌ 推送失败，请手动执行："
        echo "  git push -u origin main"
    fi
else
    # 检查是否因为仓库已存在
    if echo "$RESPONSE" | grep -q "name already exists"; then
        echo "⚠️  仓库已存在，直接推送..."
        git remote add origin "https://github.com/$GITHUB_USER/sakurai-classroom.git" 2>/dev/null || \
            git remote set-url origin "https://github.com/$GITHUB_USER/sakurai-classroom.git"
        git branch -M main
        git push -u origin main
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ 推送成功！"
            echo "  仓库地址: https://github.com/$GITHUB_USER/sakurai-classroom"
        fi
    else
        echo "❌ 创建仓库失败："
        echo "$RESPONSE" | grep -o '"message": "[^"]*"' | cut -d'"' -f4
    fi
fi
