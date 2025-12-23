# C# and ASP.NET Core - Code Styles and Guidelines

## Version Requirements

- Target C# version: **C# 12+**
- Target .NET version: **.NET 8+**
- Use modern C# 12 features including:
  - Primary constructors for classes and structs
  - Collection expressions `[..]`
  - Lambda expression default parameters
  - Alias any type with `using` directive
  - Experimental attribute
  - Inline arrays

## Project Overview

This is an ASP.NET Core 8+ application using:

- C# 12 with nullable reference types enabled
- ASP.NET Core Minimal APIs or MVC Controllers
- Entity Framework Core for data access
- Dependency Injection (built-in)
- API versioning and documentation (Swagger/OpenAPI)

## C# Code Styles

### Nullable Reference Types

- **ALWAYS** enable nullable reference types in all projects
- Use `?` suffix for nullable reference types
- Use `!` null-forgiving operator sparingly and only when you're certain
- Handle null cases explicitly

```csharp
// .csproj configuration
<PropertyGroup>
  <Nullable>enable</Nullable>
  <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
</PropertyGroup>

// Code examples
public class UserService
{
    private readonly IUserRepository _repository;

    public UserService(IUserRepository repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }

    public async Task<User?> GetUserByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _repository.FindByIdAsync(id, cancellationToken);
    }

    public async Task<User> CreateUserAsync(CreateUserRequest request, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(request);

        var user = new User
        {
            Name = request.Name,
            Email = request.Email
        };

        return await _repository.AddAsync(user, cancellationToken);
    }
}
```

### Modern C# Features

#### Primary Constructors (C# 12)

```csharp
// Use primary constructors for simple classes
public class UserService(IUserRepository repository, ILogger<UserService> logger) : IUserService
{
    private readonly IUserRepository _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    private readonly ILogger<UserService> _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    public async Task<User?> GetUserAsync(int id)
    {
        _logger.LogInformation("Getting user with ID {UserId}", id);
        return await _repository.FindByIdAsync(id);
    }
}
```

#### Collection Expressions (C# 12)

```csharp
// Use collection expressions for initialization
int[] numbers = [1, 2, 3, 4, 5];
List<string> names = ["Alice", "Bob", "Charlie"];

// Spread operator
int[] moreNumbers = [..numbers, 6, 7, 8];

// Instead of
var oldWay = new List<string> { "Alice", "Bob", "Charlie" };
```

#### File-Scoped Types

```csharp
// Use file-scoped types for internal helper classes
file class ValidationHelper
{
    public static bool IsValidEmail(string email) => email.Contains('@');
}

public class UserValidator
{
    public bool Validate(string email) => ValidationHelper.IsValidEmail(email);
}
```

### Naming Conventions

- **Classes/Interfaces/Records**: PascalCase (`UserService`, `IUserRepository`)
- **Methods**: PascalCase (`GetUserAsync`, `CreateUser`)
- **Properties**: PascalCase (`FirstName`, `EmailAddress`)
- **Private fields**: \_camelCase with underscore prefix (`_userRepository`, `_logger`)
- **Parameters/Local variables**: camelCase (`userId`, `cancellationToken`)
- **Constants**: PascalCase (`MaxRetryCount`, `DefaultTimeout`)
- **Async methods**: Suffix with `Async` (`GetUserAsync`, `SaveChangesAsync`)

### Type System Best Practices

#### Use Records for DTOs and Value Objects

```csharp
// Records for immutable DTOs
public record CreateUserRequest(string Name, string Email, DateTime? BirthDate);

public record UserResponse(int Id, string Name, string Email, DateTime CreatedAt);

// Records with validation
public record EmailAddress
{
    public string Value { get; init; }

    public EmailAddress(string value)
    {
        if (string.IsNullOrWhiteSpace(value) || !value.Contains('@'))
            throw new ArgumentException("Invalid email address", nameof(value));

        Value = value;
    }
}
```

#### Use readonly structs for Performance

```csharp
public readonly struct Point
{
    public double X { get; init; }
    public double Y { get; init; }

    public Point(double x, double y)
    {
        X = x;
        Y = y;
    }

    public double DistanceFromOrigin() => Math.Sqrt(X * X + Y * Y);
}
```

#### Pattern Matching

