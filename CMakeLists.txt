cmake_minimum_required(VERSION 3.20)
project(myplayer VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(player_app app/main.cpp)

add_library(player_core STATIC core/dummy.cpp)

target_include_directories(player_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/core)

target_link_libraries(player_app PRIVATE player_core)