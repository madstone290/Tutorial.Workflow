using Microsoft.AspNetCore.Mvc;

namespace Workflow.Inventory.WebApp.Controllers.DevOps
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
        public IActionResult Index()
        {
            var color = _configuration.GetValue<string>("UpstreamColor")?.ToLower() 
                ?? "empty";
            return Ok(color);
        }
    }
}
