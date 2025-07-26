# Ruby Coding Principles

## Sandi Metz Rules for Developers

These are strict rules from Sandi Metz that help enforce good object-oriented design and maintainable code.

### Rule 1: Classes can be no longer than 100 lines of code
```ruby
# Good - Under 100 lines
class User
  attr_reader :name, :email, :active
  
  def initialize(name:, email:, active: true)
    @name = name
    @email = email
    @active = active
  end
  
  def active?
    @active
  end
  
  def activate!
    @active = true
  end
  
  def deactivate!
    @active = false
  end
end

# Avoid - Classes exceeding 100 lines
class MassiveUser
  # ... imagine 150+ lines of methods, validations, callbacks, etc.
  # This violates the 100-line rule and indicates the class has too many responsibilities
  # Split into User, UserValidator, UserMailer, UserAnalytics, etc.
end
```

### Rule 2: Methods can be no longer than 5 lines of code
- `if`, `else`, and `end` count as lines
- In an `if` block with two branches, each branch can only be one line

```ruby
# Good - 5 lines max
def process_user(user)
  return false unless user.valid?
  user.activate!
  send_notification(user)
  true
end

# Good - if/else with single line branches
def status_message(user)
  if user.active?
    "Active"
  else
    "Inactive"
  end
end

# Avoid - Too many lines
def complex_method(user)
  return false unless user.valid?
  user.activate!
  send_notification(user)
  log_activation(user)
  update_statistics(user)
  broadcast_event(user)
  true
end
```

### Rule 3: Pass no more than 4 parameters into a method
- Hash options count as parameters

```ruby
# Good - 4 parameters max
def create_user(name, email, role, active: true)
  User.new(name: name, email: email, role: role, active: active)
end

# Good - Use objects to group related parameters
UserData = Struct.new(:name, :email, :role, :active)

def create_user(user_data)
  User.new(
    name: user_data.name,
    email: user_data.email,
    role: user_data.role,
    active: user_data.active
  )
end

# Avoid - Too many parameters
def create_user(name, email, role, department, manager, active, created_at, permissions)
  # 8 parameters make this method difficult to use and understand
end
```

### Rule Zero: Exception Rule
**"You should break these rules only if you have a good reason or your pair lets you."**

```ruby
# Good - Documented exception
class LegacyDataProcessor
  # SANDI_METZ_EXCEPTION: Legacy system integration requires more than 100 lines
  # Approved by: @team_lead
  # Reason: Complex mapping logic for 20+ legacy fields cannot be reasonably split
  
  def process_legacy_data(data)
    # ... implementation exceeds 100 lines
  end
end

# Avoid - Undocumented rule violations
class MassiveProcessor
  # This class has 200+ lines with no explanation why
  # No approval or justification for breaking the rules
end
```

## Design Principles

### When to Use OOP vs Functional Programming in Ruby

#### Use Object-Oriented Programming When:

**Modeling Domain Entities**
```ruby
# Good - OOP for domain models
class User
  attr_reader :name, :email, :role
  
  def initialize(name:, email:, role: 'user')
    @name = name
    @email = email
    @role = role
  end
  
  def admin?
    role == 'admin'
  end
end

class Resource
  attr_reader :owner, :name
  
  def initialize(owner:, name:)
    @owner = owner
    @name = name
  end
end

user = User.new(name: "John", email: "john@example.com", role: "admin")
resource = Resource.new(owner: user, name: "Document")

# Avoid - Procedural approach for domain logic
def is_admin?(user_hash)
  user_hash[:role] == 'admin'
end

def can_access?(user_hash, resource_hash)
  is_admin?(user_hash) || resource_hash[:owner] == user_hash[:name]
end
```

**Managing State and Behavior Together**
```ruby
# Good - OOP for stateful objects
class ShoppingCart
  def initialize
    @items = []
  end
  
  def add_item(item)
    @items << item
    self
  end
  
  def total
    @items.sum(&:price)
  end
  
  def empty?
    @items.empty?
  end
end

Item = Struct.new(:name, :price)
cart = ShoppingCart.new
cart.add_item(Item.new("Book", 10)).add_item(Item.new("Pen", 2))
puts cart.total # 12

# Avoid - Functional approach for stateful operations
def add_item_to_cart(cart, item)
  cart + [item]  # Creates new array each time, inefficient for state
end

def cart_total(cart)
  cart.sum(&:price)
end
```

