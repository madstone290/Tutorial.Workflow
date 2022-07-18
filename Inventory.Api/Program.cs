var builder = WebApplication.CreateBuilder(args);

var colorArg = args.FirstOrDefault(x => x.StartsWith("UpstreamColor=", StringComparison.OrdinalIgnoreCase));
if(colorArg != null)
{
    var color = colorArg.Substring(colorArg.IndexOf('=') + 1);
    builder.Configuration.AddInMemoryCollection(new List<KeyValuePair<string, string>>()
    {
        new KeyValuePair<string, string>("UpstreamColor", color)
    });
}


// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
