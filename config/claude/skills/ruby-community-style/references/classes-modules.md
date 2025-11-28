# Ruby Classes and Modules Patterns

This file contains patterns for object-oriented programming in Ruby following the Community Style Guide.

## Class Structure

### Standard Class Layout

```ruby
# ✅ GOOD: Consistent class structure
class User
  # 1. Extend and include statements
  extend Forwardable
  include Comparable

  # 2. Constants
  DEFAULT_ROLE = :member
  VALID_ROLES = %i[member admin moderator].freeze

  # 3. Attribute macros
  attr_reader :id, :email
  attr_accessor :name

  # 4. Other macros (if any)
  delegate :organization_name, to: :organization

  # 5. Public class methods
  def self.find_by_email(email)
    # ...
  end

  # 6. Initialization
  def initialize(id:, name:, email:, role: DEFAULT_ROLE)
    @id = id
    @name = name
    @email = email
    @role = role
  end

  # 7. Public instance methods
  def full_name
    name.titleize
  end

  def admin?
    @role == :admin
  end

  # 8. Protected methods (if any)
  protected

  def comparable_value
    @id
  end

  # 9. Private methods
  private

  def validate_email
    raise ArgumentError unless @email.include?("@")
  end
end
```

### Sandi Metz Rules

```ruby
# Rule 1: Classes should be no longer than 100 lines
# Rule 2: Methods should be no longer than 5 lines
# Rule 3: Pass no more than 4 parameters into a method
# Rule 4: Controllers can instantiate only one object (Rails)

# ✅ GOOD: Method under 5 lines
def full_name
  "#{first_name} #{last_name}"
end

# ❌ BAD: Method over 5 lines - extract!
def process_order
  validate_items
  calculate_subtotal
  apply_discounts
  calculate_tax
  calculate_shipping
  create_invoice
  send_confirmation
  update_inventory
end

# ✅ GOOD: Refactored to follow rules
def process_order
  validate_and_calculate
  finalize_order
end

private

def validate_and_calculate
  validate_items
  calculate_totals
end

def calculate_totals
  apply_discounts
  calculate_tax_and_shipping
end
```

## Attr Accessors

### Using Attr Methods

```ruby
# ✅ GOOD: Use attr_* for simple accessors
class User
  attr_reader :id          # read-only
  attr_writer :password    # write-only (rare)
  attr_accessor :name      # read and write

  def initialize(id:, name:)
    @id = id
    @name = name
  end
end

# ❌ BAD: Manual accessor methods
class User
  def id
    @id
  end

  def name
    @name
  end

  def name=(value)
    @name = value
  end
end
```

### Custom Accessors

```ruby
# ✅ GOOD: Custom setter with validation
class User
  attr_reader :email

  def email=(value)
    raise ArgumentError, "Invalid email" unless value.include?("@")
    @email = value.downcase.strip
  end
end

# ✅ GOOD: Lazy-loaded accessor
class Report
  def data
    @data ||= expensive_calculation
  end

  private

  def expensive_calculation
    # ...
  end
end
```

## Class Methods

### Defining Class Methods

```ruby
# ✅ GOOD: Use def self.method_name
class User
  def self.find(id)
    # ...
  end

  def self.create(attributes)
    # ...
  end
end

# ✅ GOOD: Use class << self for grouping multiple class methods
class User
  class << self
    def find(id)
      # ...
    end

    def create(attributes)
      # ...
    end

    def find_or_create(attributes)
      find(attributes[:id]) || create(attributes)
    end

    private

    def sanitize_attributes(attrs)
      # ...
    end
  end
end

# ❌ BAD: Using ClassName.method_name in definition
class User
  def User.find(id)  # Don't do this
    # ...
  end
end
```

### Factory Methods

```ruby
# ✅ GOOD: Factory method pattern
class Connection
  def self.create(type:)
    case type
    when :http  then HttpConnection.new
    when :https then HttpsConnection.new
    when :ftp   then FtpConnection.new
    else raise ArgumentError, "Unknown type: #{type}"
    end
  end

  private_class_method :new  # Prevent direct instantiation
end

# Usage
conn = Connection.create(type: :https)
```

## Access Modifiers

### Visibility

