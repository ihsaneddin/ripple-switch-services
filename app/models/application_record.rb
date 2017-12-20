class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # declare all record to implement soft deletion
  acts_as_paranoid column: :deleted_at

  include Supports::Cacheable, Supports::TableChangeNotification

  scope :recent, -> { order("updated_at DESC") }
  scope :asc, -> { order("created_at ASC") }
  scope :desc, -> { order("created_at DESC") }

  include PgSearch

  def newly_created?
    self.updated_at == self.created_at
  end
  
end
