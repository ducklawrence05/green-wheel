using Application.Dtos.Common.Request;
using Application.Dtos.Common.Response;
using Domain.Entities;

namespace Application.Repositories
{
    public interface ITicketRepository : IGenericRepository<Ticket>
    {
        Task<PageResult<Ticket>> GetAllAsync(PaginationParams pagination);

        Task<IEnumerable<Ticket>> GetByCustomerAsync(Guid customerId);

        Task<PageResult<Ticket>> GetEscalatedAsync(PaginationParams pagination);
    }
}