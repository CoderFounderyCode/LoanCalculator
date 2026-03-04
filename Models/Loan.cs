using System.ComponentModel.DataAnnotations;

namespace BlazorLoanCalculator.Models
{
    public class Loan
    {
        [Required]
        [Range(1000, 100000, ErrorMessage = "Please enter a valid purchase amount. £1000-100000")]
        public decimal LoanAmount { get; set; }

        //the term is in full years, but we will convert it to months in the calculation
        [Required]
        [Range(1, 30, ErrorMessage = "Please enter a valid term. 1-30 years")]
        public int Term { get; set; }

        [Required]
        [Range(0.0, 100, MinimumIsExclusive = false, ErrorMessage = "Please enter a valid interest rate. 0-100%")]
        public decimal Rate { get; set; }

        public decimal MonthlyPayment { get; set; }

        public decimal TotalPayment { get; set; }

        public decimal TotalInterest { get; set; }
    }
}
