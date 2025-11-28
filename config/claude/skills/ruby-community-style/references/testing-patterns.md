# Ruby Testing Patterns

This file contains testing best practices for Ruby using RSpec and Minitest.

## Test-Driven Development (TDD)

### Red-Green-Refactor Cycle

```ruby
# 1. RED: Write a failing test first
# spec/models/user_spec.rb
RSpec.describe User do
  describe "#full_name" do
    it "returns first and last name combined" do
      user = User.new(first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq("John Doe")
    end
  end
end

# Run test - it fails (RED)

# 2. GREEN: Write minimal code to pass
# app/models/user.rb
class User
  attr_reader :first_name, :last_name

  def initialize(first_name:, last_name:)
    @first_name = first_name
    @last_name = last_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

# Run test - it passes (GREEN)

# 3. REFACTOR: Improve code while keeping tests green
# Clean up, extract methods, improve naming, etc.
```

## RSpec Patterns

### File Structure

```ruby
# spec/
#   spec_helper.rb
#   rails_helper.rb (Rails only)
#   models/
#     user_spec.rb
#   services/
#     payment_service_spec.rb
#   support/
#     shared_examples.rb
#     matchers/

# File naming: {class_name}_spec.rb
# Location mirrors app/ directory structure
```

### Basic Structure

```ruby
# ✅ GOOD: Well-organized spec file
RSpec.describe User do
  # Subject definition
  subject(:user) { described_class.new(attributes) }

  # Shared setup
  let(:attributes) { { name: "John", email: "john@example.com" } }

  # Describe blocks for methods
  describe "#full_name" do
    # Context blocks for different scenarios
    context "when user has first and last name" do
      let(:attributes) { { first_name: "John", last_name: "Doe" } }

      it "returns combined name" do
        expect(user.full_name).to eq("John Doe")
      end
    end

    context "when user has only first name" do
      let(:attributes) { { first_name: "John", last_name: nil } }

      it "returns first name only" do
        expect(user.full_name).to eq("John")
      end
    end
  end

  # Class methods use .method_name
  describe ".find_by_email" do
    it "returns user with matching email" do
      # ...
    end
  end
end
```

### Describe and Context

```ruby
# ✅ GOOD: describe for things, context for state
RSpec.describe Order do
  describe "#total" do
    context "with no items" do
      it "returns zero" do
        order = Order.new(items: [])
        expect(order.total).to eq(0)
      end
    end

    context "with multiple items" do
      it "returns sum of item prices" do
        items = [Item.new(price: 10), Item.new(price: 20)]
        order = Order.new(items: items)
        expect(order.total).to eq(30)
      end
    end

    context "with discount applied" do
      it "reduces total by discount amount" do
        # ...
      end
    end
  end
end

# ❌ BAD: context without "when" or "with"
context "no items" do  # Should be "when there are no items" or "with no items"
end
```

### Let vs Let! vs Before

```ruby
# let - lazy evaluation, memoized within example
let(:user) { User.create(name: "John") }  # Created only when called

# let! - eager evaluation, runs before each example
let!(:admin) { User.create(name: "Admin", role: :admin) }  # Created immediately

# before - for setup that doesn't return a value
before do
  DatabaseCleaner.clean
  Rails.cache.clear
end

# ✅ GOOD: Use let for objects you'll reference
let(:user) { build(:user) }
let(:order) { build(:order, user: user) }

# ✅ GOOD: Use let! when you need side effects
let!(:existing_user) { create(:user, email: "existing@example.com") }

it "returns error for duplicate email" do
  new_user = build(:user, email: "existing@example.com")
  expect(new_user).not_to be_valid
end

# ✅ GOOD: Use before for actions, not object creation
before { user.activate! }

# ❌ BAD: Creating objects in before
before do
  @user = User.create(name: "John")  # Use let instead
end
```

### Subject

