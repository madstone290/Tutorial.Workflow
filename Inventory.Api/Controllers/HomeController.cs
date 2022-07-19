using Microsoft.AspNetCore.Mvc;
using Workflow.Inventory.Domain;

namespace Inventory.Api.Controllers
{
    [ApiController]
    [Route("/")]
    public class HomeController : ControllerBase
    {
        private const string Version = "2.22.11";

        [HttpGet]
        public string Get()
        {
            return $"Hi this is inventory home\nCurrent Versions is {Version}\nYou can see various features here";
        }
    }
}