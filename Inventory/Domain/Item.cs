using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Workflow.Inventory.Domain
{
    public class Item
    {
        public string Id { get; set; } = string.Empty;

        public string Name { get; set; } = string.Empty;

        public Item(string name)
        {
            Id = Guid.NewGuid().ToString();
            Name = name;
        }
    }
}
