using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Workflow.Inventory.Domain
{
    public class InventoryMap
    {
        private readonly ISet<InventoryRecord> _inventoryRecords = new HashSet<InventoryRecord>();


        private InventoryRecord? GetRecord(Item item, Location location)
        {
            return _inventoryRecords.FirstOrDefault(x => x.Item == item && x.Location == location);
        }

        public IEnumerable<InventoryRecord> GetAllRecords()
        {
            return _inventoryRecords;
        }

        public IEnumerable<InventoryRecord> GetRecordsAt(Location location)
        {
            return _inventoryRecords.Where(x=> x.Location == location);
        }

        public decimal GetQuantity(Item item, Location location)
        {
            InventoryRecord? record = GetRecord(item, location);
            return record?.Quantity ?? 0;
        }

        public void Increase(Item item, Location location, decimal quantity)
        {
            InventoryRecord? record = GetRecord(item, location);
            if (record == null)
            {
                record = new InventoryRecord(item, location, quantity);
                _inventoryRecords.Add(record);
            }
            else
            {
                record.Quantity += quantity;
            }
        }

        public void Decrease(Item item, Location location, decimal quantity)
        {
            InventoryRecord? record = GetRecord(item, location);
            if (record == null)
            {
                throw new Exception("No inventory record exists");
            }
            else
            {
                record.Quantity -= quantity;
            }
        }

        public void Move(Item item, Location from, Location to, decimal quantity)
        {
            Decrease(item, from, quantity);
            Increase(item, to, quantity);
        }

    }

}
