# Go Coding Principles

## Uber Go Style Guide Rules

### Rule 1: Functions should be no longer than 50 lines
Keep functions focused and readable. Extract complex logic into smaller functions.

```go
// Good - Under 50 lines, focused responsibility
func processUser(ctx context.Context, userID string) error {
    user, err := fetchUser(ctx, userID)
    if err != nil {
        return fmt.Errorf("fetch user %q: %w", userID, err)
    }
    
    if err := validateUser(user); err != nil {
        return fmt.Errorf("validate user %q: %w", userID, err)
    }
    
    if err := updateUserStatus(ctx, user); err != nil {
        return fmt.Errorf("update user status: %w", err)
    }
    
    return nil
}

// Good - Complex logic extracted to separate functions
func calculateUserScore(user *User) (float64, error) {
    activityScore, err := calculateActivityScore(user)
    if err != nil {
        return 0, err
    }
    
    engagementScore := calculateEngagementScore(user)
    bonusScore := calculateBonusScore(user)
    
    return (activityScore * 0.5) + (engagementScore * 0.3) + (bonusScore * 0.2), nil
}
```

### Rule 2: Structs should be no longer than 200 lines
Split large structs into smaller, focused types. Use composition over embedding for complex relationships.

```go
// Good - Under 200 lines, single responsibility
type User struct {
    ID        string
    Name      string
    Email     string
    CreatedAt time.Time
    UpdatedAt time.Time
    Active    bool
}

func NewUser(name, email string) *User {
    now := time.Now()
    return &User{
        ID:        generateUserID(),
        Name:      name,
        Email:     email,
        CreatedAt: now,
        UpdatedAt: now,
        Active:    true,
    }
}

// Good - Separate concerns into different types
type UserValidator struct {}

func (v *UserValidator) ValidateEmail(email string) error {
    if !strings.Contains(email, "@") {
        return errors.New("invalid email format")
    }
    return nil
}
```

### Rule 3: Use no more than 4 parameters in function signatures
Use structs or configuration objects for multiple related parameters.

```go
// Good - 4 parameters max
func CreateUser(name, email, role string, active bool) (*User, error) {
    return &User{
        ID:        generateUserID(),
        Name:      name,
        Email:     email,
        Role:      role,
        Active:    active,
        CreatedAt: time.Now(),
    }, nil
}

// Good - Use struct for related parameters
type UserConfig struct {
    Name       string
    Email      string
    Role       string
    Active     bool
    Department string
    Manager    string
}

func CreateUserFromConfig(config UserConfig) (*User, error) {
    user := &User{
        ID:         generateUserID(),
        Name:       config.Name,
        Email:      config.Email,
        Role:       config.Role,
        Active:     config.Active,
        Department: config.Department,
        Manager:    config.Manager,
        CreatedAt:  time.Now(),
    }
    return user, nil
}
```

### Rule Zero: Exception Rule
**"Break these rules only when you have a good reason and document it clearly."**

Document exceptions clearly with approval and reasoning.

## Fundamental Principles