```csharp
// Use pattern matching extensively
public decimal CalculateDiscount(Customer customer) => customer switch
{
    { Type: CustomerType.Premium, YearsActive: > 5 } => 0.20m,
    { Type: CustomerType.Premium } => 0.15m,
    { Type: CustomerType.Regular, YearsActive: > 2 } => 0.10m,
    _ => 0.05m
};

// List patterns (C# 11+)
public bool IsValidSequence(int[] numbers) => numbers switch
{
    [] => false,
    [var single] => single > 0,
    [var first, .. var rest] => first > 0 && rest.All(x => x > 0),
};
```

## SOLID Principles

### Single Responsibility Principle (SRP)

Each class should have one, and only one, reason to change.

```csharp
// Bad: Multiple responsibilities
public class UserController
{
    public async Task<User> CreateUser(CreateUserDto dto)
    {
        // Validation logic
        if (string.IsNullOrEmpty(dto.Email))
            throw new ArgumentException("Email required");

        // Business logic
        var user = new User { Name = dto.Name, Email = dto.Email };

        // Data access
        await _dbContext.Users.AddAsync(user);
        await _dbContext.SaveChangesAsync();

        // Email sending
        await _emailService.SendWelcomeEmail(user.Email);

        return user;
    }
}

// Good: Separated responsibilities
public class UserService(
    IUserRepository repository,
    IUserValidator validator,
    IEmailService emailService)
{
    public async Task<User> CreateUserAsync(CreateUserDto dto, CancellationToken cancellationToken = default)
    {
        await validator.ValidateAsync(dto, cancellationToken);

        var user = new User
        {
            Name = dto.Name,
            Email = dto.Email
        };

        var createdUser = await repository.AddAsync(user, cancellationToken);
        await emailService.SendWelcomeEmailAsync(createdUser.Email, cancellationToken);

        return createdUser;
    }
}
```

### Open/Closed Principle (OCP)

Classes should be open for extension but closed for modification.

```csharp
// Use interfaces and inheritance for extensibility
public interface IPaymentProcessor
{
    Task<PaymentResult> ProcessPaymentAsync(decimal amount, CancellationToken cancellationToken = default);
}

public class StripePaymentProcessor : IPaymentProcessor
{
    public async Task<PaymentResult> ProcessPaymentAsync(decimal amount, CancellationToken cancellationToken = default)
    {
        // Stripe-specific implementation
        await Task.Delay(100, cancellationToken);
        return new PaymentResult { Success = true };
    }
}

public class PayPalPaymentProcessor : IPaymentProcessor
{
    public async Task<PaymentResult> ProcessPaymentAsync(decimal amount, CancellationToken cancellationToken = default)
    {
        // PayPal-specific implementation
        await Task.Delay(100, cancellationToken);
        return new PaymentResult { Success = true };
    }
}

// Payment service that works with any processor
public class PaymentService(IPaymentProcessor paymentProcessor)
{
    public async Task<bool> ProcessOrderPaymentAsync(Order order, CancellationToken cancellationToken = default)
    {
        var result = await paymentProcessor.ProcessPaymentAsync(order.Total, cancellationToken);
        return result.Success;
    }
}
```

### Liskov Substitution Principle (LSP)

Derived classes must be substitutable for their base classes.

```csharp
public abstract class Bird
{
    public abstract void Move();
}

public class FlyingBird : Bird
{
    public override void Move() => Fly();
    protected virtual void Fly() => Console.WriteLine("Flying...");
}

public class Penguin : Bird
{
    public override void Move() => Swim();
    protected virtual void Swim() => Console.WriteLine("Swimming...");
}

// Consumers can use any Bird without knowing the specific type
public class BirdMover
{
    public void MoveBird(Bird bird) => bird.Move();
}
```

### Interface Segregation Principle (ISP)

Clients should not be forced to depend on interfaces they don't use.

```csharp
// Bad: Fat interface
public interface IWorker
{
    void Work();
    void Eat();
    void Sleep();
}

// Good: Segregated interfaces
public interface IWorkable
{
    void Work();
}

public interface IEatable
{
    void Eat();
}

public interface ISleepable
{
    void Sleep();
}

public class Human : IWorkable, IEatable, ISleepable
{
    public void Work() => Console.WriteLine("Working...");
    public void Eat() => Console.WriteLine("Eating...");
    public void Sleep() => Console.WriteLine("Sleeping...");
}

public class Robot : IWorkable
{
    public void Work() => Console.WriteLine("Working 24/7...");
}
```

