#!/bin/bash

TAG=1.80.0

libs=(
algorithm
any
array
asio
assert
beast
bimap
bind
concept_check
config
container_hash
core
date_time
detail
endian
exception
foreach
function
function_types
fusion
graph
integer
intrusive
iostreams
iterator
logic
math
move
mp11
mpl
multi_index
numeric/conversion
optional
phoenix
predef
preprocessor
property_map
property_tree
proto
range
regex
serialization
smart_ptr
spirit
static_assert
system
throw_exception
tti
tuple
type_erasure
type_index
type_traits
typeof
unordered
utility
variant
winapi
)

for lib in ${libs[@]}
do
    name="${lib/\//_}"
    fname="${name}.zip"
    echo ${fname}
    unzip ${fname} "${name}-boost-${TAG}/include/boost/*" -d boost
    cp -R boost/${base}-boost-${TAG}/include/boost/* boost/
    rm -rf boost/${base}-boost-${TAG}
done
