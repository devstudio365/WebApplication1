using Microsoft.EntityFrameworkCore;
using webapi.Controllers;
using webapi.Data;
using webapi.Models;

namespace webapi.Tests;

public class ProductsControllerTests
{
    private static AppDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new AppDbContext(options);
    }

    [Fact]
    public async Task Get_ReturnsAllProducts()
    {
        using var context = CreateContext();
        context.Products.Add(new Product { ProductID = 1, ProductName = "Test Product" });
        await context.SaveChangesAsync();

        var controller = new ProductsController(context);

        var result = await controller.Get();

        var product = Assert.Single(result.Value!);
        Assert.Equal("Test Product", product.ProductName);
    }

    [Fact]
    public async Task Get_ReturnsEmptyList_WhenNoProductsExist()
    {
        using var context = CreateContext();
        var controller = new ProductsController(context);

        var result = await controller.Get();

        Assert.Empty(result.Value!);
    }
}
