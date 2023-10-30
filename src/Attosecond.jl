module Attosecond
using Dates

body = "bodys.jl"
include_string(Dates, "include(\"$body\")")
end # module Attosecond
