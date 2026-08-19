using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Net.Http.Json;

namespace WebApplication1.Pages
{
    public class ProductsModel(IHttpClientFactory httpClientFactory) : PageModel
    {
        public List<Product> Products { get; set; } = [];

        public async Task OnGetAsync()
        {
            var client = httpClientFactory.CreateClient("Api");
            var result = await client.GetFromJsonAsync<List<Product>>("/Products");

            if (result is not null)
            {
                Products = result;
            }
        }
    }
}