```ruby
# ✅ GOOD: Named subject for clarity
RSpec.describe Calculator do
  subject(:calculator) { described_class.new }

  it "adds numbers" do
    expect(calculator.add(2, 3)).to eq(5)
  end
end

# ✅ GOOD: Implicit subject for simple cases
RSpec.describe User do
  subject { described_class.new(valid_attributes) }

  it { is_expected.to be_valid }
end

# ✅ GOOD: described_class instead of class name
subject { described_class.new }  # Refers to User automatically

# ❌ BAD: Hardcoding class name
subject { User.new }  # Breaks if class renamed
```

### One Expectation Per Test

```ruby
# ✅ GOOD: One expectation per test (when practical)
describe "#process" do
  it "marks order as processed" do
    order.process
    expect(order).to be_processed
  end

  it "sends confirmation email" do
    expect { order.process }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it "updates inventory" do
    expect { order.process }.to change { item.stock_count }.by(-1)
  end
end

# ✅ ACCEPTABLE: Related expectations in one test
it "creates user with correct attributes" do
  user = User.create(name: "John", email: "john@example.com")

  expect(user.name).to eq("John")
  expect(user.email).to eq("john@example.com")
  expect(user).to be_persisted
end
```

### Matchers

```ruby
# Equality
expect(result).to eq(expected)        # Value equality
expect(result).to eql(expected)       # Value + type equality
expect(result).to equal(expected)     # Identity (same object)
expect(result).to be(expected)        # Identity (same as equal)

# Truthiness
expect(result).to be true
expect(result).to be false
expect(result).to be_truthy
expect(result).to be_falsey
expect(result).to be_nil

# Comparisons
expect(result).to be > 5
expect(result).to be_between(1, 10)
expect(result).to be_within(0.1).of(3.14)

# Collections
expect(array).to include(item)
expect(array).to contain_exactly(1, 2, 3)  # Order doesn't matter
expect(array).to match_array([3, 2, 1])    # Same as contain_exactly
expect(array).to start_with(1)
expect(array).to end_with(3)
expect(array).to be_empty
expect(hash).to include(key: value)

# Strings
expect(string).to include("substring")
expect(string).to start_with("Hello")
expect(string).to end_with("world")
expect(string).to match(/pattern/)

# Types
expect(result).to be_a(User)
expect(result).to be_an(Array)
expect(result).to be_an_instance_of(User)

# Predicate matchers (calls method with ?)
expect(user).to be_valid       # calls user.valid?
expect(user).to be_admin       # calls user.admin?
expect(list).to be_empty       # calls list.empty?

# Change matchers
expect { action }.to change { value }.from(1).to(2)
expect { action }.to change { value }.by(1)
expect { action }.not_to change { value }

# Error matchers
expect { action }.to raise_error
expect { action }.to raise_error(CustomError)
expect { action }.to raise_error(CustomError, "message")
expect { action }.to raise_error(/pattern/)

# Throw matchers
expect { action }.to throw_symbol
expect { action }.to throw_symbol(:done)
```

### Shared Examples

```ruby
# spec/support/shared_examples.rb
RSpec.shared_examples "a timestamped model" do
  it "has created_at" do
    expect(subject).to respond_to(:created_at)
  end

  it "has updated_at" do
    expect(subject).to respond_to(:updated_at)
  end
end

RSpec.shared_examples "searchable" do |field|
  describe ".search" do
    it "finds records by #{field}" do
      record = create(described_class.name.underscore.to_sym, field => "searchable")
      expect(described_class.search("searchable")).to include(record)
    end
  end
end

# Usage
RSpec.describe User do
  it_behaves_like "a timestamped model"
  it_behaves_like "searchable", :name
end

RSpec.describe Post do
  it_behaves_like "a timestamped model"
  it_behaves_like "searchable", :title
end
```

### Mocking and Stubbing

