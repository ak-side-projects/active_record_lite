require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject

  def self.attributes
    raise Exception.new "must not call #attributes on MassObject directly" if self == MassObject
    @attributes ||= {}
  end

  def initialize(params = {})
    params.each do |col_name, col_value|
      self.send("#{col_name}=", col_value)
    end
  end

end
