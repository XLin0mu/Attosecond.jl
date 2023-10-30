export Picosecond, Femtosecond, Attosecond, HPTime

"""
    Picosecond
    Femtosecond
    Attosecond

Intervals of time less than a nanosecond.
Conversions between all `HPTimePeriod`s are permissible.
(eg `Picosecond(1) == Femtosecond(1e3) == Attosecond(1e6)`)
"""
abstract type HPTimePeriod <: Period end

for T in (:Picosecond, :Femtosecond, :Attosecond)
    @eval struct $T <: HPTimePeriod
        value::Int64
        $T(v::Number) = new(v)
    end
end

"""
Caution: The limit of HPTime is millisecond
"""
struct HPTime <: TimeType
    instant :: Attosecond
    HPTime(instant::Attosecond) = new(mod(instant, 1e12))
end

function validargs(::Type{HPTime}, p::Int64, f::Int64, a::Int64)
    -1 < p < 1000 || return ArgumentError("Picosecond: $p out of range (0:999)")
    -1 < f < 1000 || return ArgumentError("Femtosecond: $f out of range (0:999)")
    -1 < a < 1000 || return ArgumentError("Attosecond: $a out of range (0:999)")
    return nothing
end

function HPTime(p::Int64, f::Int64=0, a::Int64=0)
    err = validargs(HPTime, p, f, a)
    err === nothing || throw(err)
    return HPTime(Attosecond(1e6p + 1e3f + a))
end

for period in (:Picosecond, :Femtosecond, :Attosecond)
    period_str = string(period)
    accessor_str = lowercase(period_str)
    # Convenience method for show()
    @eval _units(x::$period) = " " * $accessor_str * (abs(value(x)) == 1 ? "" : "s")
    # AbstractString parsing (mainly for IO code)
    @eval $period(x::AbstractString) = $period(Base.parse(Int64, x))
    # The period type is printed when output, thus it already implies its own typeinfo
    @eval Base.typeinfo_implicit(::Type{$period}) = true
    # Period accessors
    typ_str = "HPTime"
    @eval begin
        @doc """
            $($period_str)(dt::$($typ_str)) -> $($period_str)

        The $($accessor_str) part of a $($typ_str) as a `$($period_str)`.
        """ $period(dt::$(Symbol(typ_str))) = $period($(Symbol(accessor_str))(dt))
    end
    @eval begin
        @doc """
            $($period_str)(v)

        Construct a `$($period_str)` object with the given `v` value. Input must be
        losslessly convertible to an [`Int64`](@ref).
        """ $period(v)
    end
end

#=
To DO List:
add 2 methods for HPTimePeriod like methods(millisecond).
apply transormation methods to HPTime types.
modify the performance of HPTime with limit as Millisecond.
=#