#### Use Functional Programming When:

**Data Transformations and Processing**
```ruby
# Good - FP for data processing
def calculate_user_stats(users)
  users
    .select(&:active?)
    .group_by(&:role)
    .transform_values { |role_users| 
      {
        count: role_users.count,
        avg_age: role_users.map(&:age).sum.to_f / role_users.count
      }
    }
end

users = [
  OpenStruct.new(name: "John", age: 30, role: "admin", active: true),
  OpenStruct.new(name: "Jane", age: 25, role: "user", active: true),
  OpenStruct.new(name: "Bob", age: 35, role: "user", active: false)
]

stats = calculate_user_stats(users)
# => {"admin"=>{:count=>1, :avg_age=>30.0}, "user"=>{:count=>1, :avg_age=>25.0}}

# Avoid - OOP for simple data transformations
class UserStatsCalculator
  def initialize(users)
    @users = users
  end
  
  def calculate
    # Unnecessary object creation for simple transformation
  end
end
```

**Pure Business Logic**
```ruby
# Good - FP for calculations
module PricingCalculator
  PROMO_CODES = { 'SAVE10' => 0.10, 'SAVE20' => 0.20 }.freeze
  
  def self.calculate_discount(order_total:, user_tier:, promo_code: nil)
    base_discount = tier_discount(user_tier)
    promo_discount = promo_code_discount(promo_code)
    total_discount = [base_discount + promo_discount, 0.5].min
    
    order_total * (1 - total_discount)
  end
  
  private
  
  def self.tier_discount(tier)
    case tier
    when 'premium' then 0.15
    when 'gold' then 0.10
    else 0.0
    end
  end
  
  def self.promo_code_discount(code)
    PROMO_CODES.fetch(code, 0.0)
  end
end

final_price = PricingCalculator.calculate_discount(
  order_total: 100,
  user_tier: 'premium',
  promo_code: 'SAVE10'
)
# => 75.0

# Avoid - Stateful object for pure calculations
class PricingCalculator
  def initialize(order_total, user_tier, promo_code)
    @order_total = order_total
    @user_tier = user_tier
    @promo_code = promo_code
  end
  
  def calculate
    # Unnecessary state for pure calculation
  end
end
```

#### Use Hybrid Approach When:

**Service Objects with Functional Core**
```ruby
# Good - OOP structure with FP core
class OrderProcessor
  def initialize(order)
    @order = order
  end
  
  def call
    result = process_order_data(@order)
    
    if result[:success]
      update_order(result[:data])
      notify_success
    else
      handle_error(result[:error])
    end
  end
  
  private
  
  def process_order_data(order)
    order
      .then { |data| validate_order(data) }
      .then { |data| calculate_totals(data) }
      .then { |data| apply_discounts(data) }
  end
  
  def validate_order(order)
    return { success: false, error: "Invalid order" } unless order[:valid]
    { success: true, data: order }
  end
end

# Avoid - Pure OOP without functional benefits
class OrderProcessor
  def call
    validate_order_state
    calculate_order_totals
    apply_order_discounts
    # Hard to test individual steps, tightly coupled
  end
end

# Avoid - Pure FP without OOP benefits
def process_order(order)
  # No clear entry point, no state management
end
```

### Class Design Principles

#### Single Responsibility Principle
```ruby
# Good - Single responsibility
class User
  attr_reader :name, :email
  
  def initialize(name:, email:)
    @name = name
    @email = email
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  private
  
  def first_name
    name.split.first
  end
  
  def last_name
    name.split.last || ""
  end
end

class UserMailer
  def self.send_welcome(user)
    puts "Sending welcome email to #{user.email}"
  end
end

# Usage
user = User.new(name: "John Doe", email: "john@example.com")
UserMailer.send_welcome(user)

# Avoid - Multiple responsibilities
class User
  attr_reader :name, :email
  
  def initialize(name:, email:)
    @name = name
    @email = email
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def send_welcome_email
    puts "Sending welcome email to #{@email}"
  end
  
  def log_activity(action)
    puts "User #{@name} performed #{action}"
  end
  
  def calculate_permissions
    # Permission logic mixed with user data
  end
end
```

