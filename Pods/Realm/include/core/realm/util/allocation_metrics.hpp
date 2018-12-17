/*************************************************************************
 *
 * REALM CONFIDENTIAL
 * __________________
 *
 *  [2011] - [2018] Realm Inc
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Realm Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Realm Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Realm Incorporated.
 *
 **************************************************************************/
#ifndef REALM_UTIL_ALLOCATION_METRICS_HPP
#define REALM_UTIL_ALLOCATION_METRICS_HPP

#include <atomic>

#include <realm/util/allocator.hpp>

namespace realm {
namespace util {

class AllocationMetric : public AllocatorBase {
public:
    /// Warning: Instances of AllocationMetric must be statically
    /// allocated. When an instance has been initialized, it must not be
    /// destroyed until the program terminates. This is to ensure that
    /// iterating over existing components is thread-safe and lock-free.
    explicit AllocationMetric(const char* name) noexcept;

    /// Return the name of this metric.
    ///
    /// This method is thread-safe.
    const char* name() const noexcept;

    /// Get the first component in the list of components. This method is
    /// thread-safe.
    static const AllocationMetric* get_top() noexcept;
    static const AllocationMetric* find(const char* name) noexcept;
    static const AllocationMetric* unknown() noexcept;

    /// Get the next component in the list. This method is thread-safe.
    const AllocationMetric* next() const noexcept;

    /// Return the currently allocated number of bytes.
    ///
    /// This method is thread-safe.
    std::size_t get_allocated_bytes() const noexcept;

    /// Return the total number of bytes that have been allocated (including
    /// allocations that have since been freed).
    ///
    /// This method is thread-safe.
    std::size_t get_total_allocated_bytes() const noexcept;

    /// Return the number of bytes that have been freed.
    ///
    /// This method is thread-safe, but may return slightly inaccurate results
    /// due if allocations are happening while this method is being called.
    std::size_t get_total_deallocated_bytes() const noexcept;

    // AllocatorBase interface:
    static AllocationMetric& get_default() noexcept; // Returns the component currently in scope.
    void* allocate(size_t size, size_t align) override final;
    void free(void* ptr, size_t size) noexcept override final;
private:
    const char* m_name;
    // This is used to iterate over all existing components. Instances of
    // AllocationMetric are expected to be statically allocated.
    const AllocationMetric* m_next = nullptr;

    // These members are aligned at 64 bytes to prevent false sharing
    // (inter-processor CPU locks when multiple processes are modifying them
    // concurrently).
    alignas(64) std::atomic<std::size_t> m_allocated_bytes;
    alignas(64) std::atomic<std::size_t> m_deallocated_bytes;

    void on_alloc(std::size_t) noexcept;
    void on_free(std::size_t) noexcept;
};


class AllocationMetricScope {
public:
    /// Establish a scope under which all allocations will be tracked as
    /// belonging to \a component (for statistical purposes).
    AllocationMetricScope(AllocationMetric& metric) noexcept;
    ~AllocationMetricScope();
    AllocationMetricScope(AllocationMetricScope&&) = delete;
    AllocationMetricScope& operator=(AllocationMetricScope&&) = delete;
private:
    AllocationMetric& m_component;
    AllocationMetric* m_previous = nullptr;
};


/// Convenience STL-compatible allocator that counts allocations as part of the
/// current AllocationMetricScope.
template <class T>
using MeteredAllocator = STLAllocator<T, AllocationMetric>;

// Implementation:

inline const char* AllocationMetric::name() const noexcept
{
    return m_name;
}

inline const AllocationMetric* AllocationMetric::next() const noexcept
{
    return m_next;
}

inline std::size_t AllocationMetric::get_allocated_bytes() const noexcept
{
    return get_total_allocated_bytes() - get_total_deallocated_bytes();
}

inline std::size_t AllocationMetric::get_total_allocated_bytes() const noexcept
{
    return m_allocated_bytes.load(std::memory_order_relaxed);
}

inline std::size_t AllocationMetric::get_total_deallocated_bytes() const noexcept
{
    return m_deallocated_bytes.load(std::memory_order_relaxed);
}

inline void* AllocationMetric::allocate(size_t size, size_t align)
{
    void* ptr = DefaultAllocator::get_default().allocate(size, align);
    on_alloc(size);
    return ptr;
}

inline void AllocationMetric::free(void* ptr, size_t size) noexcept
{
    DefaultAllocator::get_default().free(ptr, size);
    on_free(size);
}

inline void AllocationMetric::on_alloc(std::size_t size) noexcept
{
#if !REALM_MOBILE
    m_allocated_bytes.fetch_add(size, std::memory_order_relaxed);
#else
    static_cast<void>(size);
#endif
}

inline void AllocationMetric::on_free(std::size_t size) noexcept
{
#if !REALM_MOBILE
    m_deallocated_bytes.fetch_add(size, std::memory_order_relaxed);
#else
    static_cast<void>(size);
#endif
}
} // namespace util
} // namespace realm

#endif // REALM_UTIL_ALLOCATION_METRICS_HPP
