# =========== libcopp/src - stack_context =========== 
set (PROJECT_LIBCOPP_STACK_CONTEXT_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}")
set (PROJECT_LIBCOPP_STACK_ALLOC_SRC_DIR "${PROJECT_LIBCOPP_STACK_CONTEXT_SRC_DIR}/allocator")

# ========== stack information ==========
aux_source_directory("${PROJECT_LIBCOPP_STACK_CONTEXT_SRC_DIR}" SRC_LIST)
list(APPEND COPP_SRC_LIST ${SRC_LIST})

# ========== stack allocator ==========
list(APPEND COPP_SRC_LIST "${PROJECT_LIBCOPP_STACK_ALLOC_SRC_DIR}/stack_allocator_memory.cpp")
list(APPEND COPP_SRC_LIST "${PROJECT_LIBCOPP_STACK_ALLOC_SRC_DIR}/stack_allocator_malloc.cpp")

include(CheckIncludeFileCXX)
include(CheckIncludeFiles)

CHECK_INCLUDE_FILE_CXX(windows.h PROJECT_LIBCOPP_STACK_ALLOC_WINDOWS)
if(PROJECT_LIBCOPP_STACK_ALLOC_WINDOWS)
	EchoWithColor(COLOR GREEN "-- stack allocator: enable windows allocator")
	list(APPEND COPP_SRC_LIST "${PROJECT_LIBCOPP_STACK_ALLOC_SRC_DIR}/stack_allocator_windows.cpp")
	list(APPEND COPP_SRC_LIST "${PROJECT_LIBCOPP_STACK_CONTEXT_SRC_DIR}/stack_traits/stack_traits_windows.cpp")
	set(LIBCOPP_MACRO_SYS_WIN 1)
endif()

CHECK_INCLUDE_FILES("sys/resource.h;sys/time.h;unistd.h;sys/types.h;fcntl.h;sys/mman.h" PROJECT_LIBCOPP_STACK_ALLOC_POSIX)

if(PROJECT_LIBCOPP_STACK_ALLOC_POSIX)
	EchoWithColor(COLOR GREEN "-- stack allocator: enable posix allocator")
	list(APPEND COPP_SRC_LIST "${PROJECT_LIBCOPP_STACK_ALLOC_SRC_DIR}/stack_allocator_posix.cpp")
	list(APPEND COPP_SRC_LIST "${PROJECT_LIBCOPP_STACK_CONTEXT_SRC_DIR}/stack_traits/stack_traits_posix.cpp")
	set(LIBCOPP_MACRO_SYS_POSIX 1)
endif()

if(LIBCOPP_ENABLE_SEGMENTED_STACKS)
	if(NOT ${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" AND NOT ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
        EchoWithColor(COLOR YELLOW "-- set LIBCOPP_ENABLE_SEGMENTED_STACKS but only gcc and clang support segmented stacks")
        unset(LIBCOPP_ENABLE_SEGMENTED_STACKS)
    elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7.0")
        EchoWithColor(COLOR YELLOW "-- set LIBCOPP_ENABLE_SEGMENTED_STACKS but gcc 4.7.0 and upper support segmented stacks")
		unset(LIBCOPP_ENABLE_SEGMENTED_STACKS)
	elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "5.0.0")
        EchoWithColor(COLOR YELLOW "-- set LIBCOPP_ENABLE_SEGMENTED_STACKS but clang 5.0.0 and upper support segmented stacks")
        unset(LIBCOPP_ENABLE_SEGMENTED_STACKS)
    else()
        EchoWithColor(COLOR GREEN "-- Enable segmented stacks")
        add_definitions(-fsplit-stack)
        set(LIBCOPP_MACRO_USE_SEGMENTED_STACKS 1)
    endif()

	if (LIBCOPP_ENABLE_SEGMENTED_STACKS)
		EchoWithColor(COLOR GREEN "-- gcc ${CMAKE_CXX_COMPILER_VERSION} found in unix like system.")
		EchoWithColor(COLOR GREEN "-- stack allocator: enable segment allocator, add -fsplit-stack to all program use this library")
		list(APPEND COPP_SRC_LIST "${PROJECT_LIBCOPP_STACK_ALLOC_SRC_DIR}/stack_allocator_split_segment.cpp")
	endif()
endif()

if (LIBCOPP_MACRO_USE_VALGRIND OR LIBCOPP_ENABLE_VALGRIND)
    EchoWithColor(COLOR GREEN "-- enable valgrind support.")
	set(LIBCOPP_MACRO_USE_VALGRIND 1)
endif()
