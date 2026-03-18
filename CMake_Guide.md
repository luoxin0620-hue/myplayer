# CMake 常用指令用法指南

适用场景：你已经粗略学过 `CMake`，但需要一份能随时查的实战文档。  
目标：优先掌握 C++ 项目里最常见、最值得先会的写法，并且知道参数该怎么写、什么情况下该用。

---

# 目录

1. [先建立一个正确认知](#section-1)
2. [最常用命令行](#section-2)
3. [一个最小可用模板](#section-3)
4. [先掌握 4 个基础语法规则](#section-4)
5. [常用指令说明](#section-5)
6. [一份更贴近你项目的推荐结构](#section-6)
7. [初学阶段最常见的坑](#section-7)
8. [现阶段最值得先记住的命令](#section-8)
9. [一个学习顺序建议](#section-9)
10. [你当前阶段的最低目标](#section-10)
11. [一句话总结](#section-11)

---

<a id="section-1"></a>
# 1. 先建立一个正确认知

`CMake` 不是编译器，它是 **构建系统生成器**。

它主要做三件事：

1. 描述项目结构
2. 描述目标之间的依赖关系
3. 生成真正执行编译的工程文件或构建脚本

你可以把它理解成：

- 你写 `CMakeLists.txt`
- `CMake` 读取这些配置
- 然后生成 `Visual Studio` 工程、`Ninja` 构建脚本等

---

<a id="section-2"></a>
# 2. 最常用命令行

## 2.1 配置工程

```bash
cmake -S . -B build
```

含义：

- `-S .`：源码目录是当前目录
- `-B build`：构建目录是 `build/`

常见补充写法：

```bash
cmake -S . -B build -G Ninja
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake -S . -B build -DMYPLAYER_BUILD_TESTS=ON
```

什么时候加这些参数：

- `-G Ninja`：你想明确指定生成器，而不是用默认生成器
- `-DCMAKE_BUILD_TYPE=Debug`：单配置生成器下选择构建类型
- `-D变量名=值`：从命令行给 `CMakeLists.txt` 传变量

## 2.2 编译工程

```bash
cmake --build build
```

常见补充写法：

```bash
cmake --build build --config Debug
cmake --build build --target player_app
cmake --build build --parallel
```

含义：

- `--config Debug`：多配置生成器下指定配置
- `--target player_app`：只编译某个 target
- `--parallel`：并行编译

## 2.3 指定配置编译

```bash
cmake --build build --config Debug
cmake --build build --config Release
```

注意：

- 在 `Visual Studio` 这类多配置生成器下，`Debug/Release` 常通过 `--config` 指定
- 在 `Ninja`、`Makefiles` 这类单配置生成器下，通常在配置阶段指定 `-DCMAKE_BUILD_TYPE=Debug`

## 2.4 运行测试

```bash
ctest --test-dir build --output-on-failure
```

常见补充写法：

```bash
ctest --test-dir build -C Debug --output-on-failure
ctest --test-dir build -R unit
```

含义：

- `-C Debug`：多配置生成器下指定测试配置
- `-R unit`：只运行名字匹配 `unit` 的测试
- `--output-on-failure`：失败时显示测试输出，排查问题很有用

---

<a id="section-3"></a>
# 3. 一个最小可用模板

这个模板适合你现在的 `myplayer` 这种结构。

```cmake
cmake_minimum_required(VERSION 3.20)
project(myplayer VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_library(player_core
    core/dummy.cpp
)

target_include_directories(player_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/core
)

add_executable(player_app
    app/main.cpp
)

target_link_libraries(player_app
    PRIVATE
        player_core
)
```

这个例子说明了 3 件事：

1. `player_core` 是一个库 target
2. `player_app` 是一个可执行程序 target
3. `player_app` 依赖 `player_core`

---

<a id="section-4"></a>
# 4. 先掌握 4 个基础语法规则

在看各个指令之前，先记住这几个规则，后面很多写法都会更容易懂。

## 4.1 变量展开

```cmake
set(MY_NAME player_app)
message(STATUS "${MY_NAME}")
```

说明：

- 变量读取用 `${变量名}`
- 变量名通常大小写敏感地使用同一种写法

## 4.2 参数是按空格分开的

```cmake
project(myplayer VERSION 0.1.0 LANGUAGES CXX)
```

可以理解成：

- `myplayer` 是位置参数
- `VERSION`、`LANGUAGES` 是关键字参数
- 关键字后面跟自己的值

## 4.3 列表通常直接写多个值

```cmake
target_sources(player_core
    PRIVATE
        core/dummy.cpp
        core/other.cpp
)
```

说明：

- 很多命令不需要逗号
- 多个参数直接换行写即可

## 4.4 布尔值常用 `ON/OFF`

```cmake
set(CMAKE_CXX_STANDARD_REQUIRED ON)
option(MYPLAYER_BUILD_TESTS "Build tests" ON)
```

建议：

- 布尔值统一写 `ON/OFF`
- 不要混着写 `TRUE/FALSE`、`1/0`，虽然很多场景也能工作，但可读性差

---

<a id="section-5"></a>
# 5. 常用指令说明

## 5.1 `cmake_minimum_required`

### 基本写法

```cmake
cmake_minimum_required(VERSION 3.20)
```

### 参数怎么写

- `VERSION 3.20`
  - 必写
  - 表示项目要求的最低 `CMake` 版本

### 什么时候用

- 几乎所有项目的根 `CMakeLists.txt` 第一行都应该写它
- 用来告诉 `CMake`：版本太低就不要继续配置

### 示例

```cmake
cmake_minimum_required(VERSION 3.16)
cmake_minimum_required(VERSION 3.20)
```

### 注意事项

- 不要省略
- 版本不要随手写太高
- 一般写你项目实际需要、并且开发环境普遍可用的版本

---

## 5.2 `project`

### 基本写法

```cmake
project(myplayer VERSION 0.1.0 LANGUAGES CXX)
```

### 参数怎么写

- `myplayer`
  - 项目名
  - 通常写在第一个位置
- `VERSION 0.1.0`
  - 可选
  - 项目版本号
- `LANGUAGES CXX`
  - 可选但很常用
  - 指定本项目启用哪些语言

### 什么时候用

- 根 `CMakeLists.txt` 一定会用
- 项目初始化时定义项目名、版本和语言

### 示例

```cmake
project(myplayer LANGUAGES CXX)
project(myplayer VERSION 0.1.0 LANGUAGES C CXX)
```

### 注意事项

- 如果只写 C++，用 `LANGUAGES CXX`
- 不需要 C 的时候，不要顺手加 `C`
- 项目名最好和仓库名、主程序名有对应关系

---

## 5.3 `set`

`set` 是 `CMake` 里最常见、也最容易被用得过度的指令。  
你可以把它理解成：**给变量赋值**。

### 最常见写法

```cmake
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
```

### 语法 1：设置普通变量

```cmake
set(<variable> <value>...)
```

示例：

```cmake
set(PROJECT_NAME_SHORT myplayer)
set(MYPLAYER_SOURCES
    app/main.cpp
    core/dummy.cpp
)
```

参数说明：

- `<variable>`
  - 变量名
- `<value>...`
  - 一个或多个值
  - 多个值在 `CMake` 里通常会组成一个列表

什么时候用：

- 保存文件列表
- 保存路径
- 保存普通字符串
- 设置 `CMake` 内置变量，例如 `CMAKE_CXX_STANDARD`

### 语法 2：设置缓存变量

```cmake
set(<variable> <value> CACHE <type> <docstring> [FORCE])
```

示例：

```cmake
set(MYPLAYER_ROOT "D:/SDK/MyPlayer" CACHE PATH "Root path of myplayer SDK")
set(MYPLAYER_USE_FAST_MODE ON CACHE BOOL "Enable fast mode")
```

参数说明：

- `CACHE`
  - 表示把变量写入 `CMakeCache.txt`
  - 这样下次重新配置时还会保留
- `<type>`
  - 常见有 `BOOL`、`STRING`、`PATH`、`FILEPATH`
- `<docstring>`
  - 说明文字
  - 在图形化工具或缓存查看时能看到
- `FORCE`
  - 强制覆盖缓存里已有值

什么时候用：

- 这个变量应该允许用户配置
- 希望值在多次配置之间保留
- 需要暴露给 `ccmake`、`cmake-gui` 或命令行 `-D` 使用

示例：

```cmake
set(MYPLAYER_BUILD_TOOLS ON CACHE BOOL "Build command line tools")
set(FFMPEG_ROOT "" CACHE PATH "Path to ffmpeg installation")
```

注意事项：

- 有缓存变量需求时，`option` 往往比 `set(... CACHE BOOL ...)` 更直观
- 除非确实需要，不要随便加 `FORCE`

### 语法 3：设置环境变量

```cmake
set(ENV{<variable>} <value>)
```

示例：

```cmake
set(ENV{MYPLAYER_MODE} debug)
```

什么时候用：

- 偶尔需要在配置阶段影响子进程环境
- 比如调用某些外部工具时需要环境变量

注意事项：

- 这只影响当前 `CMake` 进程以及它启动的子进程
- 不会永久修改系统环境变量

### 语法 4：配合 `PARENT_SCOPE`

```cmake
set(<variable> <value> PARENT_SCOPE)
```

示例：

```cmake
set(MYPLAYER_HAS_TESTS ON PARENT_SCOPE)
```

什么时候用：

- 子目录或函数里想把变量传回上一层作用域

注意事项：

- 这个用法容易让作用域关系变乱
- 初学阶段尽量少用
- 能用 target 依赖表达的问题，就不要靠变量回传解决

### 常见值怎么写

#### 写字符串

```cmake
set(APP_NAME myplayer)
set(APP_DESC "Simple media player")
```

说明：

- 没有空格的字符串可以不加引号
- 有空格时建议加引号

#### 写路径

```cmake
set(MYPLAYER_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/third_party")
```

说明：

- 推荐拼接已有 `CMake` 变量
- 尽量不要硬编码机器相关绝对路径

#### 写列表

```cmake
set(MYPLAYER_HEADERS
    core/dummy.h
    core/player.h
)
```

说明：

- 多个值就是列表
- 后面可以直接传给 `target_sources`、`add_library` 等命令

#### 写布尔值

```cmake
set(MYPLAYER_ENABLE_LOG ON)
set(MYPLAYER_ENABLE_PROFILER OFF)
```

说明：

- 推荐统一使用 `ON/OFF`

### `set` 和命令行 `-D` 的关系

如果你有下面这行：

```cmake
set(MYPLAYER_BUILD_TESTS ON CACHE BOOL "Build tests")
```

那么可以在命令行改它：

```bash
cmake -S . -B build -DMYPLAYER_BUILD_TESTS=OFF
```

适用场景：

- 你想保留默认值
- 但又允许用户在配置时覆盖

### 什么时候应该用 `set`

- 设置 `CMake` 内置变量，例如 `CMAKE_CXX_STANDARD`
- 定义文件列表、目录列表、字符串常量
- 保存需要复用的路径
- 定义缓存变量，允许用户传参覆盖

### 什么时候不要滥用 `set`

- 不要用大量全局变量代替 target 依赖关系
- 不要把所有源码先 `set(SOURCES ...)` 再在很多地方共享，除非确实复用
- 不要用 `set` 去模拟复杂配置系统

### 你当前阶段最实用的 5 个 `set` 用法

```cmake
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(MYPLAYER_HEADERS
    core/dummy.h
    core/player.h
)

set(MYPLAYER_BUILD_EXAMPLES ON CACHE BOOL "Build example programs")
```

---

## 5.4 `add_executable`

### 基本写法

```cmake
add_executable(player_app
    app/main.cpp
)
```

### 参数怎么写

```cmake
add_executable(<target> [WIN32] [MACOSX_BUNDLE] [EXCLUDE_FROM_ALL] <sources>...)
```

关键参数：

- `<target>`
  - target 名称
  - 后续 `target_link_libraries` 等命令都靠它引用
- `<sources>...`
  - 源文件列表
- `WIN32`
  - Windows GUI 程序，不走控制台入口
- `MACOSX_BUNDLE`
  - macOS App bundle
- `EXCLUDE_FROM_ALL`
  - 默认不参与整体构建，只有显式构建该 target 时才构建

### 什么时候用

- 你要生成一个可执行程序
- 程序里有 `main()` 入口

### 示例

```cmake
add_executable(player_app app/main.cpp)

add_executable(tool_cli
    tools/cli_main.cpp
    tools/cli_command.cpp
)
```

### 注意事项

- target 名不是输出文件路径，而是逻辑目标名
- 小项目可直接把源码写进 `add_executable`
- 如果源码很多，可以先创建 target，再用 `target_sources`

---

## 5.5 `add_library`

### 基本写法

```cmake
add_library(player_core
    core/dummy.cpp
)
```

### 参数怎么写

```cmake
add_library(<target> [STATIC | SHARED | MODULE | INTERFACE] [EXCLUDE_FROM_ALL] <sources>...)
```

关键参数：

- `<target>`
  - 库 target 名称
- `STATIC`
  - 静态库
- `SHARED`
  - 动态库
- `MODULE`
  - 模块库，通常用于插件
- `INTERFACE`
  - 接口库，不编译源码，只携带使用要求
- `<sources>...`
  - 源文件列表

### 什么时候用

- 你想把项目拆成可复用模块
- 多个程序共享同一套核心逻辑
- 想把“编译一个库”和“链接这个库”分开表达

### 示例

```cmake
add_library(player_core STATIC
    core/dummy.cpp
    core/player.cpp
)

add_library(player_headers INTERFACE)
target_include_directories(player_headers INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/include)
```

### 注意事项

- 有 `.cpp` 源码时，通常不是 `INTERFACE`
- 学习阶段先用默认类型或 `STATIC`
- 只有明确需要动态库时，再考虑 `SHARED`

---

## 5.6 `target_include_directories`

### 基本写法

```cmake
target_include_directories(player_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/core
)
```

### 参数怎么写

```cmake
target_include_directories(<target> [SYSTEM] [AFTER | BEFORE]
    <INTERFACE|PUBLIC|PRIVATE> [items...]
    [<INTERFACE|PUBLIC|PRIVATE> [items...]]...
)
```

关键参数：

- `<target>`
  - 要设置头文件搜索路径的目标
- `PRIVATE`
  - 只当前 target 自己使用
- `PUBLIC`
  - 当前 target 自己用，也传给依赖它的目标
- `INTERFACE`
  - 当前 target 自己不用，只传给依赖它的目标
- `SYSTEM`
  - 把头文件目录标记为系统头文件目录，部分编译器会弱化警告
- `BEFORE`
  - 把目录放到更前面

### 什么时候用

- 某个 target 需要 `#include` 某些目录下的头文件
- 库要把自己的公开头文件暴露给调用方

### 示例

```cmake
target_include_directories(player_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)
```

### 如何判断用 `PUBLIC` 还是 `PRIVATE`

- 头文件路径只在本库 `.cpp` 里用到：`PRIVATE`
- 调用方包含你的头文件时也需要这个目录：`PUBLIC`
- 这是纯接口要求，当前 target 自己不编译源码：`INTERFACE`

### 注意事项

- 优先使用这个命令，不要优先用全局 `include_directories`
- 头文件目录应该跟着 target 走，而不是全局乱飘

---

## 5.7 `target_link_libraries`

### 基本写法

```cmake
target_link_libraries(player_app
    PRIVATE
        player_core
)
```

### 参数怎么写

```cmake
target_link_libraries(<target>
    <PRIVATE|PUBLIC|INTERFACE> <item>...
    [<PRIVATE|PUBLIC|INTERFACE> <item>...]...
)
```

`<item>` 常见可以是：

- 另一个 target，例如 `player_core`
- `find_package` 提供的 imported target，例如 `fmt::fmt`
- 平台库名，例如某些系统库

### 什么时候用

- 可执行程序依赖某个库
- 一个库依赖另一个库
- 要接入第三方库

### 示例

```cmake
target_link_libraries(player_app
    PRIVATE
        player_core
        fmt::fmt
)
```

### `PRIVATE / PUBLIC / INTERFACE` 在这里的含义

- `PRIVATE`
  - 只当前 target 链接和使用
- `PUBLIC`
  - 当前 target 使用，并把依赖继续传给依赖它的目标
- `INTERFACE`
  - 当前 target 自己不需要，但其使用者需要

### 注意事项

- 现代 `CMake` 推荐“target 链 target”
- 不要优先手工写 `.lib` 或 `.a` 文件路径

---

## 5.8 `add_subdirectory`

### 基本写法

```cmake
add_subdirectory(core)
add_subdirectory(app)
add_subdirectory(tests)
```

### 参数怎么写

```cmake
add_subdirectory(source_dir [binary_dir] [EXCLUDE_FROM_ALL])
```

关键参数：

- `source_dir`
  - 子目录路径
- `binary_dir`
  - 可选，指定该子目录单独的构建输出目录
- `EXCLUDE_FROM_ALL`
  - 默认不参与整体构建

### 什么时候用

- 项目变大，想把根 `CMakeLists.txt` 拆开
- 按模块维护自己的 target 定义

### 示例

```cmake
add_subdirectory(core)
add_subdirectory(app)

if(MYPLAYER_BUILD_TESTS)
    add_subdirectory(tests)
endif()
```

### 注意事项

- 最常见写法只传一个目录参数就够了
- 根目录保留总控逻辑，子目录定义自己的 target

---

## 5.9 `target_sources`

### 基本写法

```cmake
target_sources(player_core
    PRIVATE
        core/dummy.cpp
        core/other.cpp
)
```

### 参数怎么写

```cmake
target_sources(<target>
    <PRIVATE|PUBLIC|INTERFACE> [items...]
    [<PRIVATE|PUBLIC|INTERFACE> [items...]]...
)
```

### 什么时候用

- 你已经先创建了 target
- 想分阶段、分模块给 target 添加源码
- 想让 `CMakeLists.txt` 更清晰

### 示例

```cmake
add_library(player_core)

target_sources(player_core
    PRIVATE
        core/dummy.cpp
        core/player.cpp
)
```

### 注意事项

- 小项目直接写在 `add_library` 或 `add_executable` 里也可以
- 中型项目里，`target_sources` 通常更易维护

---

## 5.10 `option`

### 基本写法

```cmake
option(MYPLAYER_BUILD_TESTS "Build tests" ON)
```

### 参数怎么写

```cmake
option(<variable> "<help_text>" [value])
```

关键参数：

- `<variable>`
  - 开关变量名
- `"<help_text>"`
  - 说明文字
- `[value]`
  - 默认值，通常写 `ON` 或 `OFF`

### 什么时候用

- 想做一个简单开关
- 用户可以在配置阶段打开或关闭某个功能

### 示例

```cmake
option(MYPLAYER_BUILD_TESTS "Build tests" ON)
option(MYPLAYER_BUILD_EXAMPLES "Build examples" OFF)
```

配合使用：

```cmake
if(MYPLAYER_BUILD_TESTS)
    add_subdirectory(tests)
endif()
```

命令行覆盖：

```bash
cmake -S . -B build -DMYPLAYER_BUILD_TESTS=OFF
```

### 注意事项

- 用布尔开关时，`option` 通常比 `set(... CACHE BOOL ...)` 更适合
- 变量名建议带项目名前缀，避免和别的模块冲突

---

## 5.11 `if`

### 基本写法

```cmake
if(WIN32)
    message(STATUS "Building on Windows")
endif()
```

### 常见写法

```cmake
if(MYPLAYER_BUILD_TESTS)
    add_subdirectory(tests)
endif()

if(MSVC)
    target_compile_options(player_core PRIVATE /W4)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(player_core PRIVATE -Wall -Wextra)
endif()
```

### 常见判断条件

- `WIN32`
- `UNIX`
- `APPLE`
- `MSVC`
- `DEFINED 变量名`
- `EXISTS 路径`
- `变量`
- `变量 STREQUAL "字符串"`
- `NOT 条件`

### 什么时候用

- 平台分支
- 编译器分支
- 功能开关判断
- 检查路径、变量是否存在

### 注意事项

- 初学阶段少写很深的嵌套
- 平台差异尽量控制在必要范围内

---

## 5.12 `message`

### 基本写法

```cmake
message(STATUS "CMAKE_CXX_COMPILER = ${CMAKE_CXX_COMPILER}")
```

### 参数怎么写

```cmake
message([<mode>] "text")
```

常见 `<mode>`：

- `STATUS`
  - 普通状态信息
- `WARNING`
  - 警告，但继续执行
- `FATAL_ERROR`
  - 打印错误并停止配置

### 什么时候用

- 调试配置过程
- 输出关键变量
- 检查依赖缺失并中止

### 示例

```cmake
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(WARNING "FFmpeg not found, related features will be disabled")
message(FATAL_ERROR "SDL2 is required to build player_app")
```

### 注意事项

- `STATUS` 适合日常排查
- 关键依赖缺失时再用 `FATAL_ERROR`

---

## 5.13 `find_package`

### 基本写法

```cmake
find_package(fmt REQUIRED)
target_link_libraries(player_app PRIVATE fmt::fmt)
```

### 参数怎么写

```cmake
find_package(<PackageName> [version] [EXACT] [QUIET] [MODULE] [REQUIRED] [COMPONENTS ...])
```

关键参数：

- `<PackageName>`
  - 包名
- `[version]`
  - 最低版本或指定版本
- `EXACT`
  - 必须精确匹配版本
- `QUIET`
  - 查找失败时少打印信息
- `REQUIRED`
  - 找不到就直接报错
- `COMPONENTS ...`
  - 指定需要的组件

### 什么时候用

- 系统中已经安装了某个第三方库
- 包管理器已经提供了 `CMake` 配置文件
- 你希望按现代 `CMake` 方式链接外部库

### 示例

```cmake
find_package(fmt REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Qt6 REQUIRED COMPONENTS Core Widgets)

target_link_libraries(player_app
    PRIVATE
        fmt::fmt
        OpenSSL::SSL
)
```

### 注意事项

- 优先使用库暴露出来的 imported target
- 不要先想到手工写 include 路径和 lib 路径

---

## 5.14 `FetchContent`

### 基本写法

```cmake
include(FetchContent)

FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)

FetchContent_MakeAvailable(googletest)
```

### 常见步骤

1. `include(FetchContent)`
2. `FetchContent_Declare(...)`
3. `FetchContent_MakeAvailable(...)`

### `FetchContent_Declare` 参数怎么写

常见写法：

```cmake
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)
```

也可以写：

```cmake
FetchContent_Declare(
    fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG 10.2.1
)
```

常见参数：

- 第一个位置参数：依赖名字
- `URL`
  - 下载压缩包地址
- `GIT_REPOSITORY`
  - Git 仓库地址
- `GIT_TAG`
  - 标签、分支或提交

### 什么时候用

- 学习项目、中小项目接入第三方依赖
- 希望依赖跟着项目自动拉取

### 注意事项

- 网络不稳定时体验会受影响
- 企业项目里也可能改用包管理器或预装依赖

---

## 5.15 `enable_testing` 和 `add_test`

### `enable_testing` 基本写法

```cmake
enable_testing()
```

作用：

- 开启 `CTest` 支持

什么时候用：

- 项目要通过 `ctest` 统一跑测试

### `add_test` 基本写法

```cmake
add_test(NAME smoke_tests COMMAND unit_tests)
```

### `add_test` 参数怎么写

```cmake
add_test(NAME <name> COMMAND <command> [<arg>...])
```

关键参数：

- `NAME <name>`
  - 测试名字
- `COMMAND <command> [<arg>...]`
  - 运行哪个可执行程序，以及传什么参数

### 完整示例

```cmake
enable_testing()

add_executable(unit_tests tests/smoke_test.cpp)
target_link_libraries(unit_tests PRIVATE player_core GTest::gtest_main)

add_test(NAME unit_tests COMMAND unit_tests)
```

### 什么时候用

- 已经有测试程序
- 想让 `ctest` 管理它们

### 注意事项

- 只有 `add_executable(unit_tests ...)` 还不够
- 没有 `add_test(...)`，`ctest` 不会自动发现该程序

---

<a id="section-6"></a>
# 6. 一份更贴近你项目的推荐结构

如果你的工程是：

```text
myplayer/
  CMakeLists.txt
  app/
    main.cpp
  core/
    dummy.cpp
    dummy.h
  tests/
    smoke_test.cpp
```

推荐写法：

## 根目录 `CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.20)
project(myplayer VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(MYPLAYER_BUILD_TESTS "Build tests" ON)

add_subdirectory(core)
add_subdirectory(app)

if(MYPLAYER_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
```

## `core/CMakeLists.txt`

```cmake
add_library(player_core
    dummy.cpp
)

target_include_directories(player_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)
```

## `app/CMakeLists.txt`

```cmake
add_executable(player_app
    main.cpp
)

target_link_libraries(player_app
    PRIVATE
        player_core
)
```

## `tests/CMakeLists.txt`

```cmake
include(FetchContent)

FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)

FetchContent_MakeAvailable(googletest)

add_executable(unit_tests
    smoke_test.cpp
)

target_link_libraries(unit_tests
    PRIVATE
        player_core
        GTest::gtest_main
)

add_test(NAME unit_tests COMMAND unit_tests)
```

---

<a id="section-7"></a>
# 7. 初学阶段最常见的坑

## 7.1 滥用全局命令

常见问题：

- `include_directories(...)`
- `link_directories(...)`
- 全局 `add_definitions(...)`

问题在哪：

- 依赖关系不清晰
- 项目变大后很难排查

建议：

- 优先使用 `target_*` 系列命令

## 7.2 把文件路径当成依赖管理

错误倾向：

- 手工到处写头文件绝对路径
- 手工写 `.lib` 路径

建议：

- 让 target 依赖 target
- 不要让源码文件直接依赖路径拼接

## 7.3 不理解 `PUBLIC / PRIVATE / INTERFACE`

这是最常见的卡点之一。

先记一个最够用的版本：

- `PRIVATE`：只我自己用
- `PUBLIC`：我自己用，依赖我的也能用
- `INTERFACE`：我自己不用，只传递给别人

如果你现在只记住这三句话，已经够你做前期项目。

## 7.4 一开始就写得太复杂

常见表现：

- 一上来拆很多层 CMake 模块
- 一上来写大量平台分支
- 一上来做安装、导出、打包

建议：

- 学习阶段先保住最小闭环：
  - 能配置
  - 能编译
  - 能链接
  - 能跑测试

## 7.5 混淆配置阶段和编译阶段

记法：

- `cmake -S . -B build`：配置阶段
- `cmake --build build`：编译阶段

很多问题都要先判断：

- 是配置失败
- 还是编译失败

## 7.6 测试 target 建了，但 `ctest` 跑不起来

常见原因：

- 忘了 `enable_testing()`
- 忘了 `add_test(...)`

## 7.7 用变量堆配置，最后看不出 target 关系

常见表现：

- 全局 `set` 一堆 `INCLUDE_DIRS`、`LIBS`、`FLAGS`
- 然后多个 target 到处复用

问题：

- 读文件时不知道谁真正依赖谁
- 改一个变量容易影响一大片

建议：

- 能挂到 `target_include_directories`
- 能挂到 `target_link_libraries`
- 能挂到 `target_compile_definitions`
- 就不要先塞进全局变量再四处展开

---

<a id="section-8"></a>
# 8. 现阶段最值得先记住的命令

如果你只想先掌握最核心的一小部分，优先记这 10 个：

1. `cmake_minimum_required`
2. `project`
3. `set`
4. `add_library`
5. `add_executable`
6. `target_include_directories`
7. `target_link_libraries`
8. `add_subdirectory`
9. `enable_testing`
10. `add_test`

如果再往前一步，就补：

11. `FetchContent`
12. `find_package`
13. `option`
14. `if`
15. `message`

---

<a id="section-9"></a>
# 9. 一个学习顺序建议

按下面顺序学，阻力最小：

1. 先学 `add_executable`
2. 再学 `add_library`
3. 再学 `target_link_libraries`
4. 再学 `target_include_directories`
5. 再学 `set`
6. 再学 `add_subdirectory`
7. 再学测试相关
8. 最后学第三方依赖接入

---

<a id="section-10"></a>
# 10. 你当前阶段的最低目标

就你现在的学习阶段，不需要一口气掌握完整 `CMake`。

你只要先能做到下面 6 条，就已经够进入下一阶段：

1. 能写一个最小 `CMakeLists.txt`
2. 能定义库和可执行程序两个 target
3. 能让可执行程序链接自己的库
4. 知道 `PUBLIC / PRIVATE / INTERFACE` 的基本区别
5. 能用 `set` 管理标准、列表和简单开关
6. 能接入 `GoogleTest` 并通过 `ctest` 跑测试

---

<a id="section-11"></a>
# 11. 一句话总结

初学 `CMake` 时，最重要的不是背命令，而是建立一个习惯：  
**围绕 target 组织项目，而不是围绕文件路径和全局配置组织项目。**
