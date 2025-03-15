#ifndef COMMON_DEFS_H
#define COMMON_DEFS_H

#include <cstdint>

#define FixedPoint int64_t
#define FixedPointShort int32_t

const float DEFAULT_MIX_RATE=48000.0;

const FixedPoint FP_ONE=0x1000000L;
const FixedPoint FP_NEARLY_TWO=0x1ffffffL;
const FixedPoint FP_HALF=FP_ONE>>1;
const FixedPoint FP_DEC_MASK=0xffffffL;
const FixedPoint FP_INT_SHIFT=24L;

#ifndef _ALWAYS_INLINE_
#if defined(__GNUC__) && (__GNUC__ >= 4)
#define _ALWAYS_INLINE_ __attribute__((always_inline)) inline
#elif defined(__llvm__)
#define _ALWAYS_INLINE_ __attribute__((always_inline)) inline
#elif defined(_MSC_VER)
#define _ALWAYS_INLINE_ __forceinline
#else
#define _ALWAYS_INLINE_ inline
#endif
#endif

template <typename T>
_ALWAYS_INLINE_ T const& clamp(T const &v,T const &min,T const &max){ 
	return v<min?min:v>max?max:v;
}

template <typename T>
_ALWAYS_INLINE_ T const& max(T const &v,T const &min){ 
	return v<min?min:v;
}

#endif