using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Net.Http.Json;

namespace WebApplication1.Pages
{
    public class WeatherModel(IHttpClientFactory httpClientFactory, IConfiguration configuration) : PageModel
    {
        public List<WeatherForecast> Forecasts { get; set; } = [];

        public async Task OnGetAsync()
        {
            var baseUrl = configuration["WeatherApi:BaseUrl"];
            var client = httpClientFactory.CreateClient();
            var result = await client.GetFromJsonAsync<List<WeatherForecast>>($"{baseUrl}/WeatherForecast");

            if (result is not null)
            {
                Forecasts = result;
            }
        }
    }
}
