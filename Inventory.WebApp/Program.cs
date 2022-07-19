var builder = WebApplication.CreateBuilder(args);


var colorArg = args.FirstOrDefault(x => x.StartsWith("UpstreamColor=", StringComparison.OrdinalIgnoreCase));
if (colorArg != null)
{
    var color = colorArg.Substring(colorArg.IndexOf('=') + 1);
    builder.Configuration.AddInMemoryCollection(new List<KeyValuePair<string, string>>()
    {
        new KeyValuePair<string, string>("UpstreamColor", color)
    });
}



// Add services to the container.
builder.Services.AddControllersWithViews();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