#### Use Modules for Shared Behavior
```ruby
# Good - Modules for shared behavior
module Timestampable
  def touch_timestamp
    @updated_at = Time.current
  end
  
  def updated_at
    @updated_at
  end
end

class User
  include Timestampable
  
  def initialize(name:)
    @name = name
    touch_timestamp
  end
end

class Post
  include Timestampable
  
  def initialize(title:)
    @title = title
    touch_timestamp
  end
end

user = User.new(name: "John")
puts user.updated_at # Current time

# Avoid - Duplicated behavior
class User
  def initialize(name:)
    @name = name
    @updated_at = Time.current
  end
  
  def touch_timestamp
    @updated_at = Time.current
  end
end

class Post
  def initialize(title:)
    @title = title
    @updated_at = Time.current  # Duplicated logic
  end
  
  def touch_timestamp
    @updated_at = Time.current  # Duplicated logic
  end
end
```

### Method Design Principles

#### Use Keyword Arguments
```ruby
# Good - Clear parameter names
def create_user(name:, email:, active: true)
  { name: name, email: email, active: active }
end

user = create_user(name: "John", email: "john@example.com")

# Avoid - Unclear positional arguments
def create_user(name, email, active = true)
  { name: name, email: email, active: active }
end

user = create_user("John", "john@example.com", false) # What is false?
```

#### Return Early
```ruby
# Good - Early returns reduce nesting
def process_user(user)
  return "User is nil" unless user
  return "User is invalid" unless user[:valid]
  return "User is inactive" unless user[:active]
  
  "User processed successfully"
end

# Avoid - Nested conditions
def process_user(user)
  if user
    if user[:valid]
      if user[:active]
        "User processed successfully"
      else
        "User is inactive"
      end
    else
      "User is invalid"
    end
  else
    "User is nil"
  end
end
```

## Ruby Language Features

### Idiomatic Ruby

#### Use Ruby's Expressiveness
```ruby
users = [
  { name: "John", active: true },
  { name: "Jane", active: false },
  { name: "Bob", active: true }
]

names = ["john", "jane", "bob"]

# Good - Symbol to proc
active_users = users.select { |user| user[:active] }
capitalized_names = names.map(&:capitalize)

# Avoid - Verbose blocks when symbol-to-proc works
active_users = users.select { |user| user[:active] == true }
capitalized_names = names.map { |name| name.capitalize }
```

#### Use Safe Navigation
```ruby
user = { name: "John" }
address = { city: "New York" } if user[:name] == "John"

# Good - Safe navigation
city = user&.dig(:address, :city)

# Avoid - Manual nil checking
city = user && user[:address] && user[:address][:city]
```

#### Prefer Guard Clauses Over Nested Conditionals
```ruby
# Good - Guard clauses
def process_user(user)
  return unless user
  return unless user[:active]
  
  puts "Processing #{user[:name]}"
  user[:processed] = true
end

# Avoid - Nested conditions
def process_user(user)
  if user
    if user[:active]
      puts "Processing #{user[:name]}"
      user[:processed] = true
    end
  end
end
```

### Blocks, Procs, and Lambdas

#### Use Blocks for Iteration and Configuration
```ruby
# Good - Blocks for iteration
users = [{ name: "John", age: 30 }, { name: "Jane", age: 25 }]

users.each do |user|
  puts "#{user[:name]} is #{user[:age]} years old"
end

# Good - Blocks for configuration
def configure_user
  user = { name: nil, email: nil }
  yield(user) if block_given?
  user
end

user = configure_user do |u|
  u[:name] = "John"
  u[:email] = "john@example.com"
end

# Avoid - Not using blocks when appropriate
def configure_user(name, email)
  { name: name, email: email }  # Less flexible
end
```

#### Use Procs and Lambdas for Reusable Code Blocks
```ruby
# Good - Procs for reusable logic
adult_check = proc { |user| user[:age] >= 18 }
admin_check = proc { |user| user[:role] == 'admin' }

users = [
  { name: "John", age: 30, role: "admin" },
  { name: "Jane", age: 16, role: "user" }
]

adults = users.select(&adult_check)
admins = users.select(&admin_check)

# Avoid - Duplicated logic
adults = users.select { |user| user[:age] >= 18 }
admins = users.select { |user| user[:role] == 'admin' }
# If logic changes, you need to update multiple places
```

### Collections and Enumerables

