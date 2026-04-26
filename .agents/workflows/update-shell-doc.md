---
description: 手动触发全量扫描 shell/bin/ 目录下的所有 Dart 脚本，重新生成并更新 shell/README.md 文档。
---

请按照 .kiro/skills/update-shell-docs.md skill 的指引，全量更新 shell/README.md 文档：

1. 读取 shell/bin/ 目录下的所有 .dart 脚本文件，逐一分析其功能、命令行参数和使用方法
2. 读取当前的 shell/README.md
3. 对比所有脚本的实际功能与文档中的描述，找出：
   - 新增的脚本（文档中没有记录的）
   - 已删除的脚本（文档中有记录但文件已不存在的）
   - 功能或参数发生变化的脚本
4. 全量更新 shell/README.md 的「可用脚本」章节，确保每个脚本都有完整的文档
5. 同步更新「常见工作流」章节
6. 检查 Makefile 中的 make target，同步更新 Makefile 命令章节

请保持文档的中文风格和现有格式一致。