### Dependency Inversion Principle (DIP)

Depend on abstractions, not concretions.

```csharp
// Bad: Depending on concrete implementation
public class OrderService
{
    private readonly SqlServerDatabase _database = new();

    public void CreateOrder(Order order)
    {
        _database.Save(order);
    }
}

// Good: Depending on abstraction
public interface IOrderRepository
{
    Task<Order> AddAsync(Order order, CancellationToken cancellationToken = default);
}

public class OrderService(IOrderRepository repository)
{
    public async Task<Order> CreateOrderAsync(Order order, CancellationToken cancellationToken = default)
    {
        return await repository.AddAsync(order, cancellationToken);
    }
}
```

## ASP.NET Core Best Practices

### Minimal API Structure

```csharp
var builder = WebApplication.CreateBuilder(args);

// Configure services
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Register services
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IUserService, UserService>();

var app = builder.Build();

// Configure middleware pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();

// Define endpoints
app.MapGroup("/api/users")
    .MapUserEndpoints()
    .RequireAuthorization();

app.Run();

// Extension method for endpoint mapping
public static class UserEndpoints
{
    public static RouteGroupBuilder MapUserEndpoints(this RouteGroupBuilder group)
    {
        group.MapGet("/", GetAllUsers)
            .WithName("GetUsers")
            .WithOpenApi();

        group.MapGet("/{id:int}", GetUserById)
            .WithName("GetUser")
            .WithOpenApi();

        group.MapPost("/", CreateUser)
            .WithName("CreateUser")
            .WithOpenApi();

        return group;
    }

    private static async Task<IResult> GetAllUsers(
        IUserService userService,
        CancellationToken cancellationToken)
    {
        var users = await userService.GetAllUsersAsync(cancellationToken);
        return Results.Ok(users);
    }

    private static async Task<IResult> GetUserById(
        int id,
        IUserService userService,
        CancellationToken cancellationToken)
    {
        var user = await userService.GetUserByIdAsync(id, cancellationToken);
        return user is not null ? Results.Ok(user) : Results.NotFound();
    }

    private static async Task<IResult> CreateUser(
        CreateUserRequest request,
        IUserService userService,
        CancellationToken cancellationToken)
    {
        var user = await userService.CreateUserAsync(request, cancellationToken);
        return Results.CreatedAtRoute("GetUser", new { id = user.Id }, user);
    }
}
```

### Controller-Based API Structure

```csharp
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class UsersController(IUserService userService, ILogger<UsersController> logger) : ControllerBase
{
    /// <summary>
    /// Gets all users
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<UserResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<UserResponse>>> GetUsers(CancellationToken cancellationToken)
    {
        logger.LogInformation("Getting all users");
        var users = await userService.GetAllUsersAsync(cancellationToken);
        return Ok(users);
    }

    /// <summary>
    /// Gets a specific user by ID
    /// </summary>
    /// <param name="id">User ID</param>
    /// <param name="cancellationToken">Cancellation token</param>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(UserResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<UserResponse>> GetUser(int id, CancellationToken cancellationToken)
    {
        var user = await userService.GetUserByIdAsync(id, cancellationToken);

        if (user is null)
        {
            logger.LogWarning("User with ID {UserId} not found", id);
            return NotFound();
        }

        return Ok(user);
    }

    /// <summary>
    /// Creates a new user
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(UserResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<UserResponse>> CreateUser(
        [FromBody] CreateUserRequest request,
        CancellationToken cancellationToken)
    {
        var user = await userService.CreateUserAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
    }
}
```

### Dependency Injection

```csharp
// Service registration in Program.cs
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddSingleton<ICacheService, CacheService>();
builder.Services.AddTransient<IEmailService, EmailService>();

// Use options pattern for configuration
builder.Services.Configure<EmailSettings>(
    builder.Configuration.GetSection("EmailSettings"));

// Service using IOptions
public class EmailService(IOptions<EmailSettings> options) : IEmailService
{
    private readonly EmailSettings _settings = options.Value;

    public async Task SendEmailAsync(string to, string subject, string body)
    {
        // Use _settings.SmtpServer, _settings.Port, etc.
        await Task.CompletedTask;
    }
}
```

