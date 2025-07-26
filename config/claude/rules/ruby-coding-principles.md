# Ruby Coding Principles

## Sandi Metz Rules for Developers

### Rule 1: Classes can be no longer than 100 lines of code
```ruby
# Good - Under 100 lines, single responsibility
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
end

# Avoid - Classes exceeding 100 lines (split into User, UserValidator, UserMailer, etc.)
```

### Rule 2: Methods can be no longer than 5 lines of code
`if`, `else`, and `end` count as lines

```ruby
# Good - 5 lines max
def process_user(user)
  return false unless user.valid?
  user.activate!
  send_notification(user)
  true
end

# Avoid - Methods exceeding 5 lines
```

### Rule 3: Pass no more than 4 parameters into a method
```ruby
# Good - 4 parameters max
def create_user(name, email, role, active: true)
  User.new(name: name, email: email, role: role, active: active)
end

# Good - Use objects for related parameters
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
```

### Rule Zero: Exception Rule
**"Break these rules only if you have a good reason or your pair lets you."**

Document exceptions clearly with approval and reasoning.

## Design Principles

### When to Use OOP vs Functional Programming

**Use OOP for:**
- Domain entities with state and behavior
- Stateful objects (e.g., shopping carts)
- Complex object relationships

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
```

**Use FP for:**
- Data transformations and calculations
- Pure business logic
- Stateless operations

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
```

**Use Hybrid for:**
- Service objects with functional pipeline
- Complex business workflows

```ruby
# Good - Service object with functional core
class OrderProcessor
  def initialize(order)
    @order = order
  end
  
  def call
    result = process_order_data(@order)
    handle_result(result)
  end
  
  private
  
  def process_order_data(order)
    order
      .then { |data| validate_order(data) }
      .then { |data| calculate_totals(data) }
      .then { |data| apply_discounts(data) }
  end
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

# Avoid - Multiple responsibilities (mixing user data with email, logging, permissions)
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

# Avoid - Duplicated behavior across classes
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
```

## Ruby Language Features

### Key Ruby Idioms

#### Use Ruby's Expressiveness
```ruby
users = [
  { name: "John", active: true },
  { name: "Jane", active: false },
  { name: "Bob", active: true }
]

# Good - Symbol to proc and expressive methods
active_users = users.select { |user| user[:active] }
capitalized_names = names.map(&:capitalize)

# Good - Safe navigation
city = user&.dig(:address, :city)

# Good - Guard clauses
def process_user(user)
  return unless user
  return unless user[:active]
  
  puts "Processing #{user[:name]}"
  user[:processed] = true
end
```

#### Use Blocks and Enumerables
```ruby
# Good - Blocks for iteration and configuration
users.each do |user|
  puts "#{user[:name]} is #{user[:age]} years old"
end

# Good - Expressive enumerable methods
has_admin = users.any? { |user| user[:role] == 'admin' }
all_active = users.all? { |user| user[:active] }
first_user = users.find { |user| user[:role] == 'user' }

# Good - Thoughtful method chaining
active_emails = users
  .select { |user| user[:active] }
  .map { |user| user[:email] }
  .sort
```

#### String Handling
```ruby
user = { name: "John", age: 30 }

# Good - String interpolation
greeting = "Hello, #{user[:name]}! You are #{user[:age]} years old."

# Good - Heredocs for multi-line strings
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
```

#### Constants and Variables
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
end

# Good - Meaningful variable names
active_users = users.select { |user| user[:active] }
active_user_count = active_users.count

# Good - Memoization for expensive operations
def expensive_calculation
  @expensive_calculation ||= begin
    (1..1000).map { |i| i * i }.sum
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
```

### Performance Considerations

```ruby
# Good - Use symbols for hash keys (more memory efficient)
user_data = { 
  name: "John",
  email: "john@example.com",
  active: true
}

# Good - Freeze constants and immutable data
VALID_ROLES = %w[admin user guest].freeze
DEFAULT_CONFIG = { timeout: 30, retries: 3 }.freeze

# Good - Use tr for single character replacement
def sanitize_filename(filename)
  filename.tr(' ', '_').tr('/', '-')
end

# Good - Use gsub for complex patterns
def remove_html_tags(text)
  text.gsub(/<[^>]*>/, '')
end

# Avoid - Strings, mutable constants, gsub for simple replacements
```

### Metaprogramming Basics

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

# Good - Using tap for debugging and object configuration
def process_data(data)
  data
    .map(&:upcase)
    .tap { |result| puts "After upcase: #{result}" }
    .select { |item| item.length > 3 }
    .tap { |result| puts "After filter: #{result}" }
end

def create_user
  User.new.tap do |user|
    user.name = "John"
    user.email = "john@example.com"
    user.active = true
  end
end

# Avoid - Repetitive method definitions, breaking chains
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
```

### Ruby Style Guidelines

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

# Good - File organization
# lib/user_management/creator.rb
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

# Avoid - Inconsistent formatting, multiple classes per file
```

## Tools and Anti-Patterns

### Ruby Anti-Patterns to Avoid

```ruby
# Good - Use each (not for loops)
users.each { |user| puts user[:name] }

# Good - Use && and || for logic (not and/or)
if user[:valid] && user[:active]
  puts "Processing user"
end

# Good - Create new objects (don't modify frozen objects)
new_array = original_array.dup
new_array << new_item

# Good - Use constants or dependency injection (not global variables)
class UserService
  DEFAULT_TIMEOUT = 30
  
  def initialize(timeout: DEFAULT_TIMEOUT)
    @timeout = timeout
  end
end

# Avoid - for loops, and/or, modifying frozen objects, global variables
```

### Essential Tools

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

## Key Takeaways

1. **Follow Sandi Metz rules** as hard constraints
2. **Choose the right paradigm** - OOP for entities, FP for transformations, hybrid for services
3. **Be idiomatic** - use Ruby's expressiveness and built-in methods
4. **Handle errors properly** - use specific exceptions and proper rescue structure
5. **Write tests** that focus on behavior, not implementation
6. **Optimize thoughtfully** - use symbols, freeze data, memoize expensive operations
7. **Organize code** - use modules, proper file structure, and logical grouping
8. **Use tools** - linters, code analyzers, and formatters to maintain quality

> "Ruby is designed to make programmers happy." - Yukihiro Matsumoto