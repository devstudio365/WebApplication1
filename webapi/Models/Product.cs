using System.ComponentModel.DataAnnotations.Schema;

namespace webapi.Models
{
    [Table("Product")]
    public class Product
    {
        public int ProductID { get; set; }
        public string ProductName { get; set; } = string.Empty;
    }
}
