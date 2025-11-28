# Ruby Community Style Guide Patterns

This file contains comprehensive patterns and anti-patterns from the RuboCop Community Ruby Style Guide.

## Source Code Layout

### Encoding and Line Endings

```ruby
# Always use UTF-8 encoding (default in Ruby 2.0+)
# No encoding declaration needed for UTF-8

# Use Unix-style line endings (LF, not CRLF)
# Configure your editor appropriately
```

### Indentation

```ruby
# ✅ GOOD: Use 2 spaces for indentation (no tabs)
def process_user
  if valid?
    perform_action
  end
end

# ❌ BAD: Using tabs or 4 spaces
def process_user
    if valid?
        perform_action
    end
end
```

### Line Length

```ruby
# ✅ GOOD: Keep lines under 80-120 characters (80 preferred)
user = User.find_by(email: email)

# ✅ GOOD: Break long lines sensibly
def send_notification(user:, message:, options: {})
  NotificationService.new(user)
                     .with_message(message)
                     .with_options(options)
                     .deliver
end

# ✅ GOOD: Multi-line method chains
User.active
    .where(role: :admin)
    .order(created_at: :desc)
    .limit(10)
```

### Blank Lines

```ruby
# ✅ GOOD: Separate method definitions with blank lines
def method_one
  # ...
end

def method_two
  # ...
end

# ✅ GOOD: Use blank lines to separate logical sections
def process_order
  validate_items
  calculate_total

  apply_discounts
  apply_taxes

  create_invoice
  send_confirmation
end

# ❌ BAD: No blank lines between methods
def method_one
end
def method_two
end
```

### Spaces Around Operators

```ruby
# ✅ GOOD: Spaces around operators
sum = 1 + 2
name = "John"
result = a && b || c

# ✅ GOOD: Spaces after commas, colons, semicolons
[1, 2, 3]
{ key: value }

# ❌ BAD: No spaces
sum=1+2
[1,2,3]

# ✅ GOOD: No space after !, inside [], (), {}
!valid?
array[index]
method(arg)
{ key: value }

# ❌ BAD: Spaces in wrong places
! valid?
array[ index ]
method( arg )
```

### Exponent Operator Exception

```ruby
# ✅ GOOD: No space around ** (exponent)
result = 2**10

# ❌ BAD: Space around exponent
result = 2 ** 10
```

## Naming Conventions

### Methods and Variables

```ruby
# ✅ GOOD: snake_case for methods and variables
def calculate_total
  item_count = 0
  total_price = 0.0
end

# ❌ BAD: camelCase or other styles
def calculateTotal
  itemCount = 0
end
```

### Classes and Modules

```ruby
# ✅ GOOD: CamelCase for classes and modules
class UserAccount
end

module PaymentProcessor
end

# ❌ BAD: snake_case or other styles
class user_account
end
```

### Constants

```ruby
# ✅ GOOD: SCREAMING_SNAKE_CASE for constants
MAX_ITEMS = 100
DEFAULT_TIMEOUT = 30
API_BASE_URL = "https://api.example.com"

# ❌ BAD: Other styles for constants
MaxItems = 100
defaultTimeout = 30
```

### Predicate Methods

```ruby
# ✅ GOOD: End predicates with ?
def empty?
  items.count.zero?
end

def valid?
  errors.empty?
end

def admin?
  role == :admin
end

# ❌ BAD: Using is_, has_, can_ prefixes
def is_empty
  items.count.zero?
end

def has_items
  items.any?
end
```

### Dangerous Methods

```ruby
# ✅ GOOD: End dangerous methods with ! when safe version exists
class Array
  def compact   # Returns new array, original unchanged
    # ...
  end

  def compact!  # Modifies array in place
    # ...
  end
end

# ✅ GOOD: Only use ! when there's a non-! counterpart
# If there's no safe version, don't use !
def save!     # Good: save exists
end

def validate  # Good: no validate!, so no ! needed
end
```

### File Names

```ruby
# ✅ GOOD: snake_case for file names matching class names
# user_account.rb contains:
class UserAccount
end

# payment_processor.rb contains:
module PaymentProcessor
end
```