#### Use Appropriate Enumerable Methods
```ruby
users = [
  { name: "John", role: "admin", active: true },
  { name: "Jane", role: "user", active: true },
  { name: "Bob", role: "user", active: false }
]

# Good - Expressive enumerable methods
has_admin = users.any? { |user| user[:role] == 'admin' }
all_active = users.all? { |user| user[:active] }
first_user = users.find { |user| user[:role] == 'user' }

# Avoid - Manual iteration
has_admin = false
users.each { |user| has_admin = true if user[:role] == 'admin' }

all_active = true
users.each { |user| all_active = false unless user[:active] }
```

#### Chain Methods Thoughtfully
```ruby
users = [
  { name: "John", email: "john@example.com", active: true },
  { name: "Jane", email: "jane@example.com", active: false },
  { name: "Bob", email: "bob@example.com", active: true }
]

# Good - Multi-line chaining for readability
active_emails = users
  .select { |user| user[:active] }
  .map { |user| user[:email] }
  .sort

# Avoid - Long single-line chains
active_emails = users.select { |user| user[:active] }.map { |user| user[:email] }.sort.uniq.compact
```

### String Handling

#### Use String Interpolation
```ruby
user = { name: "John", age: 30 }

# Good - String interpolation
greeting = "Hello, #{user[:name]}! You are #{user[:age]} years old."

# Avoid - String concatenation
greeting = "Hello, " + user[:name] + "! You are " + user[:age].to_s + " years old."
```

#### Use Heredocs for Multi-line Strings
```ruby
# Good - Heredoc for multi-line strings
def generate_user_report(user)
  <<~REPORT
    User Report
    ===========
    Name: #{user[:name]}
    Email: #{user[:email]}
    Status: #{user[:active] ? 'Active' : 'Inactive'}
    
    Generated at: #{Time.current}
  REPORT
end

# Avoid - Concatenated multi-line strings
def generate_user_report(user)
  "User Report\n" +
  "===========\n" +
  "Name: #{user[:name]}\n" +
  "Email: #{user[:email]}\n" +
  "Status: #{user[:active] ? 'Active' : 'Inactive'}\n"
end
```

### Regular Expressions

#### Use Regex for Pattern Matching
```ruby
# Good - Regex for pattern matching
def valid_email?(email)
  email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
end

def extract_numbers(text)
  text.scan(/\d+/)
end

# Avoid - Manual string parsing
def valid_email?(email)
  email.include?('@') && email.include?('.') && email.length > 5
end

def extract_numbers(text)
  result = []
  current_number = ""
  text.each_char do |char|
    if char.match?(/\d/)
      current_number += char
    else
      result << current_number unless current_number.empty?
      current_number = ""
    end
  end
  result << current_number unless current_number.empty?
  result
end
```

### Constants and Variables

#### Use Constants for Fixed Values
```ruby
# Good - Named constants
class UserService
  MAX_RETRY_ATTEMPTS = 3
  DEFAULT_TIMEOUT = 30
  VALID_ROLES = %w[admin user guest].freeze
  
  def process_with_retries(user)
    attempts = 0
    begin
      process_user(user)
    rescue StandardError => e
      attempts += 1
      retry if attempts < MAX_RETRY_ATTEMPTS
      raise e
    end
  end
  
  private
  
  def process_user(user)
    # Implementation
  end
end

# Avoid - Magic numbers and values
class UserService
  def process_with_retries(user)
    attempts = 0
    begin
      process_user(user)
    rescue StandardError => e
      attempts += 1
      retry if attempts < 3  # What is 3?
      raise e
    end
  end
end
```

#### Use Meaningful Variable Names
```ruby
users = [
  { name: "John", active: true },
  { name: "Jane", active: false }
]

# Good - Descriptive variable names
active_users = users.select { |user| user[:active] }
active_user_count = active_users.count
total_user_count = users.count

# Avoid - Cryptic abbreviations
au = users.select { |user| user[:active] }
c = au.count
t = users.count
```

#### Use Memoization for Expensive Operations
```ruby
class UserService
  # Good - Memoization with ||=
  def expensive_calculation
    @expensive_calculation ||= begin
      # Expensive operation here
      (1..1000).map { |i| i * i }.sum
    end
  end
  
  # Avoid - Recalculating every time
  def expensive_calculation
    (1..1000).map { |i| i * i }.sum  # Calculated every call
  end
end
```

