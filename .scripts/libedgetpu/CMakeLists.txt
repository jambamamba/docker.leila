#mkdir buildPi
#cd buildPi
#cmake -DCMAKE_TOOLCHAIN_FILE=/home/dev/oosman/pi/Toolchain-RaspberryPi.cmake ../
#make VERBOSE=1 -j8

cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

set(PROJ nugen)
PROJECT(${PROJ})

set(CMAKE_C_FLAGS "-Wall -pthread")
set(CMAKE_C_FLAGS_DEBUG "-g -O0")
set(CMAKE_C_FLAGS_RELEASE "-O3")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -std=c++14 -lstdc++") #c++17 does not work with absl
set(CMAKE_CXX_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG})
set(CMAKE_CXX_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})

set(CMAKE_SYSTEM_PROCESSOR "armv7a")
set(TENSORFLOW_DIR "${CMAKE_SOURCE_DIR}/../tensorflow")

add_definitions(-DDARWINN_PORT_USE_EXTERNAL=1)
include_directories(
    ${CMAKE_SOURCE_DIR}/
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/bazel-build
    ${TENSORFLOW_DIR}/
    ${TENSORFLOW_DIR}/tensorflow/
    ${TENSORFLOW_DIR}/tensorflow/lite/
    ${TENSORFLOW_DIR}/tensorflow/lite/tools/optimize/
    ${CMAKE_BINARY_DIR}/tensorflow/src/tf/
    ${CMAKE_BINARY_DIR}/tensorflow/src/tf/tensorflow/lite/tools/make/downloads/flatbuffers/include/
    ${CMAKE_SOURCE_DIR}/../eigen3/
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/
    ${CMAKE_SOURCE_DIR}/../flatbuffers/include/
    ${CMAKE_SOURCE_DIR}/googletest/googletest/include
    ${CMAKE_SOURCE_DIR}/googletest/googlemock/include
    ${CMAKE_BINARY_DIR}/glog_install/include
    )
