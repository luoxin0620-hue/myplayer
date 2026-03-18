# myplayer C++ 编码规范

这份规范的目标不是追求“最严格”，而是让项目从一开始就保持一致、可读、可维护。

适用范围：

- `app/`
- `core/`
- `test/`

## 1. 基本原则

1. 先保证一致，再谈个人偏好。
2. 先写清晰代码，再写“聪明”代码。
3. 依赖类型、作用域和 RAII 管理复杂度，不靠注释堆逻辑。
4. 工具能自动检查的规则，尽量交给工具。

## 2. 命名规则

命名规则的目标不是“好看”，而是让你在读代码时，**一眼就能大致判断一个名字代表什么**。

一套统一命名至少能解决 3 个问题：

1. 降低阅读成本。看到名字就知道它更像类型、函数还是变量。
2. 降低沟通成本。团队讨论时，不需要每次重新约定风格。
3. 降低修改风险。名字越统一，批量搜索、重构和静态检查越稳定。

这套规则里，不同类别故意使用不同外形：

- `PascalCase` 通常留给“类型”
- `camelCase` 通常留给“动作、行为”
- `snake_case` 通常留给“数据、状态、普通值”
- `snake_case_` 用来标识“这是成员变量，不是局部变量”
- `kPascalCase` 用来标识“这是常量，不应该随意改”

### 2.1 类型

- 类、结构体、枚举、类型别名使用 `PascalCase`
- 例子：`PlayerCore`、`PlaybackState`

解释：

- `PascalCase` 的特点是每个单词首字母大写，视觉上很像“名词”或“概念”
- 类型本质上是在定义一个抽象实体，所以用这种写法最容易和变量区分
- 当你在代码里看到 `PlayerCore`，通常会自然联想到“这是一个类或类型”，而不是一个普通变量

适用对象：

- `class`
- `struct`
- `enum class`
- `using` 定义的类型别名

示例：

```cpp
class AudioDecoder {};
struct FrameInfo {};
enum class PlaybackState { kStopped, kPlaying };
using SampleCount = std::size_t;
```

常见误区：

- 不要把类型写成 `player_core`
- 不要把类型写成 `playerCore`
- 不要同一个项目里同时混用 `PlayerCore` 和 `player_core_t`

原因：

- 类型名如果和变量长得太像，阅读时会频繁停顿
- 尤其在模板、返回值、成员声明里，区分度很重要

### 2.2 函数

- 普通函数、成员函数使用 `camelCase`
- 例子：`loadFile()`、`startPlayback()`

解释：

- 函数通常表示一个动作，因此命名应尽量像“动词短语”
- `camelCase` 看起来比 `PascalCase` 更轻，和类型名有明显区分
- 当你看到 `loadFile()`、`resetState()` 时，会更容易把它理解成“要执行的行为”

适用对象：

- 普通函数
- 成员函数
- 工具函数
- 工厂函数

示例：

```cpp
void startPlayback();
bool openFile(const std::string& file_path);
int calculateFrameCount(int duration_ms);
```

命名建议：

- 优先用动词开头，如 `load`、`open`、`create`、`reset`
- 布尔返回值函数优先用可读性更强的形式，如 `isReady()`、`hasAudio()`、`canSeek()`
- 避免空泛名字，如 `doWork()`、`handleThing()`

常见误区：

- 不要把函数写成 `StartPlayback()`
- 不要把函数写成 `start_playback()`
- 不要用缩写把语义压扁，例如 `procFrm()`

### 2.3 变量

- 普通变量、局部变量、函数参数使用 `snake_case`
- 例子：`file_path`、`frame_count`

解释：

- 变量主要承载数据和状态，`snake_case` 的可读性通常比驼峰更稳定
- 多个单词之间用下划线分隔，长名字也比较容易扫读
- 局部变量和参数是代码里最常见的名字，统一使用 `snake_case` 可以减少视觉噪音

适用对象：

- 局部变量
- 函数参数
- 非成员的普通变量
- 循环变量以外的大多数短期数据

示例：

```cpp
std::string file_path;
int frame_count = 0;
bool is_ready = false;
double input_value = 0.0;
```

命名建议：

- 名字尽量表达实际含义，不要只写 `data`、`tmp`、`value`
- 生命周期很短、作用域极小的变量，可以适当短一些，但仍要可读
- 布尔变量尽量像状态，如 `is_ready`、`has_error`、`need_retry`

常见误区：

