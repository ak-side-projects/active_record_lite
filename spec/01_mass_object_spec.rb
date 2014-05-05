require 'active_record_lite/01_mass_object'

describe MassObject do
  before(:all) do
    class EmptyMassObject < MassObject
    end

    class MyMassObject < MassObject
      my_attr_accessor :x, :y

    end
  end

  it "::attributes starts out empty" do
    expect(EmptyMassObject.attributes).to be_empty
  end

  it "::attriburtes cannot be called directly on MassObject" do
    expect {
      MassObject.attributes
    }.to raise_error("must not call #attributes on MassObject directly")
  end

  it "#initialize performs mass-assignment" do
    obj = MyMassObject.new(:x => "xxx", :y => "yyy")

    expect(obj.x).to eq("xxx")
    expect(obj.y).to eq("yyy")
  end

  it "#initialize doesn't mind string keys" do
    obj = MyMassObject.new("x" => "xxx", "y" => "yyy")

    expect(obj.x).to eq("xxx")
    expect(obj.y).to eq("yyy")
  end

end