link_directories(
    ${CMAKE_BINARY_DIR}
    ${TENSORFLOW_DIR}/tensorflow/lite/tools/make/gen/rpi_armv7l/lib
    ${CMAKE_SOURCE_DIR}/../libedgetpu/out/throttled/armv7a/
    ${CMAKE_SOURCE_DIR}/../libusb/buildpi
    /home/dev/oosman/pi/x-tools/arm-rpi-linux-gnueabihf/arm-rpi-linux-gnueabihf/sysroot/usr/lib/
    ${CMAKE_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/status
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/numeric
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/strings
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/container
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/synchronization
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/debugging
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/types
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/random
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/base
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/time
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/hash
    ${CMAKE_SOURCE_DIR}/../abseil-cpp/buildpi/absl/flags
    )
add_library(edgetpu
    ./api/allocated_buffer.cc
    ./api/layer_information.cc
    ./api/tensor_util.cc
    ./api/driver_factory.cc
    ./api/buffer.cc
    ./api/driver_options_helper.cc
    ./api/watchdog.cc
    ./driver_shared/time_stamper/driver_time_stamper.cc
    ./tflite/custom_op_user_data_direct.cc
    ./tflite/custom_op_data.cc
    ./tflite/edgetpu_manager_direct.cc
    ./tflite/edgetpu_c.cc
    ./tflite/edgetpu_delegate_for_custom_op.cc
    ./tflite/edgetpu_context_direct.cc
    ./tflite/custom_op_direct.cc
    ./tflite/edgetpu_context_factory.cc
    ./tflite/custom_op.cc
    ./tflite/edgetpu_delegate_for_custom_op_tflite_plugin.cc
    ./driver/mmio_driver.cc
    ./driver/memory/mmio_address_space.cc
    ./driver/memory/dual_address_space.cc
    ./driver/memory/buddy_allocator.cc
    ./driver/memory/mmu_mapper.cc
    ./driver/memory/buddy_address_space.cc
#    ./driver/memory/fake_dram_allocator.cc
#    ./driver/memory/fake_mmu_mapper.cc
    ./driver/memory/nop_address_space.cc
    ./driver/request.cc
    ./driver/instruction_buffers.cc
    ./driver/mmio/coherent_allocator.cc
    ./driver/device_buffer.cc
    ./driver/executable_util.cc
    ./driver/aligned_allocator.cc
    ./driver/registers/socket_registers.cc
    ./driver/registers/registers.cc
    ./driver/package_verifier.cc
    ./driver/beagle/beagle_top_level_handler.cc
    ./driver/beagle/beagle_pci_driver_provider.cc
    ./driver/beagle/beagle_pci_driver_provider_linux.cc
#    ./driver/beagle/beagle_pci_driver_provider_windows.cc
    ./driver/beagle/beagle_usb_driver_provider.cc
    ./driver/beagle/beagle_kernel_top_level_handler.cc
    ./driver/beagle/beagle_top_level_interrupt_manager.cc
    ./driver/kernel/kernel_interrupt_handler.cc
    ./driver/kernel/kernel_mmu_mapper.cc
    ./driver/kernel/kernel_coherent_allocator.cc
    ./driver/kernel/kernel_registers.cc
    ./driver/kernel/kernel_event_handler.cc
#    ./driver/kernel/windows/kernel_event_handler_windows.cc
#    ./driver/kernel/windows/kernel_registers_windows.cc
#    ./driver/kernel/windows/kernel_event_windows.cc
#    ./driver/kernel/windows/kernel_coherent_allocator_windows.cc
    ./driver/kernel/kernel_wire_interrupt_handler.cc
    ./driver/kernel/linux/kernel_registers_linux.cc
    ./driver/kernel/linux/kernel_event_linux.cc
    ./driver/kernel/linux/kernel_event_handler_linux.cc
    ./driver/kernel/linux/kernel_coherent_allocator_linux.cc
    ./driver/interrupt/interrupt_controller.cc
    ./driver/interrupt/top_level_interrupt_manager.cc
    ./driver/interrupt/wire_interrupt_handler.cc
    ./driver/interrupt/grouped_interrupt_controller.cc
    ./driver/dma_info.cc
    ./driver/driver_factory.cc
    ./driver/single_queue_dma_scheduler.cc
    ./driver/scalar_core_controller.cc
    ./driver/dma_info_extractor.cc
    ./driver/single_tpu_request.cc
    ./driver/device_buffer_mapper.cc
    ./driver/driver_factory_default.cc
    ./driver/run_controller.cc
    ./driver/driver.cc
##    ./driver/driver_helper.cc
    ./driver/dma_chunker.cc
    ./driver/package_registry.cc
    ./driver/usb/usb_io_request.cc
    ./driver/usb/libusb_options_default.cc
#    ./driver/usb/libusb_options_windows.cc
    ./driver/usb/local_usb_device.cc
    ./driver/usb/usb_dfu_commands.cc
    ./driver/usb/usb_standard_commands.cc
    ./driver/usb/usb_driver.cc
    ./driver/usb/usb_dfu_util.cc
    ./driver/usb/usb_registers.cc
    ./driver/usb/usb_ml_commands.cc
#    ./driver/driver_factory_darwin.cc
    ./driver/allocator.cc
    ./driver/real_time_dma_scheduler.cc
#    ./driver/driver_factory_windows.cc
#    ./port/fileio_windows.cc
#    ./port/timer_darwin.cc
#    ./port/timer_windows.cc
    ./port/posix_time.cc
    ./port/blocking_counter.cc
    ./port/shared_mutex.cc
    ./port/default/status_macros.cc
##    ./port/default/builddata.cc
    ./port/default/port_from_tf/status.cc
    ./port/default/port_from_tf/statusor.cc
    ./port/default/port_from_tf/logging.cc
    ./port/default/stringprintf.cc
    ./port/timer_linux.cc
    )
target_link_libraries(edgetpu
    tensorflow-lite
    )

add_library(model_utils
  src/model_utils.cc
  include/model_utils.h
)
target_link_libraries(model_utils
    tensorflow-lite
)
file(WRITE absl.cc "int abslPlaceholder() { return 0; }")
add_library(absl
    absl.cc
)
target_link_libraries(absl
    absl_status
    absl_statusor
    absl_str_format_internal
    absl_strings_internal
    absl_strings
    absl_int128
    absl_cord
    absl_raw_hash_set
    absl_hashtablez_sampler
    absl_synchronization
    absl_graphcycles_internal
    absl_leak_check
    absl_leak_check_disable
    absl_failure_signal_handler
    absl_debugging_internal
    absl_examine_stack
    absl_demangle_internal
    absl_symbolize
    absl_stacktrace
    absl_bad_any_cast_impl
    absl_bad_optional_access
    absl_bad_variant_access
    absl_random_internal_randen_slow
    absl_random_internal_randen_hwaes
    absl_random_internal_platform
    absl_random_internal_randen
    absl_random_internal_pool_urbg
    absl_random_internal_distribution_test_util
    absl_random_distributions
    absl_random_internal_randen_hwaes_impl
    absl_random_seed_sequences
    absl_random_seed_gen_exception
    absl_random_internal_seed_material
    absl_base
    absl_malloc_internal
    absl_periodic_sampler
    absl_scoped_set_env
    absl_throw_delegate
    absl_exponential_biased
    absl_raw_logging_internal
    absl_spinlock_wait
    absl_strerror
    absl_log_severity
    absl_time
    absl_civil_time
    absl_time_zone
    absl_hash
    absl_city
    absl_wyhash
    absl_flags_reflection
    absl_flags_program_name
    absl_flags_usage
    absl_flags
    absl_flags_config
    absl_flags_usage_internal
    absl_flags_marshalling
    absl_flags_private_handle_accessor
    absl_flags_internal
    absl_flags_parse
    absl_flags_commandlineflag
    absl_flags_commandlineflag_internal
    )

add_executable(minimal
  src/minimal.cc
#  ${CMAKE_BINARY_DIR}/tensorflow/src/tf/tensorflow/lite/tools/make/downloads/fft2d/fftsg.c
#  ${CMAKE_BINARY_DIR}/tensorflow/src/tf/tensorflow/lite/tools/optimize/sparsity/format_converter.cc
)


target_link_libraries(minimal
    dl
    edgetpu
    model_utils
    tensorflow-lite
    absl
)