## Implementation Guidelines

### Error Handling

#### Use Specific Exceptions
```ruby
# Good - Custom exception classes
class InvalidUserError < StandardError
  def initialize(message = "User validation failed")
    super(message)
  end
end

class UserNotFoundError < StandardError
  def initialize(user_id)
    super("User with ID #{user_id} not found")
  end
end

def find_user(user_id)
  users = [{ id: 1, name: "John", valid: true }]
  user = users.find { |u| u[:id] == user_id }
  raise UserNotFoundError, user_id unless user
  raise InvalidUserError unless user[:valid]
  user
end

# Avoid - Generic string errors
def find_user(user_id)
  users = [{ id: 1, name: "John", valid: true }]
  user = users.find { |u| u[:id] == user_id }
  raise "User not found" unless user
  raise "Invalid user" unless user[:valid]
  user
end
```

#### Use Proper Error Handling Structure
```ruby
# Good - Proper begin/rescue/ensure/end structure
def process_file(filename)
  file = nil
  begin
    file = File.open(filename, 'r')
    content = file.read
    process_content(content)
  rescue Errno::ENOENT => e
    puts "File not found: #{e.message}"
  rescue StandardError => e
    puts "Error processing file: #{e.message}"
  else
    puts "File processed successfully"
  ensure
    file&.close
  end
end

# Avoid - Catching all exceptions without specificity
def process_file(filename)
  begin
    file = File.open(filename, 'r')
    content = file.read
    process_content(content)
  rescue => e
    puts "Something went wrong: #{e.message}"
  end
  # File never gets closed
end

private

def process_content(content)
  # Implementation
end
```

#### Use raise vs fail Appropriately
```ruby
# Good - Use raise for exceptions, fail for assertions
def divide(a, b)
  fail ArgumentError, "Division by zero" if b == 0
  a / b
end

def authenticate_user(token)
  user = find_user_by_token(token)
  raise AuthenticationError, "Invalid token" unless user
  user
end

# Avoid - Inconsistent usage
def divide(a, b)
  raise ArgumentError, "Division by zero" if b == 0  # Should use fail
  a / b
end

def authenticate_user(token)
  user = find_user_by_token(token)
  fail AuthenticationError, "Invalid token" unless user  # Should use raise
  user
end

private

def find_user_by_token(token)
  # Implementation
end
```

### Testing Best Practices

#### Write Descriptive Tests
```ruby
# Good - Clear test descriptions
describe "User" do
  describe "#full_name" do
    it "returns first and last name separated by space" do
      user = { name: "John Doe" }
      expect(full_name(user)).to eq("John Doe")
    end
    
    it "handles single name gracefully" do
      user = { name: "John" }
      expect(full_name(user)).to eq("John")
    end
  end
end

# Avoid - Vague test descriptions
describe "User" do
  it "works" do
    user = { name: "John Doe" }
    expect(full_name(user)).to eq("John Doe")
  end
  
  it "does stuff" do
    user = { name: "John" }
    expect(full_name(user)).to eq("John")
  end
end

def full_name(user)
  parts = user[:name].split
  "#{parts.first} #{parts.last}".strip
end
```

#### Test Behavior, Not Implementation
```ruby
# Good - Test public behavior
def test_user_activation
  user = { name: "John", active: false }
  activate_user(user)
  assert user[:active]
end

# Avoid - Test internal implementation
def test_user_activation
  user = { name: "John", active: false }
  activate_user(user)
  assert_equal true, user.instance_variable_get(:@active)  # Testing internals
end

def activate_user(user)
  user[:active] = true
end
```

### Performance Considerations

#### Use Symbols for Hash Keys
```ruby
# Good - Symbols are more memory efficient
user_data = { 
  name: "John",
  email: "john@example.com",
  active: true
}

# Avoid - Strings create new objects each time
user_data = {
  "name" => "John",
  "email" => "john@example.com",
  "active" => true
}
```

#### Use freeze for Immutable Data
```ruby
# Good - Freeze constants and immutable data
VALID_ROLES = %w[admin user guest].freeze
DEFAULT_CONFIG = { timeout: 30, retries: 3 }.freeze

class UserService
  STATUSES = %w[active inactive pending].freeze
  
  def valid_status?(status)
    STATUSES.include?(status)
  end
end

# Avoid - Mutable constants
VALID_ROLES = %w[admin user guest]  # Can be modified
DEFAULT_CONFIG = { timeout: 30, retries: 3 }  # Can be modified
```

