class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # declare all record to implement soft deletion
  acts_as_paranoid column: :deleted_at

  include Supports::Cacheable
  
end
