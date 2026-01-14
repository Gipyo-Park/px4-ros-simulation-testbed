# Install script for directory: /home/hmcl/PX4_testbed/octocopter_matlab/drone_metric_matlab/src/flight_data_collection_10hz_conver_to_c

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/hmcl/PX4_testbed/octocopter_matlab/drone_metric_matlab/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/hmcl/PX4_testbed/octocopter_matlab/drone_metric_matlab/build/flight_data_collection_10hz_conver_to_c/catkin_generated/installspace/flight_data_collection_10hz_conver_to_c.pc")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/flight_data_collection_10hz_conver_to_c/cmake" TYPE FILE FILES
    "/home/hmcl/PX4_testbed/octocopter_matlab/drone_metric_matlab/build/flight_data_collection_10hz_conver_to_c/catkin_generated/installspace/flight_data_collection_10hz_conver_to_cConfig.cmake"
    "/home/hmcl/PX4_testbed/octocopter_matlab/drone_metric_matlab/build/flight_data_collection_10hz_conver_to_c/catkin_generated/installspace/flight_data_collection_10hz_conver_to_cConfig-version.cmake"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/flight_data_collection_10hz_conver_to_c" TYPE FILE FILES "/home/hmcl/PX4_testbed/octocopter_matlab/drone_metric_matlab/src/flight_data_collection_10hz_conver_to_c/package.xml")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/flight_data_collection_10hz_conver_to_c" TYPE EXECUTABLE FILES "/home/hmcl/PX4_testbed/octocopter_matlab/drone_metric_matlab/devel/lib/flight_data_collection_10hz_conver_to_c/flight_data_collection_10hz_conver_to_c")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/flight_data_collection_10hz_conver_to_c/flight_data_collection_10hz_conver_to_c" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/flight_data_collection_10hz_conver_to_c/flight_data_collection_10hz_conver_to_c")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/flight_data_collection_10hz_conver_to_c/flight_data_collection_10hz_conver_to_c")
    endif()
  endif()
endif()

