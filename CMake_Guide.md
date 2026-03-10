# CMake 常用指令用法指南

适用场景：你已经粗略学过 `CMake`，但需要一份能随时查的实战文档。  
目标：优先掌握 C++ 项目里最常见、最值得先会的写法。

---

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

# 2. 最常用命令行

## 2.1 配置工程

```bash
cmake -S . -B build
```

含义：

- `-S .`：源码目录是当前目录
- `-B build`：构建目录是 `build/`

## 2.2 编译工程

```bash
cmake --build build
```

## 2.3 指定配置编译

```bash
cmake --build build --config Debug
cmake --build build --config Release
```

注意：

- 在 `Visual Studio` 这类多配置生成器下，`Debug/Release` 常通过 `--config` 指定
- 在 `Ninja`、`Makefiles` 这类单配置生成器下，通常在配置阶段指定

## 2.4 运行测试

```bash
ctest --test-dir build --output-on-failure
```

---

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

# 4. 常用指令说明

## 4.1 `cmake_minimum_required`

```cmake
cmake_minimum_required(VERSION 3.20)
```

作用：

- 指定项目要求的最低 `CMake` 版本

注意事项：

- 不要省略
- 版本不要乱写太高，选你机器和常见环境都能接受的版本

---

## 4.2 `project`

```cmake
project(myplayer VERSION 0.1.0 LANGUAGES CXX)
```

作用：

- 定义项目名
- 可选定义版本
- 指定语言

常用点：

- `LANGUAGES CXX` 表示当前项目使用 C++

注意事项：

- 如果项目里只用 C++，先不要额外加 `C`
- 项目名最好和仓库或主工程一致

---

## 4.3 `set`

```cmake
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
```

作用：

- 设置变量

这 3 行最常见的用途：

- 指定 C++ 标准
- 要求编译器必须支持该标准
- 不使用编译器私有扩展

注意事项：

- 初学阶段优先写这三行
- 不要一开始就在全局 `set` 过多编译选项

---

## 4.4 `add_executable`

```cmake
add_executable(player_app
    app/main.cpp
)
```

作用：

- 定义一个可执行程序 target

什么时候用：

- 你的程序入口是 `main.cpp`
- 你想产出一个 `.exe`

注意事项：

- target 名称是后面链接依赖时要引用的名字
- 一个 target 不等于一个目录，而是一个构建目标

---

## 4.5 `add_library`

```cmake
add_library(player_core
    core/dummy.cpp
)
```

作用：

- 定义一个库 target

常见类型：

- 默认库
- `STATIC`
- `SHARED`
- `INTERFACE`

示例：

```cmake
add_library(player_core STATIC core/dummy.cpp)
```

初学建议：

- 先不纠结动态库和静态库
- 前期用默认或 `STATIC` 就够了

注意事项：

- `INTERFACE` 库不编译源码，只传递头文件、编译选项、依赖信息
- 真正有 `.cpp` 源码时，不要误写成 `INTERFACE`

---

## 4.6 `target_include_directories`

```cmake
target_include_directories(player_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/core
)
```

作用：

- 指定头文件搜索路径

3 个关键字：

- `PRIVATE`：只给当前 target 自己用
- `PUBLIC`：当前 target 自己用，并且依赖它的 target 也会继承
- `INTERFACE`：当前 target 自己不用，只传给依赖方

你当前最实用的理解方式：

- 头文件要暴露给别人用，通常是 `PUBLIC`
- 只在自己内部实现里用，通常是 `PRIVATE`

注意事项：

- 优先使用 `target_include_directories`
- 尽量不要用全局 `include_directories`

---

## 4.7 `target_link_libraries`

```cmake
target_link_libraries(player_app
    PRIVATE
        player_core
)
```

作用：

- 给 target 链接依赖库

常见场景：

- 可执行程序依赖你自己的库
- 可执行程序依赖第三方库
- 库依赖另一个库

`PRIVATE/PUBLIC/INTERFACE` 在这里同样成立：

- `PRIVATE`：只影响当前 target
- `PUBLIC`：当前 target 和依赖它的目标都会继承
- `INTERFACE`：只传递给依赖方

注意事项：

- 这是现代 `CMake` 的核心命令之一
- 不要迷信“直接加 `.lib` 文件路径”这种老写法

---

## 4.8 `add_subdirectory`

```cmake
add_subdirectory(core)
add_subdirectory(app)
add_subdirectory(tests)
```

作用：

- 把子目录中的 `CMakeLists.txt` 纳入当前工程

适合什么情况：

- 项目开始变大
- 你想按模块拆分 `CMakeLists.txt`

注意事项：

- 根目录保留总控逻辑
- 每个子目录维护自己的 target 定义

---

## 4.9 `target_sources`

```cmake
target_sources(player_core
    PRIVATE
        core/dummy.cpp
        core/other.cpp
)
```

作用：

- 给已有 target 补充源码

什么时候好用：

- 你已经先创建了 target，后面再逐步添加源码

注意事项：

- 小项目可以直接写在 `add_library` / `add_executable` 里
- 中型项目用 `target_sources` 往往更清晰

