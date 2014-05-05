require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end
end

class SQLObject < MassObject
  def self.columns
    cols = DBConnection.execute2("SELECT * FROM #{self.table_name}")[0]

    cols.each do |col_name|
      define_method(col_name) do
        self.attributes[col_name]
      end

      define_method("#{col_name}=") do |value|
        self.attributes[col_name] = value
      end
    end

    cols.map(&:to_sym)
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    results = DBConnection.execute("SELECT * FROM #{self.table_name}")
    self.parse_all(results)
  end

  def self.find(id)
    result = DBConnection.execute("SELECT * FROM #{self.table_name} WHERE id = ?", id)[0]
    self.new(result)
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    col_names = @attributes.keys.join(", ")
    col_count = @attributes.keys.count
    question_marks = (["?"] * col_count).join(", ")
    values = @attributes.values
    DBConnection.execute(<<-SQL, values)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end

  def update
    column_set = @attributes.keys.map { |col| "#{col} = ?"}
    column_set = column_set[1..-1].join(", ")
    values = @attributes.values[1..-1]
    values << self.id
    results = DBConnection.execute(<<-SQL, values)
    UPDATE #{self.class.table_name}
    SET #{column_set}
    WHERE id = ?
    SQL
    p results
  end

  def attribute_values
    @attributes.values
  end
end