#### Use Efficient String Operations
```ruby
# Good - Use tr for single character replacement
def sanitize_filename(filename)
  filename.tr(' ', '_').tr('/', '-')
end

# Good - Use gsub for complex patterns
def remove_html_tags(text)
  text.gsub(/<[^>]*>/, '')
end

# Avoid - Using gsub for simple character replacement
def sanitize_filename(filename)
  filename.gsub(' ', '_').gsub('/', '-')  # Less efficient
end
```

### Metaprogramming Basics

#### Use define_method for Dynamic Methods
```ruby
# Good - Dynamic method creation
class User
  %w[name email role].each do |attribute|
    define_method("#{attribute}=") do |value|
      instance_variable_set("@#{attribute}", value)
    end
    
    define_method(attribute) do
      instance_variable_get("@#{attribute}")
    end
  end
end

user = User.new
user.name = "John"
puts user.name  # "John"

# Avoid - Repetitive method definitions
class User
  def name=(value)
    @name = value
  end
  
  def name
    @name
  end
  
  def email=(value)
    @email = value
  end
  
  def email
    @email
  end
  
  # ... repetitive for each attribute
end
```

#### Use tap for Debugging and Object Configuration
```ruby
# Good - Using tap for debugging
def process_data(data)
  data
    .map(&:upcase)
    .tap { |result| puts "After upcase: #{result}" }
    .select { |item| item.length > 3 }
    .tap { |result| puts "After filter: #{result}" }
end

# Good - Using tap for object configuration
def create_user
  User.new.tap do |user|
    user.name = "John"
    user.email = "john@example.com"
    user.active = true
  end
end

# Avoid - Breaking chain for debugging
def process_data(data)
  result = data.map(&:upcase)
  puts "After upcase: #{result}"
  result = result.select { |item| item.length > 3 }
  puts "After filter: #{result}"
  result
end
```

## Code Organization and Style

### Code Organization

#### Use Modules for Namespacing
```ruby
# Good - Organized into modules
module UserManagement
  class Creator
    def initialize(params)
      @params = params
    end
    
    def call
      { name: @params[:name], email: @params[:email] }
    end
  end
  
  class Updater
    def initialize(user, params)
      @user = user
      @params = params
    end
    
    def call
      @user.merge(@params)
    end
  end
end

# Usage
creator = UserManagement::Creator.new(name: "John", email: "john@example.com")
user = creator.call

# Avoid - Global namespace pollution
class UserCreator
  # Same implementation
end

class UserUpdater
  # Same implementation
end
```

#### Use require and require_relative Appropriately
```ruby
# Good - Use require for gems and standard library
require 'json'
require 'net/http'

# Good - Use require_relative for local files
require_relative 'user_service'
require_relative '../helpers/string_helper'

# Avoid - Using require for local files
require 'user_service'  # Depends on $LOAD_PATH
```

#### Group Related Methods
```ruby
# Good - Logical method grouping
class User
  attr_reader :name, :email, :active
  
  def initialize(name:, email:, active: true)
    @name = name
    @email = email
    @active = active
  end
  
  # Public interface
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def active?
    @active
  end
  
  def activate!
    @active = true
  end
  
  private
  
  # Private implementation
  def first_name
    name.split.first
  end
  
  def last_name
    name.split.last || ""
  end
end

# Avoid - Random method ordering
class User
  def activate!
    @active = true
  end
  
  def initialize(name:, email:, active: true)
    @name = name
    @email = email
    @active = active
  end
  
  private
  
  def first_name
    name.split.first
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def last_name
    name.split.last || ""
  end
  
  def active?
    @active
  end
end
```

### Ruby Style Guidelines

#### Formatting
```ruby
# Good - Proper formatting
users = [
  {
    name: "John",
    email: "john@example.com",
    active: true,
  },
  {
    name: "Jane",
    email: "jane@example.com",
    active: false,
  },
]

result = calculate_total(
  base_price: 100,
  tax_rate: 0.08,
  discount: 0.10
)

# Avoid - Inconsistent formatting
users = [ {name: "John",email: "john@example.com",active: true},{name: "Jane",email: "jane@example.com",active: false} ]

result = calculate_total(base_price: 100,tax_rate: 0.08,discount: 0.10)

def calculate_total(base_price:, tax_rate:, discount:)
  base_price * (1 + tax_rate) * (1 - discount)
end
```

