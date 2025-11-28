# frozen_string_literal: true

# RSpec test file template following Community Style Guide
#
# Structure:
# - describe blocks for classes/methods
# - context blocks for different scenarios
# - it blocks for individual expectations
# - One expectation per test (when practical)

require "rails_helper" # or "spec_helper" for non-Rails

RSpec.describe ClassName do
  # Subject definition - use named subject for clarity
  subject(:instance) { described_class.new(attributes) }

  # Shared setup with let (lazy evaluation)
  let(:attributes) { { name: "Test", status: :pending } }

  # Use let! for eager evaluation when side effects needed
  let!(:existing_record) { create(:record) }

  # describe for instance methods (#method_name)
  describe "#method_name" do
    # context for different scenarios (start with "when" or "with")
    context "when condition is true" do
      let(:attributes) { { name: "Test", condition: true } }

      it "returns expected result" do
        expect(instance.method_name).to eq(expected_result)
      end

      it "updates the status" do
        expect { instance.method_name }
          .to change(instance, :status)
          .from(:pending)
          .to(:completed)
      end
    end

    context "when condition is false" do
      let(:attributes) { { name: "Test", condition: false } }

      it "returns nil" do
        expect(instance.method_name).to be_nil
      end
    end

    context "with invalid input" do
      let(:attributes) { { name: nil } }

      it "raises an error" do
        expect { instance.method_name }
          .to raise_error(ArgumentError, /name cannot be blank/)
      end
    end
  end

  # describe for class methods (.method_name)
  describe ".class_method" do
    it "finds record by criteria" do
      result = described_class.class_method(criteria)
      expect(result).to eq(expected)
    end
  end

  # Shared examples for common behavior
  it_behaves_like "a timestamped model"

  # Edge cases
  describe "edge cases" do
    context "with empty collection" do
      let(:attributes) { { items: [] } }

      it "handles gracefully" do
        expect(instance.process).to eq([])
      end
    end

    context "with nil values" do
      let(:attributes) { { name: nil } }

      it "returns default" do
        expect(instance.display_name).to eq("Unknown")
      end
    end
  end
end

# Shared examples (typically in spec/support/shared_examples.rb)
RSpec.shared_examples "a timestamped model" do
  it { is_expected.to respond_to(:created_at) }
  it { is_expected.to respond_to(:updated_at) }
end