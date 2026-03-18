# myplayer 命令行速查手册

适用范围：

- `CMake` 配置、编译、测试
- `clang-format` / `clang-tidy` 格式化与静态检查
- 当前项目里最常用的 `PowerShell` 命令

这份文档重点不是讲语言语法，而是帮你在实际开发时快速找到“该敲什么命令”和“这个命令到底在做什么”。

---

# 目录

1. [先建立一个整体认识](#section-1)
2. [一套最常用的工作流](#section-2)
3. [CMake 命令](#section-3)
4. [clang-format 命令](#section-4)
5. [clang-tidy 命令](#section-5)
6. [PowerShell 常用命令](#section-6)
7. [当前项目里的常用组合命令](#section-7)
8. [常见报错与排查思路](#section-8)

---

<a id="section-1"></a>
# 1. 先建立一个整体认识

在你现在这个 `myplayer` 项目里，常见命令基本分成 3 类：

- `CMake`
  - 负责配置工程、生成构建系统、触发编译、运行测试
- `clang-format` / `clang-tidy`
  - 前者负责统一代码格式
  - 后者负责静态检查和规范检查
- `PowerShell`
  - 负责浏览文件、查看内容、设置环境变量、批量执行命令

你可以把它们理解成：

- `CMake`：负责“怎么构建项目”
- `clang-format`：负责“代码排版长什么样”
- `clang-tidy`：负责“代码有没有明显问题、是否符合规范”
- `PowerShell`：负责“怎么在终端里操作这些工具”

---

<a id="section-2"></a>
# 2. 一套最常用的工作流

如果你只是想先记住一套最常用流程，优先记下面这组：

```powershell
cd d:\MyProject\Job_hunting\Project\myplayer

cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build

clang-format -style=file -i app/main.cpp core/dummy.h core/dummy.cpp

clang-tidy -p build app/main.cpp
clang-tidy -p build core/dummy.cpp

ctest --test-dir build --output-on-failure
```

这组命令分别做了什么：

1. 进入项目目录
2. 配置工程，并生成 `compile_commands.json`
3. 编译工程
4. 按项目配置自动格式化源码
5. 对源码做静态检查
6. 运行测试

如果当前终端还没配置好 `clang` 或 `ninja` 的 `PATH`，先执行：

```powershell
$env:Path += ';C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\Llvm\bin'
$env:Path += ';C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja'
```

说明：

- 这是“当前终端临时生效”的写法
- 关闭这个 PowerShell 窗口后就失效

---

<a id="section-3"></a>
# 3. CMake 命令

## 3.1 查看版本

```powershell
cmake --version
```

作用：

- 查看当前 `cmake` 是否已安装
- 确认版本号

什么时候用：

- 第一次配置环境时
- 怀疑版本太老时

---

## 3.2 配置工程

```powershell
cmake -S . -B build
```

参数解释：

- `-S .`
  - 指定源码目录为当前目录
- `-B build`
  - 指定构建目录为 `build`

作用：

- 读取当前目录下的 `CMakeLists.txt`
- 生成构建系统文件到 `build/`

什么时候用：

- 第一次生成工程时
- 修改了 `CMakeLists.txt` 后重新配置时

补充示例：

```powershell
cmake -S . -B build -G Ninja
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake -S . -B build -DMYPLAYER_BUILD_TESTS=ON
```

这些参数的意义：

- `-G Ninja`
  - 指定生成器为 `Ninja`
- `-DCMAKE_BUILD_TYPE=Debug`
  - 单配置生成器下，指定构建类型为 `Debug`
- `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`
  - 生成 `compile_commands.json`
  - `clang-tidy` 很依赖这个文件
- `-D变量名=值`
  - 从命令行给 `CMake` 变量赋值

注意事项：

- `build/` 是构建目录，不建议把生成文件直接放源码目录
- 如果切换生成器，最好换一个新的构建目录，例如 `build-ninja/`

---

## 3.3 编译工程

```powershell
cmake --build build
```

参数解释：

- `--build build`
  - 表示编译 `build/` 这个构建目录对应的工程

作用：

- 调用底层生成器去真正执行编译

常见补充写法：

```powershell
cmake --build build --config Debug
cmake --build build --target player_app
cmake --build build --parallel
```

这些参数的意义：

- `--config Debug`
  - 多配置生成器下指定配置
  - 常见于 Visual Studio 生成器
- `--target player_app`
  - 只编译某个目标
- `--parallel`
  - 并行编译，提升速度

什么时候用：

- 正常开发时最常用的就是这个命令
- 改了 `.cpp` 代码后，通常重新编译即可

---

## 3.4 运行测试

```powershell
ctest --test-dir build --output-on-failure
```

参数解释：

- `--test-dir build`
  - 到 `build/` 对应的测试目录里运行测试
- `--output-on-failure`
  - 如果测试失败，显示失败输出

常见补充写法：

```powershell
ctest --test-dir build -C Debug --output-on-failure
ctest --test-dir build -R unit
```

这些参数的意义：

- `-C Debug`
  - 多配置生成器下指定测试配置
- `-R unit`
  - 只运行测试名匹配 `unit` 的测试

什么时候用：

- 已经写了 `enable_testing()` 和 `add_test()` 后
- 想统一运行所有测试时

注意事项：

- 如果没写 `add_test(...)`，`ctest` 发现不了你的测试程序

---

## 3.5 清理和重新配置

有时候构建目录状态混乱，最简单的办法是重新建一个干净的构建目录。

```powershell
Remove-Item -Recurse -Force build
cmake -S . -B build -G Ninja
```

作用：

- 删除旧的构建目录
- 重新生成一份干净的配置

注意事项：

- 这是删除操作，只对构建目录用，不要对源码目录乱用

---

<a id="section-4"></a>
# 4. clang-format 命令

## 4.1 查看版本

```powershell
clang-format --version
```

作用：

- 检查 `clang-format` 是否在 `PATH` 中
- 确认版本号

---

## 4.2 格式化单个文件

```powershell
clang-format -style=file -i app/main.cpp
```

参数解释：

- `-style=file`
  - 读取当前项目中的 `.clang-format`
- `-i`
  - 直接修改原文件

作用：

- 按项目规则自动整理代码格式

什么时候用：

- 改完一个文件后
- 提交前做一次格式清理

如果你不想直接改文件，可以去掉 `-i`：

```powershell
clang-format -style=file app/main.cpp
```

这时会把格式化后的内容输出到终端，而不是写回文件。

---

## 4.3 一次格式化多个文件

```powershell
clang-format -style=file -i app/main.cpp core/dummy.h core/dummy.cpp
```

作用：

- 一次格式化多个指定文件

什么时候用：

- 小项目里非常常用
- 当你只改了几个文件时最方便

---

## 4.4 批量格式化整个项目

```powershell
Get-ChildItem app,core,test -Recurse -Include *.cpp,*.cc,*.cxx,*.h,*.hpp -ErrorAction SilentlyContinue |
    ForEach-Object { clang-format -style=file -i $_.FullName }
```

这条命令分成两部分理解：

1. `Get-ChildItem ...`
   - 找出目录下所有匹配的源码文件
2. `ForEach-Object { ... }`
   - 对每个文件执行一次 `clang-format`

适用场景：

- 统一整理整个项目格式
- 第一次建立编码规范后做全项目格式化

注意事项：

- 第一次批量格式化时改动会很多
- 最好单独提交一次“纯格式化”修改

---

<a id="section-5"></a>
# 5. clang-tidy 命令

## 5.1 查看版本

```powershell
clang-tidy --version
```

作用：

- 检查 `clang-tidy` 是否可用
- 确认版本号

---

## 5.2 最推荐的用法：配合 `compile_commands.json`

```powershell
cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
clang-tidy -p build app/main.cpp
```

参数解释：

- `-p build`
  - 指定 `compile_commands.json` 所在目录

作用：

- `clang-tidy` 会按真实编译参数分析文件
- 这通常比手工写参数更稳定

什么时候用：

- 项目已经能正常 `cmake` 配置
- 想让 `clang-tidy` 读取真实 include 路径、宏定义、标准版本时

---

## 5.3 检查多个文件

```powershell
clang-tidy -p build app/main.cpp
clang-tidy -p build core/dummy.cpp
```

说明：

- 一般检查 `.cpp` 文件，而不是单独检查 `.h`
- 头文件问题通常会在包含它的 `.cpp` 中一起暴露出来

---

## 5.4 没有编译数据库时的临时写法

```powershell
clang-tidy app/main.cpp -- -std=c++17 -Icore
clang-tidy core/dummy.cpp -- -std=c++17 -Icore
```

这里最关键的是 `--`：

- `--` 前面是 `clang-tidy` 自己的参数
- `--` 后面是传给编译器解析源码的参数

作用：

- 在没有 `compile_commands.json` 时临时手工指定编译参数

什么时候用：

- 只是快速看一下某个文件
- 还没把工程完整接入 `CMake` 配置

注意事项：

- 这种写法容易漏参数
- 工程变复杂后，优先还是用 `-p build`

---

## 5.5 自动修复部分问题

```powershell
clang-tidy -p build app/main.cpp --fix
```

作用：

- 对某些可自动修复的问题直接改代码

什么时候用：

- 你已经先看过提示
- 确认本次修复范围可控

注意事项：

- 不要一上来就全项目 `--fix`
- 初学阶段更建议先看诊断，再手工理解问题

---

## 5.6 你当前项目里它更适合发现什么

在 `myplayer` 现阶段，`clang-tidy` 更适合发现这些问题：

- 命名不符合 `.clang-tidy` 规则
- 头文件缺少规范约定
- 不必要的 `using`
- 可读性和现代 C++ 用法问题

它不等于编译器，也不等于拼写检查器。

比如：

- `void main()` 是否标准，编译器和工具链会更直接暴露
- 某些函数名拼写不自然，`clang-tidy` 不一定总能识别

---

<a id="section-6"></a>
# 6. PowerShell 常用命令

## 6.1 切换目录

```powershell
cd d:\MyProject\Job_hunting\Project\myplayer
```

作用：

- 进入项目目录

补充：

- `cd` 是 `Set-Location` 的常用别名

---

## 6.2 查看文件内容

```powershell
Get-Content -Raw .\CMakeLists.txt
```

参数解释：

- `-Raw`
  - 按整体字符串读取文件
  - 对查看完整 Markdown、CMake、代码文件很方便

什么时候用：

- 想完整查看一个文本文件时

如果想只看前几行：

```powershell
Get-Content .\CMakeLists.txt -TotalCount 30
```

---

## 6.3 查找文件和目录

```powershell
Get-ChildItem
Get-ChildItem .\core
Get-ChildItem -Recurse .\Project\myplayer
```

作用：

- 类似文件浏览器里的“列出内容”

常见参数：

- `-Recurse`
  - 递归遍历子目录
- `-Filter *.cpp`
  - 按文件名过滤
- `-Force`
  - 显示隐藏项

示例：

```powershell
Get-ChildItem -Recurse -Filter clang-format.exe
```

这条命令的意思是：

- 从当前目录开始递归查找
- 只找名字叫 `clang-format.exe` 的文件

---

## 6.4 筛选对象

```powershell
Get-ChildItem | Where-Object { $_.Name -like '*.cpp' }
```

作用：

- 从命令输出结果里继续筛选

解释：

- `$_`
  - 表示“当前这一项”
- `.Name`
  - 表示当前对象的名称属性
- `-like '*.cpp'`
  - 用通配符匹配名字

什么时候用：

- `Get-ChildItem` 找出来的东西还很多，需要继续过滤时

---

## 6.5 选择输出字段

```powershell
Get-ChildItem | Select-Object Name, Length
```

作用：

- 只显示你关心的字段

常见写法：

```powershell
Get-Command clang-format | Select-Object Source
Get-ChildItem | Select-Object FullName
```

如果你只想直接取某个属性值，可用：

```powershell
Get-Command clang-format | Select-Object -ExpandProperty Source
```

`-ExpandProperty` 的意思是：

- 直接展开属性值
- 而不是输出整个对象

---

## 6.6 管道 `|`

```powershell
Get-ChildItem app -Recurse -Include *.cpp | ForEach-Object { $_.FullName }
```

作用：

- 把左边命令的输出，交给右边命令继续处理

可以理解成：

- 先找文件
- 再逐个处理文件

这是 `PowerShell` 里最常见的组合方式之一。

---

## 6.7 对每一项执行操作

```powershell
Get-ChildItem app -Recurse -Include *.cpp |
    ForEach-Object { clang-format -style=file -i $_.FullName }
```

作用：

- 对管道中的每个文件执行一次命令

解释：

- `ForEach-Object { ... }`
  - 对每个输入对象执行代码块
- `$_`
  - 当前对象
- `$_.FullName`
  - 当前对象的完整路径

注意：

- 正确写法是 `$_.FullName`
- 如果少了 `_`，命令就不是你想要的意思了

---

## 6.8 处理包含空格的程序路径

```powershell
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\Llvm\bin\clang-format.exe' --version
```

这里最关键的是 `&`：

- `&` 是调用运算符
- 用来执行一个字符串路径表示的程序

为什么需要它：

- 路径里有空格时，直接写常常会被解析错

适用场景：

- 直接运行完整路径下的程序
- 工具不在 `PATH` 里时临时调用

---

## 6.9 修改当前终端的环境变量

```powershell
$env:Path += ';C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\Llvm\bin'
```

作用：

- 给当前 PowerShell 会话追加 `PATH`

特点：

- 立刻生效
- 只对当前终端有效

什么时候用：

- 刚装完工具，想马上用
- 不想立刻改系统环境变量

---

## 6.10 永久写入当前用户的 `PATH`

```powershell
[Environment]::SetEnvironmentVariable(
  'Path',
  [Environment]::GetEnvironmentVariable('Path', 'User') + ';C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\Llvm\bin',
  'User'
)
```

作用：

- 把路径永久写进当前用户环境变量

注意事项：

- 写完后需要重新打开 PowerShell 或 VS Code 终端
- 这是修改环境配置，不是临时命令

---

## 6.11 忽略可预期错误输出

```powershell
Get-ChildItem 'C:\Program Files\LLVM' -Recurse -Filter clang-format.exe -ErrorAction SilentlyContinue
```

参数解释：

- `-ErrorAction SilentlyContinue`
  - 如果路径不存在或部分目录访问失败，不在终端打印一堆错误

什么时候用：

- 你在查找文件，但不确定某个路径一定存在时

---

## 6.12 删除目录

```powershell
Remove-Item -Recurse -Force build
```

作用：

- 递归删除 `build/` 目录

参数解释：

- `-Recurse`
  - 删除子目录和文件
- `-Force`
  - 强制删除

注意事项：

- 这是危险命令
- 只对构建目录、缓存目录这类可重建内容使用

---

<a id="section-7"></a>
# 7. 当前项目里的常用组合命令

## 7.1 首次配置开发环境

```powershell
$env:Path += ';C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\Llvm\bin'
$env:Path += ';C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja'

cd d:\MyProject\Job_hunting\Project\myplayer

clang-format --version
clang-tidy --version
cmake --version
ninja --version
```

适用场景：

- 新开一个终端
- 想先确认工具是否都能用

---

## 7.2 配置、编译、格式化、检查

```powershell
cd d:\MyProject\Job_hunting\Project\myplayer

cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build --parallel

clang-format -style=file -i app/main.cpp core/dummy.h core/dummy.cpp

clang-tidy -p build app/main.cpp
clang-tidy -p build core/dummy.cpp
```

适用场景：

- 日常开发
- 改完代码准备自查

---

## 7.3 批量格式化项目源码

```powershell
Get-ChildItem app,core,test -Recurse -Include *.cpp,*.cc,*.cxx,*.h,*.hpp -ErrorAction SilentlyContinue |
    ForEach-Object { clang-format -style=file -i $_.FullName }
```

适用场景：

- 全项目统一格式
- 新增 `.clang-format` 后第一次整理代码

---

## 7.4 重新干净配置

```powershell
Remove-Item -Recurse -Force build
cmake -S . -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
```

适用场景：

- 构建目录损坏
- 改过很多 `CMake` 配置后状态异常

---

<a id="section-8"></a>
# 8. 常见报错与排查思路

## 8.1 `clang-format` 或 `clang-tidy` not recognized

原因通常是：

- 工具没安装
- 工具已安装，但不在 `PATH`

排查顺序：

1. 先运行 `Get-Command clang-format`
2. 如果找不到，再用 `Get-ChildItem -Recurse -Filter clang-format.exe` 去找安装路径
3. 用 `$env:Path += '...'` 临时加路径
4. 再运行 `clang-format --version`

---

## 8.2 `ninja` not recognized

原因通常是：

- `Ninja` 没装
- Visual Studio 自带了 `Ninja`，但目录没进 `PATH`

你当前机器常见路径是：

```text
C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja
```

---

## 8.3 `clang-tidy -p build` 报找不到编译数据库

原因通常是：

- 还没执行 `cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`
- `compile_commands.json` 不在你传给 `-p` 的目录里

排查方法：

```powershell
Get-ChildItem .\build\compile_commands.json
```

---

## 8.4 `ctest` 跑不起来

常见原因：

- 工程没写 `enable_testing()`
- 测试程序没写 `add_test(...)`
- 还没先编译测试 target

---

## 8.5 PowerShell 路径里有空格，命令执行失败

解决办法：

- 用单引号包住路径
- 前面加 `&`

正确示例：

```powershell
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\Llvm\bin\clang-tidy.exe' --version
```

---

# 一句话总结

在你当前这个项目里，最重要的不是一次记住所有命令，而是先记住这条链路：  
**PowerShell 负责组织命令，CMake 负责构建工程，clang-format 负责排版，clang-tidy 负责静态检查。**
