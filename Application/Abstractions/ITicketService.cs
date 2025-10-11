using Application.Dtos.Common.Request;
using Application.Dtos.Common.Response;
using Application.Dtos.Ticket.Request;
using Application.Dtos.Ticket.Response;

namespace Application.Abstractions
{
    public interface ITicketService
    {
        Task<Guid> CreateAsync(Guid customerId, CreateTicketReq req);

        Task<PageResult<TicketRes>> GetAllAsync(PaginationParams pagination);

        Task<IEnumerable<TicketRes>> GetByCustomerAsync(Guid customerId);

        Task UpdateAsync(Guid id, UpdateTicketReq req, Guid staffId);

        Task EscalateToAdminAsync(Guid id);

        Task<PageResult<TicketRes>> GetEscalatedTicketsAsync(PaginationParams pagination);
    }
}