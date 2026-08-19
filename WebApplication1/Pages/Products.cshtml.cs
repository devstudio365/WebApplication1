using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Net.Http.Json;

namespace WebApplication1.Pages
{
    public class ProductsModel(IHttpClientFactory httpClientFactory, IConfiguration configuration) : PageModel
    {
        public List<Product> Products { get; set; } = [];

        public async Task OnGetAsync()
        {
            var baseUrl = configuration["ProductsApi:BaseUrl"];
            var client = httpClientFactory.CreateClient();
            var result = await client.GetFromJsonAsync<List<Product>>($"{baseUrl}/Products");

            if (result is not null)
            {
                Products = result;
            }
        }
    }
}