#### File Organization
```ruby
# Good - File: lib/user_management/creator.rb
module UserManagement
  class Creator
    def initialize(params)
      @params = params
    end
    
    def call
      @params
    end
  end
end

# Good - File: app/models/user.rb
class User
  attr_reader :name, :email
  
  def initialize(name:, email:)
    @name = name
    @email = email
  end
end

# Avoid - Multiple classes in one file
# File: user_stuff.rb
class User
  # Implementation
end

class UserCreator
  # Implementation
end

class UserMailer
  # Implementation
end
```

## Tools and Anti-Patterns

### Ruby Anti-Patterns to Avoid

#### Don't Use for Loops
```ruby
users = [{ name: "John" }, { name: "Jane" }]

# Good - Use each
users.each { |user| puts user[:name] }

# Avoid - for loops are not idiomatic Ruby
for user in users
  puts user[:name]
end
```

#### Don't Use and/or for Logic
```ruby
user = { name: "John", active: true, valid: true }

# Good - Use && and || for logic
if user[:valid] && user[:active]
  puts "Processing user"
end

success = save_user(user) && send_notification(user)

# Avoid - and/or have different precedence
if user[:valid] and user[:active]
  puts "Processing user"
end

success = save_user(user) and send_notification(user)

def save_user(user)
  true  # Simulate save
end

def send_notification(user)
  puts "Notification sent to #{user[:name]}"
end
```

#### Don't Modify Frozen Objects
```ruby
original_array = [1, 2, 3].freeze
new_item = 4

# Good - Create new objects
new_array = original_array.dup
new_array << new_item

# Avoid - Modifying frozen objects raises errors
# original_array << new_item  # Would raise FrozenError
```

#### Don't Use Global Variables
```ruby
# Good - Use constants or dependency injection
class UserService
  DEFAULT_TIMEOUT = 30
  
  def initialize(timeout: DEFAULT_TIMEOUT)
    @timeout = timeout
  end
  
  def process_user(user)
    # Use @timeout
  end
end

# Avoid - Global variables
$timeout = 30  # Global variable

class UserService
  def process_user(user)
    # Use $timeout - hard to test and maintain
  end
end
```

### Tools and Linting

#### Essential Gems
```ruby
# Gemfile
group :development do
  gem 'rubocop', '~> 1.0'      # Code style and quality
  gem 'reek', '~> 6.0'         # Code smell detection
  gem 'brakeman', '~> 5.0'     # Security scanner
end

group :test do
  gem 'simplecov', '~> 0.21'   # Code coverage
  gem 'rspec', '~> 3.0'        # Testing framework
end
```

#### Configuration
```ruby
# .rubocop.yml
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.2
  Exclude:
    - 'vendor/**/*'
    - 'db/schema.rb'

Style/Documentation:
  Enabled: false

Metrics/LineLength:
  Max: 100

Layout/LineLength:
  Max: 100

Metrics/MethodLength:
  Max: 5  # Following Sandi Metz rules

Metrics/ClassLength:
  Max: 100  # Following Sandi Metz rules

Metrics/ParameterLists:
  Max: 4  # Following Sandi Metz rules
```

## Remember

> "Ruby is designed to make programmers happy." - Yukihiro Matsumoto

Focus on writing expressive, readable code that leverages Ruby's strengths while avoiding common pitfalls. The goal is code that feels natural to Ruby developers and maintains the language's philosophy of developer happiness.

### Key Takeaways

1. **Follow Sandi Metz rules** as hard constraints for maintainable code
2. **Choose the right paradigm** - OOP for entities, FP for transformations, hybrid for services
3. **Be idiomatic** - use Ruby's expressiveness and built-in methods
4. **Handle errors properly** - use specific exceptions and proper rescue structure
5. **Write tests** that focus on behavior, not implementation
6. **Optimize thoughtfully** - use symbols, freeze data, memoize expensive operations
7. **Organize code** - use modules, proper file structure, and logical grouping
8. **Use tools** - linters, code analyzers, and formatters to maintain quality