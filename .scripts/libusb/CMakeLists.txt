#mkdir buildPi
#cd buildPi
#cmake -DCMAKE_TOOLCHAIN_FILE=/home/dev/oosman/pi/Toolchain-RaspberryPi.cmake ../
#make VERBOSE=1 -j8

cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

set(PROJ usb)
PROJECT(${PROJ})

set(CMAKE_C_FLAGS "-Wall -pthread")
set(CMAKE_C_FLAGS_DEBUG "-g -O0")
set(CMAKE_C_FLAGS_RELEASE "-O3")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -std=c++14 -lstdc++")
set(CMAKE_CXX_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG})
set(CMAKE_CXX_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})


include_directories(
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/libusb
	${CMAKE_SOURCE_DIR}/../systemd/src/libudev/
    )

FILE(GLOB SRC_FILES
	${CMAKE_SOURCE_DIR}/libusb/*.c
	${CMAKE_SOURCE_DIR}/libusb/os/linux*.c
	${CMAKE_SOURCE_DIR}/libusb/os/events_posix.c
	${CMAKE_SOURCE_DIR}/libusb/os/events_posix.h
	${CMAKE_SOURCE_DIR}/libusb/os/threads_posix.c
	${CMAKE_SOURCE_DIR}/libusb/os/threads_posix.h
    )
add_library(${PROJ} SHARED
    ${SRC_FILES}
  )

