# SetC
[![Build Status](https://travis-ci.org/johnjansen/SetClass.svg?branch=master)](https://travis-ci.org/johnjansen/SetClass)

`Set` as a class NOT as a struct
enabling inheritance with a fixed type etc 

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  SetC:
    github: [johnjansen]/SetC
```

## Usage

```crystal
require "SetC"

class DictionaryOfWords < SetC(String)
  getter :max_word_size
  @max_word_size : Int32 = 0
  
  def add(other : String)
    @max_word_size = other.size if other.size > @max_word_size
    super
  end
end

d = DictionaryOfWords.new
d << "word"
d.max_word_size #=> 4
```

## Contributing

1. Fork it ( https://github.com/[johnjansen]/SetC/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[johnjansen]](https://github.com/[johnjansen]) John Jansen - creator, maintainer
