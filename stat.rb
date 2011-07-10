require 'mongoid'

class Stat
  include Mongoid::Document

  field :name
  field :total_calls, :type => Integer
end

