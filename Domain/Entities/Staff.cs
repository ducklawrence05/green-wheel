using Domain.Commons;
using System;
using System.Collections.Generic;

namespace Domain.Entities;

public partial class Staff : SorfDeletedEntity
{
    public Guid UserId { get; set; }

   

    public Guid StationId { get; set; }

    public virtual ICollection<DispatchRequest> DispatchRequestApprovedAdmins { get; set; } = new List<DispatchRequest>();

    public virtual ICollection<DispatchRequest> DispatchRequestRequestAdmins { get; set; } = new List<DispatchRequest>();

    public virtual ICollection<DispatchRequestStaff> DispatchRequestStaffs { get; set; } = new List<DispatchRequestStaff>();

    public virtual ICollection<RentalContract> RentalContractHandoverStaffs { get; set; } = new List<RentalContract>();

    public virtual ICollection<RentalContract> RentalContractReturnStaffs { get; set; } = new List<RentalContract>();

    public virtual Station Station { get; set; } = null!;

    public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();

    public virtual User User { get; set; } = null!;

    public virtual ICollection<VehicleChecklist> VehicleChecklists { get; set; } = new List<VehicleChecklist>();
}