### Entity Framework Core Patterns

#### Repository Pattern

```csharp
public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<T>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<T> AddAsync(T entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(T entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(int id, CancellationToken cancellationToken = default);
}

public class Repository<T>(AppDbContext context) : IRepository<T> where T : class
{
    protected readonly AppDbContext _context = context;
    protected readonly DbSet<T> _dbSet = context.Set<T>();

    public virtual async Task<T?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _dbSet.FindAsync([id], cancellationToken);
    }

    public virtual async Task<IEnumerable<T>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet.ToListAsync(cancellationToken);
    }

    public virtual async Task<T> AddAsync(T entity, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
        return entity;
    }

    public virtual async Task UpdateAsync(T entity, CancellationToken cancellationToken = default)
    {
        _dbSet.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public virtual async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await GetByIdAsync(id, cancellationToken);
        if (entity is not null)
        {
            _dbSet.Remove(entity);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }
}

// Specific repository with custom queries
public interface IUserRepository : IRepository<User>
{
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<IEnumerable<User>> GetActiveUsersAsync(CancellationToken cancellationToken = default);
}

public class UserRepository(AppDbContext context) : Repository<User>(context), IUserRepository
{
    public async Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .FirstOrDefaultAsync(u => u.Email == email, cancellationToken);
    }

    public async Task<IEnumerable<User>> GetActiveUsersAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(u => u.IsActive)
            .OrderBy(u => u.Name)
            .ToListAsync(cancellationToken);
    }
}
```

#### DbContext Configuration

```csharp
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Order> Orders => Set<Order>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply all configurations from assembly
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }
}

// Separate configuration classes
public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("Users");

        builder.HasKey(u => u.Id);

        builder.Property(u => u.Name)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(255);

        builder.HasIndex(u => u.Email)
            .IsUnique();

        builder.HasMany(u => u.Orders)
            .WithOne(o => o.User)
            .HasForeignKey(o => o.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
```

### Error Handling and Validation

#### Global Exception Handler

```csharp
// Custom exception types
public class NotFoundException(string message) : Exception(message);
public class ValidationException(string message) : Exception(message);
public class UnauthorizedException(string message) : Exception(message);

// Global exception handler middleware
public class GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        logger.LogError(exception, "An unhandled exception occurred");

        var (statusCode, title) = exception switch
        {
            NotFoundException => (StatusCodes.Status404NotFound, "Resource not found"),
            ValidationException => (StatusCodes.Status400BadRequest, "Validation error"),
            UnauthorizedException => (StatusCodes.Status401Unauthorized, "Unauthorized"),
            _ => (StatusCodes.Status500InternalServerError, "Internal server error")
        };

        var problemDetails = new ProblemDetails
        {
            Status = statusCode,
            Title = title,
            Detail = exception.Message,
            Instance = httpContext.Request.Path
        };

        httpContext.Response.StatusCode = statusCode;
        await httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);

        return true;
    }
}

// Register in Program.cs
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();

// In middleware pipeline
app.UseExceptionHandler();
```

#### FluentValidation

```csharp
// Install: FluentValidation.AspNetCore

public record CreateUserRequest(string Name, string Email, DateTime? BirthDate);

public class CreateUserRequestValidator : AbstractValidator<CreateUserRequest>
{
    public CreateUserRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Name is required")
            .MaximumLength(100).WithMessage("Name must not exceed 100 characters");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required")
            .EmailAddress().WithMessage("Invalid email format");

        RuleFor(x => x.BirthDate)
            .LessThan(DateTime.Today).WithMessage("Birth date must be in the past")
            .When(x => x.BirthDate.HasValue);
    }
}

// Register in Program.cs
builder.Services.AddValidatorsFromAssemblyContaining<CreateUserRequestValidator>();

// Validation filter
public class ValidationFilter<T> : IEndpointFilter where T : class
{
    public async ValueTask<object?> InvokeAsync(
        EndpointFilterInvocationContext context,
        EndpointFilterDelegate next)
    {
        var validator = context.HttpContext.RequestServices.GetService<IValidator<T>>();

        if (validator is not null)
        {
            var entity = context.Arguments.OfType<T>().FirstOrDefault();

            if (entity is not null)
            {
                var validationResult = await validator.ValidateAsync(entity);

                if (!validationResult.IsValid)
                {
                    return Results.ValidationProblem(validationResult.ToDictionary());
                }
            }
        }

        return await next(context);
    }
}

// Use in endpoint
group.MapPost("/", CreateUser)
    .AddEndpointFilter<ValidationFilter<CreateUserRequest>>();
```