## Method Definitions

### Parentheses

```ruby
# ✅ GOOD: Use parentheses when method has parameters
def greet(name)
  puts "Hello, #{name}"
end

# ✅ GOOD: Omit parentheses when no parameters
def greet
  puts "Hello"
end

# ❌ BAD: Parentheses with no parameters
def greet()
  puts "Hello"
end
```

### Method Calls

```ruby
# ✅ GOOD: Omit parentheses for DSL-like methods
class User
  belongs_to :organization
  has_many :posts
  validates :name, presence: true
end

# ✅ GOOD: Omit for common methods
puts "Hello"
require "json"
attr_reader :name

# ✅ GOOD: Use parentheses for clarity in other cases
result = calculate(a, b)
user.update(name: "New Name")
```

### Implicit Returns

```ruby
# ✅ GOOD: Omit return when it's the last expression
def full_name
  "#{first_name} #{last_name}"
end

def calculate_total
  items.sum(&:price)
end

# ✅ GOOD: Use return for early exit (guard clauses)
def process_user(user)
  return if user.nil?
  return if user.inactive?

  perform_action(user)
end

# ❌ BAD: Explicit return at end
def full_name
  return "#{first_name} #{last_name}"
end
```

### Self Usage

```ruby
# ✅ GOOD: Omit self when not needed
def full_name
  "#{first_name} #{last_name}"  # Calls self.first_name implicitly
end

# ✅ GOOD: Use self for setters (required)
def update_name(new_name)
  self.name = new_name  # Required for assignment
end

# ✅ GOOD: Use self for disambiguation
def name=(value)
  self.name = sanitize(value)  # Must use self for recursive setter
end

# ❌ BAD: Unnecessary self
def full_name
  "#{self.first_name} #{self.last_name}"
end
```

### Guard Clauses

```ruby
# ✅ GOOD: Use guard clauses for early returns
def process_order(order)
  return if order.nil?
  return if order.cancelled?
  return unless order.valid?

  charge_payment(order)
  send_confirmation(order)
end

# ❌ BAD: Nested conditionals
def process_order(order)
  if order
    unless order.cancelled?
      if order.valid?
        charge_payment(order)
        send_confirmation(order)
      end
    end
  end
end
```

### Keyword Arguments

```ruby
# ✅ GOOD: Use keyword arguments for optional parameters
def create_user(name:, email:, role: :user, active: true)
  User.new(name: name, email: email, role: role, active: active)
end

# Usage is clear:
create_user(name: "John", email: "john@example.com")
create_user(name: "Jane", email: "jane@example.com", role: :admin)

# ❌ BAD: Positional optional arguments
def create_user(name, email, role = :user, active = true)
  # What does create_user("John", "john@example.com", true) mean?
end

# ✅ GOOD: Use ** for forwarding keyword arguments
def wrapper_method(**options)
  underlying_method(**options)
end
```

## Control Flow

### Conditionals

```ruby
# ✅ GOOD: Prefer unless for negative conditions
return unless valid?
process if ready?

# ❌ BAD: if !condition
return if !valid?
process if not ready?

# ✅ GOOD: Use modifier form for single-line conditionals
return if user.nil?
process unless skip_processing?

# ❌ BAD: Multi-line for simple conditions
if user.nil?
  return
end
```

### Ternary Operator

```ruby
# ✅ GOOD: Use ternary for simple conditionals
status = active? ? "Active" : "Inactive"
result = value.nil? ? default : value

# ❌ BAD: Nested ternaries
status = admin? ? (active? ? "Active Admin" : "Inactive Admin") : "User"

# ✅ GOOD: Use if/else for complex logic
status = if admin?
           active? ? "Active Admin" : "Inactive Admin"
         else
           "User"
         end
```

### Case Statements

```ruby
# ✅ GOOD: Prefer case over if-elsif chains
def day_type(day)
  case day
  when :saturday, :sunday
    :weekend
  when :monday, :tuesday, :wednesday, :thursday, :friday
    :weekday
  else
    :unknown
  end
end

# ✅ GOOD: case with ranges
def grade(score)
  case score
  when 90..100 then "A"
  when 80..89  then "B"
  when 70..79  then "C"
  when 60..69  then "D"
  else              "F"
  end
end
```

