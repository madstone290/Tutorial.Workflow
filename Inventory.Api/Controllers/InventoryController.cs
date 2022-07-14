using Microsoft.AspNetCore.Mvc;
using Workflow.Inventory.Domain;

namespace Inventory.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class InventoryController : ControllerBase
    {
        private static readonly InventoryMap inventoryMap = new InventoryMap();
        static InventoryController()
        {
            var pen = new Item("Pen");
            var book = new Item("Book");
            var keyboard = new Item("Keyboard");
            var room1 = new Location("room1");
            var room2 = new Location("room2");
            var room3 = new Location("room3");
            inventoryMap.Increase(pen, room1, 5);
            inventoryMap.Increase(pen, room2, 5);
            inventoryMap.Increase(book, room2, 10);
            inventoryMap.Increase(keyboard, room3, 3);
        }

        [HttpGet]
        public IEnumerable<InventoryRecord> Get()
        {
            return inventoryMap.GetAllRecords();
        }
    }
}