- 不要在同一个函数里混用 `filePath` 和 `file_path`
- 不要大量使用 `a`、`b`、`x1` 这类没有语义的名字
- 不要把类型信息硬编码进名字，例如 `str_name`、`i_count`

原因：

- 现代 IDE 和类型系统已经能告诉你类型
- 名字更应该表达“含义”，而不是“底层存储类型”

### 2.4 成员变量

- 非静态成员变量使用 `snake_case_`
- 例子：`current_state_`、`volume_`

解释：

- 成员变量和局部变量最容易重名
- 在成员变量后加 `_`，能让你在实现文件里立刻看出“这是对象状态”
- 这种写法能显著减少构造函数、setter、复杂成员函数里的歧义

示例：

```cpp
class PlayerCore {
public:
    void setVolume(int volume) {
        volume_ = volume;
    }

private:
    int volume_ = 0;
};
```

上面这个例子里：

- `volume` 是参数
- `volume_` 是成员变量

两者一眼就能区分，不需要额外加 `this->` 才看懂。

适用对象：

- 类的非静态成员变量
- 结构体里如果承担长期对象状态，也可以采用相同规则

常见误区：

- 不要写成 `_volume`
- 不要写成 `m_volume`
- 不要写成 `volumeValue`

原因：

- 前导下划线在 C++ 里容易和保留标识符规则冲突
- `m_` 是老风格，可以用，但和当前项目其他规则不够统一
- 后缀 `_` 在阅读和工具检查上都更稳定

### 2.5 常量

- 常量使用 `kPascalCase`
- 例子：`kDefaultVolume`、`kMaxRetryCount`

解释：

- 常量的特点是“值稳定，语义固定”
- 前缀 `k` 是一个非常常见的约定，表示“这是 constant”
- 后面的 `PascalCase` 让它和类型名保持整洁外形，同时又通过 `k` 和类型区分开

适用对象：

- `constexpr` 常量
- `const` 的具名编译期或运行期常量
- 类内静态常量

示例：

```cpp
constexpr int kDefaultVolume = 50;
constexpr std::size_t kMaxFrameCount = 1024;
const std::string kDefaultDeviceName = "speaker";
```

命名建议：

- 常量名应表达业务意义，而不是只表达数字本身
- 优先写 `kDefaultTimeoutMs`，不要只写 `kTimeout`

常见误区：

- 不要把常量写成全大写，例如 `DEFAULT_VOLUME`
- 不要把普通变量起成 `kVolume`
- 不要把会频繁变化的状态量当常量命名

补充说明：

- 宏常量常见写法是全大写，但这里说的是 C++ 常量对象，不是预处理宏
- 能用 `constexpr` 或 `const` 时，优先不用宏

### 2.6 宏

- 只有确实需要宏时才使用
- 宏名全部大写，下划线分隔
- 例子：`MYPLAYER_EXPORT`

解释：

- 宏不是 C++ 语言层面的实体，而是预处理阶段直接做文本替换
- 宏没有作用域、类型检查也弱，滥用后很难调试
- 所以这里的原则不是“怎么命名宏”，而是“先尽量别用宏”

什么时候才考虑用宏：

- 头文件保护宏
- 跨平台导出符号，例如 `MYPLAYER_EXPORT`
- 条件编译
- 某些必须依赖预处理器的编译开关

示例：

```cpp
#define MYPLAYER_EXPORT
#define MYPLAYER_ENABLE_LOG 1
```

为什么全大写：

- 让它和普通变量、函数、类型一眼区分开
- 提醒读代码的人：这不是普通标识符，它可能在预处理阶段就被替换掉

常见误区：

- 不要用宏定义普通常量
- 不要用宏包装简单函数逻辑
- 不要把宏命名成和函数、变量很像的样子

不推荐：

```cpp
#define DEFAULT_VOLUME 50
#define MIN(a, b) ((a) < (b) ? (a) : (b))
```

推荐：

```cpp
constexpr int kDefaultVolume = 50;

template <typename T>
const T& minValue(const T& left, const T& right) {
    return (left < right) ? left : right;
}
```

## 2.7 一眼区分的记忆方式

如果你现在还不熟，先记下面这组最够用的判断法：

- 看到 `PlayerCore`：大概率是类型
- 看到 `startPlayback()`：大概率是函数
- 看到 `file_path`：大概率是普通变量或参数
- 看到 `volume_`：大概率是成员变量
- 看到 `kDefaultVolume`：大概率是常量
- 看到 `MYPLAYER_EXPORT`：大概率是宏