### Boolean Logic

```ruby
# ✅ GOOD: Use && and || for boolean expressions
if user.valid? && user.active?
  process(user)
end

result = value || default

# ❌ BAD: Using 'and' and 'or' in conditions
if user.valid? and user.active?  # Different precedence!
  process(user)
end

# ✅ ACCEPTABLE: 'and'/'or' for control flow (but controversial)
user.save or raise "Failed to save"
```

### Negation

```ruby
# ✅ GOOD: Use ! for negation
if !valid?
  raise Error
end

# ❌ BAD: Using 'not'
if not valid?
  raise Error
end

# ✅ BETTER: Use unless for readability
unless valid?
  raise Error
end
```

### Loops

```ruby
# ✅ GOOD: Prefer iterators over for loops
users.each do |user|
  process(user)
end

# ❌ BAD: Using for loops
for user in users
  process(user)
end

# ✅ GOOD: Use each_with_index, each_with_object
items.each_with_index do |item, index|
  puts "#{index}: #{item}"
end

# ✅ GOOD: Use Kernel#loop for infinite loops
loop do
  break if done?
  process_next
end

# ❌ BAD: while true
while true
  break if done?
  process_next
end
```

## Strings

### Interpolation

```ruby
# ✅ GOOD: Use string interpolation
message = "Hello, #{name}!"
path = "#{base_url}/users/#{user_id}"

# ❌ BAD: String concatenation
message = "Hello, " + name + "!"
path = base_url + "/users/" + user_id.to_s

# ✅ GOOD: No to_s in interpolation
"User: #{user}"  # to_s is called automatically

# ❌ BAD: Explicit to_s in interpolation
"User: #{user.to_s}"
```

### Quote Style

```ruby
# Community Guide: Single quotes when no interpolation
name = 'John'
sql = 'SELECT * FROM users'

# Shopify/Airbnb Style: Double quotes consistently
name = "John"
sql = "SELECT * FROM users"

# Both agree: Double quotes when interpolation needed
message = "Hello, #{name}"
```

### Heredocs

```ruby
# ✅ GOOD: Use squiggly heredoc (<<~) for multi-line strings
query = <<~SQL
  SELECT users.name, orders.total
  FROM users
  JOIN orders ON users.id = orders.user_id
  WHERE orders.status = 'completed'
SQL

# ✅ GOOD: Heredoc preserves indentation properly
def help_text
  <<~TEXT
    Welcome to the application!

    Commands:
      help  - Show this message
      quit  - Exit the application
  TEXT
end

# ❌ BAD: Old heredoc style without squiggly
query = <<-SQL
  SELECT * FROM users
  SQL
```

### String Methods

```ruby
# ✅ GOOD: Use String#chars for character array
"hello".chars  # => ["h", "e", "l", "l", "o"]

# ❌ BAD: Using split
"hello".split("")

# ✅ GOOD: Use tr for character replacement
"hello".tr("aeiou", "*")  # => "h*ll*"

# ❌ BAD: gsub for single character replacement
"hello".gsub(/[aeiou]/, "*")
```

## Collections

### Literal Syntax

```ruby
# ✅ GOOD: Use literal syntax for arrays and hashes
array = [1, 2, 3]
hash = { key: "value" }

# ❌ BAD: Using constructors unnecessarily
array = Array.new
hash = Hash.new

# ✅ GOOD: Use %w for word arrays
STATES = %w[pending active completed cancelled]

# ✅ GOOD: Use %i for symbol arrays
STATUSES = %i[draft published archived]

# ❌ BAD: Manual array construction
STATES = ["pending", "active", "completed", "cancelled"]
STATUSES = [:draft, :published, :archived]
```

### Hash Syntax

```ruby
# ✅ GOOD: Use symbol keys with Ruby 1.9+ syntax
user = { name: "John", email: "john@example.com" }

# ❌ BAD: Old hashrocket syntax for symbols
user = { :name => "John", :email => "john@example.com" }

# ✅ GOOD: Hashrocket for non-symbol keys
results = { "Content-Type" => "application/json" }
cache = { 1 => "one", 2 => "two" }
```