### Authentication and Authorization

```csharp
// Program.cs
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    options.AddPolicy("RequireEmail", policy =>
        policy.RequireClaim(ClaimTypes.Email));
});

// Authorization in endpoints
app.MapGet("/api/admin", () => "Admin only")
    .RequireAuthorization("AdminOnly");

// Authorization in controllers
[Authorize(Roles = "Admin")]
[HttpGet("admin")]
public IActionResult AdminOnly() => Ok("Admin only");
```

## Testing

### Unit Testing with xUnit

```csharp
public class UserServiceTests
{
    private readonly Mock<IUserRepository> _mockRepository;
    private readonly Mock<ILogger<UserService>> _mockLogger;
    private readonly UserService _sut;

    public UserServiceTests()
    {
        _mockRepository = new Mock<IUserRepository>();
        _mockLogger = new Mock<ILogger<UserService>>();
        _sut = new UserService(_mockRepository.Object, _mockLogger.Object);
    }

    [Fact]
    public async Task GetUserByIdAsync_WhenUserExists_ReturnsUser()
    {
        // Arrange
        var userId = 1;
        var expectedUser = new User { Id = userId, Name = "John", Email = "john@example.com" };
        _mockRepository
            .Setup(r => r.GetByIdAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedUser);

        // Act
        var result = await _sut.GetUserByIdAsync(userId);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedUser.Id, result.Id);
        Assert.Equal(expectedUser.Name, result.Name);
    }

    [Fact]
    public async Task GetUserByIdAsync_WhenUserNotFound_ReturnsNull()
    {
        // Arrange
        _mockRepository
            .Setup(r => r.GetByIdAsync(It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);

        // Act
        var result = await _sut.GetUserByIdAsync(999);

        // Assert
        Assert.Null(result);
    }

    [Theory]
    [InlineData("")]
    [InlineData(null)]
    [InlineData("   ")]
    public async Task CreateUserAsync_WithInvalidName_ThrowsValidationException(string invalidName)
    {
        // Arrange
        var request = new CreateUserRequest(invalidName, "test@example.com", null);

        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(() => _sut.CreateUserAsync(request));
    }
}
```

### Integration Testing

```csharp
public class UserEndpointsTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public UserEndpointsTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // Replace database with in-memory version
                var descriptor = services.SingleOrDefault(
                    d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));

                if (descriptor != null)
                    services.Remove(descriptor);

                services.AddDbContext<AppDbContext>(options =>
                    options.UseInMemoryDatabase("TestDb"));
            });
        });

        _client = _factory.CreateClient();
    }

    [Fact]
    public async Task GetUsers_ReturnsSuccessStatusCode()
    {
        // Act
        var response = await _client.GetAsync("/api/users");

        // Assert
        response.EnsureSuccessStatusCode();
        Assert.Equal("application/json", response.Content.Headers.ContentType?.MediaType);
    }

    [Fact]
    public async Task CreateUser_WithValidData_ReturnsCreated()
    {
        // Arrange
        var request = new CreateUserRequest("John Doe", "john@example.com", null);
        var content = JsonContent.Create(request);

        // Act
        var response = await _client.PostAsync("/api/users", content);

        // Assert
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var user = await response.Content.ReadFromJsonAsync<UserResponse>();
        Assert.NotNull(user);
        Assert.Equal(request.Name, user.Name);
    }
}
```

## Performance and Best Practices

### Async/Await Patterns

```csharp
// Always use async/await for I/O operations
public async Task<User?> GetUserAsync(int id, CancellationToken cancellationToken = default)
{
    return await _repository.GetByIdAsync(id, cancellationToken);
}

// Use ConfigureAwait(false) in library code (not needed in ASP.NET Core)
public async Task<string> ReadFileAsync(string path)
{
    return await File.ReadAllTextAsync(path).ConfigureAwait(false);
}

// Avoid async void (except for event handlers)
// Bad
public async void ProcessData() { }

// Good
public async Task ProcessDataAsync() { }
```