---

## 4.10 `option`

```cmake
option(MYPLAYER_BUILD_TESTS "Build tests" ON)
```

作用：

- 定义一个开关项

常见用途：

- 是否编译测试
- 是否开启某个实验功能

搭配使用：

```cmake
if(MYPLAYER_BUILD_TESTS)
    add_subdirectory(tests)
endif()
```

注意事项：

- 这比手工改 `CMakeLists.txt` 更好维护

---

## 4.11 `if`

```cmake
if(WIN32)
    message(STATUS "Building on Windows")
endif()
```

作用：

- 条件判断

常见判断：

- `WIN32`
- `MSVC`
- `APPLE`
- `UNIX`
- 某个 option 是否开启

注意事项：

- 初学阶段少写复杂嵌套
- 先把跨平台差异控制在最小范围

---

## 4.12 `message`

```cmake
message(STATUS "CMAKE_CXX_COMPILER = ${CMAKE_CXX_COMPILER}")
```

作用：

- 打印调试信息

常见级别：

- `STATUS`
- `WARNING`
- `FATAL_ERROR`

注意事项：

- 配置阶段排查问题很好用
- 发现关键依赖不存在时，可以用 `FATAL_ERROR` 直接中止

---

## 4.13 `find_package`

```cmake
find_package(fmt REQUIRED)
target_link_libraries(player_app PRIVATE fmt::fmt)
```

作用：

- 查找系统或包管理器安装好的库

常见场景：

- `fmt`
- `Boost`
- `OpenSSL`
- `SDL2`

注意事项：

- 优先链接库提供的 imported target，比如 `fmt::fmt`
- 不要优先走手工写 include/lib 路径的老办法

---

## 4.14 `FetchContent`

```cmake
include(FetchContent)

FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)

FetchContent_MakeAvailable(googletest)
```

作用：

- 在配置阶段拉取第三方依赖

典型用途：

- 接入 `GoogleTest`

注意事项：

- 很适合学习项目和中小项目
- 企业项目里可能会更偏向包管理器或预置依赖
- 网络不稳定时，`FetchContent` 体验会受影响

---

## 4.15 `enable_testing` 和 `add_test`

```cmake
enable_testing()

add_executable(unit_tests tests/smoke_test.cpp)
target_link_libraries(unit_tests PRIVATE player_core GTest::gtest_main)

add_test(NAME smoke_tests COMMAND unit_tests)
```

作用：

- 开启测试支持
- 把测试可执行程序注册给 `ctest`

注意事项：

- 只有 `add_executable(unit_tests ...)` 还不够
- 没有 `add_test(...)`，`ctest` 不会自动发现你的测试程序

---

# 5. 一份更贴近你项目的推荐结构

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

# 6. 初学阶段最常见的坑

## 6.1 滥用全局命令

常见问题：

- `include_directories(...)`
- `link_directories(...)`
- 全局 `add_definitions(...)`

问题在哪：

- 依赖关系不清晰
- 项目变大后很难排查

建议：

- 优先使用 `target_*` 系列命令

---

## 6.2 把文件路径当成依赖管理

错误倾向：

- 手工到处写头文件绝对路径
- 手工写 `.lib` 路径

建议：

- 让 target 依赖 target
- 不要让源码文件直接依赖路径拼接

---

## 6.3 不理解 `PUBLIC / PRIVATE / INTERFACE`

这是最常见的卡点之一。

先记一个最够用的版本：

- `PRIVATE`：只我自己用
- `PUBLIC`：我自己用，依赖我的也能用
- `INTERFACE`：我自己不用，只传递给别人

如果你现在只记住这三句话，已经够你做前期项目。

---

## 6.4 一开始就写得太复杂

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

---

## 6.5 混淆配置阶段和编译阶段

记法：

- `cmake -S . -B build`：配置阶段
- `cmake --build build`：编译阶段

很多问题都要先判断：

- 是配置失败
- 还是编译失败

---

## 6.6 测试 target 建了，但 `ctest` 跑不起来

常见原因：

- 忘了 `enable_testing()`
- 忘了 `add_test(...)`

---

# 7. 现阶段最值得先记住的命令

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

# 8. 一个学习顺序建议

按下面顺序学，阻力最小：

1. 先学 `add_executable`
2. 再学 `add_library`
3. 再学 `target_link_libraries`
4. 再学 `target_include_directories`
5. 再学 `add_subdirectory`
6. 再学测试相关
7. 最后学第三方依赖接入

---

# 9. 你当前阶段的最低目标

就你现在的学习阶段，不需要一口气掌握完整 `CMake`。

你只要先能做到下面 5 条，就已经够进入下一阶段：

1. 能写一个最小 `CMakeLists.txt`
2. 能定义库和可执行程序两个 target
3. 能让可执行程序链接自己的库
4. 能接入 `GoogleTest`
5. 能通过 `ctest` 跑测试

---

# 10. 一句话总结

初学 `CMake` 时，最重要的不是背命令，而是建立一个习惯：  
**围绕 target 组织项目，而不是围绕文件路径和全局配置组织项目。**
