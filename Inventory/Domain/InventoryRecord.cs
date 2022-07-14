using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Workflow.Inventory.Domain
{
    public class InventoryRecord
    {
        public Item Item { get; set; } = default!;

        public Location Location { get; set; } = default!;

        public decimal Quantity { get; set; }

        public InventoryRecord(Item item, Location location, decimal quantity)
        {
            Item = item;
            Location = location;
            Quantity = quantity;
        }
    }
}
