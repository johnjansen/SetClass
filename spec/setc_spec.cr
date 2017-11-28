require "spec"
require "../src/setc"

describe "SetC" do
  describe "an empty setc" do
    it "is empty" do
      SetC(Nil).new.empty?.should be_true
    end

    it "has size 0" do
      SetC(Nil).new.size.should eq(0)
    end
  end

  describe "new" do
    it "creates new setc with enumerable without block" do
      setc_from_array = SetC.new([2, 4, 6, 4])
      setc_from_array.size.should eq(3)
      setc_from_array.to_a.sort.should eq([2, 4, 6])

      setc_from_tulpe = SetC.new({1, "hello", 'x'})
      setc_from_tulpe.size.should eq(3)
      setc_from_tulpe.to_a.includes?(1).should be_true
      setc_from_tulpe.to_a.includes?("hello").should be_true
      setc_from_tulpe.to_a.includes?('x').should be_true
    end
  end

  describe "add" do
    it "adds and includes" do
      setc = SetC(Int32).new
      setc.add 1
      setc.includes?(1).should be_true
      setc.size.should eq(1)
    end

    it "returns self" do
      setc = SetC(Int32).new
      setc.add(1).should eq(setc)
    end
  end

  describe "delete" do
    it "deletes an object" do
      setc = SetC{1, 2, 3}
      setc.delete 2
      setc.size.should eq(2)
      setc.includes?(1).should be_true
      setc.includes?(3).should be_true
    end

    it "returns self" do
      setc = SetC{1, 2, 3}
      setc.delete(2).should eq(setc)
    end
  end

  describe "dup" do
    it "creates a dup" do
      setc1 = SetC{[1, 2]}
      setc2 = setc1.dup

      setc1.should eq(setc2)
      setc1.should_not be(setc2)

      setc1.to_a.first.should be(setc2.to_a.first)

      setc1 << [3]
      setc2 << [4]

      setc2.should eq(SetC{[1, 2], [4]})
    end
  end

  describe "clone" do
    it "creates a clone" do
      setc1 = SetC{[1, 2]}
      setc2 = setc1.clone

      setc1.should eq(setc2)
      setc1.should_not be(setc2)

      setc1.to_a.first.should_not be(setc2.to_a.first)

      setc1 << [3]
      setc2 << [4]

      setc2.should eq(SetC{[1, 2], [4]})
    end
  end

  describe "==" do
    it "compares two setcs" do
      setc1 = SetC{1, 2, 3}
      setc2 = SetC{1, 2, 3}
      setc3 = SetC{1, 2, 3, 4}

      setc1.should eq(setc1)
      setc1.should eq(setc2)
      setc1.should_not eq(setc3)
    end
  end

  describe "concat" do
    it "adds all the other elements" do
      setc = SetC{1, 4, 8}
      setc.concat [1, 9, 10]
      setc.should eq(SetC{1, 4, 8, 9, 10})
    end

    it "returns self" do
      setc = SetC{1, 4, 8}
      setc.concat([1, 9, 10]).should eq(SetC{1, 4, 8, 9, 10})
    end
  end

  it "does &" do
    setc1 = SetC{1, 2, 3}
    setc2 = SetC{4, 2, 5, 3}
    setc3 = setc1 & setc2
    setc3.should eq(SetC{2, 3})
  end

  it "does |" do
    setc1 = SetC{1, 2, 3}
    setc2 = SetC{4, 2, 5, "3"}
    setc3 = setc1 | setc2
    setc3.should eq(SetC{1, 2, 3, 4, 5, "3"})
  end

  it "does -" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = SetC{2, 4, 6}
    setc3 = setc1 - setc2
    setc3.should eq(SetC{1, 3, 5})
  end

  it "does -" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = SetC{2, 4, 'a'}
    setc3 = setc1 - setc2
    setc3.should eq(SetC{1, 3, 5})
  end

  it "does -" do
    setc1 = SetC{1, 2, 3, 4, 'b'}
    setc2 = SetC{2, 4, 5}
    setc3 = setc1 - setc2
    setc3.should eq(SetC{1, 3, 'b'})
  end

  it "does -" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = [2, 4, 6]
    setc3 = setc1 - setc2
    setc3.should eq(SetC{1, 3, 5})
  end

  it "does -" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = [2, 4, 'a']
    setc3 = setc1 - setc2
    setc3.should eq(SetC{1, 3, 5})
  end

  it "does -" do
    setc1 = SetC{1, 2, 3, 4, 'b'}
    setc2 = [2, 4, 5]
    setc3 = setc1 - setc2
    setc3.should eq(SetC{1, 3, 'b'})
  end

  it "does ^" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = SetC{2, 4, 6}
    setc3 = setc1 ^ setc2
    setc3.should eq(SetC{1, 3, 5, 6})
  end

  it "does ^" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = SetC{2, 4, 'a'}
    setc3 = setc1 ^ setc2
    setc3.should eq(SetC{1, 3, 5, 'a'})
  end

  it "does ^" do
    setc1 = SetC{1, 2, 3, 4, 'b'}
    setc2 = SetC{2, 4, 5}
    setc3 = setc1 ^ setc2
    setc3.should eq(SetC{1, 3, 5, 'b'})
  end

  it "does ^" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = [2, 4, 6]
    setc3 = setc1 ^ setc2
    setc3.should eq(SetC{1, 3, 5, 6})
  end

  it "does ^" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = [2, 4, 'a']
    setc3 = setc1 ^ setc2
    setc3.should eq(SetC{1, 3, 5, 'a'})
  end

  it "does ^" do
    setc1 = SetC{1, 2, 3, 4, 'b'}
    setc2 = [2, 4, 5]
    setc3 = setc1 ^ setc2
    setc3.should eq(SetC{1, 3, 5, 'b'})
  end

  it "does subtract" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = SetC{2, 4, 6}
    setc1.subtract setc2
    setc1.should eq(SetC{1, 3, 5})
  end

  it "does subtract" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = SetC{2, 4, 'a'}
    setc1.subtract setc2
    setc1.should eq(SetC{1, 3, 5})
  end

  it "does subtract" do
    setc1 = SetC{1, 2, 3, 4, 'b'}
    setc2 = SetC{2, 4, 5}
    setc1.subtract setc2
    setc1.should eq(SetC{1, 3, 'b'})
  end

  it "does subtract" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = [2, 4, 6]
    setc1.subtract setc2
    setc1.should eq(SetC{1, 3, 5})
  end

  it "does subtract" do
    setc1 = SetC{1, 2, 3, 4, 5}
    setc2 = [2, 4, 'a']
    setc1.subtract setc2
    setc1.should eq(SetC{1, 3, 5})
  end

  it "does subtract" do
    setc1 = SetC{1, 2, 3, 4, 'b'}
    setc2 = [2, 4, 5]
    setc1.subtract setc2
    setc1.should eq(SetC{1, 3, 'b'})
  end

  it "does to_a" do
    SetC{1, 2, 3}.to_a.should eq([1, 2, 3])
  end

  it "does to_s" do
    SetC{1, 2, 3}.to_s.should eq("SetC{1, 2, 3}")
    SetC{"foo"}.to_s.should eq(%(SetC{"foo"}))
  end

  it "does clear" do
    x = SetC{1, 2, 3}
    x.to_a.should eq([1, 2, 3])
    x.clear.should be(x)
    x << 1
    x.to_a.should eq([1])
  end

  it "checks intersects" do
    setc = SetC{3, 4, 5}
    empty_setc = SetC(Int32).new

    setc.intersects?(setc).should be_true
    setc.intersects?(SetC{2, 4}).should be_true
    setc.intersects?(SetC{5, 6, 7}).should be_true
    setc.intersects?(SetC{1, 2, 6, 8, 4}).should be_true

    setc.intersects?(empty_setc).should be_false
    setc.intersects?(SetC{0, 2}).should be_false
    setc.intersects?(SetC{0, 2, 6}).should be_false
    setc.intersects?(SetC{0, 2, 6, 8, 10}).should be_false

    # Make sure setc hasn't changed
    setc.should eq(SetC{3, 4, 5})
  end

  it "compares hashes of setcs" do
    h1 = {SetC{1, 2, 3} => 1}
    h2 = {SetC{1, 2, 3} => 1}
    h1.should eq(h2)
  end

  it "does each" do
    setc = SetC{1, 2, 3}
    i = 1
    setc.each do |v|
      v.should eq(i)
      i += 1
    end.should be_nil
    i.should eq(4)
  end

  it "gets each iterator" do
    iter = SetC{1, 2, 3}.each
    iter.next.should eq(1)
    iter.next.should eq(2)
    iter.next.should eq(3)
    iter.next.should be_a(Iterator::Stop)

    iter.rewind
    iter.next.should eq(1)
  end

  it "check subset" do
    setc = SetC{1, 2, 3}
    empty_setc = SetC(Int32).new

    setc.subset?(SetC{1, 2, 3, 4}).should be_true
    setc.subset?(SetC{1, 2, 3, "4"}).should be_true
    setc.subset?(SetC{1, 2, 3}).should be_true
    setc.subset?(SetC{1, 2}).should be_false
    setc.subset?(empty_setc).should be_false

    empty_setc.subset?(SetC{1}).should be_true
    empty_setc.subset?(empty_setc).should be_true
  end

  it "check proper_subset" do
    setc = SetC{1, 2, 3}
    empty_setc = SetC(Int32).new

    setc.proper_subset?(SetC{1, 2, 3, 4}).should be_true
    setc.proper_subset?(SetC{1, 2, 3, "4"}).should be_true
    setc.proper_subset?(SetC{1, 2, 3}).should be_false
    setc.proper_subset?(SetC{1, 2}).should be_false
    setc.proper_subset?(empty_setc).should be_false

    empty_setc.proper_subset?(SetC{1}).should be_true
    empty_setc.proper_subset?(empty_setc).should be_false
  end

  it "check superset" do
    setc = SetC{1, 2, "3"}
    empty_setc = SetC(Int32).new

    setc.superset?(empty_setc).should be_true
    setc.superset?(SetC{1, 2}).should be_true
    setc.superset?(SetC{1, 2, "3"}).should be_true
    setc.superset?(SetC{1, 2, 3}).should be_false
    setc.superset?(SetC{1, 2, 3, 4}).should be_false
    setc.superset?(SetC{1, 4}).should be_false

    empty_setc.superset?(empty_setc).should be_true
  end

  it "check proper_superset" do
    setc = SetC{1, 2, "3"}
    empty_setc = SetC(Int32).new

    setc.proper_superset?(empty_setc).should be_true
    setc.proper_superset?(SetC{1, 2}).should be_true
    setc.proper_superset?(SetC{1, 2, "3"}).should be_false
    setc.proper_superset?(SetC{1, 2, 3}).should be_false
    setc.proper_superset?(SetC{1, 2, 3, 4}).should be_false
    setc.proper_superset?(SetC{1, 4}).should be_false

    empty_setc.proper_superset?(empty_setc).should be_false
  end

  it "has object_id" do
    SetC(Int32).new.object_id.should be > 0
  end

  typeof(SetC(Int32).new(initial_capacity: 1234))
end
