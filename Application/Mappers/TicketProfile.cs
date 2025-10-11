using Application.Constants;
using Application.Dtos.Ticket.Response;
using AutoMapper;
using Domain.Entities;

namespace Application.Mappers
{
    public class TicketProfile : Profile
    {
        public TicketProfile()
        {
            CreateMap<Ticket, TicketRes>()
                .ForMember(dest => dest.CustomerName,
                    opt => opt.MapFrom(src => $"{src.Requester.FirstName} {src.Requester.LastName}"))
                .ForMember(dest => dest.AssigneeName,
                    opt => opt.MapFrom(src => src.Assignee != null
                        ? $"{src.Assignee.User.FirstName} {src.Assignee.User.LastName}"
                        : null));
        }
    }
}