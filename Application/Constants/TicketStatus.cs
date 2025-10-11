using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Constants
{
    public enum TicketStatus
    {
        Pending = 0,
        Resolved = 1,
        EscalatedToAdmin = 2
    }
}