#!/bin/bash
# ============================================
# 班主任工作台 - GitHub Pages 一键部署脚本
# ============================================
# 使用方法：
# 1. 确保已安装 Git（Mac自带）
# 2. 把这个脚本和 index.html 放在同一个文件夹
# 3. 打开终端，cd 到该文件夹
# 4. 运行: bash deploy-github.sh
# ============================================

set -e

echo "========================================"
echo "  班主任工作台 - GitHub Pages 部署工具"
echo "========================================"
echo ""

# 检查 git
if ! command -v git &> /dev/null; then
    echo "❌ 未找到 Git，请先安装: https://git-scm.com"
    exit 1
fi

# 检查文件
if [ ! -f "index.html" ]; then
    echo "❌ 未找到 index.html 文件！"
    echo "请确保 index.html 和此脚本在同一个文件夹中。"
    exit 1
fi

# 检查 gh CLI
HAS_GH=false
if command -v gh &> /dev/null; then
    HAS_GH=true
fi

echo "📁 请输入信息："
echo ""

# 输入 GitHub 用户名
read -p "你的 GitHub 用户名: " USERNAME

# 输入仓库名
REPO_NAME="workbench"
read -p "仓库名称（直接回车默认为 workbench）: " INPUT_REPO
if [ -n "$INPUT_REPO" ]; then
    REPO_NAME="$INPUT_REPO"
fi

# 输入邮箱（用于 git commit）
read -p "你的邮箱（用于提交记录，直接回车跳过）: " EMAIL
if [ -n "$EMAIL" ]; then
    git config user.email "$EMAIL"
fi
git config user.name "$USERNAME"

echo ""
echo "========================================"
echo "🚀 开始部署..."
echo "========================================"

# 删除旧的临时目录
rm -rf /tmp/workbench-deploy
mkdir -p /tmp/workbench-deploy
cd /tmp/workbench-deploy

# 初始化 git 仓库
git init
git branch -M main

# 复制文件
cp "$OLDPWD/index.html" .
if [ -f "$OLDPWD/bzr-workbench-mobile.html" ]; then
    cp "$OLDPWD/bzr-workbench-mobile.html" .
    echo "✅ 已添加手机版"
fi

# 创建 README
cat > README.md << 'EOF'
# 班主任工作台

班主任日常管理工作台，包含课程表、学生管理、成绩分析等功能。

## 访问地址

- 桌面版: https://用户名.github.io/workbench/
- 手机版: https://用户名.github.io/workbench/bzr-workbench-mobile.html
EOF

# 替换用户名
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/用户名/$USERNAME/g" README.md
    sed -i '' "s/workbench/$REPO_NAME/g" README.md
else
    sed -i "s/用户名/$USERNAME/g" README.md
    sed -i "s/workbench/$REPO_NAME/g" README.md
fi

git add -A
git commit -m "班主任工作台部署"

echo ""
echo "📌 下一步需要在浏览器中操作："
echo ""
echo "1. 打开 https://github.com/new"
echo "2. Repository name 填: $REPO_NAME"
echo "3. 选择 Public（公开）"
echo "4. 不要勾选任何初始化选项"
echo "5. 点击 Create repository"
echo ""
echo "完成后按回车继续..."
read

# 添加远程仓库并推送
git remote add origin "https://github.com/$USERNAME/$REPO_NAME.git"

echo ""
echo "🔄 正推送代码到 GitHub..."
echo "如果弹出登录窗口，请登录你的 GitHub 账号"
echo ""

git push -u origin main

echo ""
echo "✅ 代码已推送成功！"
echo ""
echo "========================================"
echo "📌 最后一步：开启 GitHub Pages"
echo "========================================"
echo ""
echo "1. 打开 https://github.com/$USERNAME/$REPO_NAME/settings/pages"
echo "2. Source 选择 'Deploy from a branch'"
echo "3. Branch 选择 'main'，文件夹选 '/ (root)'"
echo "4. 点击 Save"
echo ""
echo "等待 1-2 分钟后，你的工作台链接将是："
echo ""
echo "  📱 桌面版: https://$USERNAME.github.io/$REPO_NAME/"
echo "  📱 手机版: https://$USERNAME.github.io/$REPO_NAME/bzr-workbench-mobile.html"
echo ""
echo "========================================"

# 尝试用浏览器打开 Pages 设置页
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "正在打开 GitHub Pages 设置页..."
    open "https://github.com/$USERNAME/$REPO_NAME/settings/pages"
fi

echo ""
echo "✅ 部署完成！"