### Hash Access

```ruby
# ✅ GOOD: Use Hash#fetch for required keys
config.fetch(:api_key)  # Raises KeyError if missing

# ✅ GOOD: Use Hash#fetch with default
timeout = config.fetch(:timeout, 30)
retries = config.fetch(:retries) { calculate_default }

# ❌ BAD: Using || for defaults (fails with false/nil values)
enabled = config[:enabled] || true  # Bug if enabled is false!

# ✅ GOOD: Use Hash#key? to check existence
if config.key?(:feature_flag)
  # ...
end

# ❌ BAD: Using has_key? (deprecated)
if config.has_key?(:feature_flag)
  # ...
end
```

### Array Access

```ruby
# ✅ GOOD: Use first/last instead of indices
users.first
users.last

# ❌ BAD: Using indices for first/last
users[0]
users[-1]

# ✅ GOOD: Use take/drop for slicing
users.take(5)   # First 5
users.drop(5)   # All except first 5
users.last(3)   # Last 3
```

### Enumerable Methods

```ruby
# ✅ GOOD: Use map for transformation
names = users.map(&:name)

# ✅ GOOD: Use select/reject for filtering
active_users = users.select(&:active?)
inactive_users = users.reject(&:active?)

# ✅ GOOD: Use find for single item
admin = users.find(&:admin?)

# ✅ GOOD: Use reduce for accumulation
total = orders.reduce(0) { |sum, order| sum + order.total }

# ✅ GOOD: Use flat_map instead of map + flatten
all_tags = posts.flat_map(&:tags)

# ❌ BAD: map followed by flatten
all_tags = posts.map(&:tags).flatten

# ✅ GOOD: Use each_with_object for building collections
users_by_id = users.each_with_object({}) do |user, hash|
  hash[user.id] = user
end
```

## Exceptions

### Raising Exceptions

```ruby
# ✅ GOOD: Use raise
raise ArgumentError, "Name cannot be blank"
raise CustomError, "Something went wrong"

# ❌ BAD: Using fail (though some prefer it for initial raising)
fail ArgumentError, "Name cannot be blank"

# ✅ GOOD: Separate class and message
raise ArgumentError, "Invalid input: #{input}"

# ❌ BAD: Using exception instance
raise ArgumentError.new("Invalid input")
```

### Rescuing Exceptions

```ruby
# ✅ GOOD: Rescue specific exceptions
begin
  perform_operation
rescue NetworkError => e
  log_error(e)
  retry_operation
rescue ValidationError => e
  handle_validation_error(e)
end

# ❌ BAD: Rescuing Exception (catches everything including system errors)
begin
  perform_operation
rescue Exception => e  # DON'T DO THIS
  handle_error(e)
end

# ✅ GOOD: Use implicit StandardError
begin
  perform_operation
rescue => e  # Rescues StandardError and subclasses
  handle_error(e)
end

# ❌ BAD: Empty rescue
begin
  perform_operation
rescue
  # Silent failure - DON'T DO THIS
end
```

### Implicit Begin Blocks

```ruby
# ✅ GOOD: Use method body as implicit begin
def process_file(path)
  File.read(path)
rescue Errno::ENOENT => e
  log_error("File not found: #{path}")
  nil
end

# ❌ UNNECESSARY: Explicit begin in method
def process_file(path)
  begin
    File.read(path)
  rescue Errno::ENOENT => e
    log_error("File not found: #{path}")
    nil
  end
end
```

### Ensure Blocks

```ruby
# ✅ GOOD: Use ensure for cleanup
def with_file(path)
  file = File.open(path)
  yield file
ensure
  file&.close  # Always runs, even if exception raised
end

# ❌ BAD: Return from ensure (changes return value!)
def bad_example
  return "normal"
ensure
  return "from ensure"  # This is what gets returned!
end
```

## Comments

### Documentation

