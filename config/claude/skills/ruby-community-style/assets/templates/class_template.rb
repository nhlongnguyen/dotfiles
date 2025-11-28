# frozen_string_literal: true

# Standard Ruby class template following Community Style Guide
# and Sandi Metz rules (≤100 lines, ≤5 lines per method, ≤4 params)
#
# Usage: Copy and customize for new classes
class ClassName
  # 1. Extend and include statements
  include Comparable

  # 2. Constants
  DEFAULT_VALUE = "default"

  # 3. Attribute macros
  attr_reader :id, :name
  attr_accessor :status

  # 4. Class methods
  def self.find(id)
    # Implementation
  end

  # 5. Initialization (≤4 parameters, use keyword arguments)
  def initialize(id:, name:, status: :pending)
    @id = id
    @name = name
    @status = status
  end

  # 6. Public instance methods (≤5 lines each)
  def process
    return unless valid?

    perform_action
    update_status
  end

  def valid?
    name && !name.empty?
  end

  # 7. Comparable implementation (if included)
  def <=>(other)
    id <=> other.id
  end

  # 8. Protected methods (if any)
  protected

  def comparable_value
    @id
  end

  # 9. Private methods
  private

  def perform_action
    # Implementation
  end

  def update_status
    @status = :completed
  end
end