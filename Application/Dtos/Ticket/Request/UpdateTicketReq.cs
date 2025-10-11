using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Dtos.Ticket.Request
{
    public class UpdateTicketReq
    {
        public string? Reply { get; set; }
        public int? Status { get; set; }
    }
}