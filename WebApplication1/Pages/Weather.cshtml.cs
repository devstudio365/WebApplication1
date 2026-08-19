using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Net.Http.Json;

namespace WebApplication1.Pages
{
    public class WeatherModel(IHttpClientFactory httpClientFactory) : PageModel
    {
        public List<WeatherForecast> Forecasts { get; set; } = [];

        public async Task OnGetAsync()
        {
            var client = httpClientFactory.CreateClient("Api");
            var result = await client.GetFromJsonAsync<List<WeatherForecast>>("/WeatherForecast");

            if (result is not null)
            {
                Forecasts = result;
            }
        }
    }
}
