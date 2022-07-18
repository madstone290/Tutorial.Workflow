using Microsoft.AspNetCore.Mvc;

namespace Inventory.Api.Controllers.DevOps
{
    [ApiController]
    [Route("[controller]")]
    public class UpstreamColorController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public UpstreamColorController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet]
        public string? Get()
        {
            var color = _configuration.GetValue<string>("UpStreamColor")?.ToLower();
            return color;
        }
    }
}
