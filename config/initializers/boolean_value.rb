class BooleanValue
  # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/connection_adapters/column.rb#L8
  FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF']

  def self.from_string(value)
    Rails.present? ? with_rails(value) : without_rails(value)
  end

  private

    def self.with_rails(value)
      major, minor, patch = Rails.version.split('.').map(&:to_i)
      case major
      # Rails 5
      when 5
        ActiveRecord::Type::Boolean.new.cast(value)
      # Rails 4
      when 4
        # Rails < 4.2
        if minor < 2
          ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
        # Rails >= 4.2
        else
          ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
        end
      # Other
      else
        without_rails value
      end
    end

    # as defined in Rails 5:
    # everything, except empty string and FALSE_VALUES considered as TRUE
    def self.without_rails(value)
      value == '' ? nil : !FALSE_VALUES.include?(value)
    end
end