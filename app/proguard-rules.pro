# PakFit keeps health calculations and snapshot serialization explicit in Kotlin.
# Avoid broad keep rules so release builds benefit from R8 shrinking and obfuscation.

-keepattributes RuntimeVisibleAnnotations,RuntimeVisibleParameterAnnotations,AnnotationDefault