```ruby
# ✅ GOOD: Comments explain why, not what
# Retry with exponential backoff to handle temporary network issues
3.times do |attempt|
  break if send_request
  sleep(2**attempt)
end

# ❌ BAD: Comments state the obvious
# Increment counter by 1
counter += 1

# Loop through users
users.each do |user|
  process(user)
end
```

### TODO Comments

```ruby
# ✅ GOOD: Include author name (Airbnb style)
# TODO(john.smith): Refactor this to use the new API

# ✅ GOOD: Include ticket reference
# TODO: Optimize this query (JIRA-1234)
# FIXME: This breaks with empty arrays
# HACK: Temporary workaround for API bug
```

### Commented-Out Code

```ruby
# ❌ BAD: Never leave commented-out code
def process
  # old_method
  # another_old_method
  new_method
end

# ✅ GOOD: Remove unused code (use version control)
def process
  new_method
end
```

## Metaprogramming

### General Guidance

```ruby
# ✅ GOOD: Avoid needless metaprogramming
# Explicit is better than implicit
class User
  attr_reader :name, :email

  def initialize(name:, email:)
    @name = name
    @email = email
  end
end

# ❌ BAD: Overly clever metaprogramming
class User
  %i[name email].each do |attr|
    define_method(attr) { instance_variable_get("@#{attr}") }
  end
end
```

### Method Missing

```ruby
# ❌ BAD: Using method_missing without respond_to_missing?
class Proxy
  def method_missing(name, *args)
    target.send(name, *args)
  end
end

# ✅ GOOD: Always define respond_to_missing? with method_missing
class Proxy
  def method_missing(name, *args, &block)
    if target.respond_to?(name)
      target.public_send(name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    target.respond_to?(name, include_private) || super
  end
end
```

### Send vs Public Send

```ruby
# ✅ GOOD: Use public_send to respect visibility
user.public_send(:name)

# ⚠️ CAUTION: send bypasses visibility
user.send(:private_method)  # Works but breaks encapsulation
```

## Percent Literals

```ruby
# %w - Word array (strings)
%w[foo bar baz]  # => ["foo", "bar", "baz"]

# %i - Symbol array
%i[foo bar baz]  # => [:foo, :bar, :baz]

# %r - Regular expression (useful with many slashes)
%r{^/users/\d+/posts$}

# %x - Shell command
%x(ls -la)

# %s - Symbol (rarely needed)
%s[foo bar]  # => :"foo bar"

# %q - Single-quoted string (no interpolation)
%q(Hello #{name})  # => "Hello \#{name}"

# %Q - Double-quoted string (with interpolation)
%Q(Hello #{name})  # => "Hello John"
```

## Common Anti-Patterns

### God Classes

```ruby
# ❌ BAD: Class doing too much
class UserManager
  def create_user; end
  def send_email; end
  def process_payment; end
  def generate_report; end
  def sync_with_external_api; end
  # ... 500 more lines
end

# ✅ GOOD: Single responsibility
class User
  def initialize(name:, email:); end
end

class UserMailer
  def welcome_email(user); end
end

class PaymentProcessor
  def process(user, amount); end
end
```

### Type Checking

```ruby
# ❌ BAD: Explicit type checking
def process(input)
  if input.is_a?(String)
    process_string(input)
  elsif input.is_a?(Array)
    process_array(input)
  elsif input.is_a?(Hash)
    process_hash(input)
  end
end

# ✅ GOOD: Duck typing
def process(input)
  input.each do |item|
    handle(item)
  end
end

# ✅ GOOD: Use respond_to? if needed
def process(input)
  if input.respond_to?(:each)
    input.each { |item| handle(item) }
  else
    handle(input)
  end
end
```

### Long Parameter Lists

```ruby
# ❌ BAD: Too many parameters
def create_order(user, items, shipping_address, billing_address,
                 payment_method, coupon_code, gift_wrap, notes)
  # ...
end

# ✅ GOOD: Use keyword arguments
def create_order(user:, items:, shipping_address:, billing_address:,
                 payment_method:, coupon_code: nil, gift_wrap: false, notes: nil)
  # ...
end

# ✅ BETTER: Use a parameter object
class OrderParams
  attr_reader :user, :items, :shipping_address
  # ...
end

def create_order(params)
  # ...
end
```