```ruby
# ✅ GOOD: Group methods by visibility
class Service
  def public_method
    # Available to everyone
  end

  def another_public_method
    # ...
  end

  protected

  def protected_method
    # Available to self and subclasses
  end

  private

  def private_method
    # Only available within this class
  end

  def another_private_method
    # ...
  end
end

# ✅ GOOD: Inline visibility (less common but valid)
class Service
  private def helper_method
    # ...
  end
end
```

### Private Class Methods

```ruby
# ✅ GOOD: Using private_class_method
class Service
  def self.public_api
    internal_helper
  end

  def self.internal_helper
    # ...
  end
  private_class_method :internal_helper
end

# ✅ GOOD: Using class << self with private
class Service
  class << self
    def public_api
      internal_helper
    end

    private

    def internal_helper
      # ...
    end
  end
end
```

## Inheritance

### When to Use Inheritance

```ruby
# ✅ GOOD: Use inheritance for "is-a" relationships
class Animal
  def breathe
    "breathing"
  end
end

class Dog < Animal
  def speak
    "woof"
  end
end

class Cat < Animal
  def speak
    "meow"
  end
end
```

### Template Method Pattern

```ruby
# ✅ GOOD: Template method pattern
class Report
  def generate
    header + body + footer
  end

  private

  def header
    raise NotImplementedError, "Subclass must implement"
  end

  def body
    raise NotImplementedError, "Subclass must implement"
  end

  def footer
    "Generated at #{Time.now}"
  end
end

class SalesReport < Report
  private

  def header
    "Sales Report\n"
  end

  def body
    # Generate sales data
  end
end
```

### Prefer Composition Over Inheritance

```ruby
# ❌ BAD: Deep inheritance hierarchies
class A; end
class B < A; end
class C < B; end
class D < C; end  # Too deep!

# ✅ GOOD: Composition
class Order
  def initialize(calculator:, notifier:)
    @calculator = calculator
    @notifier = notifier
  end

  def process
    total = @calculator.calculate(items)
    @notifier.notify(self, total)
  end
end

# Now we can easily swap implementations
order = Order.new(
  calculator: TaxIncludedCalculator.new,
  notifier: EmailNotifier.new
)
```

## Modules

### Module as Namespace

```ruby
# ✅ GOOD: Use modules for namespacing
module Payments
  class Gateway
    # ...
  end

  class Transaction
    # ...
  end

  class Refund
    # ...
  end
end

# Usage
gateway = Payments::Gateway.new
```

### Module as Mixin

```ruby
# ✅ GOOD: Module for shared behavior
module Timestampable
  def created_at
    @created_at ||= Time.now
  end

  def updated_at
    @updated_at
  end

  def touch
    @updated_at = Time.now
  end
end

class User
  include Timestampable
end

class Post
  include Timestampable
end
```

### Include vs Extend vs Prepend

```ruby
module Logging
  def log(message)
    puts "[LOG] #{message}"
  end
end

# include - adds methods as instance methods
class Service
  include Logging

  def perform
    log("Starting...")  # Available as instance method
  end
end

# extend - adds methods as class methods
class Service
  extend Logging
end
Service.log("Class method")  # Available as class method

# prepend - inserts module before class in lookup chain
module Auditing
  def save
    log_before_save
    super  # Calls the original save
    log_after_save
  end
end

class User
  prepend Auditing

  def save
    # Original implementation
  end
end
```

### Module Callbacks

```ruby
# ✅ GOOD: Using included/extended callbacks
module Validatable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def validates(attribute, **options)
      # Add validation
    end
  end

  def valid?
    # Check validations
  end
end

class User
  include Validatable

  validates :name, presence: true  # Class method from ClassMethods
end

user = User.new
user.valid?  # Instance method from Validatable
```

### Concern Pattern (Rails)

```ruby
# ✅ GOOD: ActiveSupport::Concern pattern
module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search, ->(query) { where("name LIKE ?", "%#{query}%") }
  end

  class_methods do
    def search_fields
      [:name, :description]
    end
  end

  def matches?(query)
    search_fields.any? { |field| send(field).include?(query) }
  end
end

class Product
  include Searchable
end
```

## Struct and Data Classes

### Using Struct

