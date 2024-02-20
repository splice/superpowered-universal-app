#ifndef Header_SuperpoweredCPU
#define Header_SuperpoweredCPU

namespace Superpowered {

/// @brief Utility class to keep the CPU running near the maximum frequency for all cores ("sustained performance mode"). Useful for pro audio applications to prevent audio dropouts, in both foreground and background states. Use this primarily on mobile devices.
/// Supports:
/// - all versions of iOS and Android,
/// - ARM and X86 CPUs,
/// - any number of CPU cores,
/// - CPUs with multiple different cores.
/// CPU monitors will report higher CPU usage if sustained performance mode is enabled. But the increased CPU usage is "fake", because this feature is achieved with NOP operations.
class CPU {
public:
/// @brief Enable/disable the sustained performance mode. This method is thread-safe.
/// @param enable Enable/disable the sustained performance mode.
    static void setSustainedPerformanceMode(bool enable);
/// @return Indicates if sustained performance mode is enabled or disabled.
    static bool getSustainedPerformanceMode();
};

}

#endif
