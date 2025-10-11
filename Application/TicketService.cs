using Application.Abstractions;
using Application.Constants;
using Application.Dtos.Common.Request;
using Application.Dtos.Common.Response;
using Application.Dtos.Ticket.Request;
using Application.Dtos.Ticket.Response;
using Application.Repositories;
using AutoMapper;
using Domain.Entities;

namespace Application
{
    public class TicketService : ITicketService
    {
        private readonly ITicketRepository _repo;
        private readonly IMapper _mapper;

        public TicketService(ITicketRepository repo, IMapper mapper)
        {
            _repo = repo;
            _mapper = mapper;
        }

        public async Task<Guid> CreateAsync(Guid customerId, CreateTicketReq req)
        {
            var ticket = new Ticket
            {
                Id = Guid.NewGuid(),
                Title = req.Title,
                Description = req.Description,
                Type = (int)TicketType.CustomerSupport,
                Status = (int)TicketStatus.Pending,
                RequesterId = customerId
            };

            await _repo.AddAsync(ticket);
            return ticket.Id;
        }

        public async Task EscalateToAdminAsync(Guid id)
        {
            var ticket = await _repo.GetByIdAsync(id) ?? throw new KeyNotFoundException("Ticket not found");
            if (ticket.Status == (int)TicketStatus.EscalatedToAdmin) throw new InvalidOperationException("This ticket is already escalated.");

            ticket.Status = (int)TicketStatus.EscalatedToAdmin;
            await _repo.UpdateAsync(ticket);
        }

        public async Task<PageResult<TicketRes>> GetAllAsync(PaginationParams pagination)
        {
            var page = await _repo.GetAllAsync(pagination);
            var data = _mapper.Map<IEnumerable<TicketRes>>(page.Items);

            return new PageResult<TicketRes>(data, page.PageNumber, page.PageSize, page.Total);
        }

        public async Task<PageResult<TicketRes>> GetEscalatedTicketsAsync(PaginationParams pagination)
        {
            var page = await _repo.GetEscalatedAsync(pagination);
            var data = _mapper.Map<IEnumerable<TicketRes>>(page.Items);
            return new PageResult<TicketRes>(data, page.PageNumber, page.PageSize, page.Total);
        }

        public async Task<IEnumerable<TicketRes>> GetByCustomerAsync(Guid customerId)
        {
            var items = await _repo.GetByCustomerAsync(customerId);
            return _mapper.Map<IEnumerable<TicketRes>>(items);
        }

        public async Task UpdateAsync(Guid id, UpdateTicketReq req, Guid staffId)
        {
            var ticket = await _repo.GetByIdAsync(id)
                ?? throw new KeyNotFoundException("Ticket not found");

            if (req.Reply is not null)
                ticket.Reply = req.Reply;

            if (req.Status.HasValue)
                ticket.Status = req.Status.Value;

            ticket.AssigneeId = staffId;
            ticket.UpdatedAt = DateTimeOffset.UtcNow;

            await _repo.UpdateAsync(ticket);
        }
    }
}