using Workflow.Inventory.Domain;
using Xunit;

namespace Inventory.UnitTests
{
    public class InventoryMapTests
    {
        [Fact]
        public void Increase_Quantity_Should_Be_Successful()
        {
            // Arrange
            Item item = new Item("I1");
            Location location = new Location("L1");
            decimal quantity = 10;
            InventoryMap inventoryMap = new InventoryMap();

            // Act
            decimal prevQuantity = inventoryMap.GetQuantity(item, location);
            inventoryMap.Increase(item, location, quantity);

            // Assert
            Assert.Equal(prevQuantity + quantity, inventoryMap.GetQuantity(item, location));

        }

        [Fact]
        public void Decrease_Quantity_Should_Be_Successful()
        {

            // Arrange
            Item item = new Item("I1");
            Location location = new Location("L1");
            decimal quantityToIncrease = 10;
            InventoryMap inventoryMap = new InventoryMap();
            inventoryMap.Increase(item, location, quantityToIncrease);


            // Act
            decimal prevQuantity = inventoryMap.GetQuantity(item, location);
            decimal quantityToDecrease = 5;
            inventoryMap.Decrease(item, location, quantityToDecrease);

            // Assert
            Assert.Equal(prevQuantity - quantityToDecrease, inventoryMap.GetQuantity(item, location));
        }

        [Fact]
        public void MoveItem_Should_Be_Successful()
        {
            // Arrange
            Item item = new Item("I1");
            Location location = new Location("L1");
            decimal quantity = 10;
            InventoryMap inventoryMap = new InventoryMap();
            inventoryMap.Increase(item, location, quantity);

            // Act
            Location locationTo = new Location("L2");
            decimal quantityToMove = 5;
            decimal prevFromQuantity = inventoryMap.GetQuantity(item, location);
            decimal prevToQuantity = inventoryMap.GetQuantity(item, locationTo);
            inventoryMap.Move(item, location, locationTo, quantityToMove);

            // Assert
            Assert.Equal(prevFromQuantity - quantityToMove, inventoryMap.GetQuantity(item, location));
            Assert.Equal(prevToQuantity + quantityToMove, inventoryMap.GetQuantity(item, locationTo));
        }
    }
}