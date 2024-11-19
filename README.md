# MasterPanel - 大师运镜操作盘

![MasterPanel Logo](./Cover.png)

MasterPanel 是一个创新的 AI 视频生成交互控制系统，旨在解决当前 AI 视频生成领域中"自由运镜"的交互痛点。

## 🌟 核心特性

- **直观的运镜控制**：将专业电影摄影的推、拉、摇、移等概念转化为移动端友好的交互界面
- **连续生成能力**：突破传统 5-10 秒的限制，支持任意长度视频的连续生成
- **双层交互设计**：
  - 基础操作盘：适合入门用户，简单直观
  - 大师控制盘：面向专业用户，支持更精细的镜头控制

## 🎯 解决的问题

1. **交互优化**：摒弃传统下拉选框式交互，提供符合手持运镜直觉的操作方式
2. **突破时长限制**：通过"最后一帧接力"技术，支持长视频创作
3. **专业级控制**：提供 pan-tilt、Zoom、roll 等专业级镜头控制能力

## 🛠️ 技术实现

### 前端实现 (iOS)
- 基于 SwiftUI 开发
- 创新的动效设计：
  - Wave 涟漪效果
  - 点阵覆盖 Shader
  - 实时追随矩阵效果
  - 控件发光反馈
  - 镜头路径可视化

### 后端 API

```python
# 主要接口
/api/v1/images/resize          # 图片预处理
/api/video/camera-prompts      # 镜头控制提示词生成
/api/video/last-frame          # 最后一帧提取
/api/prompts/translate-optimize # 提示词优化
/api/prompts/camera-path       # 镜头路径生成
```

## 📱 UI/UX 设计

- 完整设计文档：[Figma 链接](https://www.figma.com/design/3Ieex9SqYR0mnd5R5XgsOv/MasterPanel---%E5%A4%A7%E5%B8%88%E8%BF%90%E9%95%9C%E6%93%8D%E4%BD%9C%E7%9B%98UIUX%E5%AE%9E%E7%8E%B0?node-id=0-1&t=ndcMr1mFwj5DXn8B-1)
- 适配平台：
  - 移动端 (390x844)

## 🎬 演示 Demo

- [下载高清4K演示视频](https://github.com/liseami/MasterPanel?tab=readme-ov-file)
- 支持格式：MOV、MP4、AVI
- 时长：>15s

## 👥 团队成员

- **项目负责人**：赵纯想

## 📄 许可证

本项目采用 Commons Clause License 开源协议。仅供学习交流使用，未经授权禁止商用。

## 🔗 相关链接

- [项目 GitHub 仓库](https://github.com/liseami/MasterPanel)
- [赵纯想个人网站](https://me.revome.cn)

## 📌 注意事项

- 本项目仅用于参加即梦AI交互创新大赛
- SwiftUI 源码仅供学习交流
- 演示视频结尾有彩蛋🥚

---
© 2024 赵纯想. All Rights Reserved.
