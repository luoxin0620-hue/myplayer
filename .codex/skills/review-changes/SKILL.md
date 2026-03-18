---
name: review-changes
description: 自动生成 Git 代码差异（未暂存 + 已暂存 或 基于基准分支），并执行结构化的本地代码自审。触发示例：“review changes”“review <路径>”“审核修改”“审核 <路径> 修改”。
---

# review-changes 技能说明

## 目的

当用户请求进行代码审查时，本技能将：

1) 自动生成指定范围内的 Git diff（文件 / 目录 / 全仓库）。
2) **仅基于生成的 diff 内容**进行审查，不推断任何未展示的修改。
3) 输出一份结构化的中文版“提交前自我代码审查报告（pre-merge self review）”。

本技能适用于：

- 提交代码前的自查
- 模拟同事 Code Review
- 本地修改质量把关

---

## 触发方式

示例指令（中英文均可）：

- `review changes`
- `review src/foo.cpp`
- `review src/ directory changes`
- `审核修改`
- `审核 src/foo.cpp 修改`
- `审核 src/ 修改`

---

## 输入参数说明

- **目标路径（可选）**
  - 文件或目录路径（相对于仓库根目录）
  - 若未指定，则默认审查整个仓库的改动

- **审查模式（可选）**
  - 默认模式：  
    - 审查当前工作区改动（未暂存 + 已暂存）
  - 基准分支模式：  
    - 基于指定分支（如 `origin/main`）与当前 `HEAD` 的差异进行审查

---

## 固定执行流程（必须遵守）

1) **确定审查范围**
   - 若用户指定文件 / 目录，则只审查该路径
   - 否则审查整个仓库的改动

2) **生成代码差异（Diff）**
   - 优先使用脚本 `scripts/make_diff.ps1`
   - 允许的调用形式包括：
     - `powershell -ExecutionPolicy Bypass -File scripts/make_diff.ps1 -Path "<路径>" -Unstaged -Staged`
     - `powershell -ExecutionPolicy Bypass -File scripts/make_diff.ps1 -Path "<路径>" -Base "origin/main"`

3) **执行代码审查**
   - 只允许审查上述步骤生成的 diff
   - 禁止基于仓库其他内容进行推断或假设

4) **输出审查报告**
   - 严格按照“输出格式”章节中的结构输出

---

## 安全规则（强制）

### 允许的 Git 命令（只读）

- `git diff`
- `git status`
- `git rev-parse`
- `git merge-base`
- `git show`（仅限只读）

### 严禁的 Git 命令（任何形式）

- `git restore`
- `git reset`
- `git checkout`
- `git clean`
- `git rebase`
- `git commit`
- `git push`
- `git merge`

⚠️ 本技能 **绝不能** 执行任何会修改工作区、暂存区或提交历史的命令。  
如命令执行需要用户授权，仅可请求并执行上述“只读命令”。

---

## 代码审查清单（仅针对 diff）

在审查时，请重点关注以下方面（按适用性判断）：

- **正确性**
  - 逻辑错误
  - 边界条件 / 空值处理
  - off-by-one 错误

- **安全性 / 稳定性**
  - 资源生命周期（内存、句柄、文件等）
  - 错误处理是否完整
  - 异常 / 返回值处理

- **并发相关（如适用）**
  - 线程安全
  - 共享状态竞争
  - 锁使用是否合理

- **接口与契约**
  - 行为是否发生变化
  - 向后兼容性
  - API 使用是否正确

- **安全风险（如适用）**
  - 注入风险
  - 不安全反序列化
  - 敏感信息日志

- **可维护性**
  - 可读性
  - 复杂度
  - 重复代码
  - 命名是否清晰
  - 是否需要补充注释

- **测试建议（可选）**
  - 若改动风险较高，指出应补充的测试点

---

## 审查报告输出格式（必须）

### 语言

- 中文

### Summary（摘要）

- 改动内容概述
- 风险等级：Low / Medium / High

### Blocking issues（必须修复）

- `[文件:行号] 问题描述`
- 原因说明
- 建议修改方式

### Non-blocking issues（建议修复）

- `[文件:行号] 问题描述`
- 改进建议

### Suggestions / patches（建议与补丁）

- 如有必要，提供最小化的 diff 风格代码建议

### Questions to verify（待确认问题）

- 对需求、上下文或设计假设的确认问题