```ruby
# Stubs - return predefined values
allow(user).to receive(:admin?).and_return(true)
allow(User).to receive(:find).with(1).and_return(mock_user)

# Mocks - verify calls were made
expect(mailer).to receive(:send_welcome_email).with(user)
expect(logger).to receive(:info).with(/processed/)

# Doubles
user_double = double("User", name: "John", admin?: true)
user_double = instance_double(User, name: "John")  # Verifying double

# Partial doubles (on real objects)
allow(user).to receive(:expensive_calculation).and_return(42)

# ✅ GOOD: Stub external services
before do
  allow(PaymentGateway).to receive(:charge).and_return(success_response)
end

# ✅ GOOD: Verify interactions
it "sends notification" do
  expect(NotificationService).to receive(:notify).with(user, message)
  order.complete
end

# ❌ BAD: Over-mocking
it "calculates total" do
  allow(order).to receive(:items).and_return([item1, item2])
  allow(item1).to receive(:price).and_return(10)
  allow(item2).to receive(:price).and_return(20)
  # This tests nothing - we're mocking what we should test!
end
```

### Test Organization Tips

```ruby
# ✅ GOOD: Arrange-Act-Assert pattern
it "updates user name" do
  # Arrange
  user = create(:user, name: "Old Name")

  # Act
  user.update(name: "New Name")

  # Assert
  expect(user.reload.name).to eq("New Name")
end

# ✅ GOOD: Descriptive test names
it "returns nil when user not found" do
  expect(User.find_by(id: -1)).to be_nil
end

# ❌ BAD: Vague test names
it "works correctly" do
  # ...
end

it "handles edge case" do
  # ...
end
```

## Minitest Patterns

### Basic Structure

```ruby
# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Setup runs before each test
  def setup
    @user = User.new(name: "John", email: "john@example.com")
  end

  # Teardown runs after each test
  def teardown
    # Clean up if needed
  end

  # Test methods start with test_
  def test_full_name_returns_combined_name
    @user.first_name = "John"
    @user.last_name = "Doe"
    assert_equal "John Doe", @user.full_name
  end

  # Or use the test macro (Rails)
  test "full name returns combined name" do
    @user.first_name = "John"
    @user.last_name = "Doe"
    assert_equal "John Doe", @user.full_name
  end
end
```

### Assertions

```ruby
# Basic assertions
assert expression                       # truthy
assert_not expression                   # falsey (Rails) / refute (Minitest)
refute expression                       # falsey

# Equality
assert_equal expected, actual
assert_not_equal unexpected, actual
assert_same expected, actual            # Same object
assert_nil object
assert_not_nil object

# Collections
assert_includes collection, item
assert_empty collection

# Strings
assert_match /pattern/, string

# Types
assert_instance_of User, object
assert_kind_of Enumerable, object
assert_respond_to object, :method_name

# Exceptions
assert_raises(CustomError) { risky_operation }
assert_raises(CustomError, "expected message") { risky_operation }

# Changes (Rails)
assert_difference "User.count", 1 do
  User.create(name: "John")
end

assert_no_difference "User.count" do
  User.new(name: "").save  # Invalid, won't save
end

# Emails (Rails)
assert_emails 1 do
  UserMailer.welcome(@user).deliver_now
end
```

### Test Organization

```ruby
# ✅ GOOD: Shopify style - separate sections with blank lines
class OrderTest < ActiveSupport::TestCase
  test "calculates total correctly" do
    order = orders(:basic)

    result = order.calculate_total

    assert_equal 100, result
  end
end

# ✅ GOOD: Use fixtures or factories
# test/fixtures/users.yml
# john:
#   name: John Doe
#   email: john@example.com

test "finds user by email" do
  user = users(:john)
  found = User.find_by_email("john@example.com")
  assert_equal user, found
end
```

## Factory Patterns

### FactoryBot (RSpec)

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "John Doe" }
    role { :member }

    trait :admin do
      role { :admin }
    end

    trait :with_posts do
      after(:create) do |user|
        create_list(:post, 3, user: user)
      end
    end

    factory :admin_user do
      admin
    end
  end
