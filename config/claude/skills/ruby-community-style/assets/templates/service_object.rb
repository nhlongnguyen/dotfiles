# frozen_string_literal: true

# Service Object pattern template
# Use for complex business operations that don't belong in models
#
# Benefits:
# - Single Responsibility: One operation per service
# - Testable: Easy to test in isolation
# - Reusable: Can be called from controllers, jobs, or other services
#
# Usage:
#   result = ProcessOrder.call(order: order, user: user)
#   if result.success?
#     # handle success
#   else
#     # handle failure with result.error
#   end
class ServiceName
  # Result object for consistent return values
  Result = Struct.new(:success?, :value, :error, keyword_init: true) do
    def failure?
      !success?
    end
  end

  # Class method entry point
  def self.call(**args)
    new(**args).call
  end

  # Initialize with keyword arguments (≤4 parameters)
  def initialize(required_param:, optional_param: nil)
    @required_param = required_param
    @optional_param = optional_param
  end

  # Main entry point - returns Result
  def call
    return failure("Validation failed") unless valid?

    result = perform_operation
    success(result)
  rescue StandardError => e
    failure(e.message)
  end

  private

  attr_reader :required_param, :optional_param

  def valid?
    required_param.present?
  end

  def perform_operation
    # Main business logic here
    # Keep methods ≤5 lines, extract if needed
  end

  def success(value)
    Result.new(success?: true, value: value, error: nil)
  end

  def failure(error)
    Result.new(success?: false, value: nil, error: error)
  end
end