### Follow Standard Go Practices as Foundation
- Use `gofmt` for all formatting (non-negotiable)
- Follow [Effective Go](https://golang.org/doc/effective_go) as baseline
- Refer to [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments) for detailed guidance
- Use `go vet` to catch common mistakes

## Design Principles

### Error Handling Patterns

#### Wrap and Return Errors (Don't Log and Return)
```go
// Good - Wrap errors for context
func processUser(id string) error {
  user, err := getUser(id)
  if err != nil {
    return fmt.Errorf("process user %q: %w", id, err)
  }
  
  if err := validateUser(user); err != nil {
    return fmt.Errorf("validate user %q: %w", id, err)
  }
  
  return nil
}

// Avoid - Logging and returning creates noise
func processUser(id string) error {
  user, err := getUser(id)
  if err != nil {
    log.Printf("Could not get user %q: %v", id, err)
    return err // This will likely be logged again upstream
  }
  return nil
}
```

#### Define Error Sentinel Values
```go
// Good - Exportable errors for client matching
var (
  ErrUserNotFound = errors.New("user not found")
  ErrInvalidInput = errors.New("invalid input")
  
  // Unexported errors for internal use
  errDatabaseTimeout = errors.New("database timeout")
)

func FindUser(id string) (*User, error) {
  if id == "" {
    return nil, ErrInvalidInput
  }
  
  user, err := db.Get(id)
  if err != nil {
    if isTimeout(err) {
      return nil, errDatabaseTimeout
    }
    return nil, ErrUserNotFound
  }
  
  return user, nil
}

// Client can match specific errors
if err := FindUser(id); err != nil {
  if errors.Is(err, ErrUserNotFound) {
    // Handle not found case
  } else if errors.Is(err, ErrInvalidInput) {
    // Handle invalid input
  } else {
    // Handle other errors
  }
}
```

#### Custom Error Types
```go
// Good - Custom errors with context
type ValidationError struct {
  Field   string
  Message string
}

func (e *ValidationError) Error() string {
  return fmt.Sprintf("validation error on field %q: %s", e.Field, e.Message)
}

func ValidateUser(user *User) error {
  if user.Email == "" {
    return &ValidationError{
      Field:   "email",
      Message: "email is required",
    }
  }
  
  if !strings.Contains(user.Email, "@") {
    return &ValidationError{
      Field:   "email", 
      Message: "email must contain @ symbol",
    }
  }
  
  return nil
}

// Client can extract details
if err := ValidateUser(user); err != nil {
  var validationErr *ValidationError
  if errors.As(err, &validationErr) {
    fmt.Printf("Field %s failed: %s\n", validationErr.Field, validationErr.Message)
  }
}
```

### Function and Method Organization

#### Recommended Order in Go Files
```go
// Good - Logical organization
package user

import (
  "fmt"
  "time"
)

// 1. Types first
type User struct {
  ID        string
  Name      string  
  Email     string
  CreatedAt time.Time
}

type UserService struct {
  db Database
}

// 2. Constructors (New* functions)
func NewUser(name, email string) *User {
  return &User{
    ID:        generateID(),
    Name:      name,
    Email:     email,
    CreatedAt: time.Now(),
  }
}

func NewUserService(db Database) *UserService {
  return &UserService{db: db}
}

// 3. Methods grouped by receiver
func (u *User) Validate() error {
  if u.Name == "" {
    return errors.New("name is required")
  }
  if u.Email == "" {
    return errors.New("email is required")
  }
  return nil
}

func (u *User) IsActive() bool {
  return time.Since(u.CreatedAt) < 30*24*time.Hour
}

func (s *UserService) Create(user *User) error {
  return s.db.Save(user)
}

func (s *UserService) FindByID(id string) (*User, error) {
  return s.db.Get(id)
}

// 4. Plain utility functions last
func generateID() string {
  return fmt.Sprintf("user_%d", time.Now().Unix())
}

func validateEmail(email string) bool {
  return strings.Contains(email, "@")
}
```

### Interface Design

#### Keep Interfaces Small
```go
// Good - Small, focused interfaces
type Reader interface {
  Read([]byte) (int, error)
}

type Writer interface {
  Write([]byte) (int, error)
}

type Closer interface {
  Close() error
}

// Compose when needed
type ReadWriteCloser interface {
  Reader
  Writer
  Closer
}

// Avoid - Large interfaces with many methods
type FileHandler interface {
  Open(string) error
  Close() error
  Read([]byte) (int, error)
  Write([]byte) (int, error)
  Seek(int64, int) (int64, error)
  Stat() (FileInfo, error)
  Chmod(FileMode) error
  // ... many more methods
}
```

#### Accept Interfaces, Return Concrete Types
```go
// Good - Accept interfaces for flexibility
func ProcessData(r io.Reader) (*Result, error) {
  data, err := ioutil.ReadAll(r)
  if err != nil {
    return nil, err
  }
  
  return &Result{Data: data}, nil
}

// Good - Return concrete types for extensibility
type DatabaseConnection struct {
  host string
  port int
}

func (d *DatabaseConnection) Query(sql string) (*Rows, error) {
  // Implementation
  return &Rows{}, nil
}

func (d *DatabaseConnection) Execute(sql string) error {
  // Implementation
  return nil
}

func NewConnection(host string, port int) *DatabaseConnection {
  return &DatabaseConnection{host: host, port: port}
}

// Client gets concrete type and can call any method
conn := NewConnection("localhost", 5432)
rows, _ := conn.Query("SELECT * FROM users")
_ = conn.Execute("DELETE FROM temp_table")
```

#### Verify Interface Compliance at Compile Time
```go
// Good - Catch interface mismatches early
type Handler struct{}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
  // Implementation
}

// Compile-time verification
var _ http.Handler = (*Handler)(nil)

// This will fail to compile if Handler doesn't implement http.Handler
```

## Go Language Features

### Struct Usage and Initialization

#### Always Use Field Names in Struct Literals
```go
// Good - Clear field assignment
user := User{
  ID:        "123",
  Name:      "Alice",
  Email:     "alice@example.com", 
  CreatedAt: time.Now(),
  Active:    true,
}

config := Config{
  Host:     "localhost",
  Port:     8080,
  Debug:    true,
  Timeout:  30 * time.Second,
  MaxConns: 100,
}

// Avoid - Positional arguments are unclear
user := User{"123", "Alice", "alice@example.com", time.Now(), true}
```

#### Prefer &T{} Over new(T)
```go
// Good - Consistent with field initialization
user := &User{
  Name:  "Alice",
  Email: "alice@example.com",
}

// Avoid - Inconsistent style  
user := new(User)
user.Name = "Alice"
user.Email = "alice@example.com"
```

#### Use Zero Values Effectively
```go
// Good - Leverage zero values
type Server struct {
  Host string
  Port int    // zero value 0 might be fine
  mu   sync.Mutex // zero value is ready to use
}

func NewServer() *Server {
  return &Server{
    Host: "localhost",
    // Port defaults to 0, mu is ready to use
  }
}

// Good - Zero value mutex
var mu sync.Mutex
mu.Lock()
defer mu.Unlock()

// Avoid - Unnecessary initialization
mu := new(sync.Mutex) // sync.Mutex zero value is usable
```

### Embedding Guidelines

#### Use Embedding for Single, Related Types
```go
// Good - Single, related embedding
type LoggedWriter struct {
  io.Writer
  bytesWritten int64
}

func (lw *LoggedWriter) Write(data []byte) (int, error) {
  n, err := lw.Writer.Write(data)
  lw.bytesWritten += int64(n)
  return n, err
}

// Good - Preserve zero value with embedding
type Buffer struct {
  bytes.Buffer // Zero value is an empty, usable buffer
  
  // Additional fields
  maxSize int64
}

// Avoid - Multiple unrelated embeddings
type Client struct {
  sync.Mutex
  sync.WaitGroup
  bytes.Buffer
  url.URL
}
```

#### Use Named Fields for Multiple Unrelated Types
```go
// Good - Named fields for clarity and control
type Client struct {
  mu     sync.Mutex
  wg     sync.WaitGroup
  buf    bytes.Buffer
  apiURL url.URL
}

func (c *Client) process() {
  c.mu.Lock()
  defer c.mu.Unlock()
  
  // Clear intention of which mutex we're using
}
```

### Goroutine and Concurrency Patterns

#### Use Context for Cancellation
```go
// Good - Context-aware goroutine management
func (w *Worker) Start(ctx context.Context) error {
  var wg sync.WaitGroup
  
  for i := 0; i < w.numWorkers; i++ {
    wg.Add(1)
    go func(workerID int) {
      defer wg.Done()
      w.processWork(ctx, workerID)
    }(i)
  }
  
  // Wait for all goroutines to complete
  wg.Wait()
  return nil
}

func (w *Worker) processWork(ctx context.Context, id int) {
  for {
    select {
    case <-ctx.Done():
      return // Clean shutdown
    case work := <-w.workChan:
      if err := w.handleWork(work); err != nil {
        log.Printf("Worker %d error: %v", id, err)
      }
    }
  }
}
```

#### Use Atomic Operations for Counters
```go
// Good - Type-safe atomic operations
import "go.uber.org/atomic"

type Counter struct {
  value atomic.Int64
}

func (c *Counter) Increment() {
  c.value.Add(1)
}

func (c *Counter) Get() int64 {
  return c.value.Load()
}

// Avoid - Race-prone direct access
type Counter struct {
  value int64 // atomic access required but not enforced
}

func (c *Counter) Increment() {
  atomic.AddInt64(&c.value, 1)
}

func (c *Counter) Get() int64 {
  return c.value // Race condition! Should use atomic.LoadInt64
}
```

#### Defer for Resource Cleanup
```go
// Good - Reliable cleanup with defer
func processFile(filename string) error {
  file, err := os.Open(filename)
  if err != nil {
    return err
  }
  defer file.Close() // Cleanup guaranteed
  
  data, err := ioutil.ReadAll(file)
  if err != nil {
    return err // file.Close() still called
  }
  
  return processData(data)
}

// Good - Mutex cleanup
func (s *Service) updateCounter(delta int) {
  s.mu.Lock()
  defer s.mu.Unlock() // Reliable unlock
  
  if s.counter+delta < 0 {
    return // Unlock still happens
  }
  
  s.counter += delta
}
```

## Implementation Guidelines

### Variable Declaration and Scope

#### Group Related Variable Declarations
```go
// Good - Group related variables in functions
func processRequest(r *http.Request) error {
  var (
    userID   = r.Header.Get("User-ID")
    clientIP = r.RemoteAddr
    startTime = time.Now()
    err       error
  )
  
  // Process with variables
  return err
}

// Good - Group at package level
var (
  ErrInvalidInput = errors.New("invalid input")
  ErrNotFound     = errors.New("not found")
  ErrTimeout      = errors.New("timeout")
)
```

#### Reduce Variable Scope When Possible
```go
// Good - Limited error scope
if err := validateInput(input); err != nil {
  return fmt.Errorf("validation failed: %w", err)
}

// Good - Limited scope for file operations
if data, err := ioutil.ReadFile(filename); err != nil {
  return err
} else {
  return processData(data)
}

// Avoid - Wider scope than needed
err := validateInput(input)
if err != nil {
  return fmt.Errorf("validation failed: %w", err)
}
```

### Constants and Enums

#### Use iota for Related Constants
```go
// Good - Start enums at 1 to avoid zero value
type Priority int

const (
  PriorityLow Priority = iota + 1
  PriorityMedium
  PriorityHigh
  PriorityCritical
)

// Good - Bit flags
type Permission int

const (
  PermissionRead Permission = 1 << iota
  PermissionWrite
  PermissionExecute
)

func (p Permission) String() string {
  var permissions []string
  if p&PermissionRead != 0 {
    permissions = append(permissions, "read")
  }
  if p&PermissionWrite != 0 {
    permissions = append(permissions, "write")
  }
  if p&PermissionExecute != 0 {
    permissions = append(permissions, "execute")
  }
  return strings.Join(permissions, ",")
}
```

#### Group Related Constants
```go
// Good - Related constants together
const (
  DefaultTimeout = 30 * time.Second
  DefaultRetries = 3
  DefaultPort    = 8080
)

const (
  StatusPending = "pending"
  StatusActive  = "active"
  StatusExpired = "expired"
)

// Separate unrelated constants
const ConfigEnvVar = "APP_CONFIG"
```

### Naming Conventions

#### Function and Method Naming
```go
// Good - Clear, descriptive names
func ValidateUserInput(input string) error { }
func (u *User) IsActive() bool { }
func (s *Server) Start() error { }
func (s *Server) Shutdown(ctx context.Context) error { }

// Avoid - Abbreviations and unclear names
func ValidateUsrInp(inp string) error { }
func (u *User) IsA() bool { }
func (s *Server) Go() error { }
```

#### Package-Level Naming
```go
// Good - Don't repeat package name in functions
package user

func New() *User { }      // Called as user.New()
func Find(id string) { }  // Called as user.Find()
func Validate(u *User) error { } // Called as user.Validate()

// Avoid - Redundant package name
func NewUser() *User { }     // Called as user.NewUser() - redundant
func FindUser(id string) { } // Called as user.FindUser() - redundant
```

#### Receiver Names
```go
// Good - Short, consistent receiver names
type UserService struct{ }

func (us *UserService) Create(user *User) error { }
func (us *UserService) Update(user *User) error { }
func (us *UserService) Delete(id string) error { }

// For single-letter types, use the first letter
type Buffer struct{ }

func (b *Buffer) Write(data []byte) (int, error) { }
func (b *Buffer) Read(data []byte) (int, error) { }
```

## Testing Best Practices

### Test Organization and Structure

#### Table-Driven Test Structure
```go
// Good - Comprehensive table-driven test
func TestParseURL(t *testing.T) {
  tests := []struct {
    name    string
    input   string
    want    *URL
    wantErr bool
  }{
    {
      name:  "valid_http_url",
      input: "http://example.com",
      want: &URL{
        Scheme: "http",
        Host:   "example.com",
      },
      wantErr: false,
    },
    {
      name:  "valid_https_url_with_path",
      input: "https://api.example.com/v1/users",
      want: &URL{
        Scheme: "https",
        Host:   "api.example.com",
        Path:   "/v1/users",
      },
      wantErr: false,
    },
    {
      name:    "invalid_url_missing_scheme",
      input:   "example.com",
      want:    nil,
      wantErr: true,
    },
  }

  for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
      got, err := ParseURL(tt.input)
      
      if (err != nil) != tt.wantErr {
        t.Errorf("ParseURL() error = %v, wantErr %v", err, tt.wantErr)
        return
      }
      
      if !reflect.DeepEqual(got, tt.want) {
        t.Errorf("ParseURL() = %v, want %v", got, tt.want)
      }
    })
  }
}
```

#### Test Helper Functions (Use Sparingly)
```go
// Good - Simple helper for test setup
func setupTestDB(t *testing.T) *sql.DB {
  t.Helper()
  
  db, err := sql.Open("sqlite3", ":memory:")
  if err != nil {
    t.Fatalf("Failed to create test database: %v", err)
  }
  
  // Run migrations
  if err := runMigrations(db); err != nil {
    t.Fatalf("Failed to run migrations: %v", err)
  }
  
  t.Cleanup(func() {
    db.Close()
  })
  
  return db
}

// Usage in tests
func TestUserRepository(t *testing.T) {
  db := setupTestDB(t)
  repo := NewUserRepository(db)
  
  // Test logic here...
}
```

#### Test Error Messages
```go
// Good - Descriptive error messages
func TestCalculateTotal(t *testing.T) {
  got := CalculateTotal(10, 0.08)
  want := 10.80
  
  if got != want {
    t.Errorf("CalculateTotal(10, 0.08) = %.2f, want %.2f", got, want)
  }
}

// Good - Include context in error messages
func TestProcessOrder(t *testing.T) {
  order := &Order{ID: "123", Items: []Item{{Price: 10}}}
  
  err := ProcessOrder(order)
  if err != nil {
    t.Errorf("ProcessOrder(%+v) returned unexpected error: %v", order, err)
  }
}
```

### Mocking and Dependencies

#### Interface-Based Dependency Injection
```go
// Good - Interface for testing
type UserRepository interface {
  Create(user *User) error
  FindByID(id string) (*User, error)
  Update(user *User) error
  Delete(id string) error
}

type UserService struct {
  repo UserRepository
  logger Logger
}

func NewUserService(repo UserRepository, logger Logger) *UserService {
  return &UserService{repo: repo, logger: logger}
}

func (s *UserService) CreateUser(name, email string) error {
  user := &User{
    ID:    generateID(),
    Name:  name,
    Email: email,
  }
  
  if err := user.Validate(); err != nil {
    return fmt.Errorf("invalid user: %w", err)
  }
  
  if err := s.repo.Create(user); err != nil {
    s.logger.Errorf("Failed to create user: %v", err)
    return fmt.Errorf("create user: %w", err)
  }
  
  s.logger.Infof("Created user: %s", user.ID)
  return nil
}

// Test implementation
type mockUserRepository struct {
  users map[string]*User
  calls []string
}

func (m *mockUserRepository) Create(user *User) error {
  m.calls = append(m.calls, "Create")
  if m.users == nil {
    m.users = make(map[string]*User)
  }
  m.users[user.ID] = user
  return nil
}

func (m *mockUserRepository) FindByID(id string) (*User, error) {
  m.calls = append(m.calls, "FindByID")
  user, exists := m.users[id]
  if !exists {
    return nil, ErrUserNotFound
  }
  return user, nil
}

// Test usage
func TestUserService_CreateUser(t *testing.T) {
  mockRepo := &mockUserRepository{}
  mockLogger := &mockLogger{}
  service := NewUserService(mockRepo, mockLogger)
  
  err := service.CreateUser("Alice", "alice@example.com")
  if err != nil {
    t.Fatalf("CreateUser() error = %v", err)
  }
  
  // Verify interactions
  if len(mockRepo.calls) != 1 || mockRepo.calls[0] != "Create" {
    t.Errorf("Expected Create to be called once, got calls: %v", mockRepo.calls)
  }
  
  if len(mockRepo.users) != 1 {
    t.Errorf("Expected 1 user to be created, got %d", len(mockRepo.users))
  }
}
```

## Performance Considerations

### Memory Management

#### Specify Slice Capacity When Known
```go
// Good - Pre-allocate capacity to avoid reallocations
func processItems(items []string) []ProcessedItem {
  result := make([]ProcessedItem, 0, len(items)) // Capacity = len(items)
  
  for _, item := range items {
    processed := ProcessItem(item)
    result = append(result, processed)
  }
  
  return result
}

// Good - For maps too
func buildIndex(users []User) map[string]*User {
  index := make(map[string]*User, len(users))
  
  for i := range users {
    index[users[i].ID] = &users[i]
  }
  
  return index
}

// Avoid - Repeated reallocations
func processItems(items []string) []ProcessedItem {
  var result []ProcessedItem // Starts with zero capacity
  
  for _, item := range items {
    processed := ProcessItem(item)
    result = append(result, processed) // May reallocate and copy
  }
  
  return result
}
```

#### Avoid Repeated String Conversions
```go
// Good - Convert once, reuse
func writeMessages(w io.Writer, messages []string) error {
  prefix := []byte("LOG: ") // Convert once
  
  for _, msg := range messages {
    if _, err := w.Write(prefix); err != nil {
      return err
    }
    if _, err := w.Write([]byte(msg)); err != nil {
      return err
    }
    if _, err := w.Write([]byte("\n")); err != nil {
      return err
    }
  }
  
  return nil
}

// Avoid - Repeated conversion
func writeMessages(w io.Writer, messages []string) error {
  for _, msg := range messages {
    if _, err := w.Write([]byte("LOG: ")); err != nil { // Convert every time
      return err
    }
    if _, err := w.Write([]byte(msg)); err != nil {
      return err
    }
    if _, err := w.Write([]byte("\n")); err != nil { // Convert every time
      return err
    }
  }
  
  return nil
}
```

#### Use strconv Over fmt for Simple Conversions
```go
// Good - More efficient for simple conversions
func formatID(id int) string {
  return strconv.Itoa(id)
}

func formatFloat(f float64) string {
  return strconv.FormatFloat(f, 'f', 2, 64)
}

func parseInt(s string) (int, error) {
  return strconv.Atoi(s)
}

// Avoid - Slower and more allocations
func formatID(id int) string {
  return fmt.Sprint(id)
}

func formatFloat(f float64) string {
  return fmt.Sprintf("%.2f", f)
}
```

### Efficient Patterns

#### Return Early to Reduce Nesting
```go
// Good - Early returns for error cases
func processUser(user *User) error {
  if user == nil {
    return ErrInvalidUser
  }
  
  if user.Email == "" {
    return ErrMissingEmail
  }
  
  if !user.IsActive() {
    return ErrInactiveUser
  }
  
  // Main processing logic without nesting
  return user.Process()
}

// Avoid - Nested conditions
func processUser(user *User) error {
  if user != nil {
    if user.Email != "" {
      if user.IsActive() {
        return user.Process()
      } else {
        return ErrInactiveUser
      }
    } else {
      return ErrMissingEmail
    }
  } else {
    return ErrInvalidUser
  }
}
```

#### Prefer nil Slices Over Empty Slices
```go
// Good - Return nil for empty results
func findActiveUsers(users []User) []User {
  var active []User
  
  for _, user := range users {
    if user.IsActive() {
      active = append(active, user)
    }
  }
  
  return active // Returns nil if no active users found
}

// Works correctly with nil slices
users := findActiveUsers(allUsers)
for _, user := range users { // No panic with nil slice
  fmt.Println(user.Name)
}

if len(users) == 0 { // Works with nil slice
  fmt.Println("No active users")
}
```

#### Copy Returned Maps to Prevent Mutations
```go
// Good - Protect internal state
type Cache struct {
  mu    sync.RWMutex
  items map[string]string
}

func (c *Cache) GetAll() map[string]string {
  c.mu.RLock()
  defer c.mu.RUnlock()
  
  // Return copy to prevent external mutations
  result := make(map[string]string, len(c.items))
  for k, v := range c.items {
    result[k] = v
  }
  
  return result
}

// Avoid - Exposing internal state
func (c *Cache) GetAll() map[string]string {
  c.mu.RLock()
  defer c.mu.RUnlock()
  
  return c.items // Caller can mutate internal state
}
```

## Code Organization and Style

### Import Organization
```go
// Good - Standard library first, then third-party, then local
package main

import (
  "context"
  "fmt"
  "net/http"
  "time"
  
  "github.com/gorilla/mux"
  "go.uber.org/zap"
  
  "myproject/internal/config"
  "myproject/internal/database"
  "myproject/pkg/logger"
)
```

### Package Structure
```go
// Good - Package-level organization
package user

// Package-level constants
const (
  DefaultTimeout = 30 * time.Second
  MaxRetries     = 3
)

// Package-level variables  
var (
  ErrUserNotFound = errors.New("user not found")
  ErrInvalidEmail = errors.New("invalid email")
)

// Types
type User struct {
  ID    string
  Name  string
  Email string
}

type Repository interface {
  Save(*User) error
  Find(string) (*User, error)
}

// Constructors
func New(name, email string) *User {
  return &User{
    ID:    generateID(),
    Name:  name,
    Email: email,
  }
}

// Methods
func (u *User) Validate() error {
  if u.Email == "" {
    return ErrInvalidEmail
  }
  return nil
}

// Package functions
func ValidateEmail(email string) bool {
  return strings.Contains(email, "@")
}
```

### Comment Guidelines

#### Effective Documentation
```go
// Good - Package comment
// Package user provides functionality for managing user accounts
// including creation, validation, and persistence operations.
//
// Basic usage:
//
//   user := user.New("Alice", "alice@example.com")
//   if err := user.Validate(); err != nil {
//       log.Fatal(err)
//   }
package user

// Good - Function documentation
// ProcessPayment handles payment processing for an order.
// It validates the payment details, charges the payment method,
// and updates the order status.
//
// Returns an error if the payment fails or if the order
// cannot be updated.
func ProcessPayment(order *Order, payment *Payment) error {
  // Implementation
}

// Good - Complex logic explanation
func calculateShippingCost(weight float64, distance int, priority Priority) float64 {
  // Base cost calculation uses weight and distance
  baseCost := weight * 0.1 + float64(distance) * 0.05
  
  // Apply priority multiplier
  // Standard: 1.0, Express: 1.5, Overnight: 2.0
  switch priority {
  case PriorityExpress:
    baseCost *= 1.5
  case PriorityOvernight:  
    baseCost *= 2.0
  }
  
  return baseCost
}
```

## Additional Resources and Updates

### Missing Guidelines Reference

If you encounter Go coding scenarios not covered in this document, consult these authoritative sources using Context7:

**Primary Sources:**
- **Uber Go Style Guide**: `/uber-go/guide` (304 code snippets, Trust Score: 8)
- **Google Go Style Guide**: `/google/styleguide` (1201 code snippets, Trust Score: 8.9)

**Usage Example:**
```bash
# Get additional guidance on specific topics
mcp__context7__get-library-docs --library-id="/uber-go/guide" --topic="concurrency patterns"
mcp__context7__get-library-docs --library-id="/google/styleguide" --topic="API design"
```

**When to Use Context7:**
- Advanced concurrency patterns not covered here
- Enterprise-scale architecture decisions  
- Specific tooling and linter configurations
- Performance optimization techniques
- Protocol buffer and gRPC best practices

### Official Go Resources
- **Effective Go**: https://golang.org/doc/effective_go
- **Go Code Review Comments**: https://github.com/golang/go/wiki/CodeReviewComments
- **Go Blog**: https://blog.golang.org/

## Key Takeaways

1. **Follow Uber Go Style Guide rules** as structural constraints
2. **Choose the right approach** - structs for entities, functions for transformations, interfaces for services
3. **Handle errors properly** - use specific error types and proper wrapping
4. **Write descriptive tests** that focus on behavior, not implementation
5. **Use Go idioms** - channels, goroutines, and built-in functions effectively
6. **Organize code logically** - clear package structure and import organization
7. **Use tools** - golangci-lint, go vet, and other Go tooling for code quality
8. **Avoid anti-patterns** - panic for errors, ignoring errors, global variables
9. **Be idiomatic** - write Go code that feels natural to Go developers
10. **Use Context7** for additional guidance beyond this document

> "Clarity is better than cleverness." - Go Proverbs

> "Don't communicate by sharing memory; share memory by communicating." - Go Proverbs

> "A little copying is better than a little dependency." - Go Proverbs