```ruby
# ✅ GOOD: Use Struct for simple value objects
Point = Struct.new(:x, :y) do
  def distance_from_origin
    Math.sqrt(x**2 + y**2)
  end
end

point = Point.new(3, 4)
point.x  # => 3
point.distance_from_origin  # => 5.0

# ✅ GOOD: Keyword arguments with Struct
Person = Struct.new(:name, :age, keyword_init: true)
person = Person.new(name: "John", age: 30)
```

### Using Data (Ruby 3.2+)

```ruby
# ✅ GOOD: Data class for immutable value objects (Ruby 3.2+)
Point = Data.define(:x, :y) do
  def distance_from_origin
    Math.sqrt(x**2 + y**2)
  end
end

point = Point.new(x: 3, y: 4)
point.x  # => 3
# point.x = 5  # Error! Data objects are immutable
```

### When to Use Classes vs Structs

```ruby
# Use Struct for:
# - Simple data containers
# - Value objects with few methods
# - Quick prototyping

# Use Class for:
# - Complex behavior
# - Mutable state management
# - Inheritance hierarchies
# - When you need private methods/state

# ❌ BAD: Don't inherit from Struct
class Point < Struct.new(:x, :y)  # Avoid this
  def distance
    # ...
  end
end

# ✅ GOOD: Define methods in block
Point = Struct.new(:x, :y) do
  def distance
    # ...
  end
end
```

## Duck Typing

### Prefer Duck Typing

```ruby
# ❌ BAD: Type checking
def process(input)
  case input
  when String
    process_string(input)
  when Array
    process_array(input)
  when Hash
    process_hash(input)
  end
end

# ✅ GOOD: Duck typing - rely on behavior
def process(items)
  items.each { |item| handle(item) }
end

# Works with Array, Set, or any Enumerable!
process([1, 2, 3])
process(Set.new([1, 2, 3]))
process(1..3)
```

### Using respond_to?

```ruby
# ✅ GOOD: Check for capability when needed
def serialize(object)
  if object.respond_to?(:to_json)
    object.to_json
  elsif object.respond_to?(:to_hash)
    object.to_hash.to_json
  else
    object.to_s
  end
end
```

## Class Variables

### Avoid Class Variables

```ruby
# ❌ BAD: Class variables have surprising inheritance behavior
class Parent
  @@count = 0

  def self.increment
    @@count += 1
  end
end

class Child < Parent
end

Parent.increment  # @@count = 1
Child.increment   # @@count = 2 (shared with Parent!)

# ✅ GOOD: Use class instance variables
class Parent
  @count = 0

  class << self
    attr_accessor :count
  end

  def self.increment
    self.count += 1
  end
end

class Child < Parent
  @count = 0  # Each class has its own count
end

Parent.increment  # Parent.count = 1
Child.increment   # Child.count = 1 (separate!)
```

## Aliasing Methods

```ruby
# ✅ GOOD: Use alias_method for method aliases
class User
  def full_name
    "#{first_name} #{last_name}"
  end

  alias_method :name, :full_name
end

# ❌ BAD: Using alias keyword (works differently with inheritance)
class User
  def full_name
    "#{first_name} #{last_name}"
  end

  alias name full_name  # Less predictable
end
```

## Comparable Module

```ruby
# ✅ GOOD: Include Comparable and define <=>
class Version
  include Comparable

  attr_reader :major, :minor, :patch

  def initialize(version_string)
    @major, @minor, @patch = version_string.split(".").map(&:to_i)
  end

  def <=>(other)
    [major, minor, patch] <=> [other.major, other.minor, other.patch]
  end
end

v1 = Version.new("1.2.3")
v2 = Version.new("1.2.4")

v1 < v2   # => true
v1 == v2  # => false
v1 >= v2  # => false
```

## Equality Methods

```ruby
# ✅ GOOD: Define == and eql? consistently
class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def ==(other)
    other.is_a?(Point) && x == other.x && y == other.y
  end

  alias eql? ==

  def hash
    [x, y].hash
  end
end

# Now works correctly with Hash and Set
point1 = Point.new(1, 2)
point2 = Point.new(1, 2)

point1 == point2  # => true
{ point1 => "value" }[point2]  # => "value" (because hash/eql? defined)
```