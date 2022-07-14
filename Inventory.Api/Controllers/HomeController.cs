using Microsoft.AspNetCore.Mvc;
using Workflow.Inventory.Domain;

namespace Inventory.Api.Controllers
{
    [ApiController]
    [Route("/")]
    public class HomeController : ControllerBase
    {
        [HttpGet]
        public string Get()
        {
            return "Welcome to inventory api";
        }
    }
}