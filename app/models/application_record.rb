class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # declare all record to implement soft deletion
  acts_as_paranoid column: :deleted_at

  include Supports::Cacheable

  scope :recent, -> { order("updated_at DESC") }
  scope :asc, -> { order("created_at ASC") }
  
end