### Use Span<T> and Memory<T> for Performance

```csharp
public ReadOnlySpan<char> GetFileExtension(ReadOnlySpan<char> fileName)
{
    var index = fileName.LastIndexOf('.');
    return index >= 0 ? fileName[(index + 1)..] : ReadOnlySpan<char>.Empty;
}
```

### Caching

```csharp
public class CachedUserService(IUserService userService, IMemoryCache cache) : IUserService
{
    private const string CacheKeyPrefix = "user_";

    public async Task<User?> GetUserByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var cacheKey = $"{CacheKeyPrefix}{id}";

        if (cache.TryGetValue(cacheKey, out User? cachedUser))
            return cachedUser;

        var user = await userService.GetUserByIdAsync(id, cancellationToken);

        if (user is not null)
        {
            cache.Set(cacheKey, user, TimeSpan.FromMinutes(5));
        }

        return user;
    }
}
```

## Documentation

### XML Documentation Comments

```csharp
/// <summary>
/// Represents a service for managing users
/// </summary>
public interface IUserService
{
    /// <summary>
    /// Gets a user by their unique identifier
    /// </summary>
    /// <param name="id">The user's unique identifier</param>
    /// <param name="cancellationToken">Cancellation token to cancel the operation</param>
    /// <returns>The user if found; otherwise, null</returns>
    /// <exception cref="ArgumentException">Thrown when id is less than or equal to zero</exception>
    Task<User?> GetUserByIdAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Creates a new user
    /// </summary>
    /// <param name="request">The user creation request</param>
    /// <param name="cancellationToken">Cancellation token to cancel the operation</param>
    /// <returns>The created user</returns>
    /// <exception cref="ValidationException">Thrown when the request is invalid</exception>
    Task<User> CreateUserAsync(CreateUserRequest request, CancellationToken cancellationToken = default);
}
```

## Project Structure

```
MyProject/
├── src/
│   ├── MyProject.Api/
│   │   ├── Program.cs
│   │   ├── Endpoints/
│   │   │   ├── UserEndpoints.cs
│   │   │   └── OrderEndpoints.cs
│   │   ├── Middleware/
│   │   │   └── GlobalExceptionHandler.cs
│   │   └── appsettings.json
│   │
│   ├── MyProject.Core/
│   │   ├── Entities/
│   │   │   ├── User.cs
│   │   │   └── Order.cs
│   │   ├── Interfaces/
│   │   │   ├── IUserRepository.cs
│   │   │   └── IUserService.cs
│   │   ├── Services/
│   │   │   └── UserService.cs
│   │   └── Exceptions/
│   │       └── ValidationException.cs
│   │
│   └── MyProject.Infrastructure/
│       ├── Data/
│       │   ├── AppDbContext.cs
│       │   ├── Configurations/
│       │   │   └── UserConfiguration.cs
│       │   └── Repositories/
│       │       └── UserRepository.cs
│       └── Services/
│           └── EmailService.cs
│
└── tests/
    ├── MyProject.UnitTests/
    │   └── Services/
    │       └── UserServiceTests.cs
    └── MyProject.IntegrationTests/
        └── Endpoints/
            └── UserEndpointsTests.cs
```

## Summary Checklist

- ✅ Use C# 12+ features (primary constructors, collection expressions)
- ✅ Enable nullable reference types
- ✅ Follow SOLID principles
- ✅ Use async/await for all I/O operations
- ✅ Always include CancellationToken parameters
- ✅ Use records for DTOs and immutable data
- ✅ Implement proper dependency injection
- ✅ Use repository pattern for data access
- ✅ Implement global exception handling
- ✅ Use FluentValidation for request validation
- ✅ Write comprehensive XML documentation
- ✅ Include unit and integration tests
- ✅ Use pattern matching where appropriate
- ✅ Follow RESTful API conventions
- ✅ Implement proper logging with ILogger
- ✅ Use strongly-typed configuration with IOptions
- ✅ Apply authorization and authentication properly
- ✅ Use Entity Framework Core best practices
- ✅ Optimize performance with caching where appropriate
- ✅ Follow consistent naming conventions
