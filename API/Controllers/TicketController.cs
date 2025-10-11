using API.Filters;
using Application.Abstractions;
using Application.Dtos.Common.Request;
using Application.Dtos.Ticket.Request;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;

namespace API.Controllers
{
    [ApiController]
    [Route("api/tickets")]
    public class TicketController : ControllerBase
    {
        private readonly ITicketService _service;

        public TicketController(ITicketService service)
        {
            _service = service;
        }

        [HttpPost]
        [RoleAuthorize(["Staff", "Customer"])]
        public async Task<IActionResult> Create([FromBody] CreateTicketReq req)
        {
            var userId = Guid.Parse(User.FindFirst(JwtRegisteredClaimNames.Sid)!.Value);
            var id = await _service.CreateAsync(userId, req);
            return Ok(new { Id = id });
        }

        [HttpGet("me")]
        [RoleAuthorize("Customer")]
        public async Task<IActionResult> GetMyTickets()
        {
            var userId = Guid.Parse(User.FindFirst(JwtRegisteredClaimNames.Sid)!.Value);
            var data = await _service.GetByCustomerAsync(userId);
            return Ok(data);
        }

        [HttpGet]
        [RoleAuthorize(["Staff", "Admin"])]
        public async Task<IActionResult> GetAll([FromQuery] PaginationParams pagination)
        {
            var data = await _service.GetAllAsync(pagination);
            return Ok(data);
        }

        [HttpPatch("{id}")]
        [RoleAuthorize(["Staff", "Admin"])]
        public async Task<IActionResult> Update(Guid id, [FromBody] UpdateTicketReq req)
        {
            var staffId = Guid.Parse(User.FindFirst(JwtRegisteredClaimNames.Sid)!.Value);
            await _service.UpdateAsync(id, req, staffId);
            return NoContent();
        }

        [HttpPatch("{id}/escalated-to-admin")]
        [RoleAuthorize("Staff")]
        public async Task<IActionResult> EscalateToAdmin(Guid id)
        {
            var staffId = Guid.Parse(User.FindFirst(JwtRegisteredClaimNames.Sid)!.Value);
            await _service.EscalateToAdminAsync(id);
            return NoContent();
        }

        [HttpGet("escalated")]
        [RoleAuthorize("Admin")]
        public async Task<IActionResult> GetEscalatedTickets([FromQuery] PaginationParams pagination)
        {
            var data = await _service.GetEscalatedTicketsAsync(pagination);
            return Ok(data);
        }
    }
}