这就是这套命名规则最核心的价值：  
**通过名字的外形，提前告诉你这个标识符在代码里扮演什么角色。**

## 3. 文件组织

### 3.1 文件命名

- 文件名统一使用小写加下划线
- 例子：`audio_decoder.h`、`audio_decoder.cpp`

### 3.2 一类一对文件

- 一个主要类通常对应一对 `.h/.cpp`
- 头文件写接口，实现细节放 `.cpp`

### 3.3 头文件保护

- 统一使用 `#pragma once`
- 头文件应尽量做到“单独 include 也能编译”

## 4. 格式规则

### 4.1 缩进和换行

- 使用 4 空格缩进，不使用 Tab
- 单行长度尽量不超过 100 列
- 左花括号放在语句同一行

示例：

```cpp
if (is_ready) {
    startPlayback();
}
```

### 4.2 控制语句

- `if`、`for`、`while`、`switch` 后保留空格
- 即使只有一行，也加花括号

不推荐：

```cpp
if (is_ready)
    startPlayback();
```

推荐：

```cpp
if (is_ready) {
    startPlayback();
}
```

### 4.3 空格

- 二元运算符两侧加空格
- 逗号后加空格
- 函数调用括号内不加多余空格

推荐：

```cpp
int sum = left + right;
play(file_path, repeat_count);
```

## 5. 头文件和 include

### 5.1 include 顺序

推荐顺序：

1. 对应头文件
2. C++ 标准库头文件
3. 第三方库头文件
4. 项目内其他头文件

示例：

```cpp
#include "core/player.h"

#include <iostream>
#include <string>

#include "core/dummy.h"
```

### 5.2 禁止项

- 不要在头文件里写 `using namespace std;`
- 不要在头文件里包含无关的大型依赖

## 6. 类型和接口设计

### 6.1 `const`

- 只读参数、只读成员函数、只读对象优先加 `const`
- 大对象只读传参优先使用 `const T&`

示例：

```cpp
std::string formatName(const std::string& raw_name);
```

### 6.2 指针和引用

- 能明确不为空、且不需要表达“无对象”时，优先用引用
- 需要表达可空语义时，用指针
- 对象所有权优先通过栈对象和 RAII 表达

### 6.3 构造和转换

- 单参数构造函数默认加 `explicit`
- 优先使用 `enum class`
- 优先使用 `nullptr`，不要用 `NULL`

## 7. 类成员顺序

推荐顺序：

1. `public` 类型别名和常量
2. `public` 构造/析构
3. `public` 接口
4. `private` 辅助函数
5. `private` 成员变量

示例：

```cpp
class PlayerCore {
public:
    PlayerCore();

    void start();
    void stop();

private:
    void resetState();

    bool is_running_ = false;
};
```

## 8. 错误处理

- 能在当前层处理的错误，就在当前层处理
- 不能恢复的错误，再向上返回或抛出
- 错误信息要包含上下文，不要只写 `failed`

不推荐：

```cpp
std::cerr << "error" << std::endl;
```

推荐：

```cpp
std::cerr << "failed to open file: " << file_path << std::endl;
```

## 9. 注释规则

- 注释解释“为什么”，不要重复“代码正在做什么”
- 接口不直观时，在声明前写简短说明
- 过期注释要和代码一起删掉

不推荐：

```cpp
count++;  // count plus one
```

推荐：

```cpp
// Retry once to tolerate transient startup failures.
++retry_count;
```

## 10. 项目级约定

- `app/` 放程序入口和应用层逻辑
- `core/` 放核心业务逻辑和可复用模块
- `test/` 放单元测试和简单集成测试
- 优先通过 target 组织模块，不依赖全局变量和全局 include 目录

## 11. 工具约定

项目使用以下工具作为默认基线：

- `.clang-format`：自动格式化
- `.clang-tidy`：静态检查

推荐命令：

```powershell
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
clang-format -i app/main.cpp core/dummy.h core/dummy.cpp
clang-tidy app/main.cpp -- -std=c++17
```

如果后续接入 VSCode、CLion 或 Visual Studio，也优先让 IDE 直接读取这两份配置文件。

## 12. 当前项目的最小执行标准

在 `myplayer` 这个阶段，先保证下面 8 条：

1. 能编译通过
2. 命名统一
3. 没有明显拼写错误，例如 `main` 写成 `mian`
4. 每个控制语句都带花括号
5. 头文件不用 `using namespace`
6. 新增类时使用 `#pragma once`
7. 警告尽量清零
8. 提交前跑一次格式化