end

# Usage
user = create(:user)                    # Persisted
user = build(:user)                     # Not persisted
user = build_stubbed(:user)             # Stubbed (fast)
user = create(:user, :admin)            # With trait
user = create(:user, name: "Custom")    # Override attribute
users = create_list(:user, 5)           # Multiple records
```

### Fixtures (Minitest)

```ruby
# test/fixtures/users.yml
john:
  name: John Doe
  email: john@example.com
  role: member

admin:
  name: Admin User
  email: admin@example.com
  role: admin

# test/fixtures/posts.yml
johns_post:
  title: My Post
  user: john  # References john fixture

# Usage in tests
test "user has posts" do
  user = users(:john)
  post = posts(:johns_post)
  assert_includes user.posts, post
end
```

## Testing Anti-Patterns

### Testing Implementation, Not Behavior

```ruby
# ❌ BAD: Testing implementation details
it "calls the private method" do
  expect(service).to receive(:internal_helper).and_call_original
  service.process
end

# ✅ GOOD: Test observable behavior
it "returns processed result" do
  result = service.process(input)
  expect(result).to eq(expected_output)
end
```

### Over-Mocking

```ruby
# ❌ BAD: Mocking everything
it "processes order" do
  allow(order).to receive(:items).and_return(items)
  allow(order).to receive(:user).and_return(user)
  allow(order).to receive(:total).and_return(100)
  allow(PaymentService).to receive(:charge).and_return(true)

  # What are we even testing here?
  expect(order.process).to be true
end

# ✅ GOOD: Use real objects, mock only external services
it "processes order" do
  order = create(:order, :with_items)
  allow(PaymentGateway).to receive(:charge).and_return(success_response)

  expect(order.process).to be true
  expect(order).to be_completed
end
```

### Brittle Tests

```ruby
# ❌ BAD: Testing exact output format
it "displays user info" do
  expect(user.to_s).to eq("User: John Doe (john@example.com) - Member since 2024-01-15")
end

# ✅ GOOD: Test relevant parts
it "includes user name in string representation" do
  expect(user.to_s).to include("John Doe")
end

it "includes user email in string representation" do
  expect(user.to_s).to include("john@example.com")
end
```

### Test Interdependence

```ruby
# ❌ BAD: Tests depend on each other
describe User do
  it "creates user" do
    @user = User.create(name: "John")
    expect(@user).to be_persisted
  end

  it "updates user" do
    @user.update(name: "Jane")  # Depends on previous test!
    expect(@user.name).to eq("Jane")
  end
end

# ✅ GOOD: Each test is independent
describe User do
  let(:user) { create(:user, name: "John") }

  it "creates user" do
    new_user = User.create(name: "Jane")
    expect(new_user).to be_persisted
  end

  it "updates user" do
    user.update(name: "Jane")
    expect(user.name).to eq("Jane")
  end
end
```

## Performance Testing Tips

```ruby
# Avoid N+1 queries
it "loads users efficiently" do
  create_list(:user, 10, :with_posts)

  expect { User.includes(:posts).all.map(&:posts) }
    .to make_database_queries(count: 2)  # Using db-query-matchers gem
end

# Use build_stubbed for speed when persistence isn't needed
let(:user) { build_stubbed(:user) }

# Parallel tests (Rails 6+)
# config/environments/test.rb
config.active_support.test_parallelization_threshold = 50

# Database cleaner strategies
# - :transaction (fast, default for most cases)
# - :truncation (needed for tests with multiple connections)
# - :deletion (rarely needed)
```

## Coverage Guidelines

```ruby
# Aim for 80-90% coverage on critical paths
# Don't chase 100% - diminishing returns

# Focus on:
# - Public API methods
# - Business logic
# - Edge cases
# - Error conditions

# Less important:
# - Simple getters/setters
# - Framework-generated code
# - Private methods (tested through public interface)
```