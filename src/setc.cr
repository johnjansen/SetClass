# `SetC` implements a collection of unordered values with no duplicates.
#
# An `Enumerable` object can be converted to `SetC` using the `#to_setc` method.
#
# `SetC` uses `Hash` as storage, so you must note the following points:
#
# * Equality of elements is determined according to `Object#==` and `Object#hash`.
# * `SetC` assumes that the identity of each element does not change while it is stored. Modifying an element of a setc will render the setc to an unreliable state.
#
# ### Example
#
# ```
# s1 = SetC{1, 2}
# s2 = [1, 2].to_setc
# s3 = SetC.new [1, 2]
# s1 == s2 # => true
# s1 == s3 # => true
# s1.add(2)
# s1.concat([6, 8])
# s1.subset? s2 # => false
# s2.subset? s1 # => true
# ```
class SetC(T)
  include Enumerable(T)
  include Iterable(T)

  # Creates a new, empty `SetC`.
  #
  # ```
  # s = SetC(Int32).new
  # s.empty? # => true
  # ```
  #
  # An initial capacity can be specified, and it will be setc as the initial capacity
  # of the internal `Hash`.
  def initialize(initial_capacity = nil)
    @hash = Hash(T, Nil).new(initial_capacity: initial_capacity)
  end

  # Optimized version of `new` used when *other* is also an `Indexable`
  def self.new(other : Indexable(T))
    SetC(T).new(other.size).concat(other)
  end

  # Creates a new setc from the elements in *enumerable*.
  #
  # ```
  # a = [1, 3, 5]
  # s = SetC.new a
  # s.empty? # => false
  # ```
  def self.new(enumerable : Enumerable(T))
    SetC(T).new.concat(enumerable)
  end

  # Alias for `add`
  def <<(object : T)
    add object
  end

  # Adds *object* to the setc and returns `self`.
  #
  # ```
  # s = SetC{1, 5}
  # s.includes? 8 # => false
  # s << 8
  # s.includes? 8 # => true
  # ```
  def add(object : T)
    @hash[object] = nil
    self
  end

  # Adds `#each` element of *elems* to the setc and returns `self`.
  #
  # ```
  # s = SetC{1, 5}
  # s.concat [5, 5, 8, 9]
  # s.size # => 4
  # ```
  #
  # See also: `#|` to merge two setcs and return a new one.
  def concat(elems)
    elems.each { |elem| self << elem }
    self
  end

  # Returns `true` if *object* exists in the setc.
  #
  # ```
  # s = SetC{1, 5}
  # s.includes? 5 # => true
  # s.includes? 9 # => false
  # ```
  def includes?(object)
    @hash.has_key?(object)
  end

  # Removes the *object* from the setc and returns `self`.
  #
  # ```
  # s = SetC{1, 5}
  # s.includes? 5 # => true
  # s.delete 5
  # s.includes? 5 # => false
  # ```
  def delete(object)
    @hash.delete(object)
    self
  end

  # Returns the number of elements in the setc.
  #
  # ```
  # s = SetC{1, 5}
  # s.size # => 2
  # ```
  def size
    @hash.size
  end

  # Removes all elements in the setc, and returns `self`.
  #
  # ```
  # s = SetC{1, 5}
  # s.size # => 2
  # s.clear
  # s.size # => 0
  # ```
  def clear
    @hash.clear
    self
  end

  # Returns `true` if the setc is empty.
  #
  # ```
  # s = SetC(Int32).new
  # s.empty? # => true
  # s << 3
  # s.empty? # => false
  # ```
  def empty?
    @hash.empty?
  end

  # Yields each element of the setc, and returns `self`.
  def each
    @hash.each_key do |key|
      yield key
    end
  end

  # Returns an iterator for each element of the setc.
  def each
    @hash.each_key
  end

  # Intersection: returns a new setc containing elements common to both setcs.
  #
  # ```
  # SetC{1, 1, 3, 5} & SetC{1, 2, 3}               # => SetC{1, 3}
  # SetC{'a', 'b', 'b', 'z'} & SetC{'a', 'b', 'c'} # => SetC{'a', 'b'}
  # ```
  def &(other : SetC)
    smallest, largest = self, other
    if largest.size < smallest.size
      smallest, largest = largest, smallest
    end

    setc = SetC(T).new
    smallest.each do |value|
      setc.add value if largest.includes?(value)
    end
    setc
  end

  # Union: returns a new setc containing all unique elements from both setcs.
  #
  # ```
  # SetC{1, 1, 3, 5} | SetC{1, 2, 3}               # => SetC{1, 3, 5, 2}
  # SetC{'a', 'b', 'b', 'z'} | SetC{'a', 'b', 'c'} # => SetC{'a', 'b', 'z', 'c'}
  # ```
  #
  # See also: `#concat` to add elements from a setc to `self`.
  def |(other : SetC(U)) forall U
    setc = SetC(T | U).new(Math.max(size, other.size))
    each { |value| setc.add value }
    other.each { |value| setc.add value }
    setc
  end

  # Difference: returns a new setc containing elements in this setc that are not
  # present in the other.
  #
  # ```
  # SetC{1, 2, 3, 4, 5} - SetC{2, 4}               # => SetC{1, 3, 5}
  # SetC{'a', 'b', 'b', 'z'} - SetC{'a', 'b', 'c'} # => SetC{'z'}
  # ```
  def -(other : SetC)
    setc = SetC(T).new
    each do |value|
      setc.add value unless other.includes?(value)
    end
    setc
  end

  # Difference: returns a new setc containing elements in this setc that are not
  # present in the other enumerable.
  #
  # ```
  # SetC{1, 2, 3, 4, 5} - [2, 4]               # => SetC{1, 3, 5}
  # SetC{'a', 'b', 'b', 'z'} - ['a', 'b', 'c'] # => SetC{'z'}
  # ```
  def -(other : Enumerable)
    dup.subtract other
  end

  # Symmetric Difference: returns a new setc `(self - other) | (other - self)`.
  # Equivalently, returns `(self | other) - (self & other)`.
  #
  # ```
  # SetC{1, 2, 3, 4, 5} ^ SetC{2, 4, 6}            # => SetC{1, 3, 5, 6}
  # SetC{'a', 'b', 'b', 'z'} ^ SetC{'a', 'b', 'c'} # => SetC{'z', 'c'}
  # ```
  def ^(other : SetC(U)) forall U
    setc = SetC(T | U).new
    each do |value|
      setc.add value unless other.includes?(value)
    end
    other.each do |value|
      setc.add value unless includes?(value)
    end
    setc
  end

  # Symmetric Difference: returns a new setc `(self - other) | (other - self)`.
  # Equivalently, returns `(self | other) - (self & other)`.
  #
  # ```
  # SetC{1, 2, 3, 4, 5} ^ [2, 4, 6]            # => SetC{1, 3, 5, 6}
  # SetC{'a', 'b', 'b', 'z'} ^ ['a', 'b', 'c'] # => SetC{'z', 'c'}
  # ```
  def ^(other : Enumerable(U)) forall U
    setc = SetC(T | U).new(self)
    other.each do |value|
      if includes?(value)
        setc.delete value
      else
        setc.add value
      end
    end
    setc
  end

  # Returns `self` after removing from it those elements that are present in
  # the given enumerable.
  #
  # ```
  # SetC{'a', 'b', 'b', 'z'}.subtract SetC{'a', 'b', 'c'} # => SetC{'z'}
  # SetC{1, 2, 3, 4, 5}.subtract [2, 4, 6]                # => SetC{1, 3, 5}
  # ```
  def subtract(other : Enumerable)
    other.each do |value|
      delete value
    end
    self
  end

  # Returns `true` if both setcs have the same elements.
  #
  # ```
  # SetC{1, 5} == SetC{1, 5} # => true
  # ```
  def ==(other : SetC)
    same?(other) || @hash == other.@hash
  end

  # Returns a new `SetC` with all of the same elements.
  def dup
    SetC.new(self)
  end

  # Returns a new `SetC` with all of the elements cloned.
  def clone
    clone = SetC(T).new(self.size)
    each do |element|
      clone << element.clone
    end
    clone
  end

  # Returns the elements as an `Array`.
  #
  # ```
  # SetC{1, 5}.to_a # => [1,5]
  # ```
  def to_a
    @hash.keys
  end

  # Alias of `#to_s`.
  def inspect(io)
    to_s(io)
  end

  def pretty_print(pp) : Nil
    pp.list("SetC{", self, "}")
  end

  def hash
    @hash.hash
  end

  # Returns `true` if the setc and the given setc have at least one element in
  # common.
  #
  # ```
  # SetC{1, 2, 3}.intersects? SetC{4, 5} # => false
  # SetC{1, 2, 3}.intersects? SetC{3, 4} # => true
  # ```
  def intersects?(other : SetC)
    if size < other.size
      any? { |o| other.includes?(o) }
    else
      other.any? { |o| includes?(o) }
    end
  end

  # Writes a string representation of the setc to *io*.
  def to_s(io)
    io << "SetC{"
    join ", ", io, &.inspect(io)
    io << "}"
  end

  # Returns `true` if the setc is a subset of the *other* setc.
  #
  # This setc must have the same or fewer elements than the *other* setc, and all
  # of elements in this setc must be present in the *other* setc.
  #
  # ```
  # SetC{1, 5}.subset? SetC{1, 3, 5}    # => true
  # SetC{1, 3, 5}.subset? SetC{1, 3, 5} # => true
  # ```
  def subset?(other : SetC)
    return false if other.size < size
    all? { |value| other.includes?(value) }
  end

  # Returns `true` if the setc is a proper subset of the *other* setc.
  #
  # This setc must have fewer elements than the *other* setc, and all
  # of elements in this setc must be present in the *other* setc.
  #
  # ```
  # SetC{1, 5}.proper_subset? SetC{1, 3, 5}    # => true
  # SetC{1, 3, 5}.proper_subset? SetC{1, 3, 5} # => false
  # ```
  def proper_subset?(other : SetC)
    return false if other.size <= size
    all? { |value| other.includes?(value) }
  end

  # Returns `true` if the setc is a superset of the *other* setc.
  #
  # The *other* must have the same or fewer elements than this setc, and all of
  # elements in the *other* setc must be present in this setc.
  #
  # ```
  # SetC{1, 3, 5}.superset? SetC{1, 5}    # => true
  # SetC{1, 3, 5}.superset? SetC{1, 3, 5} # => true
  # ```
  def superset?(other : SetC)
    other.subset?(self)
  end

  # Returns `true` if the setc is a superset of the *other* setc.
  #
  # The *other* must have the same or fewer elements than this setc, and all of
  # elements in the *other* setc must be present in this setc.
  #
  # ```
  # SetC{1, 3, 5}.proper_superset? SetC{1, 5}    # => true
  # SetC{1, 3, 5}.proper_superset? SetC{1, 3, 5} # => false
  # ```
  def proper_superset?(other : SetC)
    other.proper_subset?(self)
  end

  # :nodoc:
  def object_id
    @hash.object_id
  end

  # :nodoc:
  def same?(other : SetC)
    @hash.same?(other.@hash)
  end
end

module Enumerable
  # Returns a new `SetC` with each unique element in the enumerable.
  def to_setc
    SetC.new(self)
  end
end
